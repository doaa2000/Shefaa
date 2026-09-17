# send-notifications

Drains `public.notifications` into Firebase Cloud Messaging. Runs once a
minute; each sweep claims what is due, sends it to every device registered to
the recipient, and marks the row.

Nothing here holds message text or decides who to tell. Producers write rows
(see `0031_notification_outbox.sql`); this only delivers them.

## Setting it up

Everything below is done once, in the Supabase project. None of it belongs in
this repository -- the keys are secrets.

### 1. Extensions

In the dashboard, Database -> Extensions, enable:

- `pg_cron` -- runs the sweep on a schedule
- `pg_net` -- lets the schedule make the HTTP call

### 2. A Firebase service account

Firebase console -> Project settings -> Service accounts -> **Generate new
private key**. The JSON it downloads holds three values this function needs:
`project_id`, `client_email` and `private_key`.

It is a credential for the whole Firebase project. Do not commit it.

### 3. Secrets

```
supabase secrets set \
  FCM_PROJECT_ID="<project_id from the JSON>" \
  FCM_CLIENT_EMAIL="<client_email from the JSON>" \
  FCM_PRIVATE_KEY="<private_key from the JSON, newlines left as \n>"
```

`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are injected by the platform;
they do not need setting.

### 4. Deploy

```
supabase functions deploy send-notifications
```

### 5. The schedule

Run once in the SQL editor, with the two placeholders filled in. The project
ref is in the function's URL; the service role key is under Settings -> API.

```sql
select cron.schedule(
  'send-notifications',
  '* * * * *',
  $$
  select net.http_post(
    url     := 'https://<project-ref>.supabase.co/functions/v1/send-notifications',
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer <service-role-key>'
    ),
    body    := '{}'::jsonb
  );
  $$
);
```

That key ends up stored in `cron.job`, which only the database owner can read.
Moving it into Supabase Vault and reading it back in the job body is the
tidier arrangement once there is a reason to rotate it.

To stop the sweep: `select cron.unschedule('send-notifications');`

## Checking on it

```sql
-- Anything stuck?
select kind, attempts, last_error, created_at
from notifications
where sent_at is null and attempts > 0
order by created_at desc
limit 20;

-- Did the last sweeps run?
select status, start_time, return_message
from cron.job_run_details
where jobid = (select jobid from cron.job where jobname = 'send-notifications')
order by start_time desc
limit 10;
```

`last_error = 'no_device'` is not a fault: that person has no phone registered
-- never opened the app, or refused notifications. The row ages out of the
queue after five sweeps.
