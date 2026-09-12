-- =============================================================================
-- Which number the doctor is on right now.
--
-- A patient's queue number is a ticket: it is their place in the booking order
-- and it does not change as people are seen. That is the right behaviour -- a
-- clinic calls "number five" and you keep number five -- but it left the app
-- saying something false. The booking card reads
--
--     "دورك رقم 3 · قدامك 2"
--
-- and computes "2 ahead" as `queue_number - 1`, which counts everyone who
-- booked earlier whether or not the doctor has already seen them. Once the
-- dashboard's queue page is in use and the doctor starts marking patients seen,
-- that number is wrong from the first tap.
--
-- What was missing is the other half of a clinic display: not just your ticket,
-- but the number being served. Everything needed is already in the table; the
-- patient simply cannot see it, because row level security hides other people's
-- bookings from them -- which is exactly why it belongs in this view, which
-- ranks over every booking and hands back only what the caller may have.
--
-- now_serving is the lowest queue number in the session that has not been dealt
-- with, and null once everyone has. It is a number, never a name: nothing here
-- tells one patient anything about another.
-- =============================================================================

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
  ),
  -- A second pass: queue_number cannot be read by a window function in the
  -- same select that computes it.
  serving as (
    select
      r.*,
      min(r.queue_number) filter (where r.status not in ('completed', 'no_show'))
        over (partition by r.doctor_id, r.booked_date, r.session) as now_serving
    from ranked r
  )
  select
    s.booking_id,
    s.doctor_id,
    s.patient_id,
    s.booked_date,
    s.session,
    s.status,
    s.queue_number,
    s.now_serving
  from serving s
  where s.patient_id = auth.uid()
     or s.doctor_id  = public.current_doctor_id()
     or public.is_admin();

grant select on public.booking_queue to authenticated, service_role;
revoke select on public.booking_queue from anon;
