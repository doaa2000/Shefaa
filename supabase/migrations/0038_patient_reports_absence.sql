-- =============================================================================
-- "I cannot come."
--
-- Once the cancellation deadline passes the button goes, and the app tells the
-- patient to contact the clinic -- without giving them any way to. There is no
-- number on the screen, and there is not going to be one: a patient who learns
-- the clinic's number books by telephone from then on, and the platform never
-- sees them again.
--
-- So the message becomes a button that does the one useful thing a telephone
-- call would have done. It does not cancel the booking: the deadline has
-- passed, and letting it cancel would make the deadline mean nothing. It tells
-- the doctor, which is the part that matters -- a place nobody is coming to is
-- a place that can be offered to somebody else, and a doctor sitting waiting
-- for a patient who already knew they were not coming is the thing this
-- platform is supposed to prevent.
--
-- Only in the window where cancelling is no longer possible and the
-- appointment has not started. Before the deadline the patient should cancel,
-- which frees the place properly; afterwards there is nothing left to warn
-- anybody about.
--
-- Safe to re-run.
-- =============================================================================

alter table public.bookings
  add column if not exists absence_reported_at timestamptz;

comment on column public.bookings.absence_reported_at is
  'When the patient said they would not be coming, after cancelling had closed. Not a cancellation: the booking stands and the doctor decides what it was.';

create or replace function public.report_absence(p_booking bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_booking       public.bookings;
  v_patient_name  text;
  v_doctor_user   uuid;
  v_starts_at     timestamptz;
begin
  if auth.uid() is null then
    raise exception 'No authenticated user'
      using errcode = 'insufficient_privilege', hint = 'not_signed_in';
  end if;

  -- Scoped to the caller's own booking in the lookup itself, so there is no
  -- separate ownership check to forget, and no way to learn whether somebody
  -- else's booking exists.
  select * into v_booking
    from public.bookings
   where id = p_booking
     and patient_id = auth.uid();

  if not found then
    raise exception 'No such booking'
      using errcode = 'no_data_found', hint = 'booking_not_found';
  end if;

  if v_booking.status = 'cancelled' then
    raise exception 'That booking is already cancelled'
      using errcode = 'check_violation', hint = 'already_cancelled';
  end if;

  -- Still cancellable: say so rather than accept this. Cancelling gives the
  -- place back, and this does not.
  if now() < public.booking_cancellable_until(
               v_booking.booked_date, v_booking.start_time) then
    raise exception 'The booking can still be cancelled'
      using errcode = 'check_violation', hint = 'cancel_instead';
  end if;

  v_starts_at := public.appointment_starts_at(
                   v_booking.booked_date, v_booking.start_time);

  if now() >= v_starts_at then
    raise exception 'That appointment has started'
      using errcode = 'check_violation', hint = 'appointment_passed';
  end if;

  -- coalesce, so pressing it twice does not move the time it was first said.
  update public.bookings
     set absence_reported_at = coalesce(absence_reported_at, now())
   where id = v_booking.id;

  -- Nobody needs reminding of an appointment they have just said they will
  -- not be at.
  delete from public.notifications
   where sent_at is null
     and kind in ('reminder_day', 'reminder_hour')
     and (data ->> 'booking_id') = v_booking.id::text;

  select d.user_id into v_doctor_user
    from public."Doctors" d
   where d.id = v_booking.doctor_id;

  select nullif(trim(p.name), '') into v_patient_name
    from public.profiles p
   where p.id = v_booking.patient_id;

  perform public.enqueue_notification(
    v_doctor_user,
    'absence_reported',
    'مريض لن يحضر',
    coalesce(v_patient_name, 'مريض') || ' — موعد '
      || public.format_appointment_when(v_booking.booked_date, v_booking.start_time)
      || '.',
    jsonb_build_object('booking_id', v_booking.id),
    now(),
    -- Said once. Pressing the button again tells nobody anything new.
    'absence:' || v_booking.id
  );
end;
$$;

revoke execute on function public.report_absence(bigint) from public;
grant execute on function public.report_absence(bigint) to authenticated;
