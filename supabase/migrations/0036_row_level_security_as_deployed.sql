-- =============================================================================
-- Writing down the protection that is already there.
--
-- Row level security is switched on for Doctors, profiles, bookings and
-- payments in the live database, with fifteen policies between them. Not one of
-- those four tables is switched on by any migration in this repository, and
-- eleven of the policies are not written down anywhere either -- payments has
-- four and this repository described none of them.
--
-- The live database is not at risk. What is at risk is the second copy of it:
-- a staging project, a restore, a developer running the migrations on a fresh
-- Supabase instance. Every one of those would come up with these four tables
-- readable and writable by any signed-in account, and the app would work
-- perfectly, so nobody would notice.
--
-- This changes nothing where it already holds. It is a transcription of
-- pg_policies as it stands, so that the repository and the database say the
-- same thing.
--
-- Safe to re-run.
-- =============================================================================

alter table public."Doctors" enable row level security;
alter table public.profiles  enable row level security;
alter table public.bookings  enable row level security;
alter table public.payments  enable row level security;

-- -----------------------------------------------------------------------------
-- Doctors
--
-- Read by everyone signed in, because the patient app has to list them. What
-- that also exposes -- phone, e-mail, licence number -- is dealt with
-- separately; this migration only records the position, it does not argue with
-- it.
-- -----------------------------------------------------------------------------
drop policy if exists ref_read_all on public."Doctors";
create policy ref_read_all on public."Doctors"
  for select to authenticated
  using (true);

drop policy if exists doctors_self_update on public."Doctors";
create policy doctors_self_update on public."Doctors"
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists ref_admin_write on public."Doctors";
create policy ref_admin_write on public."Doctors"
  for all to authenticated
  using (is_admin())
  with check (is_admin());

-- -----------------------------------------------------------------------------
-- profiles
--
-- A patient sees their own. A doctor sees the patients who have booked with
-- them, and nobody else's -- which is what is_my_patient is for.
-- -----------------------------------------------------------------------------
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = auth.uid() or is_admin());

drop policy if exists profiles_select_my_patients on public.profiles;
create policy profiles_select_my_patients on public.profiles
  for select to authenticated
  using (is_my_patient(id));

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
  for insert to authenticated
  with check (id = auth.uid());

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid() or is_admin())
  with check (id = auth.uid() or is_admin());

drop policy if exists profiles_delete_admin on public.profiles;
create policy profiles_delete_admin on public.profiles
  for delete to authenticated
  using (is_admin());

-- -----------------------------------------------------------------------------
-- bookings
--
-- Two readers with different reasons: the patient it belongs to, and the
-- doctor it was made with. Separate policies rather than one disjunction,
-- because they are separate claims and either may change without the other.
-- -----------------------------------------------------------------------------
drop policy if exists bookings_select_own on public.bookings;
create policy bookings_select_own on public.bookings
  for select to authenticated
  using (patient_id = auth.uid() or is_admin());

drop policy if exists bookings_select_doctor on public.bookings;
create policy bookings_select_doctor on public.bookings
  for select to authenticated
  using (doctor_id = current_doctor_id());

drop policy if exists bookings_insert_own on public.bookings;
create policy bookings_insert_own on public.bookings
  for insert to authenticated
  with check (patient_id = auth.uid());

drop policy if exists bookings_update_own on public.bookings;
create policy bookings_update_own on public.bookings
  for update to authenticated
  using (patient_id = auth.uid() or is_admin())
  with check (patient_id = auth.uid() or is_admin());

drop policy if exists bookings_update_doctor on public.bookings;
create policy bookings_update_doctor on public.bookings
  for update to authenticated
  using (doctor_id = current_doctor_id())
  with check (doctor_id = current_doctor_id());

drop policy if exists bookings_delete_admin on public.bookings;
create policy bookings_delete_admin on public.bookings
  for delete to authenticated
  using (is_admin());

-- -----------------------------------------------------------------------------
-- payments
--
-- The patient sees their own. Everything else about money is the owner's, or
-- goes through a function that checks who is asking -- which is why there is no
-- doctor policy here and the doctor's payments page is an rpc.
-- -----------------------------------------------------------------------------
drop policy if exists payments_select_own on public.payments;
create policy payments_select_own on public.payments
  for select to authenticated
  using (patient_id = auth.uid() or is_admin());

drop policy if exists payments_insert_own on public.payments;
create policy payments_insert_own on public.payments
  for insert to authenticated
  with check (patient_id = auth.uid());

drop policy if exists payments_write_admin on public.payments;
create policy payments_write_admin on public.payments
  for update to authenticated
  using (is_admin())
  with check (is_admin());

drop policy if exists payments_delete_admin on public.payments;
create policy payments_delete_admin on public.payments
  for delete to authenticated
  using (is_admin());
