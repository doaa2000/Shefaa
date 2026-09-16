-- =============================================================================
-- One whole-day closure per date.
--
-- 0004 gave the exceptions table `unique (doctor_id, date, session)`, which
-- does the job for the two named sessions and nothing at all for a closure of
-- the whole day: that row has session null, and in a unique index every null
-- is distinct from every other. A doctor could close the fourteenth five
-- times, and doctor_sessions_on joins on that row -- one per date is what it
-- expects to find.
--
-- Nothing else about the table changes. A doctor already has full write access
-- to their own rows, from 0005, so closing a day needs no new function: it is
-- a row in a table they own, and availability is computed from it.
--
-- Safe to re-run. Duplicate whole-day rows, if any exist, are collapsed to the
-- earliest one first -- otherwise the index cannot be created at all.
-- =============================================================================

delete from public.doctor_schedule_exceptions e
 where e.session is null
   and exists (
     select 1 from public.doctor_schedule_exceptions keep
      where keep.session is null
        and keep.doctor_id = e.doctor_id
        and keep.date      = e.date
        and keep.id        < e.id
   );

create unique index if not exists doctor_exception_one_day_closure
  on public.doctor_schedule_exceptions (doctor_id, date)
  where session is null;
