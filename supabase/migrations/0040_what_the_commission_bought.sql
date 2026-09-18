-- =============================================================================
-- What the commission bought.
--
-- The payments page states the platform's share as a deduction: a figure in
-- red beside each visit and a total at the bottom. Nothing on the page says
-- what it was for, so the only thing the page can be read as is a bill.
--
-- It is not a bill. Every booking in this system came from the app -- the
-- dashboard has had no way to enter one since 0024 -- so every patient on that
-- page is a patient the platform brought. The number that says so is how many
-- of them had never been to this doctor before.
--
-- A patient is new when their first visit here falls inside the period, which
-- is a question about their whole history rather than about the period, so it
-- is counted separately from the rows the page lists. Cancelled bookings are
-- not a first visit. A no-show is: the platform sent them and the doctor was
-- expecting them, whatever happened after.
--
-- The same number joins the home screen for the current month, where it sits
-- next to the month's revenue and explains it.
--
-- Safe to re-run.
-- =============================================================================

create or replace function public.doctor_payments(
  p_from date,
  p_to   date
)
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

  if p_from is null or p_to is null or p_to < p_from then
    raise exception 'Invalid date range'
      using errcode = 'invalid_parameter_value', hint = 'bad_range';
  end if;

  with rows as (
    select
      p.id,
      b.id            as booking_id,
      b.booked_date,
      b.session,
      b.start_time,
      b.end_time,
      b.status        as booking_status,
      pr.name         as patient_name,
      p.amount,
      p.payment_method,
      p.status,
      p.paid_at,
      p.created_at,
      p.commission_rate,
      p.commission_amount
    from public.bookings b
    join public.payments p  on p.id = b.payment_id
    left join public.profiles pr on pr.id = b.patient_id
    where b.doctor_id   = v_doctor
      and b.booked_date between p_from and p_to
  )
  select json_build_object(
    'range', json_build_object('from', p_from, 'to', p_to),
    'summary', json_build_object(
      'collected',   coalesce((select sum(amount) from rows where status = 'paid'), 0),
      -- A cancelled visit owes nothing, so it is not outstanding money.
      'outstanding', coalesce((select sum(amount) from rows
                                where status = 'pending'
                                  and booking_status not in ('cancelled', 'no_show')), 0),
      'refunded',    coalesce((select sum(amount) from rows where status = 'refunded'), 0),
      'paidCount',   (select count(*) from rows where status = 'paid'),
      'totalCount',  (select count(*) from rows),
      -- Charged on what was not called off, whether or not the fee has been
      -- collected yet: the platform's share is earned by the booking, and the
      -- collecting is between the doctor and the patient.
      'commission',  coalesce((select sum(commission_amount) from rows
                                where booking_status not in ('cancelled', 'no_show')), 0),
      'net',         coalesce((select sum(amount - coalesce(commission_amount, 0))
                                 from rows where booking_status not in ('cancelled', 'no_show')), 0),
      -- Named so the doctor can see it is not a share of these.
      'unrated',     (select count(*) from rows
                       where booking_status not in ('cancelled', 'no_show')
                         and commission_rate is null),
      -- Shown to the doctor as well, not only to the owner. It is the line
      -- that explains why the commission is lower than the bookings suggest.
      'noShow',      (select count(*) from rows where booking_status = 'no_show'),
      -- The one number that answers "what did the commission buy".
      --
      -- Not counted from `rows`: a patient is new only if they had never
      -- booked with this doctor before, which is a question about their whole
      -- history and not about this period. min(booked_date) falling inside the
      -- window is exactly "their first visit here was this month".
      --
      -- Cancelled bookings are not a first visit. A no-show is: they were sent
      -- by the platform and the doctor was expecting them, whatever happened
      -- after.
      'newPatients', (
        select count(*) from (
          select b.patient_id
            from public.bookings b
           where b.doctor_id = v_doctor
             and b.patient_id is not null
             and b.status <> 'cancelled'
           group by b.patient_id
          having min(b.booked_date) between p_from and p_to
        ) first_visits
      )
    ),
    'byMethod', coalesce((
      select json_agg(m order by m.method)
      from (
        select
          payment_method as method,
          coalesce(sum(amount) filter (where status = 'paid'), 0) as collected,
          coalesce(sum(amount) filter (where status = 'pending'
                                         and booking_status not in ('cancelled', 'no_show')), 0)
            as outstanding,
          count(*) as count
        from rows
        group by payment_method
      ) m
    ), '[]'::json),
    'items', coalesce((
      select json_agg(i order by i."bookedDate" desc, i."startTime" desc, i.id desc)
      from (
        select
          id,
          booking_id     as "bookingId",
          booked_date    as "bookedDate",
          session,
          start_time     as "startTime",
          end_time       as "endTime",
          booking_status as "bookingStatus",
          patient_name   as "patientName",
          amount,
          payment_method as method,
          status,
          paid_at        as "paidAt",
          created_at     as "createdAt",
          commission_rate   as "commissionRate",
          -- Nothing is owed on a booking that was called off in time, so the
          -- row shows nothing rather than a figure the doctor would query.
          case when booking_status not in ('cancelled', 'no_show') then commission_amount end
            as "commissionAmount"
        from rows
      ) i
    ), '[]'::json)
  )
  into v_result;

  return v_result;
