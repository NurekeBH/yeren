# Тапсырма: WhatsApp OTP арқылы аутентификация (Fastify + Postgres + TS)

> Бұл файл — **traderos/backend** проектінде жұмыс істейтін Claude agent-ке арналған тапсырма.
> Мақсат: WhatsApp (Meta Cloud API) арқылы OTP код жіберіп, телефон нөмірін растайтын
> аутентификация ағынын қосу. Логика тексерілген өндірістік жобадан (Qajet) алынды.

---

## 0. Контекст (стек — өзгертпе)

Проект анықталған стек:
- **Fastify v4** + `@fastify/jwt`, `@fastify/rate-limit`, `@fastify/cors`
- **Postgres** — таза `pg` (Prisma/ORM ЖОҚ), SQL миграциялар `scripts/migrate.js` арқылы
- **TypeScript + ESM** (`package.json` → `"type": "module"`)
  - ⚠️ Импорттар **`.js` жұрнағымен** жазылуы керек (`tsc` → `node dist/server.js`). Қазіргі кодтағы импорт стиліне қарап растап ал.
- Валидация: **zod**
- HTTP сұраныс: **axios ЖОҚ** → Node 20 глобал `fetch` қолдан
- Құрылым: `src/config`, `src/db`, `src/modules` (фичалар), `src/plugins`, `src/services` (ортақ), `src/utils`, `src/server.ts`

---

## 1. АЛДЫМЕН: кодты зерттеп, интеграция нүктелерін анықта

Кез келген файл жазбас бұрын, мына нәрселерді кодтан тауып ал (бұларды БОЛЖАМА):

- [ ] **`src/db/`** — pg `Pool` қалай экспортталған? (`pool` па, әлде `query()` хелпер ме? Файл аты?)
- [ ] **`src/db/migrations/`** (немесе `scripts/migrate.js` оқитын қалта) — миграция файлдарының **атау форматы** қандай (`001_*.sql`? timestamp?). Соңғы нөмірді тауып, келесісін қолдан.
- [ ] **`src/modules/`** — бір модульдің құрылымы қандай (мыс. `*.routes.ts` / `*.service.ts` / `*.schema.ts`)? Сол үлгіге сай жаз.
- [ ] **Роуттар `server.ts`-те қалай тіркеледі** — автолоадер ме, әлде қолмен `app.register(...)` ма?
- [ ] **`src/plugins/`** — `@fastify/jwt` қалай тіркелген? Токен беру `reply.jwtSign(...)` арқылы ма? `secret` қайдан алынады?
- [ ] **Юзер кестесі / модулі бар ма?** (`users` кестесі, телефон бағаны). OTP расталғаннан кейін юзерді тауып/құрып, токен беру керек. Бар схемаға жалған.
- [ ] **`@fastify/rate-limit`** тіркелген бе? Болмаса — тіркеу керек (OTP-ты brute-force-тан қорғау үшін міндетті).

> Әр нүктені тапқан соң, төмендегі кодтағы `🔌 ЖАЛҒАУ` деп белгіленген жерлерді нақты атауларға сай түзет.

---

## 2. Орта айнымалылары (`.env` және `.env.example`)

- [ ] Екеуіне де қос:

```env
WHATSAPP_TOKEN=               # Meta permanent token (System User арқылы)
WHATSAPP_PHONE_NUMBER_ID=     # тіркелген WhatsApp нөмірінің ID-і
WHATSAPP_TEMPLATE_NAME=traderos_otp
WHATSAPP_LANG=kk
OTP_EXPIRY_MINUTES=5
```

> Бар болса `src/config`-тағы env-валидация (zod?) схемасына осы 5 кілтті қос.

---

## 3. Миграция: `otp_codes` кестесі

- [ ] Миграция қалтасына жаңа файл жаса (атау форматын 1-қадамнан ал, мыс. `00X_otp_codes.sql`):

```sql
CREATE TABLE IF NOT EXISTS otp_codes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone       VARCHAR(20)  NOT NULL,
  code        VARCHAR(8)   NOT NULL,
  is_used     BOOLEAN      NOT NULL DEFAULT FALSE,
  expires_at  TIMESTAMPTZ  NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_otp_codes_phone ON otp_codes (phone);
```

- [ ] `gen_random_uuid()` үшін `pgcrypto` керек болса: `CREATE EXTENSION IF NOT EXISTS pgcrypto;`
- [ ] Миграцияны қолдан: `npm run db:migrate` және кестенің құрылғанын тексер.

---

## 4. WhatsApp сервисі: `src/services/whatsapp.service.ts`

- [ ] Файл жаса:

