-- =============================================================================
-- What each doctor owes the platform, and what the doctor sees of it.
--
-- 0025 wrote the share onto every booking. This reads it back: one statement
-- for the administrator covering every doctor, and the same figures on the
-- doctor's own payments page, because a share taken out of somebody's fee that
-- they cannot see is a share they will dispute.
--
-- What is charged, decided deliberately:
--
--   * Every booking that was not cancelled. Not "every booking the doctor
--     marked completed" -- that would hang the platform's income on the
--     doctor's own bookkeeping, and give them a reason to skip it.
--   * A cancellation is only possible before the deadline 0025 enforces, so a
--     cancelled booking really is one that was called off in time.
--   * A no-show is still charged, and reported separately. The doctor is the
--     only one who can say a patient did not arrive, so it is an objection to
--     be looked at, not a switch that turns the charge off by itself.
--   * Who cancelled is reported too. A doctor clearing their own bookings is
--     not the same event as patients changing their minds, and a column that
--     shows it makes the difference visible without accusing anyone.
--
-- Bookings taken before 0025 carry no rate. They are counted and reported as
-- unrated rather than folded in at today's rate, which would be inventing a
-- charge nobody agreed to.
--
-- Safe to re-run.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- The doctor's own page learns about the share.
--
-- Extends 0022's function rather than adding a second one: the figures and the
-- rows come from the same set of payments, and two calls over the same set are
-- two chances to disagree.
-- -----------------------------------------------------------------------------
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
                                  and booking_status <> 'cancelled'), 0),
      'refunded',    coalesce((select sum(amount) from rows where status = 'refunded'), 0),
      'paidCount',   (select count(*) from rows where status = 'paid'),
      'totalCount',  (select count(*) from rows),
      -- Charged on what was not called off, whether or not the fee has been
      -- collected yet: the platform's share is earned by the booking, and the
      -- collecting is between the doctor and the patient.
      'commission',  coalesce((select sum(commission_amount) from rows
                                where booking_status <> 'cancelled'), 0),
      'net',         coalesce((select sum(amount - coalesce(commission_amount, 0))
                                 from rows where booking_status <> 'cancelled'), 0),
      -- Named so the doctor can see it is not a share of these.
      'unrated',     (select count(*) from rows
                       where booking_status <> 'cancelled'
                         and commission_rate is null)
    ),
    'byMethod', coalesce((
      select json_agg(m order by m.method)
      from (
        select
          payment_method as method,
          coalesce(sum(amount) filter (where status = 'paid'), 0) as collected,
          coalesce(sum(amount) filter (where status = 'pending'
                                         and booking_status <> 'cancelled'), 0)
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
          case when booking_status <> 'cancelled' then commission_amount end
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
create or replace function public.admin_commission_statement(
  p_from date,
  p_to   date
)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_result json;
begin
  if not public.is_admin() then
    raise exception 'Administrators only'
      using errcode = 'insufficient_privilege', hint = 'not_an_admin';
  end if;

  if p_from is null or p_to is null or p_to < p_from then
    raise exception 'Invalid date range'
      using errcode = 'invalid_parameter_value', hint = 'bad_range';
  end if;

  with rows as (
    select
      d.id      as doctor_id,
      d.name    as doctor_name,
      b.status  as booking_status,
      b.cancelled_by,
      d.user_id as doctor_user_id,
      p.amount,
      p.commission_rate,
      p.commission_amount
    from public.bookings b
    join public.payments p   on p.id = b.payment_id
    join public."Doctors" d  on d.id = b.doctor_id
    where b.booked_date between p_from and p_to
  ),
  per_doctor as (
    select
      doctor_id,
      doctor_name,
      count(*) filter (where booking_status <> 'cancelled')          as bookings,
      coalesce(sum(amount) filter (where booking_status <> 'cancelled'), 0) as fees,
      coalesce(sum(commission_amount)
                 filter (where booking_status <> 'cancelled'), 0)    as commission,
      coalesce(sum(amount - coalesce(commission_amount, 0))
                 filter (where booking_status <> 'cancelled'), 0)    as net,
      count(*) filter (where booking_status = 'cancelled')           as cancelled,
      -- The doctor's own account cancelling, as opposed to the patient's.
      count(*) filter (where booking_status = 'cancelled'
                         and cancelled_by is not null
                         and cancelled_by = doctor_user_id)          as cancelled_by_doctor,
      count(*) filter (where booking_status = 'no_show')             as no_show,
      count(*) filter (where booking_status <> 'cancelled'
                         and commission_rate is null)                as unrated
    from rows
    group by doctor_id, doctor_name, doctor_user_id
  )
  select json_build_object(
    'range', json_build_object('from', p_from, 'to', p_to),
    'totals', json_build_object(
      'doctors',    (select count(*) from per_doctor where bookings > 0),
      'bookings',   coalesce((select sum(bookings) from per_doctor), 0),
      'fees',       coalesce((select sum(fees) from per_doctor), 0),
      'commission', coalesce((select sum(commission) from per_doctor), 0),
      'net',        coalesce((select sum(net) from per_doctor), 0),
      'cancelled',  coalesce((select sum(cancelled) from per_doctor), 0),
      'noShow',     coalesce((select sum(no_show) from per_doctor), 0),
      'unrated',    coalesce((select sum(unrated) from per_doctor), 0)
    ),
    'rows', coalesce((
      select json_agg(r order by r.commission desc, r."doctorName")
      from (
        select
          doctor_id           as "doctorId",
          doctor_name         as "doctorName",
          bookings,
          fees,
          commission,
          net,
          cancelled,
          cancelled_by_doctor as "cancelledByDoctor",
          no_show             as "noShow",
          unrated
        from per_doctor
        -- A doctor with nothing but cancellations still belongs on the
        -- statement: a month of nothing but cancellations is itself a finding.
        where bookings > 0 or cancelled > 0
      ) r
    ), '[]'::json)
  )
  into v_result;

  return v_result;
end;
$$;

revoke execute on function public.admin_commission_statement(date, date) from public;
grant execute on function public.admin_commission_statement(date, date)
  to authenticated, service_role;
