-- =============================================================================
-- The three things the doctor dashboard asks for and nothing answered.
--
-- Its home page, its patient list and its report page each call a function that
-- was never written, so all three failed outright -- the home page included,
-- which is the first thing a doctor sees after signing in.
--
-- None of them needs new data. Everything here is counted from bookings,
-- profiles and payments, which have been there all along.
--
-- All three are SECURITY DEFINER and all three scope themselves to
-- current_doctor_id(). That pairing is the point: definer, because counting a
-- clinic's takings means reading payment rows the doctor's own policies do not
-- show them; scoped, because the caller must never be able to ask about
-- somebody else's practice. Neither takes a doctor as an argument, so there is
-- no doctor to ask about but your own.
--
-- Safe to re-run.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- The home page's tiles.
--
-- Returns json rather than a table: PostgREST hands a set-returning function
-- back as an array, and the dashboard reads the result as a single object. One
-- row wrapped in a list would have read as undefined in every tile.
-- -----------------------------------------------------------------------------
create or replace function public.dashboard_summary()
returns json
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_doctor bigint := public.current_doctor_id();
  v_today  date := current_date;
begin
  -- An account with no doctor behind it gets zeros, not an error: the dashboard
  -- already explains that case on every page, and a failing home screen on top
  -- of it says nothing new.
  if v_doctor is null then
    return json_build_object(
      'total_patients', 0,
      'appointments_today', 0,
      'appointments_upcoming', 0,
      'consultations_this_month', 0,
      'active_prescriptions', 0,
      'unread_notifications', 0,
      'revenue_this_month', 0
    );
  end if;

  return json_build_object(
    -- People, not visits: somebody who came four times is one patient.
    'total_patients', (
      select count(distinct b.patient_id)
        from public.bookings b
       where b.doctor_id = v_doctor
         and b.patient_id is not null
         and b.status <> 'cancelled'
    ),
    'appointments_today', (
      select count(*)
        from public.bookings b
       where b.doctor_id = v_doctor
         and b.booked_date = v_today
         and b.status <> 'cancelled'
    ),
    'appointments_upcoming', (
      select count(*)
        from public.bookings b
       where b.doctor_id = v_doctor
         and b.booked_date > v_today
         and b.status <> 'cancelled'
    ),
    -- Consultations and prescriptions are not built. Zero is the truthful
    -- answer to "how many", and the dashboard no longer shows these two tiles;
    -- they stay in the shape so the contract does not change when they are.
    'consultations_this_month', 0,
    'active_prescriptions', 0,
    'unread_notifications', 0,
    -- Money that actually arrived. A booking made this month and not yet paid
    -- for is not revenue, and counting it would overstate every month.
    'revenue_this_month', coalesce((
      select sum(p.amount)
        from public.bookings b
        join public.payments p on p.id = b.payment_id
       where b.doctor_id = v_doctor
         and b.status <> 'cancelled'
         and p.status = 'paid'
         and b.booked_date >= date_trunc('month', v_today)::date
         and b.booked_date <  (date_trunc('month', v_today) + interval '1 month')::date
    ), 0)
  );
end;
$$;

revoke execute on function public.dashboard_summary() from public;
grant execute on function public.dashboard_summary() to authenticated;

-- -----------------------------------------------------------------------------
-- The doctor's own patients: everyone who has ever booked with them.
--
-- Returns the columns of `profiles` under their own names, because the
-- dashboard maps the rows with the same mapper it uses for a single profile.
-- -----------------------------------------------------------------------------
create or replace function public.doctor_patients(search text default '')
returns table (
  id         uuid,
  name       text,
  phone      text,
  gender     text,
  birth_date date,
  status     text,
  created_at timestamptz,
  image      text
)
language sql
stable
-- definer: a doctor may read the profiles of their own patients through
-- profiles_select_my_patients, but that policy is written for a lookup by id.
-- Listing them is the same question asked the other way round, and the scope
-- below is the same scope.
security definer
set search_path = public
as $$
  select p.id, p.name, p.phone, p.gender, p.birth_date, p.status, p.created_at,
         p.image
    from public.profiles p
   where exists (
     select 1
       from public.bookings b
      where b.patient_id = p.id
        and b.doctor_id  = public.current_doctor_id()
        and b.status <> 'cancelled'
   )
     -- An empty search is no search. Anything else matches name or phone,
     -- with % and _ stripped so a patient typing one cannot turn the filter
     -- into "everybody".
     and (
       coalesce(nullif(btrim(search), ''), '') = ''
       or p.name  ilike '%' || replace(replace(btrim(search), '%', ''), '_', '') || '%'
       or p.phone ilike '%' || replace(replace(btrim(search), '%', ''), '_', '') || '%'
     )
   order by p.name;
$$;

revoke execute on function public.doctor_patients(text) from public;
grant execute on function public.doctor_patients(text) to authenticated;

-- -----------------------------------------------------------------------------
-- Bookings per day, for the report page's chart.
--
-- Every day in the window appears, including the empty ones: a chart that skips
-- them draws a quiet Friday as if it never happened and slopes straight from
-- Thursday to Saturday.
-- -----------------------------------------------------------------------------
create or replace function public.bookings_trend(days integer default 30)
returns table (day date, total bigint)
language sql
stable
security definer
set search_path = public
as $$
  with span as (
    select generate_series(
      current_date - (greatest(least(days, 365), 1) - 1),
      current_date,
      interval '1 day'
    )::date as day
  )
  select s.day,
         count(b.id) as total
    from span s
    left join public.bookings b
      on  b.booked_date = s.day
      and b.doctor_id   = public.current_doctor_id()
      and b.status <> 'cancelled'
   group by s.day
   order by s.day;
$$;

revoke execute on function public.bookings_trend(integer) from public;
grant execute on function public.bookings_trend(integer) to authenticated;
