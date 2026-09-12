-- =============================================================================
-- Capacity was advisory. The database now enforces it.
--
-- 0006 made `remaining` truthful, so the app hides a full session. That is a
-- screen, not a rule: two patients tapping "book" at the same moment both read
-- the last free place and both take it, because under READ COMMITTED neither
-- transaction can see the other's uncommitted row. Nothing in the database said
-- no.
--
-- The guard is a trigger that takes a transaction advisory lock on the session
-- before counting, so bookings for the same doctor, day and session are handled
-- one at a time. The lock is keyed on the session and released at commit: a
-- different session, day or doctor never waits.
--
-- Capacity comes from doctor_sessions_on so there is one definition of what a
-- session holds -- the weekly schedule with that day's exceptions applied --
-- rather than a second copy here that could drift from it.
-- =============================================================================

create or replace function public.enforce_session_capacity()
returns trigger
language plpgsql
-- definer for the same reason doctor_sessions_on is: counting how full a
-- session is means counting other patients' bookings, which the caller's own
-- policies hide. A patient must not be able to book past a limit simply
-- because row level security stops them seeing who is already in it.
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

  perform pg_advisory_xact_lock(
    hashtextextended(
      new.doctor_id::text || '|' || new.booked_date::text || '|' || new.session,
      0
    )
  );

  select s.capacity into v_capacity
    from public.doctor_sessions_on(new.doctor_id, new.booked_date) s
   where s.session = new.session;

  -- No row means the doctor does not hold that session on that date at all --
  -- not on the weekly schedule, or closed by an exception.
  if v_capacity is null then
    -- The message is for the log; `hint` is the part callers match on, so a
    -- patient can be told this in their own language without the database
    -- holding a copy of one app's wording.
    raise exception 'Doctor holds no % session on %', new.session, new.booked_date
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
     and b.status     <> 'cancelled'
     -- On UPDATE the row is already in the table; it must not count itself.
     and b.id is distinct from new.id;

  if v_booked >= v_capacity then
    raise exception 'Session is full: % of % places taken', v_booked, v_capacity
      using errcode = 'check_violation', hint = 'session_full';
  end if;

  return new;
end;
$$;

revoke execute on function public.enforce_session_capacity() from public;

drop trigger if exists bookings_enforce_capacity on public.bookings;
create trigger bookings_enforce_capacity
  before insert or update of doctor_id, booked_date, session, status
  on public.bookings
  for each row execute function public.enforce_session_capacity();

-- -----------------------------------------------------------------------------
-- Tidying up after 0006: doctor_sessions_on became security definer there, and
-- it is still granted to anon. Nothing signed out can reach this app -- every
-- read policy is `to authenticated` -- so anon holding a function that now
-- bypasses row level security is an inconsistency, not a feature.
-- -----------------------------------------------------------------------------
revoke execute on function public.doctor_sessions_on(bigint, date) from anon;

-- =============================================================================
-- Booking became something that can be refused, so it has to be one step.
--
-- The app made two calls: insert a payment, then insert a booking. Two calls
-- are two transactions. Before this migration the second one practically never
-- failed; now "this session is full" is an ordinary outcome, and the payment
-- row from the first call would be left behind with nothing pointing at it --
-- money recorded for a visit that was refused. A patient cannot delete it
-- either (payments_delete_admin), so it would simply accumulate.
--
-- One function, one transaction: if the capacity trigger refuses the booking,
-- the payment goes with it.
-- =============================================================================

create or replace function public.create_booking(
  p_doctor  bigint,
  p_date    date,
  p_session text,
  p_start   time,
  p_end     time,
  p_amount  numeric,
  p_method  text
)
returns table (booking_id bigint, queue_number integer)
language plpgsql
-- definer so the queue number below counts every booking in the session, not
-- just the caller's. Everything it writes is pinned to auth.uid(), so it can
-- only ever create a booking for whoever is calling it.
security definer
set search_path = public
as $$
declare
  v_patient uuid := auth.uid();
  v_payment bigint;
  v_booking bigint;
  v_created timestamptz;
  v_queue   integer;
begin
  if v_patient is null then
    raise exception 'No authenticated user'
      using errcode = 'insufficient_privilege', hint = 'not_signed_in';
  end if;

  -- Said plainly here rather than let bookings_one_place_per_session surface as
  -- a duplicate key error the patient cannot read.
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

  insert into public.payments (patient_id, amount, payment_method, status)
  values (v_patient, p_amount, p_method, 'pending')
  returning id into v_payment;

  insert into public.bookings
    (patient_id, doctor_id, payment_id, booked_date, session,
     start_time, end_time, status)
  values (v_patient, p_doctor, v_payment, p_date, p_session,
          p_start, p_end, 'confirmed')
  returning id, created_at into v_booking, v_created;

  -- Same ordering as the booking_queue view, so the number the patient is told
  -- now is the number they will keep seeing.
  select count(*)::integer into v_queue
    from public.bookings b
   where b.doctor_id   = p_doctor
     and b.booked_date = p_date
     and b.session     = p_session
     and b.status     <> 'cancelled'
     and (b.created_at, b.id) <= (v_created, v_booking);

  return query select v_booking, v_queue;
end;
$$;

revoke execute on function
  public.create_booking(bigint, date, text, time, time, numeric, text) from public;
grant execute on function
  public.create_booking(bigint, date, text, time, time, numeric, text)
  to authenticated, service_role;
