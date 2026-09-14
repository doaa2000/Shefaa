-- =============================================================================
-- The platform's commission, recorded on every booking it is charged on.
--
-- The business model: a booking made in the patients' app earns the platform a
-- share of the consultation fee. Twelve per cent, for every doctor, today.
--
-- The one thing this migration exists to get right is that the rate is written
-- onto the booking, not looked up when somebody asks. A rate held in one place
-- and multiplied on read means the day it changes, every booking ever made
-- changes with it: a doctor who took patients all last month at 12% is billed
-- 15% for them. The rate a booking was made under is a fact about that
-- booking, so it lives on it.
--
-- Two more things belong here because the money depends on them:
--
--   * A cancellation deadline. Commission is charged on a booking that was not
--     cancelled -- so without a deadline, cancelling from the clinic doorstep
--     after the visit erases it. A patient may cancel up to an hour before
--     their window opens, and not after.
--
--   * Who cancelled, and when. "Cancelled" alone cannot tell a patient who
--     changed their mind from a doctor clearing a booking they owe a share of.
--
-- Safe to re-run.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- The numbers the business runs on, in one row.
--
-- A table rather than constants in a function: changing the rate should not be
-- a deployment, and the app has to be able to read the notice period to tell a
-- patient how long they have.
-- -----------------------------------------------------------------------------
create table if not exists public.platform_settings (
  -- One row, forever. The check is what makes it one.
  id                  smallint primary key default 1 check (id = 1),
  -- 0.12 is twelve per cent. Stored as a fraction because that is what it is
  -- multiplied by; a column called "percent" holding 12 invites someone to
  -- multiply by it one day.
  commission_rate     numeric(5,4) not null default 0.12
                        check (commission_rate >= 0 and commission_rate <= 1),
  -- How long before their window a patient may still cancel.
  cancellation_notice interval not null default '1 hour',
  updated_at          timestamptz not null default now()
);

insert into public.platform_settings (id) values (1)
on conflict (id) do nothing;

alter table public.platform_settings enable row level security;

-- Readable by anyone signed in: the app shows the patient their deadline, and
-- the doctor is told the share taken from their fee. A rate nobody can see is
-- a rate somebody will dispute.
drop policy if exists platform_settings_read on public.platform_settings;
create policy platform_settings_read on public.platform_settings
  for select to authenticated using (true);

drop policy if exists platform_settings_write on public.platform_settings;
create policy platform_settings_write on public.platform_settings
  for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

grant select on public.platform_settings to authenticated;
grant all on public.platform_settings to service_role;

-- -----------------------------------------------------------------------------
-- The share, on the payment it came out of.
-- -----------------------------------------------------------------------------
alter table public.payments
  add column if not exists commission_rate numeric(5,4)
    check (commission_rate is null
           or (commission_rate >= 0 and commission_rate <= 1));

-- Generated, not written: the amount and the rate are on the same row, so the
-- product can never drift from them. A figure computed once and stored by hand
-- is a figure that disagrees with its own inputs the first time one is edited.
alter table public.payments
  add column if not exists commission_amount numeric(10,2)
    generated always as (round(amount * commission_rate, 2)) stored;

comment on column public.payments.commission_rate is
  'The platform share in force when this booking was made. Null for bookings taken before there was one.';
comment on column public.payments.commission_amount is
  'amount * commission_rate. Derived; never written directly.';

-- -----------------------------------------------------------------------------
-- Who cancelled, and when.
-- -----------------------------------------------------------------------------
alter table public.bookings
  add column if not exists cancelled_at timestamptz,
  add column if not exists cancelled_by uuid references auth.users (id) on delete set null;

comment on column public.bookings.cancelled_by is
  'The account that cancelled. A patient changing their mind and a doctor clearing a booking are not the same event, and the commission statement has to tell them apart.';

-- -----------------------------------------------------------------------------
-- When a booking stops being cancellable.
--
-- Its own function because the app, the trigger and any report all have to
-- agree on it, and three copies of a deadline are two too many.
--
-- The clinic's wall clock decides, not the server's: booked_date and start_time
-- are what the doctor wrote on their schedule, in Cairo. Reading them as UTC
-- would move every deadline by the offset.
-- -----------------------------------------------------------------------------
create or replace function public.booking_cancellable_until(
  p_date  date,
  p_start time
)
returns timestamptz
language sql
stable
set search_path = public
as $$
  select ((p_date + p_start) at time zone 'Africa/Cairo')
         - (select cancellation_notice from public.platform_settings where id = 1);
$$;

grant execute on function public.booking_cancellable_until(date, time)
  to authenticated, service_role;

-- -----------------------------------------------------------------------------
-- create_booking records the rate it was made under.
-- -----------------------------------------------------------------------------
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
  v_rate    numeric;
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

  -- Read now and written onto the row: this booking is charged at today's
  -- rate for the rest of its life, whatever the rate becomes.
  select commission_rate into v_rate
    from public.platform_settings where id = 1;

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

  insert into public.payments
    (patient_id, amount, payment_method, status, commission_rate)
  values (v_patient, coalesce(v_amount, 0), p_method, 'pending', v_rate)
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
-- The deadline, and the record of who cancelled.
--
-- Everything above the deadline check is unchanged from 0008.
-- -----------------------------------------------------------------------------
create or replace function public.guard_booking_changes()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Stamped for everyone who cancels, doctor and patient alike, and before any
  -- of the rules below: the statement has to be able to tell a patient who
  -- changed their mind from a doctor clearing a booking they owe a share of.
  if new.status = 'cancelled' and old.status is distinct from 'cancelled' then
    new.cancelled_at := now();
    new.cancelled_by := auth.uid();
  end if;

  -- No JWT at all means this is not an app user: the service role, a migration,
  -- or the SQL editor. Those already have full access to the table; the rules
  -- below are about what someone signed into the apps may do. Without this the
  -- trigger locks the owner out of her own database.
  if auth.uid() is null then
    return new;
  end if;

  -- Deleting an account anonymises its bookings; that path sets its own flag
  -- and is not somebody cancelling a visit.
  if coalesce(current_setting('app.deleting_account', true), 'off') = 'on' then
    return new;
  end if;

  -- The doctor this booking is with, and an admin, decide everything about it.
  if public.is_admin() or old.doctor_id = public.current_doctor_id() then
    return new;
  end if;

  -- Nobody else may move a booking: not to another doctor, another day,
  -- another session, or another patient.
  if new.doctor_id   is distinct from old.doctor_id
     or new.patient_id  is distinct from old.patient_id
     or new.booked_date is distinct from old.booked_date
     or new.session     is distinct from old.session then
    raise exception 'A booking cannot be moved; cancel and book again'
      using errcode = 'check_violation', hint = 'booking_immutable';
  end if;

  -- And the only status a patient may set is cancelled. Whether they actually
  -- turned up is the doctor's to record.
  if new.status is distinct from old.status and new.status <> 'cancelled' then
    raise exception 'A patient may only cancel'
      using errcode = 'check_violation', hint = 'cancel_only';
  end if;

  -- Too late to call it off. Without this the whole commission rests on
  -- nothing: a patient could be seen and then cancel on the way out, and the
  -- booking would read as one that never happened.
  if new.status = 'cancelled'
     and old.status is distinct from 'cancelled'
     and now() > public.booking_cancellable_until(old.booked_date, old.start_time)
  then
    raise exception 'Too late to cancel this booking'
      using errcode = 'check_violation', hint = 'cancellation_closed';
  end if;

  return new;
end;
$$;

revoke execute on function public.guard_booking_changes() from public;
