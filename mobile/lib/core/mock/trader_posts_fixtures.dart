import '../../shared/models/trader_post.dart';

/// Трейдер посттарының (Published Ideas) каталогы — мок.
/// Провайдер бетіндегі лента: фото + мәтін + лайк + коммент.
class TraderPostsFixtures {
  TraderPostsFixtures._();

  static String _pick(String loc, Map<String, String> m) =>
      m[loc] ?? m['ru'] ?? m['kk'] ?? m.values.first;

  static String _img(String seed) => 'https://picsum.photos/seed/$seed/900/560';

  /// Берілген провайдердің посттары (жаңасы жоғарыда).
  static List<TraderPost> forProvider(String providerId, String loc) {
    String t(String kk, String ru, String en) => _pick(loc, {'kk': kk, 'ru': ru, 'en': en});
    String ago(int h) => t('$h сағат бұрын', '$h ч. назад', '${h}h ago');

    PostComment c(String author, String kk, String ru, String en) =>
        PostComment(author: author, text: t(kk, ru, en));

    final all = <TraderPost>[
      // ─── pr-1 TraderOS Desk ───
      TraderPost(
        id: 'po-1', providerId: 'pr-1', imageUrl: _img('xau-london-overlap'), baseLikes: 184, agoLabel: ago(2),
        text: t(
          'XAU/USD London/NY overlap: 4M1 OB-тен реакция күтемін. 4 462–4 458 аймағынан longʼқа қараймын, SL 4 449, TP1 4 478. DXY әлсіреп тұр — алтынға қолайлы.',
          'XAU/USD на overlap London/NY: жду реакцию от 4H OB. Смотрю long из зоны 4 462–4 458, SL 4 449, TP1 4 478. DXY слабеет — фон для золота позитивный.',
          'XAU/USD on the London/NY overlap: waiting for a reaction off the 4H OB. Eyeing a long from 4,462–4,458, SL 4,449, TP1 4,478. DXY is weakening — a positive backdrop for gold.',
        ),
        seededComments: [
          c('Алмас Gold', 'Дәл осы аймақты бақылап жүрмін 👍', 'Слежу за этой же зоной 👍', 'Watching the same zone 👍'),
          c('Ербол', '4 458 ұстаса, кіремін', 'Если удержит 4 458 — захожу', 'If 4,458 holds, I am in'),
        ],
      ),
      TraderPost(
        id: 'po-2', providerId: 'pr-1', baseLikes: 96, agoLabel: ago(7),
        text: t(
          'Ереже: NFP алдында жаңа позиция ашпаймын. Волатильділік болжанбайды — капиталды сақтау бірінші. Бүгін тек бақылаймыз.',
          'Правило: перед NFP новые позиции не открываю. Волатильность непредсказуема — сохранение капитала важнее. Сегодня только наблюдаем.',
          'Rule: I do not open new positions before NFP. Volatility is unpredictable — capital preservation comes first. Today we only watch.',
        ),
        seededComments: [
          c('Дамир', 'Тәртіп — бәрінен маңызды 🙏', 'Дисциплина важнее всего 🙏', 'Discipline above all 🙏'),
        ],
      ),
      // ─── pr-2 Алмас Gold ───
      TraderPost(
        id: 'po-3', providerId: 'pr-2', imageUrl: _img('xau-h1-setup'), baseLikes: 142, agoLabel: ago(3),
        text: t(
          'H1 BOS расталды, ретест күтемін. Кіру 4 470, SL 4 462 (80 пипс емес, 8\$). RR 1:2.4. Скриншот тіркелді 📈',
          'H1 BOS подтверждён, жду ретест. Вход 4 470, SL 4 462, RR 1:2.4. Скрин приложил 📈',
          'H1 BOS confirmed, waiting for the retest. Entry 4,470, SL 4,462, RR 1:2.4. Screenshot attached 📈',
        ),
        seededComments: [
          c('Нұрлан', 'RR жақсы екен, рахмет!', 'Хороший RR, спасибо!', 'Nice RR, thanks!'),
          c('SMC Pro', 'Liquidity 4 480-де тұр, абай бол', 'Ликвидность на 4 480, аккуратнее', 'Liquidity at 4,480, be careful'),
        ],
      ),
      TraderPost(
        id: 'po-4', providerId: 'pr-2', baseLikes: 67, agoLabel: ago(20),
        text: t(
          'Кеше TP2 алынды, +148 пипс ✅ Бірақ есте сақта: бір сделка статистика емес. Маңыздысы — процесс.',
          'Вчера взяли TP2, +148 пипсов ✅ Но помни: одна сделка — не статистика. Важен процесс.',
          'TP2 hit yesterday, +148 pips ✅ But remember: one trade is not statistics. The process is what matters.',
        ),
        seededComments: [],
      ),
      // ─── pr-3 SMC Pro ───
      TraderPost(
        id: 'po-5', providerId: 'pr-3', imageUrl: _img('smc-orderblock'), baseLikes: 210, agoLabel: ago(1),
        text: t(
          'Smart Money: Asia-да liquidity жиналды, London sweep күтемін. Sweep болса — H1 OB-тен sell. Жоспарсыз кірмеймін.',
          'Smart Money: за азию набралась ликвидность, жду sweep на Лондоне. После sweep — sell из H1 OB. Без плана не вхожу.',
          'Smart Money: liquidity built up over Asia, waiting for a London sweep. After the sweep — sell from the H1 OB. No entry without a plan.',
        ),
        seededComments: [
          c('Жанна', 'CHoCH-ты да күтесің бе?', 'Ждёшь ещё и CHoCH?', 'Waiting for a CHoCH too?'),
          c('SMC Pro', 'Иә, M15 CHoCH растаса ғана', 'Да, только при подтверждении M15 CHoCH', 'Yes, only on an M15 CHoCH confirmation'),
        ],
      ),
      // ─── pr-4 Asia Session ───
      TraderPost(
        id: 'po-6', providerId: 'pr-4', imageUrl: _img('asia-range'), baseLikes: 54, agoLabel: ago(9),
        text: t(
          'Азия сессиясы — тар range. 4 455–4 470 шекараларынан қайтуды саудалаймын, мақсат — range ортасы. Тренд жоқ, сабырлы боламыз.',
          'Азиатская сессия — узкий range. Торгую отбой от границ 4 455–4 470, цель — середина range. Тренда нет, сохраняем терпение.',
          'Asian session — a tight range. I trade the bounce off the 4,455–4,470 edges, target the range mid. No trend, stay patient.',
        ),
        seededComments: [
          c('Тимур', 'Range-ге дұрыс стратегия 👌', 'Верная стратегия для range 👌', 'Right strategy for a range 👌'),
        ],
      ),
      // ─── pr-5 London Killzone ───
      TraderPost(
        id: 'po-7', providerId: 'pr-5', imageUrl: _img('london-killzone'), baseLikes: 173, agoLabel: ago(4),
        text: t(
          'London killzone (10:00–13:00): judas swing-тен кейін нақты бағыт. Бүгін buy-side liquidity басым, longʼқа бейіммін. ICT entry — FVG-ге ретест.',
          'London killzone (10:00–13:00): после judas swing — чёткое направление. Сегодня доминирует buy-side ликвидность, склоняюсь к long. ICT-вход — ретест в FVG.',
          'London killzone (10:00–13:00): a clear direction after the judas swing. Buy-side liquidity dominates today, I lean long. ICT entry — a retest into the FVG.',
        ),
        seededComments: [
          c('Аян', 'FVG қай ТФ-те?', 'FVG на каком ТФ?', 'FVG on which timeframe?'),
          c('London Killzone', 'M5 FVG, H1 bias бойынша', 'M5 FVG по H1 bias', 'M5 FVG aligned with the H1 bias'),
        ],
      ),
    ];

    return all.where((p) => p.providerId == providerId).toList();
  }
}
