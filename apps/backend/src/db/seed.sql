-- ====================================================
-- TraderOS — Demo seed deretterі
-- migrate командасы schema.sql-дан кейін осы файлды қолданады.
-- Production-да БҰЛ ФАЙЛДЫ ҚОЛДАНБА.
-- ====================================================

-- Admin user (phone +77001234567, password: changeme123)
-- bcrypt(changeme123, 12) → әуелі регистрация арқылы жасап, кейін is_admin=true қойыңыз.

-- Demo lessons (TZ §11.3 негізінде)
insert into lessons (profile_type, source_type, source_name, title, quote, explanation, gold_application, quick_check, xp, tag)
values
  ('revenge', 'book', 'Mark Douglas — Trading in the Zone',
   'Шығыннан кейінгі ереже',
   'Anything can happen. You don''t need to know what is going to happen next to make money.',
   'Шығын — жүйенің бір бөлшегі, оны "қайтарып алу" керек дейтін эмоция нарықпен байланыссыз.',
   'XAU/USD-та SL шықса, кем дегенде 1 сағат паузаға кет. Сессияға max 3 сделка ережесі.',
   'Бүгін шығыннан кейін қандай қадам жасадың?',
   25, 'psychology'),

  ('uncontrolled_risk', 'book', 'Alexander Elder — Trading for a Living',
   '2% ережесі',
   'Risk no more than 2% of your equity on any single trade.',
   'Кез келген сделкаға 2%-дан көп қаражат тәуекелге қоймау — кәсіби трейдинг негізі.',
   '$1000 депозит → max $20 risk → 0.05 lot 40 pip SL-мен.',
   'Соңғы сделкада қанша % тәуекелге қойдыңыз?',
   30, 'risk'),

  ('hope', 'book', 'Edwin Lefèvre — Reminiscences of a Stock Operator',
   'Үміт пен Жоспар',
   'The market is never wrong; opinions often are.',
   'Үмітпен сделка ұстау — нарықпен бәсекелесу. SL кеңейту — қорғаныс рөліне қайшы.',
   'SL қойдың — оны кеңейтпе. TP жетпей жатса, breakeven-ге жылжыт, артқа емес.',
   'SL-ді бүгін бір рет болса да кеңейттіңіз бе?',
   25, 'discipline'),

  ('disciplined', 'trader', 'Paul Tudor Jones',
   'Тәуекел әуелі, пайда содан кейін',
   'The most important rule of trading is to play great defense, not great offense.',
   'Дисциплиналы трейдер үшін келесі қадам — performance edge табу.',
   'XAU/USD үшін аптада max 5 A+ setup таңда. London/NY overlap-қа шоғырлан.',
   'Сіздің A+ setup критерийлері қандай?',
   35, 'strategy'),

  ('revenge', 'film', 'Margin Call (2011)',
   'Шектен шығу нүктесі',
   'Be first, be smarter, or cheat.',
   'Эмоциялық сделкалар жылдам сезіле тұра, оларда edge жоқ.',
   '3 шығын қатарынан болса — терминалды жап. Ертеңге қалдыр.',
   'Бүгін эмоциядан кірген сделкаңыз болды ма?',
   20, 'mindset')
on conflict do nothing;

-- Demo signal (admin user қажет, әуелі тіркеуден өтіңіз)
-- insert into signals (...) values (...);

-- Demo signal providers (Ideas aggregator) — кесте бос болса ғана
insert into signal_providers (name, avatar, bio, win_rate, avg_rr, rating, subscribers, trades_count, price_per_month, verified)
select * from (values
  ('TraderOS Desk', '🏆', 'Официальный деск TraderOS. Сетапы по XAU/USD на overlap London/NY, строгий риск-менеджмент.', 0.72, 2.3, 4.8, 1240, 318, 0, true),
  ('Алмас Gold', '🦅', '5 лет опыта, только XAU/USD. 1–3 качественные идеи в день со скриншотами.', 0.66, 2.1, 4.5, 860, 412, 30000, true),
  ('SMC Pro', '📊', 'Smart Money Concepts: order block, liquidity sweep, BOS/CHoCH. Топ-даун анализ.', 0.69, 2.6, 4.6, 540, 205, 20000, true),
  ('Asia Session', '🌏', 'Идеи range-trading в азиатскую сессию. Бесплатно, но новый провайдер.', 0.58, 1.9, 4.0, 310, 156, 0, false),
  ('London Killzone', '🇬🇧', 'Killzone-сетапы на открытии Лондона. Подход ICT, чёткие вход/выход.', 0.63, 2.2, 4.3, 470, 289, 15000, true)
) as v(name, avatar, bio, win_rate, avg_rr, rating, subscribers, trades_count, price_per_month, verified)
where not exists (select 1 from signal_providers);

