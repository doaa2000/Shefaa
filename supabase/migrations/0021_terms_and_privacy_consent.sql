-- =============================================================================
-- Signup also records the terms and the privacy notice.
--
-- 0018 built the consents table and taught handle_new_user to record the
-- health-data consent from signup metadata. The registration form now carries
-- a second, separate tick for the terms and the privacy notice, and those two
-- have to be recorded the same way and for the same reason: after signUp there
-- may be no session at all, so the app cannot insert the rows itself.
--
-- Three kinds, not one row covering everything: 'health_data' was already
-- allowed by the table's CHECK, and so were 'terms' and 'privacy'. Nothing
-- about the table changes here -- only the trigger learns to fill it.
--
-- Safe to re-run.
-- =============================================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  begin
    insert into public.profiles (id, name, phone, gender, birth_date)
    values (
      new.id,
      coalesce(
        nullif(new.raw_user_meta_data ->> 'name', ''),
        split_part(new.email, '@', 1)
      ),
      nullif(new.raw_user_meta_data ->> 'phone', ''),
      -- profiles.gender has a CHECK; anything else is dropped rather than
      -- allowed to fail the insert.
      case
        when new.raw_user_meta_data ->> 'gender' in ('male', 'female')
        then new.raw_user_meta_data ->> 'gender'
      end,
      -- Same for the date: validated by shape before it is cast, because a
      -- cast that throws here would throw inside signup.
      case
        when new.raw_user_meta_data ->> 'birth_date' ~ '^\d{4}-\d{2}-\d{2}$'
        then (new.raw_user_meta_data ->> 'birth_date')::date
      end
    )
    on conflict (id) do nothing;

  exception when others then
    -- A trigger on auth.users that raises makes the signup itself fail. No
    -- detail on a profile is worth refusing to create the account over, so
    -- fall back to the row this trigger has always written and let the person
    -- fix the rest from the profile screen.
    insert into public.profiles (id, name)
    values (new.id, split_part(new.email, '@', 1))
    on conflict (id) do nothing;
  end;

  -- Separately, and just as carefully: a consent nobody can record is still
  -- not worth failing a signup over. The app asks again on the next launch
  -- when the row is missing, which is the same path every patient who
  -- registered before this migration takes.
  --
  -- One insert for all three kinds, from whichever versions the signup
  -- carried. A missing key inserts nothing for that kind rather than a row
  -- saying the patient agreed to nothing in particular.
  begin
    insert into public.consents (user_id, kind, version)
    select new.id, kind, version
    from (
      values
        ('health_data',
         nullif(new.raw_user_meta_data ->> 'health_consent_version', '')),
        ('terms',
         nullif(new.raw_user_meta_data ->> 'terms_version', '')),
        ('privacy',
         nullif(new.raw_user_meta_data ->> 'privacy_version', ''))
    ) as t (kind, version)
    where version is not null
    on conflict (user_id, kind, version) do nothing;
  exception when others then
    null;
  end;

  return new;
end;
$$;
