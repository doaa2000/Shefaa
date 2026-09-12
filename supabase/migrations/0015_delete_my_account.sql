-- =============================================================================
-- A patient can delete their account from inside the app.
--
-- Apple and Google both require it of any app that creates accounts, and refuse
-- the app outright without it. It is also the right behaviour on its own terms.
--
-- What goes and what stays:
--
--   * The auth user goes. They cannot sign in again and the email is free to
--     register with afresh.
--   * The profile goes with it -- name, phone, gender, birth date -- by the
--     cascade that already exists on profiles.id.
--   * The bookings STAY, with nobody attached to them. A visit that happened is
--     the doctor's record as much as the patient's: it is what the clinic's
--     revenue and its medical history are made of. What the doctor keeps is the
--     date, the session and the outcome; who it was is gone.
--
-- Making the bookings stay is the whole of the schema change here: they are
-- currently deleted along with the patient.
--
-- Safe to re-run.
-- =============================================================================

-- A booking with no patient is the record of a deleted one, so the column has
-- to accept it.
alter table public.bookings alter column patient_id drop not null;

do $$
declare
  v_constraint text;
begin
  -- By whatever name the constraint was given, since the base schema wrote it
  -- inline and let PostgreSQL name it.
  select conname into v_constraint
    from pg_constraint
   where conrelid = 'public.bookings'::regclass
     and contype = 'f'
     and conkey = array[
       (select attnum from pg_attribute
         where attrelid = 'public.bookings'::regclass and attname = 'patient_id')
     ];

  if v_constraint is not null then
    execute format('alter table public.bookings drop constraint %I', v_constraint);
  end if;
end $$;

alter table public.bookings
  add constraint bookings_patient_id_fkey
  foreign key (patient_id) references public.profiles (id) on delete set null;

-- -----------------------------------------------------------------------------
-- The booking guard has to let the cascade through.
--
-- guard_booking_changes refuses any update that moves a booking to another
-- patient -- which is exactly what `on delete set null` does on the way out.
-- The caller is the patient themselves, so none of the existing exemptions
-- apply and the delete would fail on its own safety rule.
--
-- A transaction-local flag rather than a hole in the rule: it is set by
-- delete_my_account and by nothing else, and it is gone at commit. A patient
-- calling `update bookings set patient_id = null` by hand is still refused.
-- -----------------------------------------------------------------------------
create or replace function public.guard_booking_changes()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Deleting an account detaches its bookings on the way out. Only
  -- delete_my_account sets this, and only for its own transaction.
  if coalesce(current_setting('app.deleting_account', true), '') = 'on' then
    return new;
  end if;

  -- No JWT at all means this is not an app user: the service role, a migration,
  -- or the SQL editor. Those already have full access to the table; the rules
  -- below are about what someone signed into the apps may do. Without this the
  -- trigger locks the owner out of her own database.
  if auth.uid() is null then
    return new;
  end if;

  -- The doctor this booking is with, and an admin, decide everything about it.
  if public.is_admin() or old.doctor_id = public.current_doctor_id() then
    return new;
  end if;

  -- Nobody else may move a booking: not to another doctor, another day,
  -- another session, or another patient.
  if new.doctor_id   is distinct from old.doctor_id
     or new.patient_id  is distinct from old.patient_id
     or new.booked_date is distinct from old.booked_date
     or new.session     is distinct from old.session then
    raise exception 'A booking cannot be moved; cancel and book again'
      using errcode = 'check_violation', hint = 'booking_immutable';
  end if;

  -- And the only status a patient may set is cancelled. Whether they actually
  -- turned up is the doctor's to record.
  if new.status is distinct from old.status and new.status <> 'cancelled' then
    raise exception 'A patient may only cancel'
      using errcode = 'check_violation', hint = 'cancel_only';
  end if;

  return new;
end;
$$;

revoke execute on function public.guard_booking_changes() from public;

-- -----------------------------------------------------------------------------
-- The function the app calls.
--
-- security definer because deleting from auth.users is not something a patient
-- may do directly, and must not become something they can do to anyone else:
-- the only row it ever touches is auth.uid()'s own, named nowhere else.
-- -----------------------------------------------------------------------------
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'No authenticated user'
      using errcode = 'insufficient_privilege', hint = 'not_signed_in';
  end if;

  -- true: transaction-local, so it is gone whether this commits or rolls back.
  perform set_config('app.deleting_account', 'on', true);

  -- Everything else follows from the foreign keys already in place:
  --   profiles.id        -> on delete cascade   (the personal details go)
  --   bookings.patient_id -> on delete set null (the visits stay, anonymous)
  --   payments.patient_id -> on delete set null (the money stays, anonymous)
  --   Doctors.user_id     -> on delete set null (a doctor who deletes their
  --                          patient account is unlinked from the dashboard,
  --                          not erased from the clinic; an admin can link
  --                          them again)
  delete from auth.users where id = v_user;
end;
$$;

revoke execute on function public.delete_my_account() from public;
grant execute on function public.delete_my_account() to authenticated;
