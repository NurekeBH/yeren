-- ============================================================
-- TraderOS Postgres Schema
-- TZ §16.1 — толық таблица тізімі.
-- TZ.rtf override: SMS жоқ, phone + bcrypt(password).
-- ============================================================

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ─────────────────── USERS ───────────────────
create table if not exists users (
  id            uuid primary key default uuid_generate_v4(),
  phone         text not null unique,
  password_hash text not null,
  name          text default '',
  city          text default '',                       -- TZ user override: страна → город
  country       text default '',                       -- тіркеуде таңдалған ел (ISO-2: KZ/RU/UZ…) — тіл шешімі үшін
  bio           text default '',
  avatar_url    text,
  trading_styles text[] default array[]::text[],       -- multi-select: smc/price_action/breakout/news/scalping
  preferred_sessions text[] default array[]::text[],   -- asia/london/new_york/overlap
  locale        text default 'kk',                     -- kk | ru | en
  is_admin      boolean default false,
  is_verified_trader boolean not null default false,
  promo_code    text unique,                            -- трейдердің жеке промокоды
  referred_by   text,                                   -- тіркелуде енгізілген промокод
  bonus_balance integer not null default 0,             -- ₸ бонус (идея ашқанда жұмсалады)
  referral_count integer not null default 0,            -- кодпен тіркелгендер саны
  is_blocked    boolean not null default false,         -- админ бұғаттаған (кіре алмайды)
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
create index if not exists users_phone_idx on users(phone);
-- Бар базаларға бағандарды идемпотентті қосу
alter table users add column if not exists is_verified_trader boolean not null default false;
alter table users add column if not exists promo_code text unique;
alter table users add column if not exists referred_by text;
alter table users add column if not exists bonus_balance integer not null default 0;
alter table users add column if not exists referral_count integer not null default 0;
alter table users add column if not exists is_blocked boolean not null default false;
alter table users add column if not exists country text default '';
create unique index if not exists users_promo_code_idx on users(promo_code) where promo_code is not null;

-- ─────────────────── ҚАЛАЛАР (оқиға фильтрі/нотификациясы үшін тұрақты тізім) ───────────────────
create table if not exists cities (
  id      serial primary key,
  name    text not null unique,
  country text not null default 'KZ'
);
create index if not exists cities_name_idx on cities (lower(name));
-- Негізгі ҚР қалалары + ТМД астаналары (autocomplete үшін). On conflict — қозғамайды.
insert into cities (name, country) values
  ('Алматы','KZ'),('Астана','KZ'),('Шымкент','KZ'),('Қарағанды','KZ'),('Ақтөбе','KZ'),
  ('Тараз','KZ'),('Павлодар','KZ'),('Өскемен','KZ'),('Семей','KZ'),('Атырау','KZ'),
  ('Қостанай','KZ'),('Қызылорда','KZ'),('Орал','KZ'),('Петропавл','KZ'),('Ақтау','KZ'),
  ('Темиртау','KZ'),('Түркістан','KZ'),('Көкшетау','KZ'),('Талдықорған','KZ'),('Екібастұз','KZ'),
  ('Жезқазған','KZ'),('Балқаш','KZ'),('Кентау','KZ'),('Рудный','KZ'),('Жанаөзен','KZ'),
  ('Москва','RU'),('Санкт-Петербург','RU'),('Казань','RU'),('Новосибирск','RU'),('Екатеринбург','RU'),
  ('Ташкент','UZ'),('Самарканд','UZ'),('Бишкек','KG'),('Ош','KG'),('Душанбе','TJ'),
  ('Ашхабад','TM'),('Баку','AZ'),('Тбилиси','GE'),('Ереван','AM'),('Минск','BY'),
  ('Киев','UA'),('Стамбул','TR'),('Дубай','AE')
on conflict (name) do nothing;

-- Латын/орыс транслитерация баламалары (теру кезінде табылу үшін — мыс. «almaty», «aktobe»,
-- «Актобе» де Ақтөбені табады). aliases бағаны + іздеу name ЖӘНЕ aliases бойынша жүреді.
alter table cities add column if not exists aliases text not null default '';
create index if not exists cities_aliases_idx on cities (lower(aliases));
update cities set aliases = v.aliases from (values
  ('Алматы','almaty alma-ata алма-ата алмата'),
  ('Астана','astana nur-sultan нурсултан нур-султан целиноград акмола'),
  ('Шымкент','shymkent chimkent чимкент шымкент'),
  ('Қарағанды','karaganda караганда qaragandy karagandy'),
  ('Ақтөбе','aktobe актобе aktyubinsk актюбинск'),
  ('Тараз','taraz джамбул jambyl jambul'),
  ('Павлодар','pavlodar павлодар'),
  ('Өскемен','oskemen ust-kamenogorsk усть-каменогорск ускемен'),
  ('Семей','semey semei semipalatinsk семипалатинск'),
  ('Атырау','atyrau guryev гурьев'),
  ('Қостанай','kostanay костанай kustanai кустанай'),
  ('Қызылорда','kyzylorda кызылорда qyzylorda'),
  ('Орал','oral uralsk уральск'),
  ('Петропавл','petropavl petropavlovsk петропавловск'),
  ('Ақтау','aktau актау shevchenko шевченко'),
  ('Темиртау','temirtau темиртау'),
  ('Түркістан','turkistan turkestan туркестан'),
  ('Көкшетау','kokshetau кокшетау'),
  ('Талдықорған','taldykorgan талдыкорган taldyqorgan'),
  ('Екібастұз','ekibastuz экибастуз'),
  ('Жезқазған','zhezkazgan жезказган'),
  ('Балқаш','balkhash балхаш'),
  ('Кентау','kentau кентау'),
  ('Рудный','rudny рудный rudniy'),
  ('Жанаөзен','zhanaozen жанаозен'),
  ('Москва','moscow moskva москва'),
  ('Санкт-Петербург','saint petersburg spb питер санкт-петербург sankt-peterburg'),
  ('Казань','kazan казань'),
  ('Новосибирск','novosibirsk новосибирск'),
  ('Екатеринбург','ekaterinburg yekaterinburg екатеринбург'),
  ('Ташкент','tashkent toshkent ташкент'),
  ('Самарканд','samarkand самарканд'),
  ('Бишкек','bishkek бишкек frunze фрунзе'),
  ('Ош','osh ош'),
  ('Душанбе','dushanbe душанбе'),
  ('Ашхабад','ashgabat ashkhabad ашхабад'),
  ('Баку','baku baki баку'),
  ('Тбилиси','tbilisi тбилиси'),
  ('Ереван','yerevan erevan ереван'),
  ('Минск','minsk минск'),
  ('Киев','kyiv kiev киев'),
  ('Стамбул','istanbul стамбул'),
  ('Дубай','dubai дубай')
) as v(name, aliases) where cities.name = v.name;

-- ҚР / Өзбекстан / Қырғызстан қалаларын ТОЛЫҚ қосу (autocomplete). on conflict — қозғамайды.
insert into cities (name, country) values
  -- Қазақстан (облыс орталықтары + аумақтық маңызы бар қалалар)
  ('Ақсу','KZ'),('Арқалық','KZ'),('Арыс','KZ'),('Атбасар','KZ'),('Аягөз','KZ'),
  ('Байқоңыр','KZ'),('Қонаев','KZ'),('Қандыағаш','KZ'),('Қаражал','KZ'),('Қаратау','KZ'),
  ('Қарқаралы','KZ'),('Қаскелең','KZ'),('Құлсары','KZ'),('Лисаковск','KZ'),('Макинск','KZ'),
  ('Сарань','KZ'),('Сәтбаев','KZ'),('Степногорск','KZ'),('Тайынша','KZ'),('Текелі','KZ'),
  ('Үшарал','KZ'),('Үштөбе','KZ'),('Хромтау','KZ'),('Шалқар','KZ'),('Шахтинск','KZ'),
  ('Шемонаиха','KZ'),('Шу','KZ'),('Щучинск','KZ'),('Ерейментау','KZ'),('Абай','KZ'),
  ('Алға','KZ'),('Арал','KZ'),('Шардара','KZ'),('Сарыағаш','KZ'),('Ленгір','KZ'),
  ('Жаркент','KZ'),('Есік','KZ'),('Жітіқара','KZ'),('Зайсан','KZ'),('Жетісай','KZ'),
  ('Жаңатас','KZ'),('Қазалы','KZ'),('Сарқан','KZ'),('Риддер','KZ'),('Курчатов','KZ'),
  ('Приозерск','KZ'),('Темір','KZ'),('Шар','KZ'),('Степняк','KZ'),('Серебрянск','KZ'),
  ('Форт-Шевченко','KZ'),('Шортанды','KZ'),('Мамлютка','KZ'),('Сергеевка','KZ'),('Есіл','KZ'),
  -- Өзбекстан
  ('Бухара','UZ'),('Наманган','UZ'),('Андижан','UZ'),('Нукус','UZ'),('Фергана','UZ'),
  ('Карши','UZ'),('Коканд','UZ'),('Маргилан','UZ'),('Хива','UZ'),('Ургенч','UZ'),
  ('Джизак','UZ'),('Навои','UZ'),('Термез','UZ'),('Гулистан','UZ'),('Чирчик','UZ'),
  ('Ангрен','UZ'),('Алмалык','UZ'),('Шахрисабз','UZ'),
  -- Қырғызстан
  ('Джалал-Абад','KG'),('Каракол','KG'),('Токмок','KG'),('Кара-Балта','KG'),('Узген','KG'),
  ('Балыкчы','KG'),('Нарын','KG'),('Талас','KG'),('Кызыл-Кия','KG'),('Баткен','KG'),
  ('Кант','KG'),('Чолпон-Ата','KG'),('Майлуу-Суу','KG')
on conflict (name) do nothing;

-- Жаңа қалалардың латын/орыс баламалары (теру кезінде табылу үшін).
update cities set aliases = v.aliases from (values
  ('Ақсу','aksu аксу'),('Арқалық','arkalyk аркалык'),('Арыс','arys арысь'),
  ('Атбасар','atbasar атбасар'),('Аягөз','ayagoz аягоз'),('Байқоңыр','baikonur байконур baikonyr'),
  ('Қонаев','konaev konaev kapshagay капшагай қапшағай qonaev'),('Қандыағаш','kandyagash кандыагаш'),
  ('Қаражал','karazhal каражал'),('Қаратау','karatau каратау'),('Қарқаралы','karkaralinsk каркаралинск karkaraly'),
  ('Қаскелең','kaskelen каскелен'),('Құлсары','kulsary кульсары qulsary'),('Лисаковск','lisakovsk лисаковск'),
  ('Макинск','makinsk макинск'),('Сарань','saran сарань'),('Сәтбаев','satbaev сатпаев satpaev nikoltsevka'),
  ('Степногорск','stepnogorsk степногорск'),('Тайынша','tayynsha таинша'),('Текелі','tekeli текели'),
  ('Үшарал','usharal ушарал'),('Үштөбе','ushtobe уштобе'),('Хромтау','khromtau хромтау'),
  ('Шалқар','shalkar шалкар'),('Шахтинск','shakhtinsk шахтинск'),('Шемонаиха','shemonaikha шемонаиха'),
  ('Шу','shu шу chu'),('Щучинск','shchuchinsk щучинск'),('Ерейментау','ereymentau ерейментау'),
  ('Абай','abai абай'),('Алға','alga алга'),('Арал','aral арал аралы aralsk'),
  ('Шардара','shardara шардара'),('Сарыағаш','saryagash сарыагаш'),('Ленгір','lenger ленгер lengir'),
  ('Жаркент','zharkent жаркент'),('Есік','esik есик issyk иссык'),('Жітіқара','zhitikara житикара'),
  ('Зайсан','zaisan зайсан'),('Жетісай','zhetysai жетысай'),('Жаңатас','zhanatas жанатас'),
  ('Қазалы','kazaly казалинск qazaly'),('Сарқан','sarkand сарканд sarqan'),('Риддер','ridder риддер leninogorsk'),
  ('Курчатов','kurchatov курчатов'),('Приозерск','priozersk приозерск'),('Темір','temir темир'),
  ('Шар','shar шар'),('Степняк','stepnyak степняк'),('Серебрянск','serebryansk серебрянск'),
  ('Форт-Шевченко','fort-shevchenko форт-шевченко'),('Шортанды','shortandy шортанды'),
  ('Мамлютка','mamlyutka мамлютка'),('Сергеевка','sergeevka сергеевка'),('Есіл','esil есиль'),
  ('Бухара','bukhara бухара buxoro'),('Наманган','namangan наманган'),('Андижан','andijan андижан andijon'),
  ('Нукус','nukus нукус'),('Фергана','fergana фергана fargona'),('Карши','karshi карши qarshi'),
  ('Коканд','kokand коканд qoqon'),('Маргилан','margilan маргилан margilon'),('Хива','khiva хива xiva'),
  ('Ургенч','urgench ургенч urganch'),('Джизак','jizzakh джизак jizzax'),('Навои','navoi навои navoiy'),
  ('Термез','termez термез termiz'),('Гулистан','gulistan гулистан guliston'),('Чирчик','chirchik чирчик chirchiq'),
  ('Ангрен','angren ангрен'),('Алмалык','almalyk алмалык olmaliq'),('Шахрисабз','shakhrisabz шахрисабз shahrisabz'),
  ('Джалал-Абад','jalal-abad джалал-абад jalalabad'),('Каракол','karakol каракол'),('Токмок','tokmok токмок tokmak'),
  ('Кара-Балта','kara-balta кара-балта karabalta'),('Узген','uzgen узген ozgon'),('Балыкчы','balykchy балыкчы balykchi'),
  ('Нарын','naryn нарын'),('Талас','talas талас'),('Кызыл-Кия','kyzyl-kiya кызыл-кия kyzylkiya'),
  ('Баткен','batken баткен'),('Кант','kant кант'),('Чолпон-Ата','cholpon-ata чолпон-ата cholponata'),
  ('Майлуу-Суу','mailuu-suu майлуу-суу mailuusuu')
) as v(name, aliases) where cities.name = v.name;

-- ─────────────────── SESSIONS / REFRESH TOKENS ───────────────────
create table if not exists user_sessions (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references users(id) on delete cascade,
  jwt_jti    text not null unique,
  user_agent text,
  ip         text,
  created_at timestamptz default now(),
  expires_at timestamptz not null,
  revoked_at timestamptz
);
create index if not exists sessions_user_idx on user_sessions(user_id);

-- ─────────────────── BROKER ACCOUNTS (TZ §9.2-9.4) ───────────────────
-- MT4/MT5: account # + server + AES-256-GCM шифрленген investor password.
-- cTrader: OAuth (refresh_token шифрленген).
create table if not exists broker_accounts (
  id                       uuid primary key default uuid_generate_v4(),
  user_id                  uuid not null references users(id) on delete cascade,
  broker_name              text not null,                -- exness | ic_markets | xm | pepperstone | oanda | fxpro | other
  platform                 text not null,                -- mt4 | mt5 | ctrader
  account_number           text not null,
  server                   text,                          -- MT4/MT5
  investor_password_cipher bytea,                         -- AES-256-GCM ciphertext+iv+tag (server-side only)
  ctrader_refresh_cipher   bytea,                         -- cTrader OAuth refresh
  balance                  numeric(14,2) default 0,
  currency                 text default 'USD',
  is_oauth                 boolean default false,
  linked_at                timestamptz default now(),
  synced_at                timestamptz,
  removed_at               timestamptz
);
create index if not exists brokers_user_idx on broker_accounts(user_id) where removed_at is null;

-- ─────────────────── TRADES (TZ §9.5) ───────────────────
create table if not exists trades (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references users(id) on delete cascade,
  account_id    uuid references broker_accounts(id) on delete set null,
  instrument    text not null default 'XAU/USD',
  direction     text not null,                           -- buy | sell
  open_price    numeric(14,4) not null,
  close_price   numeric(14,4),
  lot           numeric(8,4) not null,
  pnl           numeric(14,2),
  rr_planned    numeric(6,2),
  rr_actual     numeric(6,2),
  setup_tag     text,                                    -- retest|breakout|smc_ob|reversal|news|fvg
  session_tag   text,                                    -- asia|london|new_york|overlap
  emotion       text,                                    -- 😤|😬|😐|🙂|😌
  screenshot_url text,
  notes         text,
  ai_analysis   text,                                    -- Claude pattern detection
  source        text default 'manual',                   -- manual|mt_ea|ctrader_oauth|signal_copy
  opened_at     timestamptz not null,
  closed_at     timestamptz,
  created_at    timestamptz default now()
);
create index if not exists trades_user_opened_idx on trades(user_id, opened_at desc);
create index if not exists trades_account_idx on trades(account_id);

-- ═══════════════ TRADING JOURNAL v2 (MT investor-password sync + statement import) ═══════════════
-- Архитектура: брокерден синхрондалған ФАКТІЛЕР (journal_trades) пайдаланушы
-- АННОТАЦИЯЛАРЫНАН (trade_metadata) бөлінген. Қайта синхрон трейд фактілерін upsert
-- етеді (ticket бойынша идемпотент), бірақ тег/скриншот/эмоцияны ЕШҚАШАН өшірмейді.

-- Брокерлік аккаунттар. Investor (read-only) пароль AES-256-GCM-мен шифрленеді
-- (қабат: src/services/journal/crypto.ts). Plaintext ешқашан сақталмайды.
create table if not exists trading_accounts (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid not null references users(id) on delete cascade,
  broker          text not null,                            -- exness | xm | ic_markets | manual | ...
  platform        text not null default 'mt5',              -- mt4 | mt5 | manual
  login           text not null,                            -- MT аккаунт нөмірі ('manual' — қол режимі)
  server          text not null default '',                 -- MT сервер атауы
  account_name    text,
  currency        text not null default 'USD',
  investor_password_cipher text,                            -- AES-256-GCM: iv:tag:ciphertext (base64)
  balance         numeric(16,2),
  equity          numeric(16,2),
  sync_state      text not null default 'idle',             -- idle|connecting|fetching|upserting|ok|error
  sync_error      text,
  last_synced_at  timestamptz,
  created_at      timestamptz default now(),
  removed_at      timestamptz,
  unique (user_id, platform, login, server)
);
create index if not exists trading_accounts_user_idx on trading_accounts(user_id) where removed_at is null;

-- Брокерден синхрондалған сделка ФАКТІЛЕРІ. (account_id, ticket_id) UNIQUE → идемпотент upsert.
create table if not exists journal_trades (
  id            uuid primary key default uuid_generate_v4(),
  account_id    uuid not null references trading_accounts(id) on delete cascade,
  user_id       uuid not null references users(id) on delete cascade,
  ticket_id     text not null,                              -- брокер тикеті (manual → генерация)
  symbol        text not null,                              -- XAUUSD, EURUSD...
  side          text not null,                              -- buy | sell
  volume        numeric(12,4) not null,                     -- лот
  open_price    numeric(16,5) not null,
  close_price   numeric(16,5),
  sl            numeric(16,5),
  tp            numeric(16,5),
  commission    numeric(16,4) not null default 0,
  swap          numeric(16,4) not null default 0,
  profit        numeric(16,4) not null default 0,           -- таза P&L (валютада)
  pips          numeric(12,2),                              -- есептелген пипс
  opened_at     timestamptz not null,
  closed_at     timestamptz,                                -- null → ашық позиция
  source        text not null default 'mt_sync',            -- mt_sync | import_html | import_csv | manual
  created_at    timestamptz default now(),
  updated_at    timestamptz default now(),
  unique (account_id, ticket_id)
);
create index if not exists journal_trades_user_idx on journal_trades(user_id, closed_at desc nulls first);
create index if not exists journal_trades_account_idx on journal_trades(account_id, closed_at desc);
create index if not exists journal_trades_symbol_idx on journal_trades(user_id, symbol);

-- Пайдаланушы аннотациялары — синхрон ЕШҚАШАН өшірмейді (тұрақты (account_id, ticket_id) кілт).
create table if not exists trade_metadata (
  account_id     uuid not null references trading_accounts(id) on delete cascade,
  ticket_id      text not null,
  user_id        uuid not null references users(id) on delete cascade,
  setup_tag      text,                                      -- retest|breakout|smc_ob|reversal|news|fvg
  session_tag    text,                                      -- asia|london|new_york|overlap
  emotion        text,                                      -- 😤|😬|😐|🙂|😌
  grade          text,                                      -- A | B | C
  rr_planned     numeric(8,2),
  screenshot_url text,
  notes          text,
  tags           text[] not null default '{}',
  updated_at     timestamptz default now(),
  primary key (account_id, ticket_id)
);
create index if not exists trade_metadata_user_idx on trade_metadata(user_id);

-- ─────────────────── SIGNALS (TZ §10) ───────────────────
create table if not exists signals (
  id             uuid primary key default uuid_generate_v4(),
  pair           text not null default 'XAU/USD',
  direction      text not null,                          -- buy | sell
  entry_from     numeric(14,4) not null,
  entry_to       numeric(14,4) not null,
  tp1            numeric(14,4) not null,
  tp2            numeric(14,4),
  tp3            numeric(14,4),
  sl             numeric(14,4) not null,
  rr             numeric(6,2) not null,
  confidence     int not null check (confidence between 0 and 100),
  screenshot_url text,
  analysis       text not null,
  is_free        boolean not null default false,          -- тегін идея (paywall жоқ)
  status         text not null default 'active',         -- active | closed_tp1 | closed_tp2 | closed_tp3 | closed_sl | expired
  result_pips    int,
  source         text default 'admin',                   -- admin | telegram_bot
  source_message_id text,                                -- Telegram message id (TZ.rtf)
  created_by     uuid references users(id) on delete set null,  -- жариялаған трейдер (меншік тексеру)
  published_at   timestamptz default now(),
  closed_at      timestamptz,
  deleted_at     timestamptz,                            -- АНТИ-ФРОД: жұмсақ жою (статистика сақталады)
  auto_closed    boolean not null default false          -- тірі баға SL/TP-ке тигенде сервер автоматты жапты
);
-- Бұрыннан бар БД-лар үшін (create table if not exists жаңа бағанды қоспайды):
alter table signals add column if not exists is_free boolean not null default false;
-- АНТИ-ФРОД бағандары: жоғалтқан идеяны өшіріп немесе мәңгі «active» қалдырып
-- статистиканы бұрмалауға жол бермейміз (soft-delete + price-truth авто-шешу).
alter table signals add column if not exists deleted_at timestamptz;
alter table signals add column if not exists auto_closed boolean not null default false;
create index if not exists signals_status_published_idx on signals(status, published_at desc);
-- Авто-шешуші тірі активтерді жылдам табу үшін (жойылмаған, әлі ашық).
create index if not exists signals_active_open_idx on signals(status) where status = 'active' and deleted_at is null;

-- ─────────────────── INTEL POSTS (TZ §7) ───────────────────
create table if not exists intel_posts (
  id             uuid primary key default uuid_generate_v4(),
  source         text not null,                          -- bloomberg | reuters | fxstreet | trump_x | rss-...
  external_id    text,                                   -- dedup hash
  text           text not null,
  impact         text not null,                          -- bullish | bearish | neutral
  xau_move       numeric(8,2),
  analysis       text,                                   -- Claude/GPT талдау (TZ.rtf: Claude)
  support        numeric(14,4),
  resistance     numeric(14,4),
  suggested_sl   numeric(14,4),
  sentiment      int check (sentiment between 0 and 100),
  is_urgent      boolean default false,
  published_at   timestamptz not null,
  fetched_at     timestamptz default now()
);
create unique index if not exists intel_dedup_idx on intel_posts(source, external_id) where external_id is not null;
create index if not exists intel_published_idx on intel_posts(published_at desc);

-- ─────────────────── CALENDAR EVENTS (TZ §8) ───────────────────
create table if not exists calendar_events (
  id              uuid primary key default uuid_generate_v4(),
  external_id     text unique,                            -- Finnhub id үшін
  name            text not null,
  currency        text not null,
  impact          text not null,                          -- low | medium | high
  forecast        text,
  previous        text,
  actual          text,
  gold_impact_note text,                                  -- Claude classification
  scheduled_at    timestamptz not null,
  reminder_sent   boolean not null default false          -- push еске салу жіберілді ме
);
alter table calendar_events add column if not exists reminder_sent boolean not null default false;
create index if not exists calendar_scheduled_idx on calendar_events(scheduled_at);
create index if not exists calendar_impact_idx on calendar_events(impact, scheduled_at);

-- ─────────────────── EDGE ACADEMY (TZ §11) ───────────────────
create table if not exists lessons (
  id               uuid primary key default uuid_generate_v4(),
  profile_type     text not null,                         -- revenge | uncontrolled_risk | hope | disciplined
  source_type      text not null,                         -- book | trader | film
  source_name      text not null,
  title            text not null,
  quote            text not null,
  explanation      text not null,
  gold_application text not null,
  quick_check      text not null,
  xp               int not null default 25,
  tag              text not null,                         -- psychology | risk | strategy | discipline | mindset
  generated_by     text default 'seed',                   -- seed | claude
  generated_at     timestamptz default now()
);
create index if not exists lessons_profile_idx on lessons(profile_type);

create table if not exists user_lesson_progress (
  user_id            uuid not null references users(id) on delete cascade,
  lesson_id          uuid not null references lessons(id) on delete cascade,
  quick_check_answer text,
  completed_at       timestamptz default now(),
  primary key (user_id, lesson_id)
);

-- Gallup тест нәтижелері (TZ §11.2)
create table if not exists user_test_results (
  id           uuid primary key default uuid_generate_v4(),
  user_id      uuid not null references users(id) on delete cascade,
  profile_type text not null,                              -- доминант профиль
  scores       jsonb not null,                             -- {revenge: 5, ...}
  taken_at     timestamptz default now()
);
create index if not exists test_results_user_idx on user_test_results(user_id, taken_at desc);

-- Streak / XP / weekly progress (TZ §11.5)
create table if not exists user_progress (
  user_id        uuid primary key references users(id) on delete cascade,
  xp             int default 0,
  streak         int default 0,
  last_completed date,
  week_progress  boolean[] default array[false,false,false,false,false,false,false],
  updated_at     timestamptz default now()
);

-- ─────────────────── ACADEMY LESSONS v2 (психология сабақтары — DB жалғыз дереккөз) ───────────────────
-- Бұрын аппта mock болатын курстелген сабақтар. Локализацияланатын мәтін jsonb {ru,kk,en}.
-- Ескі `lessons` (uuid) кестесінен бөлек — id мобайл пішімінде ('l-001').
create table if not exists academy_lessons (
  id               text primary key,                      -- 'l-001'
  profile_type     text not null,                         -- revenge|uncontrolledRisk|hope|disciplined
  source_type      text not null,                         -- book|trader|film|podcast
  source_name      text not null default '',
  tag              text,                                  -- psychology|risk|strategy|discipline|mindset
  xp               int not null default 25,
  external_url     text,
  title            jsonb not null default '{}'::jsonb,    -- {ru,kk,en}
  quote            jsonb not null default '{}'::jsonb,
  explanation      jsonb not null default '{}'::jsonb,
  gold_application jsonb not null default '{}'::jsonb,
  quick_check      jsonb not null default '{}'::jsonb,    -- {question:{ru,kk,en}, options:{ru:[],kk:[],en:[]}, correctIndex}
  sort_order       int not null default 0,
  is_published     boolean not null default true,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now()
);
create index if not exists academy_lessons_profile_idx on academy_lessons(profile_type, sort_order) where is_published;

-- ─────────────────── GALLUP TEST сұрақтары (трейдер профилін анықтау) ───────────────────
create table if not exists gallup_questions (
  id         text primary key,                            -- 'q1'
  text       jsonb not null default '{}'::jsonb,          -- {ru,kk,en}
  options    jsonb not null default '[]'::jsonb,          -- [{label:{ru,kk,en}, scores:{revenge:n,...}}]
  sort_order int not null default 0,
  created_at timestamptz default now()
);

-- ─────────────────── SUBSCRIPTIONS (TZ.rtf override: Kaspi qoldan) ───────────────────
create table if not exists subscriptions (
  id           uuid primary key default uuid_generate_v4(),
  user_id      uuid not null references users(id) on delete cascade,
  status       text not null default 'inactive',            -- inactive | pending_review | active | expired
  amount       numeric(10,2) default 30000,
  currency     text default 'KZT',
  receipt_url  text,                                         -- Kaspi чек screenshot (Supabase Storage)
  submitted_at timestamptz,
  approved_by  uuid references users(id),                    -- admin who approved
  activated_at timestamptz,
  expires_at   timestamptz,
  notes        text,
  created_at   timestamptz default now()
);
create index if not exists subs_user_status_idx on subscriptions(user_id, status);

-- ─────────────────── NOTIFICATION PREFERENCES (TZ §12.2) ───────────────────
create table if not exists notification_prefs (
  user_id          uuid primary key references users(id) on delete cascade,
  signals_on       boolean default true,
  intel_on         boolean default true,
  calendar_on      boolean default true,
  ideas_on         boolean default true,
  review_on        boolean default true,
  academy_on       boolean default true,
  broker_on        boolean default true,
  streak_on        boolean default true,
  events_on        boolean default true,
  -- Оқиға push детальді сүзгілері (events_on=жалпы қосқыш; бос/false = фильтрсіз).
  ev_city          text default '',                          -- '' = кез келген қала
  ev_free_only     boolean default false,                    -- тек тегін оқиғалар
  ev_online_only   boolean default false,                    -- тек онлайн
  ev_type          text default '',                          -- '' = кез келген; masterclass|live_trade|webinar
  dnd_until_morning boolean default true,                   -- 00:00–07:00
  expo_push_token  text,                                    -- Expo Push token (mobile-ден)
  updated_at       timestamptz default now()
);
alter table notification_prefs add column if not exists ev_city text default '';
alter table notification_prefs add column if not exists ev_free_only boolean default false;
alter table notification_prefs add column if not exists ev_online_only boolean default false;
alter table notification_prefs add column if not exists ev_type text default '';
alter table notification_prefs add column if not exists events_on boolean default true;

-- ─────────────────── SIGNAL PROVIDERS (Ideas aggregator) ───────────────────
-- Бірнеше трейдер сигнал/идея береді. Статусты админ береді (verified).
create table if not exists signal_providers (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid references users(id) on delete set null,  -- провайдер аккаунты (қалауыңша)
  name            text not null,
  avatar          text default '📊',                              -- эмодзи аватар немесе url
  bio             text default '',
  win_rate        numeric(5,4) default 0,                         -- 0..1
  avg_rr          numeric(6,2) default 0,
  rating          numeric(3,2) default 0,                         -- 0..5
  subscribers     int default 0,
  trades_count    int default 0,
  price_per_month numeric(10,2) default 0,                        -- 0 = тегін, ₸
  verified        boolean default false,                          -- админ берген статус
  created_at      timestamptz default now()
);
create index if not exists providers_rating_idx on signal_providers(verified, rating desc);

create table if not exists provider_subscriptions (
  user_id     uuid not null references users(id) on delete cascade,
  provider_id uuid not null references signal_providers(id) on delete cascade,
  created_at  timestamptz default now(),
  primary key (user_id, provider_id)
);
create index if not exists prov_subs_user_idx on provider_subscriptions(user_id);

-- Сигналды провайдерге байлау
alter table signals add column if not exists provider_id uuid references signal_providers(id) on delete set null;
create index if not exists signals_provider_idx on signals(provider_id);

-- Сигналды жариялаған трейдерге байлау (меншік: тек өз сигналын жабу/жаңарту)
alter table signals add column if not exists created_by uuid references users(id) on delete set null;
create index if not exists signals_created_by_idx on signals(created_by);

-- ─────────────────── TRADER APPLICATIONS (расталған трейдер өтінімі) ───────────────────
create table if not exists trader_applications (
  id           uuid primary key default uuid_generate_v4(),
  user_id      uuid not null references users(id) on delete cascade,
  years        text,
  about        text not null,
  proof        text,
  status       text not null default 'pending',         -- pending | approved | rejected
  reviewed_by  uuid references users(id),
  reviewed_at  timestamptz,
  created_at   timestamptz default now()
);
create unique index if not exists trader_apps_one_pending on trader_applications(user_id) where status = 'pending';
create index if not exists trader_apps_status_idx on trader_applications(status, created_at desc);

-- ─────────────────── EVENTS (мастер-класс / лайв-трейд / вебинар) ───────────────────
create table if not exists events (
  id           uuid primary key default uuid_generate_v4(),
  type         text not null,                            -- masterclass | live_trade | webinar
  title        text not null,
  speaker      text not null,
  city         text not null,
  is_online    boolean default true,
  starts_at    timestamptz not null,
  price        numeric(10,2) default 0,                  -- 0 = тегін, ₸
  description  text not null,
  youtube_id   text,                                     -- видео-түсіндірме (қалауыңша)
  poster_url   text,
  is_approved  boolean not null default true,            -- админ растады ма (провайдер қосқан → false, растағанша app-та көрінбейді)
  created_by   uuid references users(id) on delete set null, -- кім қосты (провайдер модерациясы үшін)
  created_at   timestamptz default now()
);
-- Бар базаларға идемпотентті қосу (ескі оқиғалар көрінулі қалуы үшін default true)
alter table events add column if not exists is_approved boolean not null default true;
alter table events add column if not exists created_by uuid references users(id) on delete set null;
create index if not exists events_starts_idx on events(starts_at);

create table if not exists event_applications (
  id         uuid primary key default uuid_generate_v4(),
  event_id   uuid not null references events(id) on delete cascade,
  user_id    uuid not null references users(id) on delete cascade,
  name       text not null,
  phone      text not null,
  comment    text default '',
  status     text not null default 'new',               -- new | confirmed | cancelled
  created_at timestamptz default now(),
  unique (event_id, user_id)
);
create index if not exists event_apps_event_idx on event_applications(event_id);

-- ─────────────────── PRICE ALERTS (баға ескертулері) ───────────────────
create table if not exists price_alerts (
  id           uuid primary key default uuid_generate_v4(),
  user_id      uuid not null references users(id) on delete cascade,
  instrument   text not null default 'XAU/USD',
  target_price numeric(14,4) not null,
  pips         numeric(8,2),                             -- null болса — «нақты баға» режимі
  text         text not null,
  idea_id      uuid references signals(id) on delete set null,
  active       boolean default true,
  triggered_at timestamptz,
  created_at   timestamptz default now()
);
create index if not exists alerts_user_active_idx on price_alerts(user_id, active);

-- ─────────────────── LIBRARY USER DATA (сақтау / рейтинг / отзыв) ───────────────────
-- item_id — Flutter каталогының статик id-і (b-001, f-002, p-003...).
create table if not exists library_user_data (
  user_id    uuid not null references users(id) on delete cascade,
  item_id    text not null,
  saved      boolean default false,
  rating     int default 0 check (rating between 0 and 5),
  review     text default '',
  updated_at timestamptz default now(),
  primary key (user_id, item_id)
);
create index if not exists lib_user_saved_idx on library_user_data(user_id) where saved = true;
create index if not exists lib_item_idx on library_user_data(item_id);

-- ─────────────────── LIBRARY CATALOG (Кітап/Фильм/Подкаст — DB жалғыз дереккөз, админ басқарады) ───────────────────
-- Бұрын аппта mock fixture болатын каталог енді осында. Локализацияланатын мәтін
-- (summary/ideas/conclusion) jsonb {ru,kk,en} ретінде; құрылымдық өрістер бөлек бағандарда.
create table if not exists library_items (
  id            text primary key,                          -- 'b-1', 'f-12', 'p-30'
  category      text not null check (category in ('book','film','podcast')),
  title         text not null,
  author        text not null default '',                  -- автор / режиссёр / канал
  topic         text,                                      -- сұрыптау/топтау тақырыбы
  year          int,
  rating        numeric(4,2),
  rating_max    numeric(4,2) not null default 5,
  rating_source text,
  isbn          text,
  cover_url     text,
  youtube_id    text,                                      -- подкаст: YouTube video id
  external_url  text,
  lang          text,                                      -- подкаст: 'EN' | 'RU'
  summary       jsonb not null default '{}'::jsonb,        -- {ru,kk,en}
  ideas         jsonb not null default '{}'::jsonb,        -- {ru:[],kk:[],en:[]}
  conclusion    jsonb,                                     -- {ru,kk,en}
  sort_order    int not null default 0,
  is_published  boolean not null default true,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
create index if not exists library_items_cat_idx on library_items(category, sort_order) where is_published = true;

-- ─────────────────── COURSE CATALOG (Курстар — толық контент DB-де JSONB) ───────────────────
-- Әр курстың толық ағашы (модуль/сабақ/блок/квиз) тіл бойынша content jsonb-та:
--   content = { ru: <courseJson>, kk: <courseJson>, en: <courseJson> }.
-- title/subtitle/description тізім/админ ыңғайы үшін {ru,kk,en} болып бөлек хойстелген.
create table if not exists course_catalog (
  id           text primary key,                           -- курс id (мыс. 'masters')
  title        jsonb not null default '{}'::jsonb,         -- {ru,kk,en}
  subtitle     jsonb not null default '{}'::jsonb,
  description  jsonb not null default '{}'::jsonb,
  price_bonus  int not null default 0,
  emoji        text default '🧠',
  accent       bigint not null default 4280640491,         -- ARGB int (0xFF2563EB)
  cover_url    text,                                       -- видео-курс мұқабасы (URL немесе intro YouTube thumbnail)
  sort_order   int not null default 0,
  is_published boolean not null default true,
  content      jsonb not null default '{}'::jsonb,         -- curriculum: {modules→lessons}; video: {kind:'video',intro_video,modules:[{title,video,text}]}
  owner_id     uuid references users(id) on delete set null, -- провайдер қосқан курс иесі (null = платформа курсы)
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);
alter table course_catalog add column if not exists owner_id uuid references users(id) on delete set null;
alter table course_catalog add column if not exists cover_url text;
create index if not exists course_catalog_pub_idx on course_catalog(sort_order) where is_published = true;

-- ─────────────────── AGREEMENT ACCEPTANCES (заңды лог) ───────────────────
create table if not exists agreement_acceptances (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references users(id) on delete cascade,
  version     text not null default 'v1',
  ip          text,
  user_agent  text,
  accepted_at timestamptz default now()
);
create index if not exists agreement_user_idx on agreement_acceptances(user_id, accepted_at desc);

-- ─────────────────── TRADER POSTS (Published Ideas: фото/мәтін/лайк/коммент) ───────────────────
-- Провайдер бетіндегі әлеуметтік лента. Әр пост — сурет + мәтін, лайк пен коммент.
create table if not exists trader_posts (
  id          uuid primary key default uuid_generate_v4(),
  provider_id uuid not null references signal_providers(id) on delete cascade,
  text        text not null,
  image_url   text,                                          -- график скриншоты (қалауыңша)
  likes_count int default 0,                                 -- денормализацияланған санақ (trader_post_likes-тен)
  created_at  timestamptz default now()
);
create index if not exists trader_posts_provider_idx on trader_posts(provider_id, created_at desc);

create table if not exists trader_post_likes (
  post_id    uuid not null references trader_posts(id) on delete cascade,
  user_id    uuid not null references users(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (post_id, user_id)
);
create index if not exists trader_post_likes_user_idx on trader_post_likes(user_id);

create table if not exists trader_post_comments (
  id         uuid primary key default uuid_generate_v4(),
  post_id    uuid not null references trader_posts(id) on delete cascade,
  user_id    uuid references users(id) on delete set null,
  author     text not null,                                  -- көрсетілетін аты (snapshot)
  text       text not null,
  created_at timestamptz default now()
);
create index if not exists trader_post_comments_post_idx on trader_post_comments(post_id, created_at);

-- ─────────────────── POST REPORTS (пост шағымдары → админ модерациясы) ───────────────────
create table if not exists post_reports (
  id          uuid primary key default uuid_generate_v4(),
  post_id     uuid not null references trader_posts(id) on delete cascade,
  user_id     uuid not null references users(id) on delete cascade,   -- шағымданушы
  reason      text not null,                                          -- sexual|harmful|spam|harassment|misinfo|other
  note        text,
  status      text not null default 'open',                           -- open | resolved
  action      text,                                                   -- deleted | dismissed
  created_at  timestamptz default now(),
  reviewed_at timestamptz,
  unique (post_id, user_id)
);
create index if not exists post_reports_status_idx on post_reports(status, created_at desc);

-- ─────────────────── SIGNAL PURCHASES (ақылы идеялар) ───────────────────
-- Әр идея ақылы: TP 50–200 пипс → 500 ₸, 200 пипстен астам → 1000 ₸.
-- price_tg — сатып алу сәтіндегі баға (snapshot, серверде есептеледі).
create table if not exists signal_purchases (
  user_id    uuid not null references users(id) on delete cascade,
  signal_id  uuid not null references signals(id) on delete cascade,
  price_tg   int not null,
  bonus_used int not null default 0,                      -- қолданылған бонус (ұпай)
  created_at timestamptz default now(),
  primary key (user_id, signal_id)
);
alter table signal_purchases add column if not exists bonus_used int not null default 0;
create index if not exists signal_purchases_user_idx on signal_purchases(user_id, created_at desc);

-- ─────────────────── SIGNAL VOTES (нәтижеге дауыс) ───────────────────
-- Ашқан (төлеген/тегін) қолданушылар идея нәтижесіне дауыс береді: tp1|tp2|tp3|sl.
-- Бір қолданушы — бір дауыс (PK), қайта дауыс берсе on conflict жаңартылады.
create table if not exists signal_votes (
  user_id    uuid not null references users(id) on delete cascade,
  signal_id  uuid not null references signals(id) on delete cascade,
  outcome    text not null check (outcome in ('tp1','tp2','tp3','sl')),
  created_at timestamptz default now(),
  primary key (user_id, signal_id)
);
create index if not exists signal_votes_signal_idx on signal_votes(signal_id);

-- ─────────────────── SIGNAL UPDATES (трейдер follow-up хабарлары) ───────────────────
-- Трейдер өз идеясына timeline-апдейт қосады (мыс. «әлі ұстап тұрмын, TP3 күтемін»).
create table if not exists signal_updates (
  id         uuid primary key default uuid_generate_v4(),
  signal_id  uuid not null references signals(id) on delete cascade,
  text       text not null,
  created_at timestamptz default now()
);
create index if not exists signal_updates_signal_idx on signal_updates(signal_id, created_at);

-- ─────────────────── SUPPORT MESSAGES (қолдау → админ) ───────────────────
-- Пайдаланушы профильден жазған хабарлар админ-панельде көрінеді.
create table if not exists support_messages (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid references users(id) on delete set null,
  text       text not null,
  resolved   boolean not null default false,
  created_at timestamptz default now()
);
create index if not exists support_messages_idx on support_messages(resolved, created_at desc);

-- ─────────────────── HOUSEKEEPING ───────────────────
-- updated_at автоматты жаңарту үшін trigger функциясы
create or replace function set_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

drop trigger if exists trg_users_updated on users;
create trigger trg_users_updated before update on users
  for each row execute function set_updated_at();

drop trigger if exists trg_notifs_updated on notification_prefs;
create trigger trg_notifs_updated before update on notification_prefs
  for each row execute function set_updated_at();

-- ─────────────────── АКАДЕМИЯ КУРСТАРЫ + БОНУС ЛЕДЖЕР ───────────────────
-- Бонус транзакциялар журналы — монетизация дашбордының деректер көзі.
-- amount: + кіріс (топ-ап, реферал), − шығыс (курс/идея ашу).
create table if not exists bonus_transactions (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references users(id) on delete cascade,
  type       text not null,             -- topup | spend_course | spend_signal | referral | signup
  amount     integer not null,          -- бонус ұпай (+/−)
  ref        text,                      -- 'course:<id>' | 'signal:<id>' | 'kaspi'
  created_at timestamptz not null default now()
);
create index if not exists bonus_tx_user_idx on bonus_transactions(user_id, created_at desc);
create index if not exists bonus_tx_type_idx on bonus_transactions(type, created_at desc);

-- Курс сатып алулар (бонуспен ашу) — әр пайдаланушы әр курсты бір рет.
create table if not exists course_purchases (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references users(id) on delete cascade,
  course_id  text not null,
  bonus_used integer not null default 0,
  created_at timestamptz not null default now(),
  unique(user_id, course_id)
);
create index if not exists course_purchases_user_idx on course_purchases(user_id);
create index if not exists course_purchases_course_idx on course_purchases(course_id, created_at desc);

-- Курс прогресі — өтілген (learned) сабақтар.
create table if not exists course_progress (
  user_id      uuid not null references users(id) on delete cascade,
  course_id    text not null,
  lesson_id    text not null,
  completed_at timestamptz not null default now(),
  primary key (user_id, course_id, lesson_id)
);
create index if not exists course_progress_user_idx on course_progress(user_id, course_id);

-- Финалдық емтихан нәтижелері (курстан кейін).
create table if not exists exam_results (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references users(id) on delete cascade,
  course_id   text not null,
  score       integer not null,         -- дұрыс жауап саны
  total       integer not null,         -- сұрақ саны
  passed      boolean not null default false,
  per_module  jsonb not null default '{}'::jsonb,  -- {moduleIndex: {correct,total}}
  created_at  timestamptz not null default now()
);
create index if not exists exam_results_user_idx on exam_results(user_id, course_id, created_at desc);

-- ─────────────────── ОПТИМИЗАЦИЯ: ҚОСЫМША ИНДЕКСТЕР ───────────────────
-- Барлығы idempotent (if not exists) — миграцияда қайта қосуға қауіпсіз.
-- Админ тізімі/санағы + жаңа қолданушылар (created_at сұрыптау/сүзгі).
create index if not exists users_created_at_idx on users(created_at desc);
-- Провайдерге жазылғандар: хабарландыру тарату + жазылушылар саны.
create index if not exists prov_subs_provider_idx on provider_subscriptions(provider_id);
-- Идея сатып алуды тез тексеру (user_id + signal_id).
create index if not exists signal_purchases_user_signal_idx on signal_purchases(user_id, signal_id);
-- Қолданушының іс-шара өтінімдері.
create index if not exists event_apps_user_idx on event_applications(user_id);
-- Баға ескертулерін фонда тексеру: тек белсенді ескертулер (poller бүкіл базаны
-- сканерлемейді).
create index if not exists price_alerts_active_idx on price_alerts(instrument) where active;
-- Календарь push еске салуы: жіберілмеген оқиғалар ғана.
create index if not exists calendar_reminder_idx on calendar_events(scheduled_at) where not reminder_sent;
-- Курс/идея сатылым есебі (админ дашборды) + емтихан статистикасы.
create index if not exists exam_results_course_idx on exam_results(course_id, created_at desc);

-- ─────────────────── UPLOADS (суреттер — ӨЗ DB-де, Supabase емес) ───────────────────
-- Мұқаба/аватар/скриншот суреттері Postgres-те (bytea). GET /api/v1/uploads/:id арқылы беріледі.
create table if not exists uploads (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid references users(id) on delete set null,
  mime       text not null default 'image/jpeg',
  data       bytea not null,
  created_at timestamptz default now()
);
