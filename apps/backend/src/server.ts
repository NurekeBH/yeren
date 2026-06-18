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
import { notificationsRoutes } from './modules/notifications/routes.js';
import { providersRoutes } from './modules/providers/routes.js';
import { postsRoutes } from './modules/posts/routes.js';
import { eventsRoutes } from './modules/events/routes.js';
import { alertsRoutes } from './modules/alerts/routes.js';
import { libraryRoutes } from './modules/library/routes.js';
import { agreementRoutes } from './modules/agreement/routes.js';
import { supportRoutes } from './modules/support/routes.js';
import { ingestNews } from './services/news.js';
import { ingestCalendar } from './services/calendar.js';
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
  await notificationsRoutes(api);
  await providersRoutes(api);
  await postsRoutes(api);
  await eventsRoutes(api);
  await alertsRoutes(api);
  await libraryRoutes(api);
  await agreementRoutes(api);
  await supportRoutes(api);
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
  app.log.info(`ALTYN API listening at http://${env.HOST}:${env.PORT}`);
} catch (err) {
  app.log.error(err, 'failed_to_start');
  process.exit(1);
}

// ─────────────── Market Intel real-time poller ───────────────
// FINNHUB_API_KEY болса — жаңалықтарды әр 60 секунд сайын автоматты тартып,
// intel_posts-қа жазады әрі жаңа urgent жаңалықтарға бірден FCM push жібереді
// (ingestNews ішінде sendIntelPush шақырылады). Кілт болмаса — поллинг қосылмайды.
if (env.FINNHUB_API_KEY) {
  const POLL_MS = 60_000;
  let polling = false;
  const poll = async () => {
    if (polling) return; // алдыңғысы аяқталмаса — өткіземіз
    polling = true;
    try {
      const r = await ingestNews();
      if (r.inserted > 0) app.log.info({ inserted: r.inserted, sources: r.sources }, 'intel_ingested');
    } catch (err) {
      app.log.warn(err, 'intel_poll_failed');
    } finally {
      polling = false;
    }
  };
  void poll(); // бірден бір рет
  const timer = setInterval(() => void poll(), POLL_MS);
  timer.unref?.();
  app.log.info(`Market Intel poller started (every ${POLL_MS / 1000}s)`);

  // Экономикалық календарь — live (Finnhub economic calendar), әр 30 минут.
  const calPoll = async () => {
    try {
      const r = await ingestCalendar();
      if (r.inserted > 0) app.log.info({ inserted: r.inserted }, 'calendar_ingested');
    } catch (err) {
      app.log.warn(err, 'calendar_poll_failed');
    }
  };
  void calPoll();
  const calTimer = setInterval(() => void calPoll(), 30 * 60_000);
  calTimer.unref?.();
} else {
  app.log.info('Market Intel poller disabled (no FINNHUB_API_KEY)');
}
