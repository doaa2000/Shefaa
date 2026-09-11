-- =============================================================================
-- Doctor logins: link a Doctors row to an auth account.
--
-- Nothing connected the three apps. The admin panel writes Doctors.email; the
-- doctor dashboard identifies a doctor through Doctors.user_id; the base schema
-- had neither column, so the admin panel's save would fail on an unknown column
-- and no doctor could ever sign in. Without that link the weekly schedule from
-- 0004 has nobody to edit it.
--
-- The link is made by matching a CONFIRMED email, in both directions, so it
-- works whichever happens first: the admin adding the doctor, or the doctor
-- signing up.
--
-- ############ READ THIS ############
-- The security of this rests on email confirmation being ON
-- (Authentication -> Providers -> Email -> Confirm email). With it off,
-- Supabase confirms every signup immediately, and anyone who knows a doctor's
-- email address could sign up with it and take over that doctor's dashboard.
-- Turn it on before any real doctor is added.
-- ###################################
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Columns the other two apps rely on, missing from the reconstructed schema.
-- -----------------------------------------------------------------------------
alter table public."Doctors" add column if not exists email          text;
alter table public."Doctors" add column if not exists user_id        uuid;
alter table public."Doctors" add column if not exists phone          text;
alter table public."Doctors" add column if not exists bio            text;
alter table public."Doctors" add column if not exists license_number text;
alter table public."Doctors" add column if not exists updated_at     timestamptz not null default now();

do $$ begin
  alter table public."Doctors"
    add constraint doctors_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete set null;
exception when duplicate_object then null; end $$;

-- One auth account is one doctor.
create unique index if not exists doctors_user_id_key
  on public."Doctors" (user_id) where user_id is not null;

-- Two doctors cannot claim the same address, or a match would be ambiguous.
create unique index if not exists doctors_email_key
  on public."Doctors" (lower(email)) where email is not null;

-- -----------------------------------------------------------------------------
-- 2. Which doctor is signed in. The dashboard's RLS is built on this.
-- -----------------------------------------------------------------------------
create or replace function public.current_doctor_id()
returns bigint
language sql
stable
security definer
set search_path = public
as $$
  select id from public."Doctors" where user_id = auth.uid() limit 1;
$$;

revoke execute on function public.current_doctor_id() from public;
grant execute on function public.current_doctor_id() to authenticated, service_role;

-- -----------------------------------------------------------------------------
-- 3. The link itself.
--
-- Claims only a doctor row that is still unclaimed, and only from an account
-- whose address is confirmed. Both conditions matter: the first stops a second
-- account stealing a linked doctor, the second is what makes "owns the address"
-- mean anything.
-- -----------------------------------------------------------------------------
create or replace function public.link_doctor_account(p_user_id uuid, p_email text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_doctor_id bigint;
begin
  if p_user_id is null or p_email is null or p_email = '' then
    return null;
  end if;

  update public."Doctors"
     set user_id = p_user_id,
         updated_at = now()
   where lower(email) = lower(p_email)
     and user_id is null
  returning id into v_doctor_id;

  return v_doctor_id;
end;
$$;

-- Direction A: the doctor signs up (or confirms) after the admin added them.
create or replace function public.on_auth_user_confirmed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.email_confirmed_at is not null then
    perform public.link_doctor_account(new.id, new.email);
  end if;
  return new;
end;
$$;

drop trigger if exists on_auth_user_confirmed_link_doctor on auth.users;
create trigger on_auth_user_confirmed_link_doctor
  after insert or update of email_confirmed_at on auth.users
  for each row execute function public.on_auth_user_confirmed();

-- Direction B: the admin adds the doctor after they already have an account.
create or replace function public.on_doctor_email_set()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
begin
  if new.email is null or new.user_id is not null then
    return new;
  end if;

  select u.id into v_user_id
    from auth.users u
   where lower(u.email) = lower(new.email)
     and u.email_confirmed_at is not null
   limit 1;

  if v_user_id is not null
     and not exists (select 1 from public."Doctors" d where d.user_id = v_user_id) then
    new.user_id := v_user_id;
  end if;

  return new;
end;
$$;

drop trigger if exists on_doctor_email_set_link_account on public."Doctors";
create trigger on_doctor_email_set_link_account
  before insert or update of email on public."Doctors"
  for each row execute function public.on_doctor_email_set();

-- -----------------------------------------------------------------------------
-- 4. A linked doctor owns their own schedule.
--
-- 0004 left writing to admins only, because there was no way to be a doctor.
-- There is now, so add the doctor's own access beside it. Policies are OR-ed,
-- so this widens write access to exactly "the admin, or this doctor".
-- -----------------------------------------------------------------------------
do $$
declare tbl text;
begin
  foreach tbl in array array['doctor_schedule', 'doctor_schedule_exceptions']
  loop
    execute format('drop policy if exists sched_doctor_write on public.%I;', tbl);
    execute format(
      'create policy sched_doctor_write on public.%I
         for all to authenticated
         using (doctor_id = public.current_doctor_id())
         with check (doctor_id = public.current_doctor_id());', tbl);
  end loop;
end $$;

-- A doctor may edit their own row, but not create or delete doctors, and not
-- reassign the row to another account.
drop policy if exists doctors_self_update on public."Doctors";
create policy doctors_self_update on public."Doctors"
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
