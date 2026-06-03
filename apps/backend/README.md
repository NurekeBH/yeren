# TraderOS Backend

Node.js 20 + Fastify + Postgres (Supabase) REST API.

## Жылдам бастау

```bash
cd apps/backend
cp .env.example .env
# .env-те DATABASE_URL, JWT_SECRET, INVESTOR_PWD_KEY-ні жаңартыңыз

# Тәуелділіктерді орнату (monorepo root-та pnpm болса):
pnpm install
# немесе npm:
npm install

# Postgres схеманы қолдану + seed
npm run db:migrate

# Dev serverді іске қосу
npm run dev
# → http://localhost:3000/health
```

## INVESTOR_PWD_KEY жасау

```bash
node -e "console.log(require('node:crypto').randomBytes(32).toString('hex'))"
```

## JWT_SECRET жасау

```bash
node -e "console.log(require('node:crypto').randomBytes(48).toString('base64url'))"
```

## API endpoints

Барлық endpoints `/api/v1` prefix-те.

### Auth (TZ.rtf override — SMS жоқ)
- `POST /auth/register` — `{ phone, password, name?, city?, trading_styles?, preferred_sessions?, locale? }`
- `POST /auth/login` — `{ phone, password }` → `{ token, user_id }`
- `GET /auth/me` 🔒
- `PATCH /auth/me` 🔒

### Signals (TZ §10)
- `GET /signals`
- `GET /signals/:id`
- `GET /signals/stats` — Win Rate / Profit Factor / Avg RR
- `POST /signals` 🛡 admin
- `POST /signals/:id/close` 🛡 admin

### Intel (TZ §7)
- `GET /intel?limit=30`
- `POST /intel` 🛡 admin (RSS / Telegram / Trump X ingest)

### Calendar (TZ §8)
- `GET /calendar?from=&to=&impact=`
- `POST /calendar/upsert` 🛡 admin (Finnhub poller)

### Trades (TZ §9)
- `GET /trades?account_id=&limit=` 🔒
- `POST /trades` 🔒
- `DELETE /trades/:id` 🔒
- `GET /trades/kpi` 🔒

### Brokers (TZ §9.2-9.4)
- `GET /brokers` 🔒
- `POST /brokers/mt` 🔒 — MT4/MT5 + investor password (AES-256-GCM-те шифрленеді)
- `POST /brokers/ctrader` 🔒 — cTrader OAuth
- `POST /brokers/:id/sync` 🔒
- `DELETE /brokers/:id` 🔒

### Academy (TZ §11)
- `GET /lessons?profile_type=`
- `GET /lessons/:id`
- `POST /lessons/:id/complete` 🔒 — `{ quick_check_answer? }` → XP + streak жаңартады
- `POST /academy/test` 🔒 — Gallup нәтижесі
- `GET /academy/test/latest` 🔒
- `GET /academy/progress` 🔒

### Subscription (TZ.rtf override — Kaspi)
- `GET /subscription` 🔒
- `POST /subscription/receipt` 🔒 — `{ receipt_url }` → pending_review
- `GET /subscription/pending` 🛡 admin
- `POST /subscription/:id/approve` 🛡 admin → +30 күн active
- `POST /subscription/:id/reject` 🛡 admin

### Notifications (TZ §12.2)
- `GET /notifications/prefs` 🔒
- `PATCH /notifications/prefs` 🔒

## Қауіпсіздік

- **Investor Password** (MT4/MT5) — AES-256-GCM-те, ключ INVESTOR_PWD_KEY-те, client-ке жіберілмейді. UI тек `••••••XX` масканы алады.
- **bcrypt** rounds=12 (env-те конфигур).
- **JWT** Bearer Auth, refresh tokens — кейінгі итерацияда (user_sessions кестесі дайын).
- **Rate limit**: 200 req/min/IP.

## Жоба құрылымы

```
src/
├── config/env.ts          Zod-ты валидацияланған env
├── db/
│   ├── client.ts          pg Pool + query/tx helpers
│   ├── schema.sql         барлық CREATE TABLE
│   └── seed.sql           demo сабақтар
├── plugins/
│   └── auth.ts            JWT + authenticate/requireAdmin
├── modules/               әр feature: routes.ts
│   ├── auth/
│   ├── signals/
│   ├── intel/
│   ├── calendar/
│   ├── trades/
│   ├── brokers/
│   ├── academy/
│   ├── subscription/
│   └── notifications/
├── utils/crypto.ts        AES-256-GCM (investor password)
└── server.ts              Fastify bootstrap
```

## Болашақ итерациялар

- Telegram bot Webhook → `POST /signals` source=`telegram_bot` (TZ.rtf)
- Finnhub Calendar poller cron
- RSS poller → Claude analyze → `POST /intel`
- MT EA → REST receiver `POST /trades` source=`mt_ea`
- cTrader OAuth callback handler
- Expo Push notifications (signals/intel/calendar event triggers)
