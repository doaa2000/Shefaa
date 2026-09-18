-- =============================================================================
-- An hour that has passed is not an appointment.
--
-- doctor_sessions_on builds a day's windows from the doctor's weekly schedule
-- and never looks at the clock, so at three in the afternoon a patient was
-- still offered this morning's nine o'clock -- and create_booking took it,
-- because it refused a past *date* and never a past *time*. The clinic got a
-- booking for an hour that was over, and the patient got a confirmation and a
-- reminder for it.
--
-- Two changes, kept apart on purpose.
--
-- The listing gains a flag rather than a rule. The same function answers the
-- capacity trigger, and through it the doctor recording a patient who walked
-- in this morning -- a booking for an hour that has passed, which is exactly
-- right and must go on working. So the filter is asked for, by the app that
-- is offering places, and not imposed on everyone who asks what a day holds.
--
-- create_booking refuses outright. That is the patient's door, and a screen
-- left open since this morning must not be able to buy a place in it.
-- doctor_create_booking is untouched: the clinic records what happened,
-- including what happened three hours ago.
--
-- Safe to re-run.
-- =============================================================================

-- A parameter cannot be added in place -- create or replace would leave the
-- two-argument version beside it, and PostgREST would then have two functions
-- of the same name to choose between. Dropping first is safe: the callers are
-- plpgsql bodies, which resolve the name when they run, and every one of them
-- passes two arguments and gets the default.
drop function if exists public.doctor_sessions_on(bigint, date);

create or replace function public.doctor_sessions_on(
  p_doctor   bigint,
  p_date     date,
  -- Off by default, so every existing caller -- the capacity trigger above
  -- all -- keeps getting the day as the schedule describes it.
  p_from_now boolean default false
)
returns table (
  session    text,
  start_time time,
  end_time   time,
  capacity   integer,
  booked     bigint,
  remaining  integer
)
language sql
stable
-- definer, not invoker: counting how full a window is means counting other
-- people's bookings, which the caller's own policies hide from them.
security definer
set search_path = public
as $$
  with base as (
    select s.session, s.start_time, s.end_time, s.capacity, s.slot_minutes
    from public.doctor_schedule s
    where s.doctor_id = p_doctor
      and s.weekday = extract(dow from p_date)::smallint
      and s.is_active
  ),
  applied as (
    select
      b.session,
      coalesce(ex.start_time, b.start_time) as start_time,
      coalesce(ex.end_time,   b.end_time)   as end_time,
      coalesce(ex.capacity,   b.capacity)   as capacity,
      b.slot_minutes,
      -- a whole-day exception wins over a per-session one
      coalesce(day_ex.is_closed, ex.is_closed, false) as closed
    from base b
    left join public.doctor_schedule_exceptions ex
      on ex.doctor_id = p_doctor and ex.date = p_date and ex.session = b.session
    left join public.doctor_schedule_exceptions day_ex
      on day_ex.doctor_id = p_doctor and day_ex.date = p_date and day_ex.session is null
  ),
  counted as (
    select
      a.*,
      (a.end_time - a.start_time) as span,
      case
        when a.slot_minutes is null then 1
        else greatest(
          ceil(
            extract(epoch from (a.end_time - a.start_time))
              / (a.slot_minutes * 60.0)
          )::integer,
          1
        )
      end as window_count
    from applied a
    where not a.closed
  ),
  windows as (
    select
      c.session,
      (c.start_time + (c.span * g.i / c.window_count))::time as start_time,
      -- least() in interval space rather than on the times themselves: a window
      -- that overshoots must stop at the end of the session, and `time` wraps
      -- past midnight instead of clamping.
      (c.start_time + least(c.span * (g.i + 1) / c.window_count, c.span))::time
        as end_time,
      -- Integer division on the running total, not capacity/windows: the parts
      -- then add up to the capacity exactly instead of losing or inventing a
      -- place to rounding. 10 places over 3 windows gives 3, 3, 4.
      (c.capacity * (g.i + 1) / c.window_count)
        - (c.capacity * g.i / c.window_count) as capacity
    from counted c
    cross join lateral generate_series(0, c.window_count - 1) as g(i)
  )
  select
    w.session,
    w.start_time,
    w.end_time,
    w.capacity,
    count(bk.id) as booked,
    greatest(w.capacity - count(bk.id), 0)::integer as remaining
  from windows w
  left join public.bookings bk
    on  bk.doctor_id   = p_doctor
    and bk.booked_date = p_date
    and bk.session     = w.session
    -- The window, not the session. For a session that is one window the two are
    -- the same time, so bookings made before this migration still match.
    and bk.start_time  = w.start_time
    and bk.status <> 'cancelled'
  -- A capacity too small to spread leaves empty windows; they are not bookable
  -- and showing them would be offering a place that does not exist.
  where w.capacity > 0
    -- And, when asked, nothing whose hour has already come. Only today can
    -- have any: a future date has none and a past one is entirely behind us,
    -- which the caller refuses before it gets here.
    and (
      not coalesce(p_from_now, false)
      or p_date <> (now() at time zone 'Africa/Cairo')::date
      or w.start_time > (now() at time zone 'Africa/Cairo')::time
    )
  group by w.session, w.start_time, w.end_time, w.capacity
  order by w.start_time;
$$;

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

  -- The hour, not only the day. A date check alone lets a patient book this
  -- morning's nine o'clock at three in the afternoon: the date is today, so
  -- nothing above objects, and the clinic gets a booking for an hour that is
  -- over. Compared as a moment rather than as a time of day, so it is the
  -- clinic's clock deciding and not the phone's.
  if public.appointment_starts_at(p_date, p_start) <= now() then
    raise exception 'That appointment time has passed'
      using errcode = 'check_violation', hint = 'time_has_passed';
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

revoke all on function public.doctor_sessions_on(bigint, date, boolean) from public;
grant execute on function public.doctor_sessions_on(bigint, date, boolean)
  to authenticated, service_role;

revoke execute on function
  public.create_booking(bigint, date, text, time, time, text) from public;
grant execute on function
  public.create_booking(bigint, date, text, time, time, text) to authenticated;
