# ALTYN — Deployment Guide

Three pieces ship independently:

| Piece | Folder | Hosting (suggested) |
|-------|--------|---------------------|
| Backend API (Fastify + pg) | `apps/backend` | Railway / Render / Fly.io |
| Postgres database | — | Railway PG / Render PG / Supabase / Neon |
| Admin panel (Next.js) | `apps/admin` | Vercel |
| Mobile app (Flutter) | `mobile` | Play Store / App Store (points at the API URL) |

The mobile app runs in **mock mode by default**. It talks to the backend only when built with `--dart-define=USE_REMOTE_API=true` and `--dart-define=API_BASE_URL=https://<api>/api/v1` (see step 6).

---

## 1. Generate secrets

```bash
# JWT_SECRET — min 32 chars
openssl rand -base64 48

# INVESTOR_PWD_KEY — exactly 32 bytes = 64 hex chars
openssl rand -hex 32
```

## 2. Required environment variables

| Var | Required | Notes |
|-----|----------|-------|
| `DATABASE_URL` | ✅ | `postgresql://user:pass@host:5432/db` (managed PG gives you this) |
| `JWT_SECRET` | ✅ | ≥ 32 chars (step 1) |
| `INVESTOR_PWD_KEY` | ✅ | exactly 64 hex chars (step 1) |
| `NODE_ENV` | ✅ | `production` |
| `CORS_ORIGIN` | ✅ | the admin panel origin, e.g. `https://altyn-admin.vercel.app` (use `*` only for quick tests) |
| `PORT` | auto | most hosts inject this; the server reads it |
| `FINNHUB_API_KEY` | optional | market intel / calendar / news ingestion |
| `FCM_PROJECT_ID` / `FCM_CLIENT_EMAIL` / `FCM_PRIVATE_KEY` | optional | push (Firebase service account — see step 7) |
| `ANTHROPIC_API_KEY` | optional | Claude analysis features |
| `SUPABASE_URL` / `SUPABASE_SERVICE_KEY` | optional | storage for receipts/screenshots |

Full reference: [`apps/backend/.env.example`](../apps/backend/.env.example). **Never commit the real `.env`.**

---

## 3. Deploy the backend — Option A: Railway (recommended)

1. **railway.app** → New Project → *Deploy from GitHub repo* → pick `NurekeBH/yeren`.
2. Service settings → **Root Directory** = `apps/backend`.
   - Build: `npm install && npm run build`
   - Start: `npm start`  (runs `node dist/server.js`)
3. Add a **Postgres** plugin to the project → it exposes `DATABASE_URL`. In the backend service’s *Variables*, add a reference to that `DATABASE_URL` plus the rest from step 2.
4. **Run migrations once** (Railway → service → *Shell* / one-off command):
   ```bash
   npm run db:migrate     # applies src/db/schema.sql + seed.sql (idempotent)
   ```
   For production without demo data, run only the schema:
   ```bash
   node -e "const{Pool}=require('pg');const fs=require('fs');new Pool({connectionString:process.env.DATABASE_URL,ssl:{rejectUnauthorized:false}}).query(fs.readFileSync('src/db/schema.sql','utf8')).then(()=>process.exit(0))"
   ```
5. Verify: open `https://<railway-domain>/health` → `{ "ok": true }`.

### Option B: Render

1. **New → PostgreSQL** → copy its *Internal Database URL*.
2. **New → Web Service** → repo `NurekeBH/yeren`, Root Directory `apps/backend`, Runtime Node, Build `npm install && npm run build`, Start `npm start`.
3. Add env vars (step 2) incl. the Postgres URL. Add `NODE_ENV=production`.
4. Migrations: Render *Shell* → `npm run db:migrate`.
5. Check `/health`.

> Node 20+ is required (see `engines` in package.json). Postgres needs `uuid-ossp` + `pgcrypto` extensions — `schema.sql` enables them with `create extension if not exists`, so a standard managed Postgres works.

---

## 4. Create the first admin

The app has no public admin signup. Register a normal account, then flip the flag in SQL:

```bash
# register via the API (replace host)
curl -X POST https://<api>/api/v1/auth/register \
  -H 'content-type: application/json' \
  -d '{"phone":"+77010000000","password":"changeme123"}'
```
```sql
-- in the DB console
update users set is_admin = true where phone = '+77010000000';
```
Log in to the admin panel with those credentials.

---

## 5. Deploy the admin panel (Vercel)

1. **vercel.com** → Import `NurekeBH/yeren` → **Root Directory** = `apps/admin`.
2. Env var: `NEXT_PUBLIC_API_BASE_URL = https://<api>/api/v1`.
3. Deploy. Add the resulting Vercel origin to the backend’s `CORS_ORIGIN` and redeploy the backend.

---

## 6. Point the mobile app at the backend

By default the app uses mock data. For a real build:

```bash
cd mobile
flutter build apk --release \
  --dart-define=USE_REMOTE_API=true \
  --dart-define=API_BASE_URL=https://<api>/api/v1
# iOS: flutter build ipa --release --dart-define=...
```

- Android emulator pointing at a local backend uses `http://10.0.2.2:3000/api/v1`.
- Production must be **HTTPS** (Android blocks cleartext by default).

---

## 7. Push (FCM) service account

`push.ts` sends via firebase-admin. From **Firebase Console → Project Settings → Service accounts → Generate new private key** (JSON), set on the host:

- `FCM_PROJECT_ID` = `project_id`
- `FCM_CLIENT_EMAIL` = `client_email`
- `FCM_PRIVATE_KEY` = the `private_key` value, **on one line** with literal `\n` (the code un-escapes them). In most dashboards paste it wrapped in quotes:
  `"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"`

If these are unset, push is a safe no-op (logged, not sent). iOS push additionally needs an APNs Auth Key uploaded in the Firebase console + the Push capability enabled in Xcode (see the iOS notes in the FCM commit).

---

## 8. Smoke test

```bash
curl https://<api>/health
curl -X POST https://<api>/api/v1/auth/login -H 'content-type: application/json' \
  -d '{"phone":"+77010000000","password":"changeme123"}'   # returns { token }
```
Then open the app built per step 6 and register/login against the live API.