```ts
const API_URL = "https://graph.facebook.com/v22.0";

export async function sendOtpViaTemplate(phone: string, otpCode: string): Promise<boolean> {
  const token = process.env.WHATSAPP_TOKEN;
  const phoneNumberId = process.env.WHATSAPP_PHONE_NUMBER_ID;
  if (!token || !phoneNumberId) {
    console.error("WHATSAPP_TOKEN / WHATSAPP_PHONE_NUMBER_ID жоқ");
    return false;
  }

  const cleanPhone = phone.replace(/^\+/, ""); // +77... -> 77...
  const payload = {
    messaging_product: "whatsapp",
    to: cleanPhone,
    type: "template",
    template: {
      name: process.env.WHATSAPP_TEMPLATE_NAME,
      language: { code: process.env.WHATSAPP_LANG ?? "kk" },
      components: [
        { type: "body", parameters: [{ type: "text", text: otpCode }] },
        // "copy code" батырмасы. Template-те батырма ЖОҚ болса — мына блокты алып таста:
        { type: "button", sub_type: "url", index: "0",
          parameters: [{ type: "text", text: otpCode }] },
      ],
    },
  };

  try {
    const res = await fetch(`${API_URL}/${phoneNumberId}/messages`, {
      method: "POST",
      headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
      body: JSON.stringify(payload),
      signal: AbortSignal.timeout(30_000),
    });
    const data = await res.json();
    if (res.ok && data?.messages?.[0]?.id) {
      console.log(`WhatsApp OTP жіберілді ${phone}, id=${data.messages[0].id}`);
      return true;
    }
    console.error("WhatsApp API қатесі:", res.status, data);
    return false;
  } catch (err) {
    console.error(`WhatsApp сұраныс қатесі ${phone}:`, err);
    return false;
  }
}
```

---

## 5. OTP сервисі: `src/modules/auth/otp.service.ts`

- [ ] Файл жаса (`pool` импортын 1-қадамдағы нақты экспортқа түзет):

```ts
import { randomInt } from "node:crypto";
import { pool } from "../../db/index.js";              // 🔌 ЖАЛҒАУ: pg Pool экспорты
import { sendOtpViaTemplate } from "../../services/whatsapp.service.js";

const OTP_LENGTH = 4;
const DEBUG_MASTER_OTP = "9074";                        // тек dev үшін
const isProd = process.env.NODE_ENV === "production";

function generateCode(): string {
  return String(randomInt(0, 10 ** OTP_LENGTH)).padStart(OTP_LENGTH, "0");
}

export async function sendOtp(phone: string): Promise<void> {
  // ескі қолданылмаған кодтарды өшіру
  await pool.query(`DELETE FROM otp_codes WHERE phone = $1 AND is_used = FALSE`, [phone]);

  const code = generateCode();
  const minutes = Number(process.env.OTP_EXPIRY_MINUTES ?? 5);
  const expiresAt = new Date(Date.now() + minutes * 60_000);

  await pool.query(
    `INSERT INTO otp_codes (phone, code, expires_at) VALUES ($1, $2, $3)`,
    [phone, code, expiresAt],
  );

  const ok = await sendOtpViaTemplate(phone, code);
  if (!ok) throw new Error("OTP жіберілмеді");
  if (!isProd) console.log(`[DEBUG] OTP ${phone}: ${code}`);  // прод-та НИКОГДА логқа/жауапқа кодты жазба
}

export async function verifyOtp(phone: string, code: string): Promise<boolean> {
  // DEBUG мастер-код — тек dev-та (прод-та өткізілмейді)
  if (!isProd && code === DEBUG_MASTER_OTP) {
    console.warn(`DEBUG мастер-код қолданылды ${phone}`);
    return true;
  }

  const { rows } = await pool.query(
    `SELECT id, expires_at FROM otp_codes
     WHERE phone = $1 AND code = $2 AND is_used = FALSE
     ORDER BY created_at DESC LIMIT 1`,
    [phone, code],
  );
  const record = rows[0];
  if (!record) return false;
  if (new Date() > new Date(record.expires_at)) return false;

  await pool.query(`UPDATE otp_codes SET is_used = TRUE WHERE id = $1`, [record.id]);
  return true;
}
```

---

## 6. Роуттар: `src/modules/auth/auth.routes.ts`

- [ ] Бар модуль үлгісіне сай жаса. `reply.jwtSign` мен юзер-логиканы 1-қадамдағыға түзет:

