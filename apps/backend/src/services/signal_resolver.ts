import { query } from '../db/client.js';
import { getXauPrice } from './prices.js';

/// АНТИ-ФРОД: тірі XAU/USD бағасымен ашық идеяларды АВТОМАТТЫ шешу.
/// Себебі: провайдер жоғалтқан идеяны әдейі «active» қалдырып, статистикасында
/// loss саналмауын қалауы мүмкін. Сервер бағаны нақты көріп тұрғандықтан, SL/TP-ке
/// тигенде идеяны өзі жабады — нәтиже шынайы бағадан, провайдердің сөзінен емес.
///
/// XAU/USD pip = 0.10 (баға бірлігі). result_pips = қашықтық / 0.10 (бүтін).

const XAU_PIP = 0.10;

/// Идея ашылғаннан кейін осы күннен аса ешбір деңгейге тимесе — «expired» (void,
/// Win Rate-ке кірмейді). Дрейфтеп ешқашан шешілмейтін идеяларды тазалайды.
const EXPIRE_DAYS = 30;

type SigRow = {
  id: string;
  direction: string; // buy | sell
  entry_from: string;
  entry_to: string;
  tp1: string;
  tp2: string | null;
  tp3: string | null;
  sl: string;
  published_at: string;
};

/// Бір идеяны баға бойынша бағалау: жабу керек болса {status, pips}, әйтпесе null.
function evaluate(s: SigRow, price: number): { status: string; pips: number } | null {
  const mid = (Number(s.entry_from) + Number(s.entry_to)) / 2;
  const sl = Number(s.sl);
  const tps: Array<{ status: string; level: number }> = [
    { status: 'closed_tp1', level: Number(s.tp1) },
    ...(s.tp2 != null ? [{ status: 'closed_tp2', level: Number(s.tp2) }] : []),
    ...(s.tp3 != null ? [{ status: 'closed_tp3', level: Number(s.tp3) }] : []),
  ];
  const pipsBetween = (a: number, b: number) => Math.round(Math.abs(a - b) / XAU_PIP);

  if (s.direction === 'buy') {
    // SL-ді алдымен тексереміз (анти-фрод: жоғалтуды жоғалтпаймыз).
    if (price <= sl) return { status: 'closed_sl', pips: -pipsBetween(mid, sl) };
    // Бағаға жеткен ең ЖОҒАРЫ TP.
    const hit = tps.filter((t) => price >= t.level).sort((a, b) => b.level - a.level)[0];
    if (hit) return { status: hit.status, pips: pipsBetween(hit.level, mid) };
  } else {
    if (price >= sl) return { status: 'closed_sl', pips: -pipsBetween(mid, sl) };
    // sell үшін ең ТӨМЕН тиген TP.
    const hit = tps.filter((t) => price <= t.level).sort((a, b) => a.level - b.level)[0];
    if (hit) return { status: hit.status, pips: pipsBetween(mid, hit.level) };
  }
  return null;
}

/// Барлық ашық XAU/USD идеяларын тірі бағамен бағалап, тигендерін жабады.
/// Ескі (EXPIRE_DAYS) шешілмегендерді «expired» етеді (статистикаға кірмейді).
export async function resolveActiveSignals(): Promise<{ closed: number; expired: number; price: number | null }> {
  return resolveAtPrice(getXauPrice());
}

/// Берілген бағамен шешу (тестке ыңғайлы — баға явно беріледі).
export async function resolveAtPrice(
  price: number | null,
): Promise<{ closed: number; expired: number; price: number | null }> {
  // Тек ашық, жойылмаған XAU/USD идеялар.
  const { rows } = await query<SigRow>(
    `select id, direction, entry_from, entry_to, tp1, tp2, tp3, sl, published_at
       from signals
      where status = 'active' and deleted_at is null and pair = 'XAU/USD'`,
  );

  let closed = 0;
  let expired = 0;

  if (price != null) {
    for (const s of rows) {
      const verdict = evaluate(s, price);
      if (!verdict) continue;
      // and status='active' — басқа процесс жауып үлгерсе қайта жазбаймыз (race-safe).
      const r = await query(
        `update signals set status = $1, result_pips = $2, closed_at = now(), auto_closed = true
          where id = $3 and status = 'active' and deleted_at is null`,
        [verdict.status, verdict.pips, s.id],
      );
      if (r.rowCount && r.rowCount > 0) closed++;
    }
  }

  // Ескі шешілмегендерді void («expired») — ешбір деңгейге тимей дрейфтегендер.
  const exp = await query(
    `update signals set status = 'expired', closed_at = now()
      where status = 'active' and deleted_at is null
        and published_at < now() - interval '${EXPIRE_DAYS} days'`,
  );
  expired = exp.rowCount ?? 0;

  return { closed, expired, price };
}
