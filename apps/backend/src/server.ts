import Fastify from 'fastify';
import cors from '@fastify/cors';
import rateLimit from '@fastify/rate-limit';
import multipart from '@fastify/multipart';
import { env } from './config/env.js';
import { registerAuth } from './plugins/auth.js';
import { authRoutes } from './modules/auth/routes.js';
import { signalsRoutes } from './modules/signals/routes.js';
import { intelRoutes } from './modules/intel/routes.js';
import { calendarRoutes } from './modules/calendar/routes.js';
import { tradesRoutes } from './modules/trades/routes.js';
import { brokersRoutes } from './modules/brokers/routes.js';
import { academyRoutes } from './modules/academy/routes.js';
import { subscriptionRoutes } from './modules/subscription/routes.js';
import { notificationsRoutes } from './modules/notifications/routes.js';
import { pool } from './db/client.js';

const app = Fastify({
  logger: env.NODE_ENV === 'development'
    ? { level: env.LOG_LEVEL, transport: { target: 'pino-pretty' } }
    : { level: env.LOG_LEVEL },
  bodyLimit: 5 * 1024 * 1024,
  trustProxy: true,
});

await app.register(cors, { origin: env.CORS_ORIGIN, credentials: true });
await app.register(rateLimit, { max: 200, timeWindow: '1 minute' });
await app.register(multipart, { limits: { fileSize: 5 * 1024 * 1024 } });
await registerAuth(app);

app.get('/health', async () => ({
  ok: true,
  env: env.NODE_ENV,
  time: new Date().toISOString(),
}));

await app.register(async (api) => {
  await authRoutes(api);
  await signalsRoutes(api);
  await intelRoutes(api);
  await calendarRoutes(api);
  await tradesRoutes(api);
  await brokersRoutes(api);
  await academyRoutes(api);
  await subscriptionRoutes(api);
  await notificationsRoutes(api);
}, { prefix: '/api/v1' });

const shutdown = async (signal: string) => {
  app.log.info({ signal }, 'shutting down');
  try {
    await app.close();
    await pool.end();
    process.exit(0);
  } catch (err) {
    app.log.error(err, 'shutdown_error');
    process.exit(1);
  }
};
process.on('SIGINT', () => void shutdown('SIGINT'));
process.on('SIGTERM', () => void shutdown('SIGTERM'));

try {
  await app.listen({ port: env.PORT, host: env.HOST });
  app.log.info(`TraderOS API listening at http://${env.HOST}:${env.PORT}`);
} catch (err) {
  app.log.error(err, 'failed_to_start');
  process.exit(1);
}