```ts
import type { FastifyInstance } from "fastify";
import { z } from "zod";
import { sendOtp, verifyOtp } from "./otp.service.js";

const phoneSchema = z.object({ phone: z.string().min(5).max(20) });
const verifySchema = z.object({
  phone: z.string().min(5).max(20),
  otp_code: z.string().length(4),
});

export async function authRoutes(app: FastifyInstance) {
  app.post(
    "/auth/send-otp",
    { config: { rateLimit: { max: 3, timeWindow: "1 minute" } } }, // brute-force қорғаны
    async (req, reply) => {
      const { phone } = phoneSchema.parse(req.body);
      await sendOtp(phone);
      return reply.send({ message: "OTP коды WhatsApp-қа жіберілді" });
    },
  );

  app.post(
    "/auth/verify-otp",
    { config: { rateLimit: { max: 5, timeWindow: "1 minute" } } },
    async (req, reply) => {
      const { phone, otp_code } = verifySchema.parse(req.body);
      const ok = await verifyOtp(phone, otp_code);
      if (!ok) return reply.code(400).send({ message: "Дұрыс емес немесе мерзімі біткен код" });

      // 🔌 ЖАЛҒАУ: юзерді телефон бойынша тауып/құр (users кестесі), сосын токен бер
      const token = await reply.jwtSign({ phone });
      return reply.send({ message: "Телефон расталды", access_token: token });
    },
  );
}
```

---

## 7. Тіркеу: `src/server.ts`

- [ ] Модульді тіркеу үлгісіне сай қос (автолоадер болса — қалтаға салу жеткілікті):

```ts
import { authRoutes } from "./modules/auth/auth.routes.js";
await app.register(authRoutes);
```

- [ ] `@fastify/rate-limit` тіркелмеген болса, `authRoutes`-тан БҰРЫН тіркеу керек:

```ts
import rateLimit from "@fastify/rate-limit";
await app.register(rateLimit, { global: false }); // route-config арқылы ғана
```

---

## 8. Meta (WhatsApp) жағы — кодсыз, бірақ МІНДЕТТІ

> Бұл бөлік адам қолымен Meta панелінде жасалады. Agent орындай алмайды — пайдаланушыға еске сал.

- [ ] Meta Business аккаунт → developers.facebook.com → **WhatsApp Cloud API** app.
- [ ] Бизнес телефон нөмірін WhatsApp-қа тіркеу (verify).
- [ ] **Message Template** жаса (модерация бірнеше сағат-күн алуы мүмкін):
  - Категория: **Authentication**
  - Body: `{{1}}` (код), қаласаң "copy code" батырмасы.
  - Тіл: `kk` (немесе `.env`-тегі `WHATSAPP_LANG`-қа сәйкес).
  - Template аты `.env`-тегі `WHATSAPP_TEMPLATE_NAME`-ге сай болсын.
- [ ] **`WHATSAPP_PHONE_NUMBER_ID`** ал.
- [ ] **Permanent `WHATSAPP_TOKEN`** жаса (System User token). ⚠️ Уақытша token 24 сағатта өледі — өндіріске жарамайды.

---

## 9. Тестілеу

- [ ] `npm run typecheck` — қате жоқ.
- [ ] Dev: `npm run dev`.
- [ ] `POST /auth/send-otp` `{ "phone": "+77001234567" }` → 200.
- [ ] Кодты тексеру:
  - dev-та: лог `[DEBUG] OTP ...`-тан немесе `otp_codes` кестесінен оқы; не мастер-код `9074`.
  - нақты: WhatsApp хабарламасынан.
- [ ] `POST /auth/verify-otp` `{ "phone": "...", "otp_code": "...." }` → `access_token` қайтару.
- [ ] Мерзімі біткен / қате / қайта қолданылған код → 400.
- [ ] Rate-limit: 1 минутта 3-тен көп `send-otp` → 429.

---

## 10. Қауіпсіздік чеклисті (БҰЗБА)

- [ ] Прод-та OTP кодын жауапқа да, логқа да ҚАЙТАРМА (тек dev лог).
- [ ] `DEBUG_MASTER_OTP` (`9074`) тек `NODE_ENV !== "production"`-та жұмыс істейді.
- [ ] `send-otp` және `verify-otp` rate-limit-пен қорғалған.
- [ ] Permanent token .env-те, гитке кірмейді (`.gitignore` тексер).
- [ ] Код 1 рет қана қолданылады (`is_used`), 5 мин жарамды.
- [ ] (Қаласаң) `verify-otp`-қа сәтсіз әрекет санауышын қосып, N реттен кейін кодты жарамсыз ету.

---

### Қысқаша файл картасы (жасалатын/өзгеретін)
```
.env, .env.example                         (+5 кілт)
src/db/migrations/00X_otp_codes.sql        (жаңа)
src/services/whatsapp.service.ts           (жаңа)
src/modules/auth/otp.service.ts            (жаңа)
src/modules/auth/auth.routes.ts            (жаңа)
src/server.ts                              (роут + rate-limit тіркеу)
src/config/*                               (env схемасы бар болса — жаңарту)
```
