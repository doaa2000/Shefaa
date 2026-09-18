-- =============================================================================
-- Asking, once, after the visit.
--
-- 0044 gave patients somewhere to rate a doctor. Nobody opens an app to do
-- that. A rating system nobody is asked to use collects a handful of reviews
-- from the delighted and the furious, and an average drawn from those two is
-- worse than no average at all.
--
-- So the same queue that carries the reminders carries one request, three
-- hours after the appointment ends: long enough that the visit is over,
-- close enough that it is still the day they remember.
--
-- Once. The dedupe key is the booking, a patient who has already rated is not
-- asked, and a request still sitting in the queue when they rate is deleted
-- rather than delivered.
--
-- Safe to re-run.
-- =============================================================================

create or replace function public.queue_review_requests()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  with finished as (
    select b.id,
           b.patient_id,
           d.name as doctor_name,
           public.appointment_starts_at(b.booked_date, b.end_time) as ends_at
    from public.bookings b
    join public."Doctors" d on d.id = b.doctor_id
    where b.patient_id is not null
      -- Nothing to review: one was called off, the other never happened.
      and b.status not in ('cancelled', 'no_show')
      -- Bounded backwards on purpose. Without it the first sweep after this
      -- deploys would ask every patient about every appointment they have
      -- ever had, which is how an app gets uninstalled.
      and b.booked_date between current_date - 3 and current_date
      and not exists (
        select 1 from public.doctor_reviews r where r.booking_id = b.id
      )
  ),
  inserted as (
    insert into public.notifications
      (user_id, kind, title, body, data, send_after, dedupe_key)
    select f.patient_id,
           'review_request',
           'كيف كانت زيارتك؟',
           'شاركنا رأيك في ' || coalesce(f.doctor_name, 'الطبيب')
             || '. تقييمك يساعد غيرك على الاختيار.',
           jsonb_build_object('booking_id', f.id, 'action', 'review'),
           -- Not the moment they walk out: a request that arrives while they
           -- are still paying at the desk is one more thing being asked of
           -- them in a place they want to leave.
           f.ends_at + interval '3 hours',
           'review:' || f.id
    from finished f
    on conflict (dedupe_key) do nothing
    returning 1
  )
  select count(*) into v_count from inserted;

  return v_count;
end;
$$;

revoke all on function public.queue_review_requests() from public;
grant execute on function public.queue_review_requests() to service_role;

-- -----------------------------------------------------------------------------
-- A request already answered is not sent.
--
-- The sweep will not write one for a booking that has a review, but a patient
-- who rates from the bookings screen before the queued request goes out would
-- still receive it. Being asked for something you have just given reads as an
-- app that was not listening.
-- -----------------------------------------------------------------------------
create or replace function public.clear_review_request()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.notifications
  where sent_at is null
    and kind = 'review_request'
    and (data ->> 'booking_id') = new.booking_id::text;

  return new;
end;
$$;

drop trigger if exists review_clears_its_request on public.doctor_reviews;
create trigger review_clears_its_request
  after insert on public.doctor_reviews
  for each row execute function public.clear_review_request();

revoke all on function public.clear_review_request() from public;
