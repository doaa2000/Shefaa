-- =============================================================================
-- The patient app admits only the accounts it created.
--
-- All three apps sign in through the same Supabase auth, so until now a doctor
-- could open the patient app with their dashboard login and a patient could
-- open the dashboard and be shown an empty one. Neither leaks anything -- the
-- policies are per-row and hold either way -- but one login that means two
-- different people is a question every later feature has to answer, and it
-- already produced one: a doctor tapping "delete account" in the patient app
-- would take their own dashboard access with them.
--
-- An account that was not created in the patient app is a doctor's or an
-- admin's. There is nothing else: every other auth user signed up through the
-- app itself.
--
-- Safe to re-run.
-- =============================================================================

create or replace function public.is_patient_account()
returns boolean
language sql
stable
-- definer: the caller must be able to ask this about themselves before the app
-- will let them in, and reading the doctor and admin tables to find out is not
-- something their own policies would allow.
security definer
set search_path = public
as $$
  select auth.uid() is not null
     and not exists (
       select 1 from public."Doctors" d where d.user_id = auth.uid()
     )
     and not exists (
       select 1 from public.admins a where a.id = auth.uid()
     );
$$;

revoke execute on function public.is_patient_account() from public;
grant execute on function public.is_patient_account() to authenticated;
