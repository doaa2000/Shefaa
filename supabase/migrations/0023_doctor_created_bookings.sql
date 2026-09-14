-- =============================================================================
-- A booking the doctor adds by hand gets a fee, like every other booking.
--
-- The dashboard created walk-ins by inserting straight into `bookings`, with no
-- payment row at all. The appointment existed and the money did not: it never
-- reached the payments page, was never owed by anyone, and never showed up in
-- the day's takings. A clinic that sees half its patients without an
-- appointment was reading half its income.
--
-- doctor_create_booking writes the pair in one transaction, the way
-- create_booking does for patients. The differences are deliberate:
--
--   * The amount may be given. A patient must never name their own price, but
--     the doctor setting the fee for a follow-up at their own desk is exactly
--     who should. Left out, it is the doctor's standing consultation fee.
--   * It can be marked collected on the spot, because at a walk-in desk the
--     money usually changes hands there and then.
--   * It may overbook. The capacity check exists to stop strangers filling a
--     window from the app; a doctor adding the person standing in front of them
--     is not that, and refusing would be the database overruling the only one
--     who can see the waiting room.
--
-- Safe to re-run.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- The capacity trigger yields to the doctor.
--
-- Everything else about it is unchanged. The flag is transaction-local and set
-- only inside doctor_create_booking below, so this is not a door a patient can
-- open: nothing outside a function can set it on a PostgREST request.
-- -----------------------------------------------------------------------------
create or replace function public.enforce_session_capacity()
returns trigger
language plpgsql
-- definer for the same reason doctor_sessions_on is: counting how full a window
-- is means counting other patients' bookings, which the caller's own policies
-- hide. A patient must not be able to book past a limit simply because row
-- level security stops them seeing who is already in it.
security definer
set search_path = public
as $$
declare
  v_capacity integer;
  v_booked   integer;
begin
  -- A cancellation frees a place, it never takes one.
  if new.status = 'cancelled' then
    return new;
  end if;

  -- The doctor booking somebody in at their own desk. Both checks below are
  -- about strangers arriving through the app, and neither describes this.
  if coalesce(current_setting('app.doctor_booking', true), 'off') = 'on' then
    return new;
  end if;

  -- Keyed on the window, so two patients booking different hours of the same
  -- long session never wait for each other.
  perform pg_advisory_xact_lock(
    hashtextextended(
      new.doctor_id::text || '|' || new.booked_date::text || '|'
        || new.session || '|' || new.start_time::text,
      0
    )
  );

  select s.capacity into v_capacity
    from public.doctor_sessions_on(new.doctor_id, new.booked_date) s
   where s.session    = new.session
     and s.start_time = new.start_time;

  -- No row means the doctor offers no such window that day: not on the weekly
  -- schedule, closed by an exception, or a start time that begins no window at
  -- all -- a booking assembled by hand rather than taken from what was offered.
  if v_capacity is null then
    -- The message is for the log; `hint` is the part callers match on, so a
    -- patient can be told this in their own language without the database
    -- holding a copy of one app's wording.
    raise exception 'Doctor offers no % appointment at % on %',
      new.session, new.start_time, new.booked_date
      using errcode = 'check_violation', hint = 'session_not_offered';
  end if;

  -- Counted here rather than taken from doctor_sessions_on's `booked`: that
  -- function is STABLE, so it reads the calling statement's snapshot, which was
  -- taken before this transaction waited for the lock. This count runs in a
  -- volatile trigger and sees what the transaction ahead of us committed.
  select count(*) into v_booked
    from public.bookings b
   where b.doctor_id   = new.doctor_id
     and b.booked_date = new.booked_date
     and b.session     = new.session
     and b.start_time  = new.start_time
     and b.status     <> 'cancelled'
     -- On UPDATE the row is already in the table; it must not count itself.
     and b.id is distinct from new.id;

  if v_booked >= v_capacity then
    raise exception 'This appointment is full'
      using errcode = 'check_violation', hint = 'session_full';
  end if;

  return new;
end;
$$;

revoke execute on function public.enforce_session_capacity() from public;

-- -----------------------------------------------------------------------------
-- The booking and its fee, together.
-- -----------------------------------------------------------------------------
create or replace function public.doctor_create_booking(
  p_patient uuid,
  p_date    date,
  p_session text,
  p_start   time,
  p_end     time,
  p_method  text    default 'cash',
  p_amount  numeric default null,
  p_paid    boolean default false,
  p_status  text    default 'confirmed'
)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_doctor  bigint := public.current_doctor_id();
  v_amount  numeric;
  v_payment bigint;
  v_booking bigint;
begin
  if v_doctor is null then
    raise exception 'Not a doctor account'
      using errcode = 'insufficient_privilege', hint = 'not_a_doctor';
  end if;

  if p_status not in ('pending', 'confirmed', 'completed') then
    raise exception 'Unsupported booking status: %', p_status
      using errcode = 'invalid_parameter_value', hint = 'bad_status';
  end if;

  if not exists (select 1 from public.profiles where id = p_patient) then
    raise exception 'Patient not found'
      using errcode = 'no_data_found', hint = 'patient_not_found';
  end if;

  -- Given, or the doctor's own standing fee. Negative is refused rather than
  -- quietly clamped: a fee below zero is a typo, not a discount.
  v_amount := coalesce(
    p_amount,
    (select d.consultation_fee from public."Doctors" d where d.id = v_doctor),
    0
  );

  if v_amount < 0 then
    raise exception 'Fee cannot be negative'
      using errcode = 'invalid_parameter_value', hint = 'bad_amount';
  end if;

  -- The same guard the patient path has, for the same reason: two places in
  -- one session for one person is a mistake every time.
  if exists (
    select 1 from public.bookings b
     where b.patient_id  = p_patient
       and b.doctor_id   = v_doctor
       and b.booked_date = p_date
       and b.session     = p_session
       and b.status     <> 'cancelled'
  ) then
    raise exception 'Patient already holds a place in this session'
      using errcode = 'unique_violation', hint = 'already_booked';
  end if;

  insert into public.payments
    (patient_id, amount, payment_method, status, paid_at, marked_by)
  values (
    p_patient,
    v_amount,
    p_method,
    case when p_paid then 'paid' else 'pending' end,
    case when p_paid then now() end,
    case when p_paid then auth.uid() end
  )
  returning id into v_payment;

  -- Set after the payment and before the booking: it is the booking insert the
  -- trigger fires on, and the flag dies with the transaction either way.
  perform set_config('app.doctor_booking', 'on', true);

  insert into public.bookings
    (patient_id, doctor_id, payment_id, booked_date, session,
     start_time, end_time, status)
  values (p_patient, v_doctor, v_payment, p_date, p_session,
          p_start, p_end, p_status)
  returning id into v_booking;

  return json_build_object(
    'bookingId', v_booking,
    'paymentId', v_payment,
    'amount', v_amount,
    'paid', p_paid
  );
end;
$$;

revoke execute on function
  public.doctor_create_booking(uuid, date, text, time, time, text, numeric, boolean, text)
  from public;
grant execute on function
  public.doctor_create_booking(uuid, date, text, time, time, text, numeric, boolean, text)
  to authenticated, service_role;
