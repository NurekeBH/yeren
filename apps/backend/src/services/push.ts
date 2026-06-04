import { cert, getApps, initializeApp, type App } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import { env } from '../config/env.js';
import { query } from '../db/client.js';

/// Push-хабарламалар (Firebase Cloud Messaging, Admin SDK).
/// FCM конфигурацияланбаса (env жоқ) — no-op (тек логқа жазады).

const fcmReady = !!(env.FCM_PROJECT_ID && env.FCM_CLIENT_EMAIL && env.FCM_PRIVATE_KEY);

let _app: App | null = null;

function messaging() {
  if (!fcmReady) return null;
  if (!_app) {
    _app =
      getApps()[0] ??
      initializeApp({
        credential: cert({
          projectId: env.FCM_PROJECT_ID,
          clientEmail: env.FCM_CLIENT_EMAIL,
          // .env-те \n әріптік сақталады — нақты жоларалыққа айналдырамыз.
          privateKey: (env.FCM_PRIVATE_KEY ?? '').replace(/\\n/g, '\n'),
        }),
      });
  }
  return getMessaging(_app);
}

export type IntelPush = { id: string; text: string; impact: string };

/// Market Intel urgent жаңалығы туралы push (intel_on қосулы құрылғыларға).
export async function sendIntelPush(post: IntelPush): Promise<void> {
  const { rows } = await query<{ token: string }>(
    `select expo_push_token as token from notification_prefs
      where intel_on = true and expo_push_token is not null and expo_push_token <> ''`,
  );
  const tokens = rows.map((r) => r.token);
  const title = 'Market Intel';
  const body = post.text.length > 160 ? `${post.text.slice(0, 157)}…` : post.text;

  const m = messaging();
  if (!m || tokens.length === 0) {
    // eslint-disable-next-line no-console
    console.log(`[push:intel] (${m ? 'no recipients' : 'FCM not configured'}) "${title}: ${body}"`);
    return;
  }

  // FCM multicast лимиті — бір сұранысқа 500 токен.
  const invalid: string[] = [];
  let sent = 0;
  let failed = 0;
  for (let i = 0; i < tokens.length; i += 500) {
    const chunk = tokens.slice(i, i + 500);
    const res = await m.sendEachForMulticast({
      tokens: chunk,
      notification: { title, body },
      data: { type: 'intel', id: post.id, impact: post.impact },
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
    sent += res.successCount;
    failed += res.failureCount;
    res.responses.forEach((r, idx) => {
      if (!r.success) {
        const code = r.error?.code ?? '';
        if (
          code.includes('registration-token-not-registered') ||
          code.includes('invalid-argument') ||
          code.includes('invalid-registration-token')
        ) {
          invalid.push(chunk[idx]!);
        }
      }
    });
  }

  // Жарамсыз/ескірген токендерді тазалаймыз.
  if (invalid.length > 0) {
    await query(`update notification_prefs set expo_push_token = null where expo_push_token = any($1)`, [invalid]);
  }

  // eslint-disable-next-line no-console
  console.log(`[push:intel] sent=${sent} failed=${failed} cleaned=${invalid.length} "${title}: ${body}"`);
}
