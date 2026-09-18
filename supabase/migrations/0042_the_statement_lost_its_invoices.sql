-- =============================================================================
-- The statement stopped saying which periods were already invoiced.
--
-- 0027 added the invoice to `admin_commission_statement`: which invoice exists
-- for the doctor and the period, whether it is issued or paid, and what it was
-- raised for. The admin page is built on those three fields -- they are what
-- turns the row's button from "raise an invoice" into "mark it collected", and
-- what fills the "invoiced" and "collected" cards above the table.
--
-- 0034 then re-emitted the same function to stop counting no-shows, starting
-- from 0026's text rather than 0027's, and took all of that back out with it.
-- Nothing failed: the function still answered, the page still drew, and every
-- invoice ever raised was invisible from the one screen it is raised from. An
-- invoice could be issued and then never settled, because the button to settle
-- it never appeared.
--
-- This re-emits the function with both changes at once, and fixes the same
-- omission on the other side: `issue_commission_invoice` was never taught the
-- no-show rule either, so an invoice would bill a doctor for patients the
-- statement above it had already stopped charging them for. The two now count
-- the same bookings, which was the point of computing them from one rule.
--
-- Safe to re-run.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Raising one: every booking in the period that was neither cancelled nor
-- missed, at the rate each was booked under.
-- -----------------------------------------------------------------------------
create or replace function public.issue_commission_invoice(
  p_doctor bigint,
  p_from   date,
  p_to     date
)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_bookings   integer;
  v_fees       numeric;
  v_commission numeric;
  v_id         bigint;
begin
  if not public.is_admin() then
    raise exception 'Administrators only'
      using errcode = 'insufficient_privilege', hint = 'not_an_admin';
  end if;

  if p_from is null or p_to is null or p_to < p_from then
    raise exception 'Invalid date range'
      using errcode = 'invalid_parameter_value', hint = 'bad_range';
  end if;

  if not exists (select 1 from public."Doctors" where id = p_doctor) then
    raise exception 'Doctor not found'
      using errcode = 'no_data_found', hint = 'doctor_not_found';
  end if;

  select
    count(*),
    coalesce(sum(p.amount), 0),
    coalesce(sum(p.commission_amount), 0)
  into v_bookings, v_fees, v_commission
  from public.bookings b
  join public.payments p on p.id = b.payment_id
  where b.doctor_id   = p_doctor
    and b.booked_date between p_from and p_to
    -- A patient who never arrived paid nothing and cost the doctor a slot.
    -- Billing a share of a fee that was never collected is the one thing this
    -- must not do.
    and b.status not in ('cancelled', 'no_show');

  -- Nothing to bill is not an error, but it is not an invoice either. An
  -- invoice for zero is a piece of paper that says nothing and still has to be
  -- chased, marked paid and filed.
  if v_commission <= 0 then
    raise exception 'Nothing to invoice for this period'
      using errcode = 'no_data_found', hint = 'nothing_due';
  end if;

  insert into public.commission_invoices
    (doctor_id, period_start, period_end, bookings, fees, commission, issued_by)
  values (p_doctor, p_from, p_to, v_bookings, v_fees, v_commission, auth.uid())
  returning id into v_id;

  return json_build_object(
    'id', v_id,
    'doctorId', p_doctor,
    'bookings', v_bookings,
    'fees', v_fees,
    'commission', v_commission,
    'status', 'issued'
  );
exception
  when unique_violation then
    raise exception 'This period is already invoiced for this doctor'
      using errcode = 'unique_violation', hint = 'already_invoiced';
end;
$$;

revoke execute on function public.issue_commission_invoice(bigint, date, date) from public;
grant execute on function public.issue_commission_invoice(bigint, date, date)
  to authenticated, service_role;

-- -----------------------------------------------------------------------------
-- The statement, with the invoice back on it.
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
      count(*) filter (where booking_status not in ('cancelled', 'no_show'))          as bookings,
      coalesce(sum(amount) filter (where booking_status not in ('cancelled', 'no_show')), 0) as fees,
      coalesce(sum(commission_amount)
                 filter (where booking_status not in ('cancelled', 'no_show')), 0)    as commission,
      coalesce(sum(amount - coalesce(commission_amount, 0))
                 filter (where booking_status not in ('cancelled', 'no_show')), 0)    as net,
      count(*) filter (where booking_status = 'cancelled')           as cancelled,
      -- The doctor's own account cancelling, as opposed to the patient's.
      count(*) filter (where booking_status = 'cancelled'
                         and cancelled_by is not null
                         and cancelled_by = doctor_user_id)          as cancelled_by_doctor,
      count(*) filter (where booking_status = 'no_show')             as no_show,
      count(*) filter (where booking_status not in ('cancelled', 'no_show')
                         and commission_rate is null)                as unrated
    from rows
    group by doctor_id, doctor_name, doctor_user_id
  ),
  -- Exactly the period the page is looking at. A live invoice only; a voided
  -- one leaves the row ready to be invoiced again, which is how a mistake is
  -- corrected.
  with_invoice as (
    select
      pd.*,
      inv.id         as invoice_id,
      inv.status     as invoice_status,
      inv.commission as invoiced_commission,
      inv.paid_at    as invoice_paid_at
    from per_doctor pd
    left join public.commission_invoices inv
      on inv.doctor_id    = pd.doctor_id
     and inv.period_start = p_from
     and inv.period_end   = p_to
     and inv.status <> 'void'
  )
  select json_build_object(
    'range', json_build_object('from', p_from, 'to', p_to),
    'totals', json_build_object(
      'doctors',    (select count(*) from with_invoice where bookings > 0),
      'bookings',   coalesce((select sum(bookings) from with_invoice), 0),
      'fees',       coalesce((select sum(fees) from with_invoice), 0),
      'commission', coalesce((select sum(commission) from with_invoice), 0),
      'net',        coalesce((select sum(net) from with_invoice), 0),
      'cancelled',  coalesce((select sum(cancelled) from with_invoice), 0),
      'noShow',     coalesce((select sum(no_show) from with_invoice), 0),
      'unrated',    coalesce((select sum(unrated) from with_invoice), 0),
      -- What has actually been settled for this period, and what has not:
      -- the two numbers the month is closed on.
      'invoiced',   coalesce((select sum(invoiced_commission) from with_invoice
                               where invoice_id is not null), 0),
      'collected',  coalesce((select sum(invoiced_commission) from with_invoice
                               where invoice_status = 'paid'), 0)
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
          unrated,
          invoice_id          as "invoiceId",
          invoice_status      as "invoiceStatus",
          invoiced_commission as "invoicedCommission",
          invoice_paid_at     as "invoicePaidAt"
        from with_invoice
        -- A doctor with nothing but cancellations still belongs on the
        -- statement: a month of nothing but cancellations is itself a finding.
        -- no_show joins that list now it no longer counts as a booking --
        -- otherwise the one doctor worth looking at is the one who disappears.
        where bookings > 0 or cancelled > 0 or no_show > 0
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
