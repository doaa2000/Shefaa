-- =============================================================================
-- The review is asked for inside the app, not by notification.
--
-- 0045 put the request in the notification queue. It works, and it is the
-- wrong channel: the notifications this app sends are about appointments --
-- booked, cancelled, tomorrow, in an hour -- and every one of them is worth
-- interrupting somebody for. A request to rate a doctor is not, and mixing it
-- in teaches patients that a notification from Shefaa might be nothing, which
-- is how the reminders stop being read.
--
-- So the ask moves to the moment the patient is already in the app. Nothing
-- interrupts them; the sheet is simply there when they next open it, three
-- hours or more after the visit.
--
-- What is dropped: the sweep that wrote the requests, the trigger that deleted
-- them again, and any request already queued but not yet sent. Reviews
-- themselves, and everything in 0044, are untouched.
--
-- Safe to re-run.
-- =============================================================================

drop trigger if exists review_clears_its_request on public.doctor_reviews;
drop function if exists public.clear_review_request();
drop function if exists public.queue_review_requests();

-- Anything the old sweep queued and the sender has not taken yet. A sent one
-- is left alone: it is on somebody's phone, and deleting the record of it
-- would not take it back.
delete from public.notifications
 where kind = 'review_request'
   and sent_at is null;

-- -----------------------------------------------------------------------------
-- The one visit to ask about, if there is one.
--
-- Answers for the caller and nobody else. One row at most, the most recent,
-- because a sheet that appears four times in a row is a sheet that gets
-- dismissed four times in a row.
-- -----------------------------------------------------------------------------
create or replace function public.pending_review()
returns json
language sql
stable
security definer
set search_path = public
as $$
  select json_build_object(
           'bookingId',  b.id,
           'doctorId',   d.id,
           'doctorName', d.name,
           'bookedDate', b.booked_date,
           'startTime',  b.start_time
         )
    from public.bookings b
    join public."Doctors" d on d.id = b.doctor_id
   where b.patient_id = auth.uid()
     -- Nothing to review: one was called off, the other never happened.
     and b.status not in ('cancelled', 'no_show')
     -- Long enough after that the visit is over and they are home.
     and public.appointment_starts_at(b.booked_date, b.end_time)
           <= now() - interval '3 hours'
     -- And not so long after that it is a question about something they have
     -- forgotten. A week is the outside edge of "how was it".
     and b.booked_date >= current_date - 7
     and not exists (
       select 1 from public.doctor_reviews r where r.booking_id = b.id
     )
   order by b.booked_date desc, b.start_time desc
   limit 1;
$$;

revoke execute on function public.pending_review() from public;
grant execute on function public.pending_review() to authenticated;
