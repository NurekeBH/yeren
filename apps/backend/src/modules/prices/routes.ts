import type { FastifyInstance } from 'fastify';
import { getQuotesMeta } from '../../services/prices.js';

/// Нарық бағалары — сервер жағында кэштеледі (PAXG + Yahoo). Публичный: auth қажет емес.
/// App дисплейі мен alert поллері осы БІР дереккөзден оқиды.
export async function pricesRoutes(app: FastifyInstance) {
  app.get('/prices', async () => getQuotesMeta());
}
