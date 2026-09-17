-- =============================================================================
-- A doctor's telephone number is not public.
--
-- The policy on Doctors reads `using (true)`: every signed-in account may read
-- every column of every row. The patient app was also asking for every column,
-- which meant each patient's phone received every doctor's telephone number,
-- e-mail address, licence number and account id on every search -- none of it
-- ever drawn on a screen, all of it in the response.
--
-- Narrowing the app's queries stopped that happening by accident. It cannot
-- stop it on purpose: a request written by hand asks for whatever it likes,
-- and this one is worth writing. A competitor harvests every doctor's number
-- in a single call; a patient who learns the clinic's number books by
-- telephone from then on, and the platform never sees them again.
--
-- So the table stops being readable by patients at all, and what a patient is
-- allowed to know about a doctor becomes a view.
--
-- Three readers, three answers:
--
--   the owner       reads the table, everything, via is_admin()
--   the doctor      reads the table, their own row, via user_id = auth.uid()
--   everyone else   reads doctors_public, and cannot see the table
--
-- Safe to re-run.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- What a patient may know.
--
-- No status filter. A patient whose doctor was deactivated after they booked
-- still has a booking with a name on it, and hiding the row would empty their
-- own appointment list. The column is here so the listing queries can go on
-- excluding inactive doctors themselves.
-- -----------------------------------------------------------------------------
create or replace view public.doctors_public as
  select
    id,
    name,
    title,
    specialization,
    specialty_id,
    clinic_id,
    image,
    location,
    rating,
    consultation_fee,
    waiting_time,
    bio,
    status
  from public."Doctors";

comment on view public.doctors_public is
  'Doctors as a patient may see them. The table itself carries contact details and is readable only by the owner and by each doctor for their own row.';

-- Runs as its owner rather than its caller, which is the whole point: it is
-- the one door through the policy below. Stated rather than left to the
-- default, because a default that changes silently changes who can read what.
alter view public.doctors_public set (security_invoker = false);

revoke all on public.doctors_public from anon, authenticated;
grant select on public.doctors_public to authenticated;

-- -----------------------------------------------------------------------------
-- And the table closes.
--
-- ref_read_all is dropped rather than amended: the name said what it did, and
-- what it does now is different.
-- -----------------------------------------------------------------------------
drop policy if exists ref_read_all on public."Doctors";
drop policy if exists doctors_read_own_or_admin on public."Doctors";
create policy doctors_read_own_or_admin on public."Doctors"
  for select to authenticated
  using (is_admin() or user_id = auth.uid());

-- Nothing signed in as a patient has business reading it, and anon never had a
-- policy to read it under -- so the grant it was carrying was only ever going
-- to mislead whoever read it next.
revoke select on public."Doctors" from anon;
