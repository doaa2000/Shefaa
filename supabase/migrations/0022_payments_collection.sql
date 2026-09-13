-- =============================================================================
-- Payments the doctor can actually see, and actually mark as collected.
--
-- Three things were wrong at once, and the payments page in the doctor
-- dashboard could not work until all three were fixed:
--
--   1. A doctor could not read a payment row at all. The policy on payments is
--      "the patient who owns it, or an administrator", so the dashboard's
--      query came back with a null payment on every booking and the page was
--      permanently empty. Fixed here the same way the rest of the dashboard
--      reads what it needs: a definer function scoped to the signed-in doctor,
--      rather than a new policy widening the table for everybody.
--
--   2. Nothing ever moved a payment past 'pending'. There is no payment
--      gateway; the fee is handed over at the clinic. So the status has to be
--      something a person sets, and until now nobody could. set_payment_status
--      is that, and it records who marked it and when -- a takings figure
--      nobody can trace back is not worth reading.
--
--   3. The amount came from the app. create_booking took p_amount as a
--      parameter and wrote whatever it was given, so a patient could book at
--      any price they liked and every figure on this page was built on it.
--      The fee now comes from Doctors.consultation_fee, server-side, and the
--      parameter is gone rather than ignored.
--
-- Safe to re-run.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- When it was collected, and by whom.
-- -----------------------------------------------------------------------------
alter table public.payments
  add column if not exists paid_at   timestamptz,
  add column if not exists marked_by uuid references auth.users (id) on delete set null;

comment on column public.payments.paid_at is
  'When the money was actually taken. Null while the payment is outstanding.';
comment on column public.payments.marked_by is
  'Who marked it. Null for rows that predate the dashboard button.';

-- -----------------------------------------------------------------------------
-- The fee is the doctor's, not the caller's.
--
-- The signature changes, so the old function is dropped rather than replaced:
-- leaving it behind would keep a callable route that still takes a price from
-- whoever is asking.
-- -----------------------------------------------------------------------------
drop function if exists
  public.create_booking(bigint, date, text, time, time, numeric, text);

create or replace function public.create_booking(
  p_doctor  bigint,
  p_date    date,
  p_session text,
  p_start   time,
  p_end     time,
  p_method  text
)
returns table (booking_id bigint)
language plpgsql
-- definer so the capacity check behind it can count every booking in the
-- window, not just the caller's. Everything it writes is pinned to auth.uid(),
-- so it can only ever create a booking for whoever is calling it.
security definer
set search_path = public
as $$
declare
  v_patient uuid := auth.uid();
  v_amount  numeric;
  v_payment bigint;
  v_booking bigint;
begin
  if v_patient is null then
    raise exception 'No authenticated user'
      using errcode = 'insufficient_privilege', hint = 'not_signed_in';
  end if;

  select d.consultation_fee into v_amount
    from public."Doctors" d
   where d.id = p_doctor;

  if not found then
    raise exception 'Doctor not found'
      using errcode = 'no_data_found', hint = 'doctor_not_found';
  end if;

  -- Said plainly here rather than let bookings_one_place_per_session surface as
  -- a duplicate key error the patient cannot read. Still one place per session
  -- rather than per window: booking two hours of the same evening is a mistake,
  -- not a use case.
  if exists (
    select 1 from public.bookings b
     where b.patient_id  = v_patient
       and b.doctor_id   = p_doctor
       and b.booked_date = p_date
       and b.session     = p_session
       and b.status     <> 'cancelled'
  ) then
    raise exception 'Patient already holds a place in this session'
      using errcode = 'unique_violation', hint = 'already_booked';
  end if;

  insert into public.payments (patient_id, amount, payment_method, status)
  values (v_patient, coalesce(v_amount, 0), p_method, 'pending')
  returning id into v_payment;

  insert into public.bookings
    (patient_id, doctor_id, payment_id, booked_date, session,
     start_time, end_time, status)
  values (v_patient, p_doctor, v_payment, p_date, p_session,
          p_start, p_end, 'confirmed')
  returning id into v_booking;

  return query select v_booking;
end;
$$;

revoke execute on function
  public.create_booking(bigint, date, text, time, time, text) from public;
grant execute on function
  public.create_booking(bigint, date, text, time, time, text) to authenticated;

-- -----------------------------------------------------------------------------
-- What the doctor collected, and what is still owed.
--
-- One call for the whole page: the figures, the split by method, and the rows.
-- Three round trips for three views of the same set of payments would be three
-- chances for them to disagree with each other.
--
-- json rather than a table, so the client gets one object instead of an array
-- it has to unwrap.
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
      p.created_at
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
      'totalCount',  (select count(*) from rows)
    ),
    -- Cash is in the drawer and instapay is in the bank; they are reconciled
    -- separately, so they are reported separately.
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
          created_at     as "createdAt"
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
-- Marking a payment collected, refunded, or outstanding again.
--
-- Only the doctor the booking belongs to, or an administrator. 'failed' is not
-- offered: it means a gateway declined, and there is no gateway -- money that
-- was not handed over is simply still pending.
-- -----------------------------------------------------------------------------
create or replace function public.set_payment_status(
  p_payment bigint,
  p_status  text
)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_doctor bigint := public.current_doctor_id();
  v_admin  boolean := public.is_admin();
  v_result json;
begin
  if p_status not in ('paid', 'pending', 'refunded') then
    raise exception 'Unsupported payment status: %', p_status
      using errcode = 'invalid_parameter_value', hint = 'bad_status';
  end if;

  if v_doctor is null and not v_admin then
    raise exception 'Not a doctor account'
      using errcode = 'insufficient_privilege', hint = 'not_a_doctor';
  end if;

  -- The payment has to hang off a booking this doctor owns. Without this a
  -- doctor could settle the whole clinic's takings from their own dashboard.
  if not v_admin and not exists (
    select 1 from public.bookings b
     where b.payment_id = p_payment
       and b.doctor_id  = v_doctor
  ) then
    raise exception 'Payment not found'
      using errcode = 'no_data_found', hint = 'not_found';
  end if;

  update public.payments p
     set status    = p_status,
         -- Cleared when the payment goes back to outstanding or is refunded,
         -- so paid_at always answers "when was this money taken" and never
         -- describes a payment that is no longer collected.
         paid_at   = case when p_status = 'paid' then now() end,
         marked_by = auth.uid()
   where p.id = p_payment
  returning json_build_object(
    'id', p.id,
    'status', p.status,
    'paidAt', p.paid_at,
    'amount', p.amount,
    'method', p.payment_method
  ) into v_result;

  if v_result is null then
    raise exception 'Payment not found'
      using errcode = 'no_data_found', hint = 'not_found';
  end if;

  return v_result;
end;
$$;

revoke execute on function public.set_payment_status(bigint, text) from public;
grant execute on function public.set_payment_status(bigint, text)
  to authenticated, service_role;
