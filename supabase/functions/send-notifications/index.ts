// Drains the notification queue into Firebase.
//
// Runs on a schedule, once a minute. Everything it needs to decide is already
// in the database: which messages are due, who they are for, and which devices
// those people are holding. It adds nothing of its own except the delivery.
//
// Deployed and scheduled per the README beside this file.

import { createClient } from "jsr:@supabase/supabase-js@2";
import * as jose from "npm:jose@5";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// What the scheduler presents to prove it is the scheduler. Its own secret
// rather than the service role key, for two reasons: the key the platform
// injects here is the legacy JWT one, and a project whose dashboard hands out
// the newer `sb_secret_` format would never match it; and the schedule is
// stored in cron.job, so whatever it carries is a credential sitting in a
// table -- better that it be one that can do nothing but start a sweep.
//
// The service role key is still accepted so that an existing schedule keeps
// working while it is being moved over.
const CRON_SECRET = Deno.env.get("CRON_SECRET") ?? "";

const FCM_PROJECT_ID = Deno.env.get("FCM_PROJECT_ID")!;
const FCM_CLIENT_EMAIL = Deno.env.get("FCM_CLIENT_EMAIL")!;
// Stored with the newlines escaped, because that is how it comes out of the
// service-account JSON and how a secret survives being pasted into a form.
const FCM_PRIVATE_KEY = (Deno.env.get("FCM_PRIVATE_KEY") ?? "").replace(
  /\\n/g,
  "\n",
);

const FCM_ENDPOINT =
  `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`;

/** How many messages one sweep will take. A minute is plenty for this many. */
const BATCH = 200;

interface QueuedNotification {
  id: number;
  user_id: string;
  kind: string;
  title: string;
  body: string;
  data: Record<string, unknown> | null;
}

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

// -----------------------------------------------------------------------------
// Google's access token.
//
// Held between invocations for as long as the isolate lives, because minting it
// costs a signature and a round trip and it is good for an hour. Retired a
// minute early so a token can never expire between the check and the send.
// -----------------------------------------------------------------------------
let cachedToken: { value: string; expiresAt: number } | null = null;

async function accessToken(): Promise<string> {
  const now = Date.now();
  if (cachedToken && cachedToken.expiresAt > now + 60_000) {
    return cachedToken.value;
  }

  const key = await jose.importPKCS8(FCM_PRIVATE_KEY, "RS256");
  const assertion = await new jose.SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256" })
    .setIssuer(FCM_CLIENT_EMAIL)
    .setSubject(FCM_CLIENT_EMAIL)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt()
    .setExpirationTime("1h")
    .sign(key);

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  if (!response.ok) {
    throw new Error(`google token: ${response.status} ${await response.text()}`);
  }

  const payload = await response.json() as {
    access_token: string;
    expires_in: number;
  };

  cachedToken = {
    value: payload.access_token,
    expiresAt: now + payload.expires_in * 1000,
  };
  return cachedToken.value;
}

// -----------------------------------------------------------------------------
// One message to one device.
// -----------------------------------------------------------------------------

/** Firebase requires every value in the data payload to be a string. */
function stringifyValues(
  data: Record<string, unknown> | null,
): Record<string, string> {
  const out: Record<string, string> = {};
  for (const [key, value] of Object.entries(data ?? {})) {
    if (value !== null && value !== undefined) out[key] = String(value);
  }
  return out;
}

type SendOutcome =
  | { ok: true }
  | { ok: false; error: string; tokenIsDead: boolean };

async function sendToDevice(
  bearer: string,
  token: string,
  notification: QueuedNotification,
): Promise<SendOutcome> {
  const response = await fetch(FCM_ENDPOINT, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${bearer}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token,
        notification: { title: notification.title, body: notification.body },
        data: {
          ...stringifyValues(notification.data),
          kind: notification.kind,
        },
        android: {
          // These are appointments. A message that waits for the phone to come
          // out of standby is a message that arrives after the appointment.
          priority: "high",
          notification: { sound: "default" },
        },
        apns: { payload: { aps: { sound: "default" } } },
      },
    }),
  });

  if (response.ok) return { ok: true };

  const text = await response.text();

  // A token Firebase no longer recognises is not a failure to retry -- the app
  // was uninstalled, or the token was replaced. Deleting it is the only thing
  // that stops us paying for that device on every notification from now on.
  const tokenIsDead = response.status === 404 ||
    (response.status === 400 && text.includes("INVALID_ARGUMENT")) ||
    text.includes("UNREGISTERED");

  return { ok: false, error: `${response.status} ${text.slice(0, 200)}`, tokenIsDead };
}

