-- =============================================================================
-- Cancelling is open until the appointment itself.
--
-- There was an hour's notice: cancel before it, and after it the button went.
-- That made sense while a late cancellation still cost the doctor a
-- commission, because the deadline was what the charge hung on. 0034 removed
-- the charge -- a doctor who saw nobody collects nothing, so the platform
-- takes no share -- and the deadline was left standing with nothing behind it.
--
-- What it did in the meantime was stop a patient doing the right thing. A
-- patient who knows at half past four that they cannot make five o'clock could
-- not give the place back; it sat held until the appointment passed, while
-- somebody else could have taken it. The report-absence button existed only to
-- work around that, which is a strange thing for a system to need.
--
-- So: no notice period. The deadline becomes the appointment itself, which is
-- exactly what a notice of zero already computes -- booking_cancellable_until
-- subtracts it from the start time, and the guard already refuses a
-- cancellation once that moment has passed. Nothing new to enforce.
--
-- The report-absence path stays as it is. It refuses while cancelling is still
-- possible, so with no notice it can never fire, and the app's button never
-- appears -- but restoring a notice is one update to this row, and everything
-- comes back with it.
--
-- Safe to re-run.
-- =============================================================================

update public.platform_settings
   set cancellation_notice = interval '0'
 where id = 1;

comment on column public.platform_settings.cancellation_notice is
  'How long before the appointment cancelling closes. Zero means it stays open until the appointment starts, which is the current policy.';
