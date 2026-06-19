import bcrypt from 'bcrypt';
import { env } from '../config/env.js';
import { tx } from '../db/client.js';

/// Деплойда админ аккаунтын қамтамасыз ету. ADMIN_PHONE + ADMIN_PASSWORD env
/// орнатылса: ол телефон бойынша қолданушы болмаса — жасаймыз, болса —
/// is_admin=true қойып, құпиясөзін жаңартамыз. Осы кредпен админ-панельге кіресіз.
export async function ensureAdmin(log: { info: (o: unknown, m?: string) => void }): Promise<void> {
  const phone = env.ADMIN_PHONE?.trim();
  const password = env.ADMIN_PASSWORD;
  if (!phone || !password) return; // орнатылмаса — өткіземіз

  const hash = await bcrypt.hash(password, env.BCRYPT_ROUNDS);
  await tx(async (c) => {
    const existing = await c.query<{ id: string }>('select id from users where phone = $1', [phone]);
    if (existing.rowCount) {
      await c.query('update users set is_admin = true, is_blocked = false, password_hash = $1 where phone = $2', [hash, phone]);
      return;
    }
    const u = await c.query<{ id: string }>(
      `insert into users (phone, password_hash, name, is_admin, locale)
       values ($1, $2, 'Administrator', true, 'ru') returning id`,
      [phone, hash],
    );
    const id = u.rows[0]!.id;
    await c.query('insert into notification_prefs (user_id) values ($1) on conflict do nothing', [id]);
    await c.query('insert into user_progress (user_id) values ($1) on conflict do nothing', [id]);
    await c.query("insert into subscriptions (user_id, status) values ($1, 'inactive') on conflict do nothing", [id]);
  });
  log.info({ phone }, 'admin_ensured');
}
