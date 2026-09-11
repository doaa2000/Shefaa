-- =============================================================================
-- Queue numbers and remaining places were computed under the caller's own RLS.
--
-- doctor_sessions_on was declared `security invoker`, so its
--
--     count(bk.id) ... from public.bookings bk
--
-- ran under the caller's policies -- and bookings_select_own limits a patient to
-- `patient_id = auth.uid()`. The count it needs is precisely the one RLS hides.
--
-- Measured on a session that really held 2 bookings:
--
--     patient who already booked   -> booked = 1, remaining = 9
--     patient about to book        -> booked = 0, remaining = 10
--
-- So every patient was told "دورك رقم ١" however full the session was, and
-- `remaining` never reached zero, so a full session never showed as full.
--
-- The fix is `security definer`. It is the right tool here and not a hole: the
-- function returns aggregates only -- session, times, capacity, a count -- and
-- never a row that identifies a patient. search_path is pinned, as it must be.
--
-- NOTE this does not stop two patients racing for the last place; the capacity
-- check is still advisory, enforced by the UI. A database-level guard is a
-- separate change.
-- =============================================================================

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
-- definer, not invoker: counting how full a session is means counting other
-- people's bookings, which the caller's own policies hide from them.
security definer
set search_path = public
as $$
  with base as (
    select s.session, s.start_time, s.end_time, s.capacity
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
      -- a whole-day exception wins over a per-session one
      coalesce(day_ex.is_closed, ex.is_closed, false) as closed
    from base b
    left join public.doctor_schedule_exceptions ex
      on ex.doctor_id = p_doctor and ex.date = p_date and ex.session = b.session
    left join public.doctor_schedule_exceptions day_ex
      on day_ex.doctor_id = p_doctor and day_ex.date = p_date and day_ex.session is null
  )
  select
    a.session, a.start_time, a.end_time, a.capacity,
    count(bk.id) as booked,
    greatest(a.capacity - count(bk.id), 0)::integer as remaining
  from applied a
  left join public.bookings bk
    on  bk.doctor_id   = p_doctor
    and bk.booked_date = p_date
    and bk.session     = a.session
    and bk.status <> 'cancelled'
  where not a.closed
  group by a.session, a.start_time, a.end_time, a.capacity
  order by a.start_time;
$$;

revoke execute on function public.doctor_sessions_on(bigint, date) from public;
grant execute on function public.doctor_sessions_on(bigint, date)
  to anon, authenticated, service_role;

-- -----------------------------------------------------------------------------
-- booking_queue: right numbers, but it was handing them out for every booking.
--
-- The view is `security_invoker = false` (the default), so it runs as its owner
-- and computes row_number() over every booking -- which is what makes the queue
-- number correct. The same thing meant any signed-in patient could read the
-- whole view: every booking's patient_id, doctor, date and session.
--
-- Rank over everyone, then hand back only the rows the caller is entitled to.
-- The ranking still counts the bookings it no longer shows.
-- -----------------------------------------------------------------------------
create or replace view public.booking_queue as
  with ranked as (
    select
      b.id as booking_id,
      b.doctor_id,
      b.patient_id,
      b.booked_date,
      b.session,
      b.status,
      row_number() over (
        partition by b.doctor_id, b.booked_date, b.session
        order by b.created_at, b.id
      )::integer as queue_number
    from public.bookings b
    where b.status <> 'cancelled'
  )
  select
    r.booking_id,
    r.doctor_id,
    r.patient_id,
    r.booked_date,
    r.session,
    r.status,
    r.queue_number
  from ranked r
  where r.patient_id = auth.uid()
     or r.doctor_id  = public.current_doctor_id()
     or public.is_admin();

grant select on public.booking_queue to authenticated, service_role;

-- anon has no bookings and no doctor, so every row was already filtered out for
-- it. Dropping the grant says so rather than leaving it to the filter.
revoke select on public.booking_queue from anon;
