import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { query } from '../../db/client.js';
import { encryptInvestor, maskInvestor } from '../../utils/crypto.js';

const LinkMt = z.object({
  broker_name: z.enum(['exness', 'ic_markets', 'xm', 'pepperstone', 'oanda', 'fxpro', 'other']),
  platform: z.enum(['mt4', 'mt5']),
  account_number: z.string().min(1).max(40),
  server: z.string().min(1).max(80),
  investor_password: z.string().min(4).max(64),
});

interface BrokerRow {
  id: string; broker_name: string; platform: string; account_number: string;
  server: string | null; investor_password_cipher: Buffer | null;
  balance: string; currency: string; is_oauth: boolean;
  linked_at: string; synced_at: string | null;
}

function shape(r: BrokerRow) {
  return {
    id: r.id,
    broker_name: r.broker_name,
    platform: r.platform,
    account_number: r.account_number,
    server: r.server,
    investor_password_masked: r.investor_password_cipher ? '••••••••' : null,
    balance: Number(r.balance),
    currency: r.currency,
    is_oauth: r.is_oauth,
    linked_at: r.linked_at,
    synced_at: r.synced_at,
  };
}

export async function brokersRoutes(app: FastifyInstance) {
  app.get('/brokers', { onRequest: [app.authenticate] }, async (req) => {
    const { rows } = await query<BrokerRow>(
      `select id, broker_name, platform, account_number, server, investor_password_cipher,
              balance, currency, is_oauth, linked_at, synced_at
       from broker_accounts where user_id = $1 and removed_at is null
       order by linked_at desc`,
      [req.userId],
    );
    return { accounts: rows.map(shape) };
  });

  app.post('/brokers/mt', { onRequest: [app.authenticate] }, async (req, reply) => {
    const parsed = LinkMt.safeParse(req.body);
    if (!parsed.success) return reply.code(400).send({ error: 'bad_request', issues: parsed.error.issues });
    const d = parsed.data;
    const cipher = encryptInvestor(d.investor_password);
    const { rows } = await query<BrokerRow>(
      `insert into broker_accounts (user_id, broker_name, platform, account_number, server, investor_password_cipher, is_oauth)
       values ($1,$2,$3,$4,$5,$6,false)
       returning id, broker_name, platform, account_number, server, investor_password_cipher,
                 balance, currency, is_oauth, linked_at, synced_at`,
      [req.userId, d.broker_name, d.platform, d.account_number, d.server, cipher],
    );
    return { account: shape(rows[0]!), password_masked: maskInvestor(d.investor_password) };
  });

  app.post('/brokers/:id/sync', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    // Қазір тек «соңғы тексеру» уақытын белгілейміз (synced_at).
    // Нақты MT5 сделка импорты сыртқы инфрақұрылымды талап етеді: MetaApi
    // (metaapi.cloud) investor password арқылы read-only тарихты береді —
    // ол үшін METAAPI_TOKEN (ақылы), broker_accounts-та metaapi_account_id
    // бағаны және деплой керек. Сол себепті бұл деплой-кезеңіне қалдырылды.
    const { rowCount } = await query(
      `update broker_accounts set synced_at = now() where id = $1 and user_id = $2 and removed_at is null`,
      [id, req.userId],
    );
    if (!rowCount) return reply.code(404).send({ error: 'not_found' });
    return { ok: true, synced_at: new Date().toISOString() };
  });

  app.delete('/brokers/:id', { onRequest: [app.authenticate] }, async (req, reply) => {
    const id = (req.params as { id: string }).id;
    const { rowCount } = await query(
      `update broker_accounts set removed_at = now() where id = $1 and user_id = $2 and removed_at is null`,
      [id, req.userId],
    );
    if (!rowCount) return reply.code(404).send({ error: 'not_found' });
    return { ok: true };
  });
}
