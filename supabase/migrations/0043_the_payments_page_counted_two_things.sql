-- =============================================================================
-- Two figures on the payments page were counting different things.
--
-- `collected` was every fee marked paid, including fees taken for visits that
-- were cancelled or never attended. The fees total beside it counts only the
-- appointments that happened. Both were right on their own and wrong together:
-- a doctor reading 5,500 collected above 4,000 in fees is reading a mistake,
-- and there was no line anywhere saying where the other 1,500 went.
--
-- `collected` now means money taken for appointments that happened, and money
-- held for ones that did not is a figure of its own, shown when it exists.
--
-- Two figures are added for the same reason. `commissionable` is the fees the
-- share was actually charged on: bookings made before the commission existed
-- carry no rate, so "12%" was printing next to a total it had never been
-- applied to -- 60 next to 4,000, which reads as a broken sum. `unpaidCount`
-- counts appointments still to be collected, which the page was deriving as
-- total minus paid: an expression that counts a refund and a cancellation as
-- money owed.
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
      -- Money taken for appointments that actually happened. A fee collected
      -- for one that was called off is real money too, but it is not earnings
      -- from seeing patients -- and counted in the same figure it made the
      -- total disagree with the fees line beside it.
      'collected',   coalesce((select sum(amount) from rows
                                where status = 'paid'
                                  and booking_status not in ('cancelled', 'no_show')), 0),
      -- Held out on its own, and shown only when there is any: the doctor is
      -- holding money for a visit that never took place.
      'collectedOff', coalesce((select sum(amount) from rows
                                 where status = 'paid'
                                   and booking_status in ('cancelled', 'no_show')), 0),
      -- A cancelled visit owes nothing, so it is not outstanding money.
      'outstanding', coalesce((select sum(amount) from rows
                                where status = 'pending'
                                  and booking_status not in ('cancelled', 'no_show')), 0),
      'refunded',    coalesce((select sum(amount) from rows where status = 'refunded'), 0),
      'paidCount',   (select count(*) from rows where status = 'paid'),
      -- How many appointments are still waiting to be collected. Derived from
      -- the rows rather than from totalCount minus paidCount, which counts a
      -- refund and a cancellation as money owed.
      'unpaidCount', (select count(*) from rows
                       where status = 'pending'
                         and booking_status not in ('cancelled', 'no_show')),
      'totalCount',  (select count(*) from rows),
      -- Charged on what was not called off, whether or not the fee has been
      -- collected yet: the platform's share is earned by the booking, and the
      -- collecting is between the doctor and the patient.
      'commission',  coalesce((select sum(commission_amount) from rows
                                where booking_status not in ('cancelled', 'no_show')), 0),
      'net',         coalesce((select sum(amount - coalesce(commission_amount, 0))
                                 from rows where booking_status not in ('cancelled', 'no_show')), 0),
      -- The fees the share was actually taken from. Bookings made before the
      -- commission existed carry no rate, so without this the percentage
      -- appears beside a total it was never applied to.
      'commissionable', coalesce((select sum(amount) from rows
                                   where booking_status not in ('cancelled', 'no_show')
                                     and commission_rate is not null), 0),
      -- Named so the doctor can see it is not a share of these.
      'unrated',     (select count(*) from rows
                       where booking_status not in ('cancelled', 'no_show')
                         and commission_rate is null),
      -- Shown to the doctor as well, not only to the owner. It is the line
      -- that explains why the commission is lower than the bookings suggest.
      'noShow',      (select count(*) from rows where booking_status = 'no_show')
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
