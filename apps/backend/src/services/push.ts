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

export type PushPayload = {
  title: string;
  body: string;
  data?: Record<string, string>;
};

/// Берілген токендерге push жіберу (500-дік чанк, жарамсыз токендерді тазалау).
export async function sendPushToTokens(tokens: string[], payload: PushPayload): Promise<void> {
  const uniq = [...new Set(tokens.filter((t) => t && t.length > 0))];
  const m = messaging();
  if (!m || uniq.length === 0) {
    // eslint-disable-next-line no-console
    console.log(`[push] (${m ? 'no recipients' : 'FCM not configured'}) "${payload.title}: ${payload.body}"`);
    return;
  }
  const invalid: string[] = [];
  let sent = 0;
  let failed = 0;
  for (let i = 0; i < uniq.length; i += 500) {
    const chunk = uniq.slice(i, i + 500);
    const res = await m.sendEachForMulticast({
      tokens: chunk,
      notification: { title: payload.title, body: payload.body },
      data: payload.data ?? {},
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
  if (invalid.length > 0) {
    await query(`update notification_prefs set expo_push_token = null where expo_push_token = any($1)`, [invalid]);
  }
  // eslint-disable-next-line no-console
  console.log(`[push] sent=${sent} failed=${failed} cleaned=${invalid.length} "${payload.title}: ${payload.body}"`);
}

const SAFE_CATEGORIES = new Set(['signals_on', 'intel_on', 'calendar_on', 'ideas_on', 'review_on', 'academy_on', 'broker_on', 'streak_on', 'events_on']);

/// Категория қосулы (мыс. signals_on=true) барлық құрылғыларға push.
export async function sendToCategory(column: string, payload: PushPayload): Promise<void> {
  if (!SAFE_CATEGORIES.has(column)) throw new Error(`bad category: ${column}`);
  const { rows } = await query<{ token: string }>(
    `select expo_push_token as token from notification_prefs
      where ${column} = true and expo_push_token is not null and expo_push_token <> ''`,
  );
  await sendPushToTokens(rows.map((r) => r.token), payload);
}

/// Бір қолданушыға push (баға дабылы сияқты дербес хабарлар).
export async function sendToUser(userId: string, payload: PushPayload): Promise<void> {
  const { rows } = await query<{ token: string }>(
    `select expo_push_token as token from notification_prefs
      where user_id = $1 and expo_push_token is not null and expo_push_token <> ''`,
    [userId],
  );
  await sendPushToTokens(rows.map((r) => r.token), payload);
}

export type IntelPush = { id: string; text: string; impact: string };

/// Market Intel urgent жаңалығы туралы push (intel_on қосулы құрылғыларға).
export async function sendIntelPush(post: IntelPush): Promise<void> {
  const body = post.text.length > 160 ? `${post.text.slice(0, 157)}…` : post.text;
  await sendToCategory('intel_on', {
    title: 'Market Intel',
    body,
    data: { type: 'intel', id: post.id, impact: post.impact },
  });
}
