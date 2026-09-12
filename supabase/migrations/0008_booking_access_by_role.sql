-- =============================================================================
-- A doctor could not see a single one of their own bookings.
--
-- bookings_select_own is `patient_id = auth.uid() or is_admin()`. A doctor
-- signed into the dashboard is neither, so every query the dashboard makes came
-- back empty -- measured on a doctor with two bookings: 0 rows. The Appointments
-- page has been blank for every doctor since the policies were written, and
-- nothing that moves the queue along can be built on top of that.
--
-- These policies are OR-ed with the existing ones, so they widen access to
-- exactly "the patient, an admin, or the doctor this booking is with".
-- =============================================================================

-- Answering "is this one of my patients?" means reading bookings that the
-- caller's own policies may hide, so it is asked by a definer function that
-- returns nothing but a boolean about the caller's own practice.
create or replace function public.is_my_patient(p_patient uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
      from public."Doctors" d
      join public.bookings b on b.doctor_id = d.id
     where d.user_id = auth.uid()
       and b.patient_id = p_patient
  );
$$;

revoke execute on function public.is_my_patient(uuid) from public;
grant execute on function public.is_my_patient(uuid) to authenticated, service_role;

-- -----------------------------------------------------------------------------
-- The doctor's own bookings.
--
-- current_doctor_id() is null for a patient, and `doctor_id = null` is never
-- true, so this policy is invisible to everyone who is not a linked doctor.
-- -----------------------------------------------------------------------------
drop policy if exists bookings_select_doctor on public.bookings;
create policy bookings_select_doctor on public.bookings
  for select to authenticated
  using (doctor_id = public.current_doctor_id());

-- Marking a patient seen, or not seen. RLS cannot restrict this to the status
-- column -- that is a column privilege, and `authenticated` needs table-wide
-- UPDATE for the patient's own cancel -- so a doctor can in principle edit
-- other fields of their own bookings. Moving one is still subject to the
-- capacity trigger, and they cannot hand it to another doctor: the check
-- clause pins doctor_id to them.
drop policy if exists bookings_update_doctor on public.bookings;
create policy bookings_update_doctor on public.bookings
  for update to authenticated
  using (doctor_id = public.current_doctor_id())
  with check (doctor_id = public.current_doctor_id());

-- -----------------------------------------------------------------------------
-- The names of the patients who booked them -- and nothing more than that:
-- a profile becomes visible only once that patient has a booking with them.
-- -----------------------------------------------------------------------------
drop policy if exists profiles_select_my_patients on public.profiles;
create policy profiles_select_my_patients on public.profiles
  for select to authenticated
  using (public.is_my_patient(id));

-- =============================================================================
-- What a patient may change about a booking: whether they are coming.
--
-- bookings_update_own lets a patient write any column of their own row, because
-- row level security grants access per row, not per column. So a patient could
-- mark their own booking `completed` -- the status commission is charged on --
-- or set a completed one back to cancelled and erase it. They could also move
-- it to another date while keeping their original created_at, which is the
-- field the queue is ordered by: booked early, jump the queue on a later day.
--
-- The app only ever cancels. This says so.
-- =============================================================================

create or replace function public.guard_booking_changes()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
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

drop trigger if exists bookings_guard_changes on public.bookings;
create trigger bookings_guard_changes
  before update on public.bookings
  for each row execute function public.guard_booking_changes();
