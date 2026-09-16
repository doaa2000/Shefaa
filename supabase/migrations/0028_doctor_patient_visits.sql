-- =============================================================================
-- A patient's history with the doctor looking at it.
--
-- The dashboard's patient page shows a phone number and a date of birth. A
-- doctor opens a patient to see when they came, how often, and what happened
-- -- not to look up their number.
--
-- Scoped to the doctor asking, and only to them. A doctor may see the visits
-- that happened in their own clinic; what the same patient did at another
-- clinic is none of their business, and the join below is what says so rather
-- than a filter the dashboard could forget to send.
--
-- A definer function rather than a query from the page, because the fee lives
-- on payments, which a doctor cannot read: the policy there is the patient who
-- owns it, or an administrator. The same reason doctor_payments exists.
--
-- Safe to re-run.
-- =============================================================================

create or replace function public.doctor_patient_visits(p_patient uuid)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_doctor bigint := public.current_doctor_id();
  v_result json;
begin
  if v_doctor is null then
    raise exception 'Not a doctor account'
      using errcode = 'insufficient_privilege', hint = 'not_a_doctor';
  end if;

  -- Not "patient not found": whether a uuid belongs to a real patient is not
  -- something an account with no bookings for them is entitled to learn.
  if not exists (
    select 1 from public.bookings
     where doctor_id = v_doctor and patient_id = p_patient
  ) then
    return json_build_object(
      'summary', json_build_object(
        'visits', 0, 'attended', 0, 'noShow', 0, 'cancelled', 0,
        'fees', 0, 'firstVisit', null, 'lastVisit', null
      ),
      'items', '[]'::json
    );
  end if;

  with rows as (
    select
      b.id,
      b.booked_date,
      b.session,
      b.start_time,
      b.end_time,
      b.status,
      b.created_at,
      p.amount,
      p.payment_method,
      p.status as payment_status
    from public.bookings b
    left join public.payments p on p.id = b.payment_id
    where b.doctor_id  = v_doctor
      and b.patient_id = p_patient
  )
  select json_build_object(
    'summary', json_build_object(
      -- A cancelled booking is not a visit. Counting it as one would tell the
      -- doctor they have seen somebody they have never met.
      'visits',     (select count(*) from rows where status <> 'cancelled'),
      'attended',   (select count(*) from rows where status = 'completed'),
      'noShow',     (select count(*) from rows where status = 'no_show'),
      'cancelled',  (select count(*) from rows where status = 'cancelled'),
      'fees',       coalesce((select sum(amount) from rows
                               where status <> 'cancelled'), 0),
      'firstVisit', (select min(booked_date) from rows where status <> 'cancelled'),
      'lastVisit',  (select max(booked_date) from rows where status <> 'cancelled')
    ),
    'items', coalesce((
      select json_agg(i order by i."bookedDate" desc, i."startTime" desc)
      from (
        select
          id,
          booked_date    as "bookedDate",
          session,
          start_time     as "startTime",
          end_time       as "endTime",
          status,
          created_at     as "createdAt",
          amount,
          payment_method as "paymentMethod",
          payment_status as "paymentStatus"
        from rows
      ) i
    ), '[]'::json)
  )
  into v_result;

  return v_result;
end;
$$;

revoke execute on function public.doctor_patient_visits(uuid) from public;
grant execute on function public.doctor_patient_visits(uuid)
  to authenticated, service_role;
