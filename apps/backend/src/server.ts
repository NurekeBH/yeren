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
import { subscriptionRoutes } from './modules/subscription/routes.js';
import { adminRoutes } from './modules/admin/routes.js';
import { traderAppsRoutes } from './modules/trader_apps/routes.js';
import { coursesRoutes } from './modules/courses/routes.js';
import { uploadsRoutes } from './modules/uploads/routes.js';
import { pricesRoutes } from './modules/prices/routes.js';
import { journalRoutes } from './modules/journal/routes.js';
import { ensureAdmin } from './services/bootstrap_admin.js';
import { ingestNews } from './services/news.js';
import { ingestCalendar } from './services/calendar.js';
import { checkPriceAlerts } from './services/alerts.js';
import { resolveActiveSignals } from './services/signal_resolver.js';
import { startPricePoller, startBinanceWs } from './services/prices.js';
import { sendCalendarReminders } from './services/calendar_reminders.js';
import { pool } from './db/client.js';

const app = Fastify({
  logger: env.NODE_ENV === 'development'
    ? { level: env.LOG_LEVEL, transport: { target: 'pino-pretty' } }
    : { level: env.LOG_LEVEL },
  bodyLimit: 5 * 1024 * 1024,
  trustProxy: true,
});

// Денесіз POST/PATCH әрекеттер (approve/reject/like/ingest/close/...) Content-Type:
// application/json-мен бос дене жіберсе, Fastify әдепкіде 400 ("Body cannot be empty")
// береді. Бос денені {} деп қабылдаймыз — осылайша денесіз әрекеттер барлық клиентте
// (admin, mobile) дұрыс жұмыс істейді.
app.addContentTypeParser('application/json', { parseAs: 'string' }, (_req, body, done) => {
  const raw = (body as string) ?? '';
  if (raw.trim() === '') return done(null, {});
  try {
    done(null, JSON.parse(raw));
  } catch {
    const err = new Error('Invalid JSON body') as Error & { statusCode?: number };
    err.statusCode = 400;
    done(err, undefined);
  }
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
  await subscriptionRoutes(api);
  await adminRoutes(api);
  await traderAppsRoutes(api);
  await coursesRoutes(api);
  await uploadsRoutes(api);
  await pricesRoutes(api);
  await journalRoutes(api);
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
  // Деплойда ADMIN_PHONE/ADMIN_PASSWORD орнатылса — админ аккаунтын қамтамасыз етеміз.
  await ensureAdmin(app.log).catch((e) => app.log.warn(e, 'ensure_admin_failed'));
  // Бағаны сервер жағында жинау. XAU — Binance WS (нақты уақыт), қалғаны REST (Yahoo).
  startPricePoller(app.log);
  startBinanceWs(app.log);
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
} else {
  app.log.info('Market Intel poller disabled (no FINNHUB_API_KEY)');
}

// ─────────────── Экономикалық календарь поллері (кілтсіз, Forex Factory) ───────────────
// faireconomy.media тегін фиді — Finnhub-тың calendar endpoint-ы premium болғандықтан.
{
  const CAL_MS = 30 * 60_000;
  const calPoll = async () => {
    try {
      const r = await ingestCalendar();
      if (r.inserted > 0) app.log.info({ inserted: r.inserted }, 'calendar_ingested');
    } catch (err) {
      app.log.warn(err, 'calendar_poll_failed');
    }
  };
  void calPoll();
  const calTimer = setInterval(() => void calPoll(), CAL_MS);
  calTimer.unref?.();
  app.log.info('Economic calendar poller started (Forex Factory, every 30m)');
}

// ─────────────── Баға дабылы поллері (кілтсіз, Binance PAXG) ───────────────
// Тірі XAU/USD бағасы мақсатты деңгейді кигенде дабыл иесіне FCM push жібереді.
{
  const ALERT_MS = 60_000;
  let checking = false;
  const tick = async () => {
    if (checking) return;
    checking = true;
    try {
      const r = await checkPriceAlerts();
      if (r.triggered > 0) app.log.info({ triggered: r.triggered, price: r.price }, 'price_alerts_triggered');
      // АНТИ-ФРОД: ашық идеяларды тірі бағамен авто-шешу (SL/TP-ке тигенде жабу).
      const sr = await resolveActiveSignals();
      if (sr.closed > 0 || sr.expired > 0) {
        app.log.info({ closed: sr.closed, expired: sr.expired, price: sr.price }, 'signals_auto_resolved');
      }
    } catch (err) {
      app.log.warn(err, 'price_alert_check_failed');
    } finally {
      checking = false;
    }
  };
  void tick();
  const alertTimer = setInterval(() => void tick(), ALERT_MS);
  alertTimer.unref?.();
  app.log.info(`Price-alert + signal-resolver poller started (every ${ALERT_MS / 1000}s)`);
}

// ─────────────── Календарь еске салу поллері (high-impact, ~15 мин бұрын) ───────────────
{
  const CAL_MS = 5 * 60_000;
  let busy = false;
  const tick = async () => {
    if (busy) return;
    busy = true;
    try {
      const r = await sendCalendarReminders();
      if (r.sent > 0) app.log.info({ sent: r.sent }, 'calendar_reminders_sent');
    } catch (err) {
      app.log.warn(err, 'calendar_reminder_failed');
    } finally {
      busy = false;
    }
  };
  void tick();
  const calRemTimer = setInterval(() => void tick(), CAL_MS);
  calRemTimer.unref?.();
  app.log.info(`Calendar-reminder poller started (every ${CAL_MS / 60000}m)`);
}
