# TraderOS

XAU/USD трейдерлеріне арналған mobile қосымша. TraderOS TZ Final.docx + TZ.rtf түзетулері негізінде жасалған.

## Құрылым

```
EREN/
├── mobile/              Flutter mobile app (iOS + Android)
├── apps/
│   ├── backend/         Node.js + Fastify REST/WebSocket API
│   ├── admin/           Next.js админ панелі (подписка растау)
│   └── bot/             Telegram bot — сигналдарды қабылдау + парсинг
├── packages/
│   └── shared/          Ортақ types/zod схемалар (Node жобалары үшін)
├── docs/                ТЗ, архитектура, шешімдер
├── TraderOS TZ Final.docx
└── TZ.rtf               Соңғы түзетулер (override)
```

## Стек

- **Mobile**: Flutter (Dart), Riverpod, go_router, sqflite, dio, intl
- **Backend**: Node.js 20 + Fastify, TypeScript, Supabase (Postgres + Storage), Redis
- **Bot**: Node.js + grammY (Telegram), Claude API сигнал парсингі үшін
- **Admin**: Next.js + Supabase Auth
- **AI**: Anthropic Claude API (TZ.rtf override — OpenAI жоқ)
- **Prices**: Finnhub WebSocket (XAU/USD, DXY, XAG, USOIL)

## i18n

Үш тіл бірден: `ru` (орысша, default), `kk` (қазақша), `en` (ағылшынша). Mobile app-те пайдаланушы таңдайды.

## Тіркелу/Авторизация

SMS жоқ. Флоу: телефон номері → пароль қою → дайын.

## Подписка

30 күн, 30 000 ₸. Kaspi Pay сілтемесі → клиент чек жүктейді → менеджер қолмен растайды.

## Команда (Mobile)

```bash
cd mobile
flutter pub get
flutter run
```

## Команда (Backend жобалары)

```bash
pnpm install
pnpm backend:dev   # Fastify API
pnpm admin:dev     # Next.js admin
pnpm bot:dev       # Telegram bot
```
