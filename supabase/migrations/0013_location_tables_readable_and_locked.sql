-- =============================================================================
-- The location hierarchy: readable by everyone, writable by the admin only.
--
-- Two things brought this on.
--
-- 1. The app is about to read Governorates, Cities and Clinics for the city
--    picker. If row level security is on with no select policy, those reads
--    come back as zero rows -- not as an error -- and the picker would look
--    broken for no visible reason.
--
-- 2. 0003 granted insert, update and delete on every table in the schema to
--    `authenticated`. On a table with row level security switched off, that
--    grant is the whole answer: any signed-in patient could rename a clinic or
--    delete a governorate. Turning security on with a read-only policy for
--    patients is what closes that.
--
-- Safe to re-run.
-- =============================================================================

do $$
declare
  t text;
begin
  foreach t in array array['Governorates', 'Cities', 'Clinics'] loop
    if to_regclass(format('public.%I', t)) is null then
      raise notice 'table public.% not present -- skipping', t;
      continue;
    end if;

    execute format('alter table public.%I enable row level security', t);

    -- Where the clinics are is not private. A patient has to be able to read
    -- this before signing in, or the picker is empty on the signup screen.
    execute format('drop policy if exists %I on public.%I', t || '_read', t);
    execute format($p$
      create policy %I on public.%I
        for select to anon, authenticated
        using (true)
    $p$, t || '_read', t);

    -- Everything else is the admin panel's, and nobody else's.
    execute format('drop policy if exists %I on public.%I', t || '_admin_write', t);
    execute format($p$
      create policy %I on public.%I
        for all to authenticated
        using (public.is_admin()) with check (public.is_admin())
    $p$, t || '_admin_write', t);
  end loop;
end $$;

-- Speeds up the two lookups the picker makes: the cities of a governorate, and
-- the clinics of a city.
create index if not exists cities_governorate_idx
  on public."Cities" (governorate_id);

create index if not exists clinics_city_idx
  on public."Clinics" (city_id);
