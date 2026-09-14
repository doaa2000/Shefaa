-- =============================================================================
-- The dashboard does not create bookings. Undoing 0023.
--
-- 0023 gave the doctor dashboard a way to add a booking with its fee, for the
-- walk-in who never used the app. The product decision went the other way:
-- patients book in their own app and nowhere else, and the dashboard shows and
-- manages what is already there.
--
-- So the route is removed rather than left callable. A function that creates
-- bookings, can price them itself and is allowed past the capacity check is
-- not something to leave lying in the schema because it might be wanted later;
-- if it is wanted later it comes back in a migration, which is a smaller cost
-- than an unused door.
--
-- The capacity trigger goes back to what it was before 0023, with no override
-- in it, because nothing sets that flag any more and a branch nobody can reach
-- is a branch nobody checks.
--
-- Known consequence, accepted deliberately: the payments page counts the
-- bookings made in the app, and a patient the clinic sees without one is not
-- in it.
--
-- Safe to re-run.
-- =============================================================================

drop function if exists public.doctor_create_booking(
  uuid, date, text, time, time, text, numeric, boolean, text
);

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
    raise exception 'This appointment is full'
      using errcode = 'check_violation', hint = 'session_full';
  end if;

  return new;
end;
$$;

revoke execute on function public.enforce_session_capacity() from public;
