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
create unique index if not exists users_promo_code_idx on users(promo_code) where promo_code is not null;

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
  status         text not null default 'active',         -- active | closed_tp1 | closed_tp2 | closed_tp3 | closed_sl
  result_pips    int,
  source         text default 'admin',                   -- admin | telegram_bot
  source_message_id text,                                -- Telegram message id (TZ.rtf)
  created_by     uuid references users(id) on delete set null,  -- жариялаған трейдер (меншік тексеру)
  published_at   timestamptz default now(),
  closed_at      timestamptz
);
-- Бұрыннан бар БД-лар үшін (create table if not exists жаңа бағанды қоспайды):
alter table signals add column if not exists is_free boolean not null default false;
create index if not exists signals_status_published_idx on signals(status, published_at desc);

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
  dnd_until_morning boolean default true,                   -- 00:00–07:00
  expo_push_token  text,                                    -- Expo Push token (mobile-ден)
  updated_at       timestamptz default now()
);

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
  created_at   timestamptz default now()
);
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
