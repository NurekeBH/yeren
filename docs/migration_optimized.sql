-- ============================================================================
-- ALTYN — Zero-Downtime performance migration.
-- ВАЖНО: CREATE INDEX CONCURRENTLY НЕЛЬЗЯ внутри транзакции и НЕ блокирует
-- INSERT/UPDATE (строит индекс в фоне). Запускать КАЖДУЮ команду отдельно
-- (psql в autocommit / по одной), НЕ оборачивать в BEGIN/COMMIT.
-- Прим.: в живой схеме колонка называется `pair` (= 'XAU/USD'), не `asset`.
-- ============================================================================

-- 1) Частичный индекс под главный экран: только АКТИВНЫЕ, не удалённые идеи,
--    свежие сверху. Сканируется крошечное подмножество → Index Scan вместо Seq Scan.
create index concurrently if not exists idx_signals_active_feed
  on signals (published_at desc)
  where status = 'active' and deleted_at is null;

-- 2) Активные идеи конкретной пары (XAU/USD) — если появятся другие инструменты.
create index concurrently if not exists idx_signals_active_pair
  on signals (pair, published_at desc)
  where status = 'active' and deleted_at is null;

-- 3) Составной индекс: история бонусов пользователя (выборка user_id + сорт created_at desc).
create index concurrently if not exists idx_bonus_tx_user_created
  on bonus_transactions (user_id, created_at desc);

-- 4) FK-индексы для быстрых JOIN (все внешние ключи должны быть проиндексированы):
create index concurrently if not exists idx_signals_created_by  on signals(created_by);
create index concurrently if not exists idx_signals_provider    on signals(provider_id);
create index concurrently if not exists idx_signal_purch_signal on signal_purchases(signal_id);
create index concurrently if not exists idx_signal_purch_user   on signal_purchases(user_id);
create index concurrently if not exists idx_course_purch_course on course_purchases(course_id);
create index concurrently if not exists idx_provider_payouts_u  on provider_payouts(user_id);

-- 5) Витрина покупок по сигналу (для gold_trader_performance / earned) — покрывающий индекс.
create index concurrently if not exists idx_signal_purch_signal_price
  on signal_purchases (signal_id) include (price_tg);

-- ── Проверка эффекта: до/после ──
--   EXPLAIN (ANALYZE, BUFFERS)
--   select * from signals where status='active' and deleted_at is null
--   order by published_at desc limit 20;
-- ДО:  Seq Scan on signals  (rows=... ) + Sort            → десятки-сотни мс
-- ПОСЛЕ: Index Scan using idx_signals_active_feed (rows=20) → sub-1ms

-- ── Онлайн-добавление CHECK-констрейнта без длинной блокировки (пример) ──
--   alter table course_catalog add constraint chk_price_nonneg check (price_bonus >= 0) not valid;
--   alter table course_catalog validate constraint chk_price_nonneg;  -- без ACCESS EXCLUSIVE
