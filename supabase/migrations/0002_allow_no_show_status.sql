-- =============================================================================
-- Allow 'no_show' on bookings.status.
--
-- The doctor dashboard offers "No show" as a status (its appointment.labels.ts
-- lists it alongside completed/cancelled) and calls updateStatus with it, but
-- the CHECK constraint in 0000_base_schema.sql did not permit the value, so the
-- action would have failed against the database with a constraint violation.
--
-- The distinction also matters for revenue: commission is owed on a visit that
-- happened, and a booking the patient never showed up for is not that. Without
-- a separate value both collapse into 'cancelled' and the history needed to
-- bill a clinic later is lost.
--
-- Run this only if you already applied 0000_base_schema.sql. Fresh installs
-- pick the value up from the corrected 0000.
-- =============================================================================

alter table public.bookings drop constraint if exists bookings_status_check;

alter table public.bookings add constraint bookings_status_check
  check (status in ('pending', 'confirmed', 'completed', 'cancelled', 'no_show'));
