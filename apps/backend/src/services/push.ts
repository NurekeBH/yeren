import { env } from '../config/env.js';
import { query } from '../db/client.js';

/// Push-хабарламалар (Firebase Cloud Messaging).
/// FCM конфигурацияланбаса — no-op (тек логқа жазады).
/// Нақты жеткізу үшін: firebase-admin SDK немесе FCM HTTP v1 API + service account.

const fcmReady = !!(env.FCM_PROJECT_ID && env.FCM_CLIENT_EMAIL && env.FCM_PRIVATE_KEY);

export type IntelPush = { id: string; text: string; impact: string };

/// Market Intel urgent жаңалығы туралы push (скриншоттағыдай «Latest …»).
export async function sendIntelPush(post: IntelPush): Promise<void> {
  // intel_on қосулы + push токені бар пайдаланушылар
  const { rows } = await query<{ token: string }>(
    `select expo_push_token as token from notification_prefs
      where intel_on = true and expo_push_token is not null and expo_push_token <> ''`,
  );
  const tokens = rows.map((r) => r.token);
  const title = 'Latest';
  const body = post.text.length > 160 ? `${post.text.slice(0, 157)}…` : post.text;

  if (!fcmReady || tokens.length === 0) {
    // eslint-disable-next-line no-console
    console.log(`[push:intel] (${fcmReady ? 'no recipients' : 'FCM not configured'}) "${title}: ${body}"`);
    return;
  }

  // TODO: FCM HTTP v1 — POST https://fcm.googleapis.com/v1/projects/<id>/messages:send
  // OAuth2 (service account) + { message: { token, notification: { title, body }, data: { type: 'intel', id } } }
  // eslint-disable-next-line no-console
  console.log(`[push:intel] would send to ${tokens.length} devices: "${title}: ${body}"`);
}
