-- =============================================================================
-- booking_queue was invisible to everyone except a patient or their doctor --
-- including the database owner.
--
-- 0006 narrowed the view to "your own rows" with
--
--     where patient_id = auth.uid()
--        or doctor_id  = current_doctor_id()
--        or is_admin()
--
-- which was right for the two API roles and wrong for everybody else. A view's
-- WHERE clause is not row level security: it applies to every caller, so it
-- also caught the connections that are trusted by definition.
--
--   postgres (the SQL editor)  -> 0 rows, while the table held bookings.
--                                 The owner could not inspect her own queue,
--                                 which is exactly what you reach for when a
--                                 queue number looks wrong.
--   service_role               -> ERROR: permission denied for function
--                                 is_admin. Not even a wrong answer: the view
--                                 cannot be read at all, because is_admin() was
--                                 only ever granted to `authenticated`.
--
-- Neither is a security boundary worth keeping. Both roles can already read
-- public.bookings directly; all the view was doing was making the queue harder
-- to look at than the table it is built from.
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
  -- Named roles rather than `auth.uid() is null`: anon reaches PostgREST with
  -- no sub claim either, and this must not become a way for it to read every
  -- booking if the grant below is ever loosened.
  where current_user not in ('anon', 'authenticated')
     or s.patient_id = auth.uid()
     or s.doctor_id  = public.current_doctor_id()
     or public.is_admin();

grant select on public.booking_queue to authenticated, service_role;
revoke select on public.booking_queue from anon;

-- is_admin() was granted to `authenticated` alone, so anything the service role
-- touched that calls it failed outright. It reports on the caller and tells a
-- caller nothing it does not already know about itself.
grant execute on function public.is_admin() to service_role;
