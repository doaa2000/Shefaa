-- =============================================================================
-- A booking is a window to arrive in, not a place in a queue.
--
-- The queue number was wrong and could not be made right. It ranked bookings by
-- when they were made, among the patients who used the app -- while the clinic
-- calls people in the order they walk in, and most of them never booked at all.
-- A patient told "you are number 3" arrived to find seven people ahead of them.
--
-- So the app stops promising a position and promises a window instead, which is
-- something it can keep. The doctor chooses which shape their day takes:
--
--   slot_minutes is null  ->  one window, the whole session: "6:00 - 9:00 pm"
--   slot_minutes = 60     ->  hourly windows: "9-10", "10-11", "11-12" ...
--
-- Null is the default, and it is what every existing row gets, so nothing
-- changes for a doctor who does not touch the setting.
--
-- Inside a window the clinic works exactly as it does today, first come first
-- served, and a walk-in costs the app nothing because the app never claimed an
-- order.
--
-- Safe to re-run.
-- =============================================================================

alter table public.doctor_schedule
  add column if not exists slot_minutes integer;

alter table public.doctor_schedule
  drop constraint if exists doctor_schedule_slot_minutes_positive;
alter table public.doctor_schedule
  add constraint doctor_schedule_slot_minutes_positive
  check (slot_minutes is null or slot_minutes > 0);

comment on column public.doctor_schedule.slot_minutes is
  'Length of each bookable window in minutes. Null means the whole session is '
  'one window, which is how a first-come-first-served clinic actually runs.';

-- Deliberately NOT added to doctor_schedule_exceptions. The other overrides
-- there work by coalesce, and null is a meaningful value here -- it is what
-- "one window" means -- so an exception could turn windows on for a day but
-- never off again. A half-working override is worse than none.

-- -----------------------------------------------------------------------------
-- doctor_sessions_on: the same shape as before, one row per bookable window
-- rather than one per session. A session with slot_minutes null yields exactly
-- one row, which is what it yielded before this migration, so every caller
-- keeps working unchanged.
-- -----------------------------------------------------------------------------
create or replace function public.doctor_sessions_on(p_doctor bigint, p_date date)
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
  group by w.session, w.start_time, w.end_time, w.capacity
  order by w.start_time;
$$;

revoke execute on function public.doctor_sessions_on(bigint, date) from public;
grant execute on function public.doctor_sessions_on(bigint, date)
  to authenticated, service_role;

-- -----------------------------------------------------------------------------
-- Capacity belongs to the window now, not to the whole session.
--
-- Without this a six-hour day split into six windows would still be counted as
-- one pot: every patient could pick the 9-10 window and the trigger would wave
-- them through until the session's total was reached -- which is the exact
-- crowd the windows exist to spread out.
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
    raise exception 'This appointment is full: % of % places taken',
      v_booked, v_capacity
      using errcode = 'check_violation', hint = 'session_full';
  end if;

  return new;
end;
$$;

revoke execute on function public.enforce_session_capacity() from public;

-- start_time decides which window a booking is in, so a change to it has to be
-- re-checked against that window's capacity.
drop trigger if exists bookings_enforce_capacity on public.bookings;
create trigger bookings_enforce_capacity
  before insert or update of doctor_id, booked_date, session, start_time, status
  on public.bookings
  for each row execute function public.enforce_session_capacity();

-- -----------------------------------------------------------------------------
-- create_booking stops handing out a number.
--
-- The return type changes, so the old function has to go first rather than be
-- replaced. Everything else about it is unchanged: one transaction, so a
-- payment is never left behind by a booking the capacity trigger refused.
-- -----------------------------------------------------------------------------
drop function if exists
  public.create_booking(bigint, date, text, time, time, numeric, text);

create or replace function public.create_booking(
  p_doctor  bigint,
  p_date    date,
  p_session text,
  p_start   time,
  p_end     time,
  p_amount  numeric,
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
  v_payment bigint;
  v_booking bigint;
begin
  if v_patient is null then
    raise exception 'No authenticated user'
      using errcode = 'insufficient_privilege', hint = 'not_signed_in';
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

  insert into public.payments (patient_id, amount, payment_method, status)
  values (v_patient, p_amount, p_method, 'pending')
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
  public.create_booking(bigint, date, text, time, time, numeric, text) from public;
grant execute on function
  public.create_booking(bigint, date, text, time, time, numeric, text)
  to authenticated, service_role;

-- -----------------------------------------------------------------------------
-- booking_queue goes. It existed to hand a patient a number, and there is no
-- longer a number to hand them: the ranking it computed was over app bookings
-- ordered by when they were made, which is neither everyone in the room nor the
-- order the doctor calls them in.
--
-- Nothing else depends on it. The doctor dashboard reads `bookings` directly
-- and groups them itself.
-- -----------------------------------------------------------------------------
drop view if exists public.booking_queue;
