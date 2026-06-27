import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';
import { wrapInvestorPassword } from '../../services/journal/crypto.js';
import {
  syncAccount,
  upsertTrades,
  defaultMtProvider,
  type RawOrder,
} from '../../services/journal/sync_engine.js';
import { parseStatement, StatementParseError } from '../../services/journal/parser.js';
import { coreStats, calendarGrid, emotionsMatrix, tagBreakdown } from '../../services/journal/analytics.js';

// ── DTO ──
interface AccountRow {
  id: string;
  broker: string;
  platform: string;
  login: string;
  server: string;
  account_name: string | null;
  currency: string;
  balance: string | null;
  equity: string | null;
  sync_state: string;
  sync_error: string | null;
  last_synced_at: string | null;
  investor_password_cipher: string | null;
  created_at: string;
}
function accountDto(r: AccountRow) {
  return {
    id: r.id,
    broker: r.broker,
    platform: r.platform,
    login: r.login,
    server: r.server,
    account_name: r.account_name,
    currency: r.currency,
    balance: r.balance == null ? null : Number(r.balance),
    equity: r.equity == null ? null : Number(r.equity),
    sync_state: r.sync_state,
    sync_error: r.sync_error,
    last_synced_at: r.last_synced_at,
    has_credentials: !!r.investor_password_cipher,
    created_at: r.created_at,
  };
}
const ACC_COLS =
  'id, broker, platform, login, server, account_name, currency, balance, equity, sync_state, sync_error, last_synced_at, investor_password_cipher, created_at';

async function getOrCreateManualAccount(userId: string): Promise<string> {
  const found = await query<{ id: string }>(
    `select id from trading_accounts where user_id = $1 and platform = 'manual' and removed_at is null limit 1`,
    [userId],
  );
  if (found.rows[0]) return found.rows[0].id;
  const ins = await query<{ id: string }>(
    `insert into trading_accounts (user_id, broker, platform, login, server, account_name)
     values ($1, 'manual', 'manual', 'manual', '', 'Қолмен енгізу') returning id`,
    [userId],
  );
  return ins.rows[0].id;
}

const LinkBody = z.object({
  broker: z.string().min(1),
  platform: z.enum(['mt4', 'mt5']).default('mt5'),
  login: z.string().min(1),
  server: z.string().min(1),
  account_name: z.string().optional(),
  investor_password: z.string().min(1),
});

const ManualTrade = z.object({
  account_id: z.string().uuid().optional(),
  symbol: z.string().min(1),
  side: z.enum(['buy', 'sell']),
  volume: z.number().positive(),
  open_price: z.number(),
  close_price: z.number().nullable().optional(),
  sl: z.number().nullable().optional(),
  tp: z.number().nullable().optional(),
  commission: z.number().optional(),
  swap: z.number().optional(),
  profit: z.number().optional(),
  opened_at: z.string(),
  closed_at: z.string().nullable().optional(),
  // метадата
  setup_tag: z.string().nullish(),
  session_tag: z.string().nullish(),
  emotion: z.string().nullish(),
  grade: z.string().nullish(),
  rr_planned: z.number().nullish(),
  notes: z.string().nullish(),
  screenshot_url: z.string().nullish(),
});

const MetaBody = z.object({
  setup_tag: z.string().nullish(),
  session_tag: z.string().nullish(),
  emotion: z.string().nullish(),
  grade: z.string().nullish(),
  rr_planned: z.number().nullish(),
  notes: z.string().nullish(),
  screenshot_url: z.string().nullish(),
  tags: z.array(z.string()).optional(),
});

