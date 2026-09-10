#!/usr/bin/env bash
#
# Regenerates supabase/RESTORE_ALL.sql — the whole database in one paste, for
# the Supabase SQL Editor.
#
# RESTORE_ALL.sql is GENERATED. Never edit it by hand: change the sources below
# and re-run this script, or the copy and the sources drift apart.
#
#   ./scripts/build-restore.sh
#
# Part 3 lives in the Shefaa_Admin_Panel repo. If that repo is not a sibling of
# this one, pass its path:
#
#   ./scripts/build-restore.sh ../Shefaa_Admin_Panel
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADMIN_REPO="${1:-$REPO_ROOT/../Shefaa_Admin_Panel}"

SCHEMA="$REPO_ROOT/supabase/migrations/0000_base_schema.sql"
SEED="$REPO_ROOT/supabase/seed.sql"
RLS="$ADMIN_REPO/supabase/migrations/002_fix_rls_policies.sql"
OUT="$REPO_ROOT/supabase/RESTORE_ALL.sql"

for f in "$SCHEMA" "$SEED"; do
  [[ -f "$f" ]] || { echo "error: missing $f" >&2; exit 1; }
done

if [[ ! -f "$RLS" ]]; then
  echo "error: cannot find the RLS migration at $RLS" >&2
  echo "  pass the Shefaa_Admin_Panel path: ./scripts/build-restore.sh /path/to/Shefaa_Admin_Panel" >&2
  exit 1
fi

{
  cat <<'HEADER'
-- =============================================================================
-- Shefaa — full restore, in one paste.
--
-- Supabase Dashboard -> SQL Editor -> New query -> paste all of this -> Run.
--
-- GENERATED FILE — do not edit. Run ./scripts/build-restore.sh instead.
-- Sources:
--   supabase/migrations/0000_base_schema.sql
--   supabase/seed.sql
--   ../Shefaa_Admin_Panel/supabase/migrations/002_fix_rls_policies.sql
--
-- Safe to re-run: every statement is if-not-exists / on-conflict-do-nothing.
-- Two manual steps follow at the bottom.
-- =============================================================================

HEADER
  echo "-- ############## 1 of 3 — SCHEMA ##############"
  cat "$SCHEMA"
  echo
  echo "-- ############## 2 of 3 — REFERENCE DATA ##############"
  cat "$SEED"
  echo
  echo "-- ############## 3 of 3 — SECURITY POLICIES ##############"
  cat "$RLS"
  echo
  cat <<'FOOTER'
-- =============================================================================
-- AFTER RUNNING THE ABOVE — two steps that need your own values.
--
--  1. Create your account:
--     Dashboard -> Authentication -> Users -> Add user
--     Tick "Auto Confirm User". A profiles row is created by trigger.
--
--  2. Make yourself an admin (without this the admin panel reads empty,
--     which is the policies working, not a bug):
--
--       insert into public.admins (id, name)
--       select id, 'Owner' from auth.users where email = 'YOUR_EMAIL_HERE'
--       on conflict (id) do nothing;
--
--  Then check:  10 specialties · 14 doctors · ~2304 slots · 1 admin
-- =============================================================================
FOOTER
} > "$OUT"

echo "Wrote $OUT ($(wc -l < "$OUT") lines)"
