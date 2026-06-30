/// Қарапайым процесс-ішілік TTL кэш. Redis ҚАЖЕТ ЕМЕС — бір инстанс/бір VPS.
/// Горизонталь масштабта (бірнеше API) ғана Redis-ке көшу керек.
/// Қолданысы: const data = await getOrSet('key', 60_000, () => loadFromDb());

type Entry = { value: unknown; exp: number };
const store = new Map<string, Entry>();

/// Кілт бойынша кэштен оқиды; жоқ/ескірген болса loader-ды шақырып, нәтижені кэштейді.
/// Бірдей кілтке қатар келген сұраулар БІР loader-ды күтеді (thundering herd жоқ).
const inflight = new Map<string, Promise<unknown>>();

export async function getOrSet<T>(key: string, ttlMs: number, loader: () => Promise<T>): Promise<T> {
  const hit = store.get(key);
  const now = Date.now();
  if (hit && hit.exp > now) return hit.value as T;

  const running = inflight.get(key);
  if (running) return running as Promise<T>;

  const p = (async () => {
    try {
      const value = await loader();
      store.set(key, { value, exp: Date.now() + ttlMs });
      return value;
    } finally {
      inflight.delete(key);
    }
  })();
  inflight.set(key, p);
  return p as Promise<T>;
}

/// Кэшті жарамсыз ету (админ жазғанда — мыс. library/course CRUD).
export function invalidate(key: string): void {
  store.delete(key);
}

/// Префикс бойынша тазалау (мыс. барлық 'calendar:' кілттері).
export function invalidatePrefix(prefix: string): void {
  for (const k of store.keys()) {
    if (k.startsWith(prefix)) store.delete(k);
  }
}
