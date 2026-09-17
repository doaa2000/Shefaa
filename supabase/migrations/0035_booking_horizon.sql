-- =============================================================================
-- How far ahead a patient may book.
--
-- Until now: thirty days in the app, and nothing at all in the database. The
-- thirty was a constant on the screen that draws the date strip, so a request
-- sent by hand could book a date a year out -- and hold that place in that
-- session for a year, against a doctor whose schedule will have changed many
-- times over.
--
-- Even inside the app, thirty days is too long. A place held for a month is a
-- month in which nobody else could take it, and the patient holding it is the
-- one least likely to still want it.
--
-- A week, and checked where it cannot be argued with. The app's date strip
-- reads the same setting, so the screen and the rule can never drift apart --
-- and the number changes with an update, not a release.
--
-- The past is refused here too, which nothing refused before: a booking dated
-- yesterday was accepted, and then sat in the doctor's list forever, never
-- arriving and never expiring.
--
-- Safe to re-run.
-- =============================================================================

alter table public.platform_settings
  add column if not exists booking_horizon interval not null default '7 days';

comment on column public.platform_settings.booking_horizon is
  'How far ahead of today a patient may book. Enforced by create_booking and read by the app to draw its date strip.';

-- -----------------------------------------------------------------------------
-- The app needs the same number to decide which dates to offer. Returned in
-- days because a date strip counts days, and derived from the interval so
-- there is still only one place the policy is written down.
-- -----------------------------------------------------------------------------
create or replace function public.booking_horizon_days()
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select greatest(1, ceil(extract(epoch from booking_horizon) / 86400)::integer)
  from public.platform_settings
  where id = 1;
$$;

revoke execute on function public.booking_horizon_days() from public;
grant execute on function public.booking_horizon_days() to anon, authenticated;

-- -----------------------------------------------------------------------------
-- create_booking, re-emitted with the window enforced.
--
-- Whole rather than patched: a function that books appointments and takes
-- money should exist in one readable piece, not as a base version plus three
-- migrations of amendments.
-- -----------------------------------------------------------------------------
create or replace function public.create_booking(
  p_doctor  bigint,
  p_date    date,
  p_session text,
  p_start   time,
  p_end     time,
  p_method  text
)
returns table (booking_id bigint)
language plpgsql
-- definer so the capacity check behind it can count every booking in the
-- window, not just the caller's. Everything it writes is pinned to auth.uid(),
-- so it can only ever create a booking for whoever is calling it.
security definer
set search_path = public
as $$
declare
  v_patient uuid := auth.uid();
  v_amount  numeric;
  v_rate    numeric;
  v_horizon interval;
  v_today   date;
  v_payment bigint;
  v_booking bigint;
begin
  if v_patient is null then
    raise exception 'No authenticated user'
      using errcode = 'insufficient_privilege', hint = 'not_signed_in';
  end if;

  select d.consultation_fee into v_amount
    from public."Doctors" d
   where d.id = p_doctor;

  if not found then
    raise exception 'Doctor not found'
      using errcode = 'no_data_found', hint = 'doctor_not_found';
  end if;

  -- Read now and written onto the row: this booking is charged at today's
  -- rate for the rest of its life, whatever the rate becomes.
  select commission_rate, booking_horizon into v_rate, v_horizon
    from public.platform_settings where id = 1;

  -- The clinic's today, not the server's. After 10pm in Cairo a server in UTC
  -- has already moved on, and would start refusing tomorrow morning's
  -- appointments as though they were in the past.
  v_today := (now() at time zone 'Africa/Cairo')::date;

  if p_date < v_today then
    raise exception 'That date has passed'
      using errcode = 'check_violation', hint = 'date_in_past';
  end if;

  if p_date > v_today + v_horizon then
    raise exception 'That date is too far ahead'
      using errcode = 'check_violation', hint = 'beyond_horizon';
  end if;

  -- Said plainly here rather than let bookings_one_place_per_session surface as
  -- a duplicate key error the patient cannot read. Still one place per session
  -- rather than per window: booking two hours of the same evening is a mistake,
  -- not a use case.
  if exists (
    select 1 from public.bookings b
     where b.patient_id  = v_patient
       and b.doctor_id   = p_doctor
       and b.booked_date = p_date
       and b.session     = p_session
       and b.status     <> 'cancelled'
  ) then
    raise exception 'Patient already holds a place in this session'
      using errcode = 'unique_violation', hint = 'already_booked';
  end if;

  insert into public.payments
    (patient_id, amount, payment_method, status, commission_rate)
  values (v_patient, coalesce(v_amount, 0), p_method, 'pending', v_rate)
  returning id into v_payment;

  insert into public.bookings
    (patient_id, doctor_id, payment_id, booked_date, session,
     start_time, end_time, status)
  values (v_patient, p_doctor, v_payment, p_date, p_session,
          p_start, p_end, 'confirmed')
  returning id into v_booking;

  return query select v_booking;
end;
$$;

revoke execute on function
  public.create_booking(bigint, date, text, time, time, text) from public;
grant execute on function
  public.create_booking(bigint, date, text, time, time, text) to authenticated;
