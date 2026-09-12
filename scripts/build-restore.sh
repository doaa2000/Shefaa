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

SEED="$REPO_ROOT/supabase/seed.sql"
ADMIN_BASE="$ADMIN_REPO/supabase/migrations/001_admin_integration.sql"
RLS="$ADMIN_REPO/supabase/migrations/002_fix_rls_policies.sql"
OUT="$REPO_ROOT/supabase/RESTORE_ALL.sql"

[[ -f "$SEED" ]] || { echo "error: missing $SEED" >&2; exit 1; }

# Every migration, in filename order, so a new one is picked up without
# editing this script -- the previous version named 0000 alone and silently
# left 0004's tables out, which the seed then failed to insert into.
mapfile -t MIGRATIONS < <(find "$REPO_ROOT/supabase/migrations" -name '*.sql' | sort)
[[ ${#MIGRATIONS[@]} -gt 0 ]] || { echo "error: no migrations found" >&2; exit 1; }

# 001 was left out until it cost something: a function defined only there was
# missing from every rebuilt database, so a check against one reported it
# missing from the live database too, which it was not.
if [[ ! -f "$ADMIN_BASE" ]]; then
  echo "error: cannot find the admin base migration at $ADMIN_BASE" >&2
  exit 1
fi

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
--   supabase/migrations/*.sql   (in order)
--   supabase/seed.sql
--   ../Shefaa_Admin_Panel/supabase/migrations/001_admin_integration.sql
--   ../Shefaa_Admin_Panel/supabase/migrations/002_fix_rls_policies.sql
--
-- Safe to re-run: every statement is if-not-exists / on-conflict-do-nothing.
-- Two manual steps follow at the bottom.
-- =============================================================================

HEADER
  echo "-- ############## 1 of 3 — SCHEMA ##############"
  # The admin panel's baseline is additive -- it expects the app's tables to be
  # there already -- so it goes after 0000 and before the rest. Before 0000 it
  # fails on the first table it touches; after everything, it would put back the
  # older definitions that later migrations here deliberately replace.
  for m in "${MIGRATIONS[@]}"; do
    echo
    echo "-- ---- $(basename "$m") ----"
    cat "$m"
    if [[ "$(basename "$m")" == 0000_* ]]; then
      echo
      echo "-- ---- 001_admin_integration.sql (admin panel) ----"
      cat "$ADMIN_BASE"
    fi
  done
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
