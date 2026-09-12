-- =============================================================================
-- Registering with email confirmation on lost the patient's details.
--
-- The app writes the name, phone, gender and birth date to `profiles` itself,
-- straight after signUp. That only works when signUp hands back a session --
-- which it does only while email confirmation is off. Turn confirmation on and
-- there is no session, the write fails on row level security, and the patient
-- is left with whatever this trigger put there: a name guessed from the part
-- of their address before the @.
--
-- That is why confirmation is still off, and confirmation being off is what the
-- warning in 0005 is about: anyone who knows a doctor's address can sign up
-- with it and take over their dashboard. This is the half that has to be fixed
-- before that one can be closed.
--
-- So the details travel with the signup itself, as user metadata, and this
-- trigger writes them. It runs as the definer inside the signup transaction,
-- before any session exists, so it works either way.
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

  return new;
end;
$$;