-- Demo events — кесте бос болса ғана
insert into events (type, title, speaker, city, is_online, starts_at, price, description, youtube_id)
select type, title, speaker, city, is_online, now() + ((days)::text || ' days')::interval, price, description, youtube_id
from (values
  ('masterclass', 'Психология трейдинга: дисциплина и риск', 'Александр Герчик', 'Алматы', false, 5, 15000, 'Полный мастер-класс: контроль эмоций, дисциплина после убытка, критерий A+ сетапа и дневной лимит риска.', 'DuImQVIE82I'),
  ('live_trade', 'Live-сессия по XAU/USD: London open', 'TraderOS', 'Онлайн', true, 2, 0, 'Прямой эфир-разбор XAU/USD на открытии Лондона: HTF bias, ликвидность, retest-сетап.', null),
  ('webinar', 'Управление капиталом с нуля', 'MaxCapital — Максим Петров', 'Онлайн', true, 7, 5000, 'Расчёт размера позиции, risk %, дневной лимит и сохранение депозита. Практика с калькулятором.', 'PZocEdQcst0'),
  ('masterclass', 'Smart Money: структура рынка', 'TraderOS Pro', 'Астана', false, 12, 20000, 'Order block, liquidity sweep, BOS/CHoCH на реальных графиках. Топ-даун workflow.', null),
  ('live_trade', 'Разбор сделок недели', 'Тимофей Мартынов', 'Онлайн', true, 9, 0, 'Живой разбор сделок участников: ошибки, верные решения, ведение журнала.', 'HbsPPpeACvI'),
  ('webinar', 'Риск-менеджмент: считаем лот', 'ProMarket — Олег Полунин', 'Онлайн', true, 4, 0, 'Формулы и примеры грамотного расчёта риска. Бесплатный вебинар для начинающих.', 'X3OMQriyHFg')
) as v(type, title, speaker, city, is_online, days, price, description, youtube_id)
where not exists (select 1 from events);

-- Demo trader posts (Published Ideas) — кесте бос болса ғана, провайдерге атымен байланады
insert into trader_posts (provider_id, text, image_url, likes_count, created_at)
select p.id, v.text, v.image_url, v.likes_count, now() - ((v.hours_ago)::text || ' hours')::interval
from (values
  ('TraderOS Desk', 'XAU/USD на overlap London/NY: жду реакцию от 4H OB. Смотрю long из зоны 4 462–4 458, SL 4 449, TP1 4 478. DXY слабеет — фон для золота позитивный.', 'https://picsum.photos/seed/xau-london-overlap/900/560', 184, 2),
  ('TraderOS Desk', 'Правило: перед NFP новые позиции не открываю. Волатильность непредсказуема — сохранение капитала важнее. Сегодня только наблюдаем.', null, 96, 7),
  ('Алмас Gold', 'H1 BOS подтверждён, жду ретест. Вход 4 470, SL 4 462, RR 1:2.4. Скрин приложил.', 'https://picsum.photos/seed/xau-h1-setup/900/560', 142, 3),
  ('Алмас Gold', 'Вчера взяли TP2, +148 пипсов. Но помни: одна сделка — не статистика. Важен процесс.', null, 67, 20),
  ('SMC Pro', 'Smart Money: за азию набралась ликвидность, жду sweep на Лондоне. После sweep — sell из H1 OB. Без плана не вхожу.', 'https://picsum.photos/seed/smc-orderblock/900/560', 210, 1),
  ('Asia Session', 'Азиатская сессия — узкий range. Торгую отбой от границ 4 455–4 470, цель — середина range. Тренда нет, сохраняем терпение.', 'https://picsum.photos/seed/asia-range/900/560', 54, 9),
  ('London Killzone', 'London killzone (10:00–13:00): после judas swing — чёткое направление. Сегодня доминирует buy-side ликвидность, склоняюсь к long. ICT-вход — ретест в FVG.', 'https://picsum.photos/seed/london-killzone/900/560', 173, 4)
) as v(provider_name, text, image_url, likes_count, hours_ago)
join signal_providers p on p.name = v.provider_name
where not exists (select 1 from trader_posts);