async function upsertMetadata(
  accountId: string,
  ticketId: string,
  userId: string,
  d: z.infer<typeof MetaBody>,
): Promise<void> {
  await query(
    `insert into trade_metadata (account_id, ticket_id, user_id, setup_tag, session_tag, emotion, grade, rr_planned, notes, screenshot_url, tags)
     values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,coalesce($11::text[],'{}'))
     on conflict (account_id, ticket_id) do update set
        setup_tag = coalesce(excluded.setup_tag, trade_metadata.setup_tag),
        session_tag = coalesce(excluded.session_tag, trade_metadata.session_tag),
        emotion = coalesce(excluded.emotion, trade_metadata.emotion),
        grade = coalesce(excluded.grade, trade_metadata.grade),
        rr_planned = coalesce(excluded.rr_planned, trade_metadata.rr_planned),
        notes = coalesce(excluded.notes, trade_metadata.notes),
        screenshot_url = coalesce(excluded.screenshot_url, trade_metadata.screenshot_url),
        tags = coalesce(excluded.tags, trade_metadata.tags),
        updated_at = now()`,
    [
      accountId, ticketId, userId, d.setup_tag ?? null, d.session_tag ?? null, d.emotion ?? null,
      d.grade ?? null, d.rr_planned ?? null, d.notes ?? null, d.screenshot_url ?? null,
      d.tags ?? null,
    ],
  );
}

