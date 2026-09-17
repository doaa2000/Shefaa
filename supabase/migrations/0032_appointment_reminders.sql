-- =============================================================================
-- Reminding the patient: a day before, and an hour before.
--
-- This is what the queue was built for. There is no new delivery here and no
-- new schedule -- a reminder is an ordinary row with a send_after in the
-- future, and the sender that already runs picks it up when its time comes.
--
-- Queueing runs on every sweep and is safe to run as often as anyone likes:
-- each reminder carries a dedupe key made from the booking, so a second run
-- over the same appointment writes nothing.
--
-- Only appointments inside the next twenty-six hours are considered. Further
-- out there is nothing to do yet, and a sweep that walked every future booking
-- every minute would grow with the business for no benefit.
--
-- Safe to re-run.
-- =============================================================================

-- Times are stored as a local date and a local time, which is what a clinic
-- actually schedules: "the ninth of October at half past nine" does not move
-- because a server is in another country. Turning that into an instant is
-- therefore always done against Cairo.
create or replace function public.appointment_starts_at(
  p_date  date,
  p_start time
) returns timestamptz
language sql
stable
as $$
  select (p_date + p_start) at time zone 'Africa/Cairo';
$$;

-- Split out of format_appointment_when, because a reminder that already says
-- "tomorrow" should not then repeat the date.
create or replace function public.format_appointment_time(
  p_start time
) returns text
language sql
immutable
as $$
  select to_char(p_start, 'FMHH12:MI')
      || case when p_start < time '12:00' then ' صباحًا' else ' مساءً' end;
$$;

create or replace function public.format_appointment_when(
  p_date  date,
  p_start time
) returns text
language sql
immutable
as $$
  select to_char(p_date, 'FMDD/FMMM/YYYY')
      || ' في تمام '
      || public.format_appointment_time(p_start);
$$;

-- The sweep's only query. Partial, because a cancelled booking is never
-- reminded about and they are the rows that pile up.
create index if not exists bookings_upcoming_idx
  on public.bookings (booked_date, start_time)
  where status <> 'cancelled';

-- -----------------------------------------------------------------------------
-- queue_appointment_reminders -- called at the start of every sweep.
--
-- A reminder is only written while its moment is still ahead. An appointment
-- booked twenty hours in advance never gets a "tomorrow" reminder, because
-- there is no tomorrow left to remind about; it still gets the one an hour
-- before. Writing it late instead would send "your appointment is tomorrow"
-- about something happening this evening, which is worse than silence.
-- -----------------------------------------------------------------------------
create or replace function public.queue_appointment_reminders()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_written integer := 0;
  v_count   integer;
begin
  with upcoming as (
    select b.id,
           b.patient_id,
           b.start_time,
           d.name as doctor_name,
           public.appointment_starts_at(b.booked_date, b.start_time) as starts_at
    from public.bookings b
    join public."Doctors" d on d.id = b.doctor_id
    where b.status <> 'cancelled'
      and b.patient_id is not null
      and b.booked_date between current_date - 1 and current_date + 2
  ),
  inserted as (
    insert into public.notifications
      (user_id, kind, title, body, data, send_after, dedupe_key)
    select u.patient_id,
           'reminder_day',
           'تذكير بموعد الغد',
           'موعدك مع ' || coalesce(u.doctor_name, 'الطبيب') || ' غدًا في تمام '
             || public.format_appointment_time(u.start_time) || '.',
           jsonb_build_object('booking_id', u.id),
           u.starts_at - interval '1 day',
           'reminder_day:' || u.id
    from upcoming u
    where u.starts_at - interval '1 day' > now()
      and u.starts_at < now() + interval '26 hours'
    on conflict (dedupe_key) do nothing
    returning 1
  )
  select count(*) into v_count from inserted;
  v_written := v_written + v_count;

  with upcoming as (
    select b.id,
           b.patient_id,
           b.start_time,
           d.name as doctor_name,
           public.appointment_starts_at(b.booked_date, b.start_time) as starts_at
    from public.bookings b
    join public."Doctors" d on d.id = b.doctor_id
    where b.status <> 'cancelled'
      and b.patient_id is not null
      and b.booked_date between current_date - 1 and current_date + 2
  ),
  inserted as (
    insert into public.notifications
      (user_id, kind, title, body, data, send_after, dedupe_key)
    select u.patient_id,
           'reminder_hour',
           'موعدك بعد ساعة',
           'موعدك مع ' || coalesce(u.doctor_name, 'الطبيب') || ' في تمام '
             || public.format_appointment_time(u.start_time) || '.',
           jsonb_build_object('booking_id', u.id),
           u.starts_at - interval '1 hour',
           'reminder_hour:' || u.id
    from upcoming u
    where u.starts_at - interval '1 hour' > now()
      and u.starts_at < now() + interval '26 hours'
    on conflict (dedupe_key) do nothing
    returning 1
  )
  select count(*) into v_count from inserted;
  v_written := v_written + v_count;

  return v_written;
end;
$$;

revoke all on function public.queue_appointment_reminders() from public;
grant execute on function public.queue_appointment_reminders() to service_role;

-- -----------------------------------------------------------------------------
-- A moved appointment must not be reminded about at its old time.
--
-- The cancellation trigger in 0031 already drops unsent reminders, because a
-- reminder for an appointment that is not happening sends someone to a clinic.
-- Moving one is the same problem wearing different clothes: the queued row
-- still holds yesterday's hour in its text and its send_after. Dropping it
-- lets the next sweep write it again from what the booking now says.
-- -----------------------------------------------------------------------------
create or replace function public.clear_reminders_on_reschedule()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.booked_date is not distinct from old.booked_date
     and new.start_time is not distinct from old.start_time then
    return new;
  end if;

  delete from public.notifications
  where sent_at is null
    and kind in ('reminder_day', 'reminder_hour')
    and (data ->> 'booking_id') = new.id::text;

  return new;
end;
$$;

drop trigger if exists booking_rescheduled_clears_reminders on public.bookings;
create trigger booking_rescheduled_clears_reminders
  after update of booked_date, start_time on public.bookings
  for each row execute function public.clear_reminders_on_reschedule();

revoke all on function public.clear_reminders_on_reschedule() from public;
