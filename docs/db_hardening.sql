-- ============================================================================
-- ALTYN — High-Load DB hardening (reference).
-- PostgreSQL 14+. Цель: sub-20ms выборки при 100k+ пользователей, ACID-балансы,
-- иммутабельный леджер. Живая схема — apps/backend/src/db/schema.sql; здесь —
-- целевые CONSTRAINTS/INDEXES. CHECK-констрейнты добавлять на проде через
-- ADD CONSTRAINT ... NOT VALID + VALIDATE CONSTRAINT (без долгой блокировки).
-- ============================================================================

-- ─────────────── SIGNALS ───────────────
create table if not exists signals (
  id            uuid primary key default gen_random_uuid(),
  trader_id     uuid not null references users(id) on delete cascade,   -- = created_by в живой схеме
  provider_id   uuid references signal_providers(id) on delete set null,
  asset         text not null default 'XAU/USD',
  type          text not null default 'advanced',                        -- bpe | advanced_engulf | ...
  direction     text not null check (direction in ('buy','sell')),
  entry_from    numeric(14,4) not null check (entry_from >= 0),
  entry_to      numeric(14,4) not null check (entry_to   >= 0),
  take_profit   numeric(14,4) check (take_profit >= 0),
  stop_loss     numeric(14,4) check (stop_loss   >= 0),
  is_premium    boolean not null default true,
  price_bonus   integer not null default 500 check (price_bonus in (0,500,1000)),
  confidence    int not null check (confidence between 0 and 100),
  status        text not null default 'active',
  published_at  timestamptz not null default now(),
  deleted_at    timestamptz
);

-- Составной ЧАСТИЧНЫЙ индекс под ленту активных идей (sub-20ms при 100k+):
-- фильтр deleted_at is null «зашит» в индекс → скан только «живых» строк.
create index if not exists idx_signals_active
  on signals (status, published_at desc)
  where deleted_at is null;

-- Идеи конкретного трейдера (профиль/выплаты) — только живые, новые сверху.
create index if not exists idx_signals_trader
  on signals (trader_id, published_at desc)
  where deleted_at is null;

-- Быстрый резолвер «активные, не удалённые» (фоновый авто-close по цене).
create index if not exists idx_signals_open
  on signals (status)
  where status = 'active' and deleted_at is null;

-- ─────────────── BONUS_TRANSACTIONS (иммутабельный леджер) ───────────────
-- Только INSERT. Баланс = сумма amount по user_id (единый источник правды,
-- без дублирующей колонки-баланса → нет рассинхрона). Дебет = amount < 0.
create table if not exists bonus_transactions (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(id) on delete cascade,
  amount     integer not null check (amount <> 0),
  kind       text not null check (kind in ('credit','debit')),
  reason     text not null,               -- payout | purchase_signal | referral_bonus | signup | topup
  ref        text,                        -- 'signal:<id>' | 'ref:<uid>' | 'kaspi'
  created_at timestamptz not null default now()
);

-- Леджер пользователя (баланс/история) — новые сверху.
create index if not exists idx_transactions_user
  on bonus_transactions (user_id, created_at desc);

-- Аналитика по типам (маркетинг-расход, монетизация).
create index if not exists idx_transactions_reason
  on bonus_transactions (reason, created_at desc);

-- ИММУТАБЕЛЬНОСТЬ на уровне БД: запрет UPDATE/DELETE строк леджера.
create or replace function ledger_immutable() returns trigger as $$
begin
  raise exception 'bonus_transactions is append-only';
end; $$ language plpgsql;

drop trigger if exists trg_ledger_immutable on bonus_transactions;
create trigger trg_ledger_immutable
  before update or delete on bonus_transactions
  for each row execute function ledger_immutable();

-- ─────────────── PROVIDER_PAYOUTS (выплаты трейдерам) ───────────────
create table if not exists provider_payouts (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references users(id) on delete cascade,
  provider_id uuid references signal_providers(id) on delete set null,
  amount      numeric(14,2) not null check (amount > 0),
  currency    text not null default 'KZT',
  paid_by     uuid references users(id) on delete set null,
  created_at  timestamptz not null default now()
);
create index if not exists idx_payouts_user on provider_payouts (user_id, created_at desc);

-- ─────────────── Пример: онлайн-добавление CHECK без длинной блокировки ───────────────
--   alter table signals add constraint chk_entry_nonneg check (entry_from >= 0) not valid;
--   alter table signals validate constraint chk_entry_nonneg;   -- валидирует без ACCESS EXCLUSIVE
