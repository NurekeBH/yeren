import '../../shared/models/gallup.dart';
import '../../shared/models/library_item.dart';
import 'catalog_books_a.dart';
import 'catalog_books_b.dart';
import 'catalog_films.dart';
import 'catalog_podcasts_1.dart';
import 'catalog_podcasts_2.dart';
import 'catalog_podcasts_3.dart';

/// Библиотека каталогы — максималды толтырылған тізім (кітаптар/фильмдер/подкасттар),
/// рейтингтерімен. Подкасттар = YouTube видеолары (приложение ішінде ойнайды).
/// Барлық мәтін `loc` (kk/ru/en) бойынша таңдалады; default — ru.
class LibraryFixtures {
  LibraryFixtures._();

  static String _pick(String loc, Map<String, String> m) =>
      m[loc] ?? m['ru'] ?? m['kk'] ?? m.values.first;

  static List<LibraryItem> all(String loc) {
    String t(String kk, String ru, String en) =>
        _pick(loc, {'kk': kk, 'ru': ru, 'en': en});

    LibraryItem pod({
      required String id,
      required String title,
      required String channel,
      required String youtubeId,
      required GallupProfile profile,
      String lang = 'EN',
      required String kk,
      required String ru,
      required String en,
    }) =>
        LibraryItem(
          id: id,
          category: LibraryCategory.podcast,
          title: title,
          author: channel,
          youtubeId: youtubeId,
          externalUrl: 'https://www.youtube.com/watch?v=$youtubeId',
          profile: profile,
          lang: lang,
          summary: t(kk, ru, en),
        );

    final items = <LibraryItem>[
      // ───────────── PODCASTS / YouTube — 90% орысша, әртүрлі спикерлер ─────────────
      // Ағылшын (классика, 2)
      pod(
        id: 'p-001', title: 'Jack Schwager: Lessons from the World\'s Greatest Traders',
        channel: 'Chat With Traders', youtubeId: 'Ht-8dx0PGHA', profile: GallupProfile.disciplined,
        kk: 'Market Wizards авторы Джек Швагер 30+ жыл бойы ондаған үздік трейдерден сұхбат алған. Бұл әңгімеде ол олардың ортақ қасиеттерін — қатаң тәуекел-менеджмент, дисциплина және өз edge-іне адалдықты — ашып береді.',
        ru: 'Автор Market Wizards Джек Швагер за 30+ лет проинтервьюировал десятки лучших трейдеров. Здесь он раскрывает, что их объединяет: жёсткий риск-менеджмент, дисциплина и верность собственному edge, а не конкретная стратегия.',
        en: 'Market Wizards author Jack Schwager interviewed dozens of top traders over 30+ years. He distils what they share: strict risk management, discipline and loyalty to one\'s edge — not a single strategy.',
      ),
      pod(
        id: 'p-002', title: '4 Steps to Trade in the Zone — Mark Douglas',
        channel: 'Wealthspace', youtubeId: '4cS1fRpwsZ4', profile: GallupProfile.hope, lang: 'EN',
        kk: 'Марк Дугластың «зонаға» (ағынға) кірудің 4 қадамы: жүйеге сену, тәртіп, тәуекелді толық қабылдау және фокус. Әр сделканы тәуелсіз ықтималдық ретінде қабылдау — эмоциясыз орындаудың кілті.',
        ru: 'Четыре шага Марка Дугласа для входа «в зону»: вера в систему, дисциплина, полное принятие риска и фокус. Воспринимать каждую сделку как независимую вероятность — ключ к исполнению без эмоций.',
        en: 'Mark Douglas\'s four steps to get "in the zone": belief in the system, discipline, fully accepting risk, and focus. Treating each trade as an independent probability is the key to emotion-free execution.',
      ),

      // ───────────────── ОРЫСША ПОДКАСТАР (RU, 18 — әртүрлі спикерлер) ─────────────────
      pod(
        id: 'p-003', title: 'Психология трейдера — основа успешной торговли',
        channel: 'SHEVELEVTRADE', youtubeId: 'gYX3K8_kOLc', profile: GallupProfile.revenge, lang: 'RU',
        kk: 'Орыс тілінде сабақ: неге психология техникалық талдаудан маңыздырақ. Эмоцияны нақты уақытта тану, шығыннан кейінгі «қайтару» рефлексін бақылау және ережеге сүйеніп ойлау тәсілдері талданады.',
        ru: 'Урок на русском: почему психология важнее технического анализа. Разбираются распознавание эмоций в реальном времени, контроль рефлекса «отыграться» после убытка и мышление по правилам.',
        en: 'A Russian-language lesson on why psychology beats technical analysis. Covers recognizing emotions in real time, controlling the post-loss "revenge" reflex, and rule-based thinking.',
      ),
      pod(
        id: 'p-004', title: 'Психология трейдинга: как сохранить разум',
        channel: 'InvestFuture', youtubeId: 'kBZqRSLdhw4', profile: GallupProfile.hope, lang: 'RU',
        kk: 'Орыс тілінде: жоғары волатильділік пен дүрбелең кезінде сабырлылықты қалай сақтау керек. Бір нәтижеге үміт артудың орнына ықтималдықпен ойлауға және жоспарға сүйенуге үйретеді.',
        ru: 'На русском: как сохранять хладнокровие при высокой волатильности и панике на рынке. Учит мыслить вероятностями и опираться на план вместо надежды на один исход.',
        en: 'In Russian: how to stay calm amid high volatility and market panic. Teaches probabilistic thinking and relying on a plan instead of hoping for one outcome.',
      ),
      pod(
        id: 'p-005', title: '7 причин, почему вы теряете деньги',
        channel: 'Tiger.com', youtubeId: 'hQzbmlkyr28', profile: GallupProfile.uncontrolledRisk, lang: 'RU',
        kk: 'Орыс тілінде: трейдердің ақша жоғалтуының 7 нақты себебі мен өзін-өзі саботаж механизмі. Әрқайсысына практикалық қарсы әрекет ұсынылады — тәуекелді шектеуден журналға дейін.',
        ru: 'На русском: семь конкретных причин потери денег и механизм самосаботажа. К каждой даётся практическое противодействие — от ограничения риска до ведения журнала.',
        en: 'In Russian: seven concrete reasons traders lose money and the self-sabotage mechanism. Each comes with a practical countermeasure — from risk limits to journaling.',
      ),
      pod(
        id: 'p-006', title: 'Ошибки трейдеров: торговля без эмоций',
        channel: 'Сергей Виноградов', youtubeId: '_4D7ne5wDc4', profile: GallupProfile.revenge, lang: 'RU',
        kk: 'Орыс тілінде: жаңадан бастаушылардың ең жиі қателері және оларды болдырмау жолдары. Эмоциясыз, тек жазылған ережелерге сүйеніп сауда жасаудың тәжірибесі көрсетіледі.',
        ru: 'На русском: самые частые ошибки новичков и как их избежать. Показана практика торговли без эмоций — строго по записанным правилам.',
        en: 'In Russian: the most common beginner mistakes and how to avoid them. Demonstrates emotion-free trading driven strictly by written rules.',
      ),
      pod(
        id: 'p-007', title: 'Твои главные враги на рынке',
        channel: 'Crypto Falcon', youtubeId: '85bJl18oHv4', profile: GallupProfile.hope, lang: 'RU',
        kk: 'Орыс тілінде: трейдердің ішкі жаулары — үміт, қорқыныш, ашкөздік пен FOMO — қалай зиян келтіреді. Әр эмоцияны тану және оны жоспармен ауыстыру әдістері талқыланады.',
        ru: 'На русском: внутренние враги трейдера — надежда, страх, жадность и FOMO — и как они вредят. Обсуждается распознавание каждой эмоции и замена её планом.',
        en: "In Russian: a trader's inner enemies — hope, fear, greed and FOMO — and the harm they do. Covers spotting each emotion and replacing it with a plan.",
      ),
      pod(
        id: 'p-008', title: 'Дисциплина в трейдинге: 7 правил',
        channel: 'Cryptology Key', youtubeId: 'Zxe5iQhiTUw', profile: GallupProfile.disciplined, lang: 'RU',
        kk: 'Орыс тілінде: тұрақты плюсқа шығудың 7 нақты тәртіп ережесі. Күндік лимит, A+ сетап критерийі, журнал жүргізу мен паузаның рөлі толық түсіндіріледі.',
        ru: 'На русском: семь конкретных правил дисциплины для выхода в стабильный плюс. Подробно про дневной лимит, критерий A+ сетапа, ведение журнала и роль паузы.',
        en: 'In Russian: seven concrete discipline rules to reach steady profit. Explains daily limits, A+ setup criteria, journaling and the role of taking a pause.',
      ),
      pod(
        id: 'p-009', title: 'Психология: как заработать и не потерять всё',
        channel: 'Хедлайнеры — Никита Ануфриев', youtubeId: 'RvHaM3SQHNE', profile: GallupProfile.hope, lang: 'RU',
        kk: 'Орыс тілінде сұхбат: ірі пайда мен толық талқандаудың арасындағы жіңішке шек. Капиталды сақтау мен ашкөздікті тежеудің психологиясы туралы.',
        ru: 'Интервью на русском: тонкая грань между крупной прибылью и полным разорением. О психологии сохранения капитала и обуздания жадности.',
        en: 'A Russian-language interview on the thin line between big profit and total ruin. About the psychology of preserving capital and curbing greed.',
      ),
      pod(
        id: 'p-010', title: 'Психология трейдинга и решение торговых проблем',
        channel: 'AlexxxFX', youtubeId: 'yy8rPxiQVwE', profile: GallupProfile.revenge, lang: 'RU',
        kk: 'Орыс тілінде: нақты сауда мәселелерін (overtrading, tilt, SL-ді жылжыту) психологиялық тұрғыдан шешу әдістері. Әр мәселеге қадамдық алгоритм беріледі.',
        ru: 'На русском: методы решения конкретных торговых проблем (овертрейдинг, tilt, перенос SL) с точки зрения психологии. К каждой проблеме — пошаговый алгоритм.',
        en: 'In Russian: psychological methods to solve concrete trading problems (overtrading, tilt, moving the SL). Each problem gets a step-by-step algorithm.',
      ),
      pod(
        id: 'p-011', title: 'Мастер-класс по психологии трейдинга',
        channel: 'Умный трейдинг на Forex', youtubeId: 'DuImQVIE82I', profile: GallupProfile.disciplined, lang: 'RU',
        kk: 'Орыс тілінде сағаттық мастер-класс (Рэнди Хауэлл негізінде): сенімдер жүйесі, тәуекелді қабылдау және тұрақты орындау. Терең, бірақ практикалық материал.',
        ru: 'Часовой мастер-класс на русском (по Рэнди Хауэллу): система убеждений, принятие риска и стабильное исполнение. Глубокий, но практичный материал.',
        en: 'A one-hour Russian-language masterclass (based on Randy Howell): belief systems, accepting risk and consistent execution. Deep yet practical.',
      ),
      pod(
        id: 'p-012', title: 'Риск-менеджмент — шанс на выживание',
        channel: 'Gerchik & Co', youtubeId: 'fbiOHjnsJLE', profile: GallupProfile.uncontrolledRisk, lang: 'RU',
        kk: 'Орыс тілінде: Александр Герчиктен — депозитті сақтайтын қатаң risk-менеджмент. «Алдымен жоғалтпа, сосын тап» қағидасы мен сделкаға тіркелген тәуекел % егжей-тегжейлі.',
        ru: 'На русском: Александр Герчик о жёстком риск-менеджменте, который сохраняет депозит. Подробно про принцип «сначала не теряй» и фиксированный риск % на сделку.',
        en: 'In Russian: Alexander Gerchik on strict risk management that preserves the account. Details the "don\'t lose first" principle and a fixed risk % per trade.',
      ),
      pod(
        id: 'p-013', title: 'Риск-менеджмент: семинар в Москве',
        channel: 'Alexander Gerchik', youtubeId: 'rgTe2zqm2HU', profile: GallupProfile.disciplined, lang: 'RU',
        kk: 'Орыс тілінде толық семинар: тәуекелді басқарудың есептері мен ережелері. Лотты SL-ден есептеу, күндік шектеу және статистикалық edge нақты мысалдармен.',
        ru: 'Полный семинар на русском: расчёты и правила управления рисками. Расчёт лота из SL, дневной лимит и статистический edge на конкретных примерах.',
        en: 'A full Russian-language seminar: risk-management math and rules. Lot-from-SL sizing, daily limits and statistical edge on concrete examples.',
      ),
      pod(
        id: 'p-014', title: 'Ценный опыт трейдера: путь и ошибки',
        channel: 'На пенсию в 35 лет', youtubeId: 'HbsPPpeACvI', profile: GallupProfile.disciplined, lang: 'RU',
        kk: 'Орыс тілінде сұхбат (Тимофей Мартынов): 20 жылдық тәжірибе, жіберілген қателер мен дисциплинаның бағасы. Биржадан бизнес құру тұрғысынан көзқарас.',
        ru: 'Интервью на русском (Тимофей Мартынов): 20 лет опыта, совершённые ошибки и цена дисциплины. Взгляд на биржу как на построение бизнеса.',
        en: 'A Russian-language interview (Timofey Martynov): 20 years of experience, mistakes made and the price of discipline. Treating the market as building a business.',
      ),
      pod(
        id: 'p-015', title: 'Игры, в которые играют деньги',
        channel: 'Игры, в которые играют деньги', youtubeId: 'Ut3MxnUzmcA', profile: GallupProfile.hope, lang: 'RU',
        kk: 'Орыс тілінде эксклюзив сұхбат (Smart-Lab негізін қалаушы): қатесіз инвестиция мифі, ықтималдық пен сабырлылық. Үміт пен жоспардың айырмашылығы.',
        ru: 'Эксклюзивное интервью на русском (основатель Smart-Lab): миф об инвестициях без ошибок, вероятности и терпение. Разница между надеждой и планом.',
        en: 'An exclusive Russian-language interview (Smart-Lab founder): the myth of error-free investing, probabilities and patience. The difference between hope and a plan.',
      ),
      pod(
        id: 'p-016', title: 'Трейдинг с нуля: стоп-лосс и риск-менеджмент',
        channel: 'khtrader', youtubeId: 'D6Wglu_MFio', profile: GallupProfile.uncontrolledRisk, lang: 'RU',
        kk: 'Орыс тілінде практикалық сабақ: SL дұрыс қою, сделкаға тәуекелді есептеу және Excel-мен капиталды басқару. Жаңадан бастаушыға таза негіз.',
        ru: 'Практический урок на русском: правильная постановка SL, расчёт риска на сделку и управление капиталом в Excel. Чистая база для новичка.',
        en: 'A practical Russian-language lesson: setting the SL correctly, per-trade risk math and capital management in Excel. A clean base for beginners.',
      ),
      pod(
        id: 'p-017', title: 'Управление капиталом без риска',
        channel: 'MaxCapital — Максим Петров', youtubeId: 'PZocEdQcst0', profile: GallupProfile.uncontrolledRisk, lang: 'RU',
        kk: 'Орыс тілінде: капиталды қорғаудың негіздері мен risk-менеджментпен қалай бастау керек. Позиция мөлшері мен депозитті сақтаудың практикалық ережелері.',
        ru: 'На русском: основы защиты капитала и как начать с риск-менеджмента. Практические правила размера позиции и сохранения депозита.',
        en: 'In Russian: the basics of protecting capital and starting with risk management. Practical rules for position size and preserving the account.',
      ),
      pod(
        id: 'p-018', title: 'Риск-менеджмент: как грамотно считать риски',
        channel: 'ProMarket — Полунин Олег', youtubeId: 'X3OMQriyHFg', profile: GallupProfile.disciplined, lang: 'RU',
        kk: 'Орыс тілінде: тәуекелді сауатты есептеу мен капиталды басқару. Жаңадан бастаушыларға арналған нақты формулалар мен мысалдар.',
        ru: 'На русском: как грамотно считать риски и управлять капиталом. Конкретные формулы и примеры для начинающих.',
        en: 'In Russian: how to compute risk properly and manage capital. Concrete formulas and examples for beginners.',
      ),
      pod(
        id: 'p-019', title: 'Введение в управление капиталом',
        channel: 'КИТ Финанс Брокер', youtubeId: '7i5fUNFDJSo', profile: GallupProfile.disciplined, lang: 'RU',
        kk: 'Орыс тілінде брокердің білім беру материалы: капиталды басқару мен risk-менеджменттің негіздері. Тәуекелді шектеудің жүйелі тәсілі.',
        ru: 'Образовательный материал брокера на русском: основы управления капиталом и риск-менеджмента. Системный подход к ограничению риска.',
        en: 'A broker\'s Russian-language educational piece: the basics of capital and risk management. A systematic approach to limiting risk.',
      ),
      pod(
        id: 'p-020', title: 'Грабли трейдера: как не слить депозит',
        channel: 'Gerchik & Co', youtubeId: 'sj7-8-EP5kI', profile: GallupProfile.uncontrolledRisk, lang: 'RU',
        kk: 'Орыс тілінде: ақшаны басқару ережелері мен жиі жіберілетін қателер. Депозитті сақтап қалудың нақты қадамдары мен «граблиден» аулақ болу.',
        ru: 'На русском: правила управления деньгами и типичные ошибки. Конкретные шаги, чтобы сохранить депозит и не наступать на «грабли».',
        en: 'In Russian: money-management rules and typical mistakes. Concrete steps to preserve the account and avoid stepping on the same rakes.',
      ),
    ];

    // Кітаптар мен фильмдер — толық каталогтан (250 кітап + 100 фильм).
    // Подкасттар — қолмен жазылған, тіл бойынша араластырылады (EN ↔ RU кезектесіп).
    final pods = items.where((x) => x.category == LibraryCategory.podcast).toList();
    final en = pods.where((p) => p.lang != 'RU').toList();
    final ru = pods.where((p) => p.lang == 'RU').toList();
    final mixed = <LibraryItem>[];
    for (var i = 0; i < en.length || i < ru.length; i++) {
      if (i < en.length) mixed.add(en[i]);
      if (i < ru.length) mixed.add(ru[i]);
    }
    return [
      ...kBooksCatalogA,
      ...kBooksCatalogB,
      ...kFilmsCatalog,
      ...mixed,
      ...kPodcasts1,
      ...kPodcasts2,
      ...kPodcasts3,
    ];
  }
}
