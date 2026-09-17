-- =============================================================================
-- Where to send a notification.
--
-- Firebase gives every installation of the app a token, and a message is sent
-- to a token, not to a person. So before anything can be sent at all, there
-- has to be a row somewhere saying which tokens belong to which account. This
-- is that row, and nothing else: no message text, no schedule, no history.
-- Those come with the senders.
--
-- The token is the primary key rather than (user_id, token), because a token
-- identifies an installation and an installation can change hands. A patient
-- signs out and a relative signs in on the same phone; Firebase hands the app
-- the same token, and it must now point at the new account and stop pointing
-- at the old one. With the token as the key, that is one upsert. With a
-- composite key it is two rows, and the first one keeps receiving the second
-- one's appointments.
--
-- Writes go through register_device_token / unregister_device_token rather
-- than through the table, for that same handover: the row being replaced
-- belongs to somebody else, so no policy written in terms of the caller can
-- allow the update without also allowing a patient to hijack a token they
-- guessed. The functions are the narrow opening -- they only ever write the
-- caller's own id, and the token they write is one the caller's own device
-- handed them.
--
-- Safe to re-run.
-- =============================================================================

create table if not exists public.device_tokens (
  token       text primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  platform    text not null check (platform in ('android', 'ios', 'web')),
  created_at  timestamptz not null default now(),
  -- Touched on every registration. Firebase drops tokens that have been
  -- unreachable for a long time, and a sender that keeps a row it has not seen
  -- in months is a sender wasting a request on every notification forever.
  updated_at  timestamptz not null default now()
);

create index if not exists device_tokens_user_idx
  on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

-- No policy, deliberately. Every write is a function call below, and the only
-- reader is the sender, which runs with the service role and is not subject to
-- row level security. A patient has no reason to read the list of devices --
-- not even their own -- and a table with no policy is the clearest way to say
-- so.
revoke all on public.device_tokens from anon, authenticated;

-- -----------------------------------------------------------------------------
-- register_device_token -- called after sign-in and whenever Firebase rotates
-- the token.
-- -----------------------------------------------------------------------------
create or replace function public.register_device_token(
  p_token    text,
  p_platform text
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not signed in' using hint = 'auth_required';
  end if;

  if p_token is null or length(trim(p_token)) = 0 then
    raise exception 'empty token' using hint = 'token_required';
  end if;

  insert into public.device_tokens (token, user_id, platform)
  values (trim(p_token), auth.uid(), p_platform)
  on conflict (token) do update
    set user_id    = excluded.user_id,
        platform   = excluded.platform,
        updated_at = now();
end;
$$;

-- -----------------------------------------------------------------------------
-- unregister_device_token -- called before sign-out.
--
-- Scoped to the caller: signing out of one account must not silence a token
-- that has since been claimed by another. If the row has already moved on,
-- this deletes nothing, which is the correct outcome.
-- -----------------------------------------------------------------------------
create or replace function public.unregister_device_token(
  p_token text
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.device_tokens
  where token = trim(p_token)
    and user_id = auth.uid();
end;
$$;

revoke all on function public.register_device_token(text, text) from public;
revoke all on function public.unregister_device_token(text) from public;
grant execute on function public.register_device_token(text, text) to authenticated;
grant execute on function public.unregister_device_token(text) to authenticated;
