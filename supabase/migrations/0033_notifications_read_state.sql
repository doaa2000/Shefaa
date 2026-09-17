-- =============================================================================
-- Letting the doctor read their own notifications, and mark them read.
--
-- The dashboard has had a notifications page since before there was anything
-- behind it: it queried a table that did not exist, with columns that were
-- never designed. 0031 created a table of that name for the sender's benefit,
-- which changed the page's failure without fixing it.
--
-- The queue turns out to be exactly the right list. It already holds the title
-- and the body that were sent, addressed to a user, in order -- and it already
-- lets that user read their own rows. The only thing a list needs that a queue
-- does not is a record of what has been looked at.
--
-- Deleting is deliberately not offered. The row is also the delivery record --
-- attempts, last_error, sent_at -- and it is what a dedupe key points at: drop
-- the row for an unsent reminder and the next sweep writes it again, so
-- "clear" would mean "send it to the patient twice".
--
-- Safe to re-run.
-- =============================================================================

alter table public.notifications
  add column if not exists read_at timestamptz;

-- The list's own query: this person's delivered messages, newest first.
create index if not exists notifications_unread_idx
  on public.notifications (user_id)
  where read_at is null;

-- -----------------------------------------------------------------------------
-- Marking read.
--
-- Through functions rather than an update policy, because the table has none
-- by design: everything that writes to it is the sender or a trigger. A policy
-- narrow enough to allow only this would still be a second door into a table
-- that is meant to have one.
--
-- Both are scoped to auth.uid(), so the worst a caller can do with another
-- person's id is nothing at all.
-- -----------------------------------------------------------------------------
create or replace function public.mark_notification_read(p_id bigint)
returns void
language sql
security definer
set search_path = public
as $$
  update public.notifications
     set read_at = coalesce(read_at, now())
   where id = p_id
     and user_id = auth.uid();
$$;

create or replace function public.mark_all_notifications_read()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  update public.notifications
     set read_at = now()
   where user_id = auth.uid()
     and read_at is null
     -- Nothing that has not gone out yet: a reminder queued for tomorrow is
     -- not something anyone has seen, and marking it read would hide it from
     -- the list on the day it matters.
     and sent_at is not null;

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke all on function public.mark_notification_read(bigint) from public;
revoke all on function public.mark_all_notifications_read() from public;
grant execute on function public.mark_notification_read(bigint) to authenticated;
grant execute on function public.mark_all_notifications_read() to authenticated;
