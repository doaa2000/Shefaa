#!/usr/bin/env bash
#
# Shefaa — database backup.
#
# The project is on the Supabase Free plan, which has no automatic backups.
# This script is the backup. Run it on a schedule (cron, or a GitHub Action)
# and keep the output somewhere that is not the Supabase project.
#
# Usage:
#   export SUPABASE_DB_URL='postgresql://postgres:PASSWORD@db.<ref>.supabase.co:5432/postgres'
#   ./scripts/backup.sh [output-dir]        # default: ./backups
#
# Get the connection string from:
#   Supabase Dashboard -> Project Settings -> Database -> Connection string -> URI
#
# Restore a dump with:
#   psql "$SUPABASE_DB_URL" -f backups/shefaa-YYYY-MM-DD-HHMM.sql
#
set -euo pipefail

if [[ -z "${SUPABASE_DB_URL:-}" ]]; then
  echo "error: SUPABASE_DB_URL is not set." >&2
  echo "  export SUPABASE_DB_URL='postgresql://postgres:PASSWORD@db.<ref>.supabase.co:5432/postgres'" >&2
  exit 1
fi

command -v pg_dump >/dev/null || { echo "error: pg_dump not found. Install the postgresql client." >&2; exit 1; }

OUT_DIR="${1:-./backups}"
mkdir -p "$OUT_DIR"

STAMP="$(date -u +%Y-%m-%d-%H%M)"
FILE="$OUT_DIR/shefaa-$STAMP.sql"

echo "Dumping to $FILE ..."

# --clean --if-exists so the dump can be replayed onto a non-empty database.
# The auth schema is included: it holds the user accounts, which are the part
# that cannot be rebuilt from the repo.
pg_dump "$SUPABASE_DB_URL" \
  --clean --if-exists --no-owner --no-privileges \
  --schema=public --schema=auth \
  --file="$FILE"

gzip -f "$FILE"
echo "Wrote $FILE.gz ($(du -h "$FILE.gz" | cut -f1))"

# Keep the 30 most recent dumps.
ls -1t "$OUT_DIR"/shefaa-*.sql.gz 2>/dev/null | tail -n +31 | xargs -r rm --
echo "Done. $(ls -1 "$OUT_DIR"/shefaa-*.sql.gz 2>/dev/null | wc -l) backup(s) retained."