export async function journalRoutes(app: FastifyInstance) {
  // ════════════ Аккаунттар ════════════
  app.get('/journal/accounts', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query<AccountRow>(
      `select ${ACC_COLS} from trading_accounts
        where user_id = $1 and removed_at is null and platform <> 'manual'
        order by created_at desc`,
      [req.userId],
    );
    return { accounts: rows.map(accountDto) };
  });

  // Аккаунт жалғау (investor пароль AES-256-GCM-мен шифрленеді).
  app.post('/journal/accounts', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = LinkBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;
    const cipher = wrapInvestorPassword(d.investor_password);
    const { rows } = await query<AccountRow>(
      `insert into trading_accounts (user_id, broker, platform, login, server, account_name, investor_password_cipher)
       values ($1,$2,$3,$4,$5,$6,$7)
       on conflict (user_id, platform, login, server) do update set
          broker = excluded.broker, account_name = excluded.account_name,
          investor_password_cipher = excluded.investor_password_cipher, removed_at = null
       returning ${ACC_COLS}`,
      [req.userId, d.broker, d.platform, d.login, d.server, d.account_name ?? null, cipher],
    );
    return { account: accountDto(rows[0]) };
  });

  app.delete('/journal/accounts/:id', { onRequest: [app.authenticate] }, async (req) => {
    const id = (req.params as { id: string }).id;
    await query('update trading_accounts set removed_at = now() where id = $1 and user_id = $2', [id, req.userId]);
    return { ok: true };
  });

  // Синхрондау (MT investor-password арқылы тарихты тарту → upsert).
  app.post('/journal/accounts/:id/sync', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const own = await query('select 1 from trading_accounts where id = $1 and user_id = $2 and removed_at is null', [
      id,
      req.userId,
    ]);
    if (!own.rowCount) return reply.code(404).send({ error: 'not_found' });
    const result = await syncAccount(id, defaultMtProvider);
    return result;
  });

  // ════════════ Импорт (.html / .csv statement) ════════════
  app.post('/journal/import', { onRequest: [app.authenticate] }, async (req, reply) => {
    const accountId = (req.query as { account_id?: string }).account_id;
    let targetAccount: string;
    if (accountId) {
      const own = await query('select 1 from trading_accounts where id = $1 and user_id = $2 and removed_at is null', [
        accountId,
        req.userId,
      ]);
      if (!own.rowCount) return reply.code(404).send({ error: 'account_not_found' });
      targetAccount = accountId;
    } else {
      targetAccount = await getOrCreateManualAccount(req.userId!);
    }

    const file = await req.file();
    if (!file) return reply.code(400).send({ error: 'no_file' });
    const content = (await file.toBuffer()).toString('utf8');

    try {
      const parsed = parseStatement(content, file.filename);
      const orders: RawOrder[] = parsed.orders.map((o) => ({ ...o, source: 'import' }) as RawOrder);
      const { inserted, updated } = await upsertTrades(targetAccount, req.userId!, orders);
      return {
        ok: true,
        format: parsed.format,
        parsed: parsed.orders.length,
        inserted,
        updated,
        skipped: parsed.skipped,
        warnings: parsed.warnings,
      };
    } catch (err) {
      if (err instanceof StatementParseError) {
        return reply.code(422).send({ error: err.code, message: err.message });
      }
      app.log.error({ err }, 'statement import failed');
      return reply.code(500).send({ error: 'import_failed' });
    }
  });

  // ════════════ Сделкалар ════════════
  app.get('/journal/trades', { onRequest: [app.authenticate] }, async (req) => {
    const q = req.query as { account_id?: string; limit?: string };
    const limit = Math.min(Number(q.limit) || 200, 1000);
    const { rows } = await query(
      `select t.id, t.account_id, t.ticket_id, t.symbol, t.side, t.volume, t.open_price, t.close_price,
              t.sl, t.tp, t.commission, t.swap, t.profit, t.pips, t.opened_at, t.closed_at, t.source,
              m.setup_tag, m.session_tag, m.emotion, m.grade, m.rr_planned, m.screenshot_url, m.notes, m.tags,
              a.broker, a.platform
         from journal_trades t
         left join trade_metadata m on m.account_id = t.account_id and m.ticket_id = t.ticket_id
         join trading_accounts a on a.id = t.account_id
        where t.user_id = $1 and ($2::uuid is null or t.account_id = $2)
        order by coalesce(t.closed_at, t.opened_at) desc
        limit $3`,
      [req.userId, q.account_id ?? null, limit],
    );
    return { trades: rows };
  });

  // Қолмен сделка қосу (Manual аккаунтқа).
  app.post('/journal/trades', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = ManualTrade.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;
    const accountId = d.account_id ?? (await getOrCreateManualAccount(req.userId!));
    const ticket = `m-${Date.now()}-${Math.floor(Math.random() * 1e6)}`;
    const order: RawOrder = {
      ticket,
      symbol: d.symbol,
      side: d.side,
      volume: d.volume,
      openPrice: d.open_price,
      closePrice: d.close_price ?? null,
      sl: d.sl ?? null,
      tp: d.tp ?? null,
      commission: d.commission ?? 0,
      swap: d.swap ?? 0,
      profit: d.profit ?? 0,
      openedAt: d.opened_at,
      closedAt: d.closed_at ?? null,
      source: 'manual',
    } as RawOrder;
    await upsertTrades(accountId, req.userId!, [order]);
    await upsertMetadata(accountId, ticket, req.userId!, d);
    return { ok: true, ticket_id: ticket, account_id: accountId };
  });

  app.delete('/journal/trades/:id', { onRequest: [app.authenticate] }, async (req) => {
    const id = (req.params as { id: string }).id;
    await query('delete from journal_trades where id = $1 and user_id = $2', [id, req.userId]);
    return { ok: true };
  });

  // Трейд аннотациясын (метадата) сақтау — синхрон оны өшірмейді.
  app.put('/journal/trades/:id/metadata', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const parsed = MetaBody.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const t = await query<{ account_id: string; ticket_id: string }>(
      'select account_id, ticket_id from journal_trades where id = $1 and user_id = $2',
      [id, req.userId],
    );
    if (!t.rows[0]) return reply.code(404).send({ error: 'not_found' });
    await upsertMetadata(t.rows[0].account_id, t.rows[0].ticket_id, req.userId!, parsed.data);
    return { ok: true };
  });

  // ════════════ Аналитика ════════════
  app.get('/journal/analytics', { onRequest: [app.authenticate] }, async (req) => {
    const q = req.query as { account_id?: string; from?: string; to?: string };
    const acc = q.account_id ?? null;
    const [stats, calendar, emotions, setups, sessions] = await Promise.all([
      coreStats(req.userId!, acc),
      calendarGrid(req.userId!, acc, q.from ?? null, q.to ?? null),
      emotionsMatrix(req.userId!, acc),
      tagBreakdown(req.userId!, acc, 'setup_tag'),
      tagBreakdown(req.userId!, acc, 'session_tag'),
    ]);
    return { stats, calendar, emotions, setups, sessions };
  });
}
