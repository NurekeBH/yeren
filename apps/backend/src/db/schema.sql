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
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
create index if not exists users_phone_idx on users(phone);

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
  status         text not null default 'active',         -- active | closed_tp1 | closed_tp2 | closed_tp3 | closed_sl
  result_pips    int,
  source         text default 'admin',                   -- admin | telegram_bot
  source_message_id text,                                -- Telegram message id (TZ.rtf)
  published_at   timestamptz default now(),
  closed_at      timestamptz
);
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
  scheduled_at    timestamptz not null
);
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