end;
$$;

revoke execute on function public.doctor_payments(date, date) from public;
grant execute on function public.doctor_payments(date, date)
  to authenticated, service_role;

-- -----------------------------------------------------------------------------
-- The administrator's statement: every doctor, one row each.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- The home screen, with the same number for the current month.
--
-- Re-emitted whole. The three zeros it used to return for consultations,
-- prescriptions and unread notifications were written into the function, not
-- counted -- and a doctor reading "الاستشارات: ٠" has no way to know the answer
-- was never looked up. Two of those tables still do not exist, so their keys
-- go rather than lie. Notifications do exist now, so that one is counted.
-- -----------------------------------------------------------------------------
create or replace function public.dashboard_summary()
returns json
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_doctor       bigint := public.current_doctor_id();
  v_today        date   := (now() at time zone 'Africa/Cairo')::date;
  v_month_start  date;
  v_month_end    date;
begin
  v_month_start := date_trunc('month', v_today)::date;
  v_month_end   := (date_trunc('month', v_today) + interval '1 month')::date;

  -- An account with no doctor behind it gets zeros, not an error: the dashboard
  -- already explains that case on every page, and a failing home screen on top
  -- of it says nothing new.
  if v_doctor is null then
    return json_build_object(
      'total_patients', 0,
      'new_patients_this_month', 0,
      'appointments_today', 0,
      'appointments_upcoming', 0,
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
    -- Of those, the ones who had never been here before this month.
    'new_patients_this_month', (
      select count(*) from (
        select b.patient_id
          from public.bookings b
         where b.doctor_id = v_doctor
           and b.patient_id is not null
           and b.status <> 'cancelled'
         group by b.patient_id
        having min(b.booked_date) >= v_month_start
           and min(b.booked_date) <  v_month_end
      ) first_visits
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
    -- Counted now rather than assumed to be zero. The row is addressed to the
    -- account, and only the ones that were actually delivered are news.
    'unread_notifications', (
      select count(*)
        from public.notifications n
       where n.user_id = auth.uid()
         and n.sent_at is not null
         and n.read_at is null
    ),
    -- Money that actually arrived. A booking made this month and not yet paid
    -- for is not revenue, and counting it would overstate every month.
    'revenue_this_month', coalesce((
      select sum(p.amount)
        from public.bookings b
        join public.payments p on p.id = b.payment_id
       where b.doctor_id = v_doctor
         and b.status <> 'cancelled'
         and p.status = 'paid'
         and b.booked_date >= v_month_start
         and b.booked_date <  v_month_end
    ), 0)
  );
end;
$$;

revoke execute on function public.dashboard_summary() from public;
grant execute on function public.dashboard_summary() to authenticated;
