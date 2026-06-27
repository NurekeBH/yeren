/// Провайдер = расталған юзер. Юзер approve болғанда (немесе админ роль бергенде)
/// оған signal_providers профилі авто-жасалады. Ол providers тізімінде көрінеді,
/// жазылуға болады әрі ол сигнал жариялай алады. Жалған (user_id NULL) провайдерлер жоқ.

// tx client (c.query) де, standalone query да сәйкес келетін орындаушы.
type Exec = (sql: string, params?: unknown[]) => Promise<{ rows: Array<Record<string, unknown>> }>;

/// Юзерге провайдер профилін қамтамасыз ету (болмаса жасайды). Профиль id қайтарады.
export async function ensureProviderProfile(q: Exec, userId: string): Promise<string | null> {
  const existing = await q('select id from signal_providers where user_id = $1', [userId]);
  if (existing.rows[0]) return existing.rows[0].id as string;

  const u = await q('select name, phone, bio, avatar_url from users where id = $1', [userId]);
  const row = u.rows[0];
  if (!row) return null;
  const name = ((row.name as string | null)?.trim()) || (row.phone as string) || 'Провайдер';
  const avatar = (row.avatar_url as string | null) || '📊';
  const ins = await q(
    `insert into signal_providers (user_id, name, bio, avatar, verified)
     values ($1, $2, $3, $4, true) returning id`,
    [userId, name, (row.bio as string | null) ?? '', avatar],
  );
  return ins.rows[0].id as string;
}

/// Провайдер ролі алынғанда — профильді өшіру (подписки cascade, signals.provider_id NULL болады).
export async function removeProviderProfile(q: Exec, userId: string): Promise<void> {
  await q('delete from signal_providers where user_id = $1', [userId]);
}
