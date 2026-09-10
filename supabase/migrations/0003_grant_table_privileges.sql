-- =============================================================================
-- Grant table privileges to the Supabase roles.
--
-- PostgreSQL checks permissions in two layers:
--
--   1. GRANT       — may this role touch the table at all?
--   2. RLS policy  — which rows may it see or change?
--
-- 0000_base_schema.sql and 002_fix_rls_policies.sql set up layer 2 and left
-- layer 1 entirely to Supabase's default privileges. When those defaults do
-- not apply -- as happened here after the tables were dropped and recreated --
-- every query from the app fails with:
--
--   PostgrestException(message: permission denied for table specialties,
--                      code: 42501)
--
-- Note the difference in symptom: a row blocked by RLS comes back as an empty
-- result, never as an error. A 42501 is always a missing GRANT.
--
-- Safe to re-run.
-- =============================================================================

grant usage on schema public to anon, authenticated, service_role;

-- SELECT/INSERT/UPDATE/DELETE only -- deliberately NOT `grant all`, which
-- would include TRUNCATE. TRUNCATE is not subject to row level security, so
-- granting it would let any signed-in patient empty a table outright no matter
-- what the policies say.
grant select, insert, update, delete
  on all tables in schema public
  to authenticated;

grant select on all tables in schema public to anon;

-- Identity columns do not need this, but any serial column added later would.
grant usage, select on all sequences in schema public to anon, authenticated, service_role;

-- service_role runs behind the API and bypasses RLS by design; it is the role
-- an Edge Function uses to create a booking and its payment server-side.
grant all on all tables in schema public to service_role;

-- The same, for tables added from here on, so a new table is never invisible
-- to the app for this reason again.
alter default privileges in schema public
  grant select, insert, update, delete on tables to authenticated;

alter default privileges in schema public
  grant select on tables to anon;

alter default privileges in schema public
  grant all on tables to service_role;

alter default privileges in schema public
  grant usage, select on sequences to anon, authenticated, service_role;