// -----------------------------------------------------------------------------

async function sweep(): Promise<Record<string, number>> {
  // Reminders are written here rather than on a schedule of their own. They
  // are due long before they are sent -- a day, an hour -- so a minute's
  // latency in writing them is nothing, and a second schedule would be a
  // second thing to configure, to forget, and to find broken later.
  //
  // Idempotent: each reminder carries a dedupe key made from its booking, so
  // this writes nothing on the sweeps in between.
  const { data: queued, error: queueError } = await supabase
    .rpc("queue_appointment_reminders");

  // Not fatal. Whatever is already in the queue should still go out, and the
  // next sweep is a minute away.
  if (queueError) console.error("queue reminders:", queueError.message);

  const { data: claimed, error: claimError } = await supabase
    .rpc("claim_due_notifications", { p_limit: BATCH });

  if (claimError) throw new Error(`claim: ${claimError.message}`);

  const reminders = typeof queued === "number" ? queued : 0;

  const messages = (claimed ?? []) as QueuedNotification[];
  if (messages.length === 0) {
    return { reminders, claimed: 0, sent: 0, failed: 0, pruned: 0 };
  }

  const recipients = [...new Set(messages.map((m) => m.user_id))];

  const { data: rows, error: tokenError } = await supabase
    .from("device_tokens")
    .select("user_id, token")
    .in("user_id", recipients);

  if (tokenError) throw new Error(`tokens: ${tokenError.message}`);

  const tokensByUser = new Map<string, string[]>();
  for (const row of (rows ?? []) as { user_id: string; token: string }[]) {
    const list = tokensByUser.get(row.user_id) ?? [];
    list.push(row.token);
    tokensByUser.set(row.user_id, list);
  }

  const bearer = await accessToken();
  const dead = new Set<string>();
  let sent = 0;
  let failed = 0;

  for (const message of messages) {
    const tokens = tokensByUser.get(message.user_id) ?? [];

    if (tokens.length === 0) {
      // Not an error worth shouting about: this person has never opened the
      // app on a phone, or refused notifications. It ages out of the queue on
      // its own after five sweeps.
      failed++;
      await supabase.rpc("mark_notification_failed", {
        p_id: message.id,
        p_error: "no_device",
      });
      continue;
    }

    const outcomes = await Promise.all(
      tokens.map((token) => sendToDevice(bearer, token, message)),
    );

    outcomes.forEach((outcome, index) => {
      if (!outcome.ok && outcome.tokenIsDead) dead.add(tokens[index]);
    });

    // One phone reached is the message delivered. A patient with a dead second
    // device should not be told twice tomorrow that nothing arrived.
    if (outcomes.some((outcome) => outcome.ok)) {
      sent++;
      await supabase.rpc("mark_notification_sent", { p_id: message.id });
    } else {
      failed++;
      const first = outcomes.find((outcome) => !outcome.ok);
      await supabase.rpc("mark_notification_failed", {
        p_id: message.id,
        p_error: first && !first.ok ? first.error : "unknown",
      });
    }
  }

  if (dead.size > 0) {
    await supabase.from("device_tokens").delete().in("token", [...dead]);
  }

  return { reminders, claimed: messages.length, sent, failed, pruned: dead.size };
}

/** Constant-time, so a wrong secret cannot be found one character at a time. */
function presentedSecretIsValid(presented: string): boolean {
  const accepted = [CRON_SECRET, SERVICE_ROLE_KEY].filter((value) =>
    value.length > 0
  );

  let valid = false;
  for (const expected of accepted) {
    let difference = presented.length ^ expected.length;
    for (let i = 0; i < presented.length; i++) {
      difference |= presented.charCodeAt(i) ^ expected.charCodeAt(i % expected.length);
    }
    valid = valid || difference === 0;
  }
  return valid;
}

Deno.serve(async (request: Request) => {
  // Only the scheduler. The platform's own JWT check would also let any
  // signed-in patient set a sweep running, which is not dangerous but is not
  // theirs to do either.
  const header = request.headers.get("Authorization") ?? "";
  if (!presentedSecretIsValid(header.replace(/^Bearer\s+/i, ""))) {
    return new Response("forbidden", { status: 403 });
  }

  try {
    const result = await sweep();
    return Response.json(result);
  } catch (error) {
    console.error("send-notifications", error);
    return Response.json(
      { error: error instanceof Error ? error.message : String(error) },
      { status: 500 },
    );
  }
});
