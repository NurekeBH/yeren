import '../../shared/models/gallup.dart';
import '../../shared/models/library_item.dart';
import 'catalog_books_a.dart';
import 'catalog_books_b.dart';
import 'catalog_films.dart';
import 'library_content.dart';

/// Библиотека каталогы — максималды толтырылған тізім (кітаптар/фильмдер/подкасттар),
/// рейтингтерімен. Подкасттар = YouTube видеолары (приложение ішінде ойнайды).
/// Барлық мәтін `loc` (kk/ru/en) бойынша таңдалады; default — ru.
class LibraryFixtures {
  LibraryFixtures._();

  static String _pick(String loc, Map<String, String> m) =>
      m[loc] ?? m['ru'] ?? m['kk'] ?? m.values.first;

  /// Кітаптардың орысша атаулары (ресми аудармалар). ru локалінде осы көрсетіледі.
  static const _ruTitles = <String, String>{
    'b-001': 'Зональный трейдинг',
    'b-002': 'Дисциплинированный трейдер',
    'b-003': 'Психология трейдинга',
    'b-004': 'Самоучитель трейдера',
    'b-005': 'Воспоминания биржевого спекулянта',
    'b-006': 'Биржевые маги',
    'b-007': 'Новые маги рынка',
    'b-008': 'Как играть и выигрывать на бирже',
    'b-009': 'Одураченные случайностью',
    'b-010': 'Чёрный лебедь',
    'b-011': 'Антихрупкость',
    'b-012': 'Принцип ставок',
    'b-013': 'Думай медленно… решай быстро',
    'b-014': 'Трейдинг — ваш путь к финансовой свободе',
    'b-017': 'Атомные привычки',
    'b-019': 'Технический анализ финансовых рынков',
    'b-020': 'Японские свечи',
    'b-021': 'Разумный инвестор',
    'b-022': 'Путь черепах',
    'b-023': 'О самом важном',
    'b-024': 'Когда гений терпит поражение',
    'b-025': 'Покер лжецов',
    'b-026': 'Большая игра на понижение',
    'b-027': 'Flash Boys: Высокочастотная революция',
    'b-028': 'Метод Питера Линча',
    'b-030': 'Руководство разумного инвестора',
    'b-033': 'Алхимия финансов',
    'b-035': 'Обыкновенные акции, необыкновенные доходы',
    'b-036': 'Эссе об инвестициях',
    'b-038': 'Трейдинг с доктором Элдером',
    // Фильмдер (орысша прокат атаулары)
    'f-001': 'Волк с Уолл-стрит',
    'f-002': 'Игра на понижение',
    'f-003': 'Предел риска',
    'f-004': 'Уолл-стрит',
    'f-005': 'Аферист',
    'f-006': 'Бойлерная',
    'f-007': 'Инсайдеры',
    'f-008': 'Слишком большие, чтобы рухнуть',
    'f-010': 'Поменяться местами',
    'f-011': 'Энрон: Самые смышлёные парни в комнате',
    'f-013': 'Уолл-стрит: Деньги не спят',
    'f-014': 'В погоне за счастьем',
    'f-015': 'Области тьмы',
    'f-016': 'Золото',
    'f-017': 'Финансовый монстр',
    'f-018': 'Порочная страсть',
    'f-019': '99 домов',
    'f-020': 'Тупые деньги',
    'f-021': 'Стать Уорреном Баффетом',
    'f-022': 'Капитализм: История любви',
  };

  static List<LibraryItem> all(String loc) {
    String t(String kk, String ru, String en) =>
        _pick(loc, {'kk': kk, 'ru': ru, 'en': en});

    // Структурированный разбор (genre / идеи / заключение) по id из library_content.dart.
    String? genreOf(String id) {
      final c = kLibraryContent[id];
      return c == null ? null : _pick(loc, c.genre);
    }

    List<String> ideasOf(String id) {
      final c = kLibraryContent[id];
      if (c == null) return const [];
      return c.ideas[loc] ?? c.ideas['ru'] ?? c.ideas['en'] ?? const [];
    }

    String? conclusionOf(String id) {
      final c = kLibraryContent[id];
      return c == null ? null : _pick(loc, c.conclusion);
    }

    LibraryItem book({
      required String id,
      required String title,
      required String author,
      required int year,
      required double rating,
      required GallupProfile profile,
      String? isbn,
      String? url,
      required String kk,
      required String ru,
      required String en,
    }) =>
        LibraryItem(
          id: id,
          category: LibraryCategory.book,
          title: loc == 'ru' ? (_ruTitles[id] ?? title) : title,
          author: author,
          year: year,
          rating: rating,
          ratingMax: 5,
          ratingSource: 'Goodreads',
          profile: profile,
          isbn: isbn,
          externalUrl: url,
          summary: t(kk, ru, en),
          genre: genreOf(id),
          ideas: ideasOf(id),
          conclusion: conclusionOf(id),
        );

    LibraryItem film({
      required String id,
      required String title,
      required String author,
      required int year,
      required double rating,
      required GallupProfile profile,
      String? imdb,
      required String kk,
      required String ru,
      required String en,
    }) =>
        LibraryItem(
          id: id,
          category: LibraryCategory.film,
          title: loc == 'ru' ? (_ruTitles[id] ?? title) : title,
          author: author,
          year: year,
          rating: rating,
          ratingMax: 10,
          ratingSource: 'IMDb',
          profile: profile,
          externalUrl: imdb == null ? null : 'https://www.imdb.com/title/$imdb/',
          summary: t(kk, ru, en),
          genre: genreOf(id),
          ideas: ideasOf(id),
          conclusion: conclusionOf(id),
        );

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
      // ─────────────────────────── BOOKS (40) ───────────────────────────
      book(
        id: 'b-001', title: 'Trading in the Zone', author: 'Mark Douglas',
        year: 2000, rating: 4.16, profile: GallupProfile.revenge, isbn: '0735201447',
        url: 'https://www.goodreads.com/book/show/85366.Trading_in_the_Zone',
        kk: 'Нарықтағы табыс талдауда емес — ойлау тәртібінде. Дуглас «ықтималдық ойлауын» түсіндіреді: әр сделка — нәтижесі белгісіз тәуелсіз оқиға, сондықтан бір сделкаға эмоция арту мағынасыз. Кітап сенім жүйесін қайта құрып, қорқыныш пен ашкөздіктен арылтып, ережені тұрақты орындауға баулиды.',
        ru: 'Успех на рынке — не в анализе, а в мышлении. Дуглас объясняет «вероятностное мышление»: каждая сделка — независимое событие с неизвестным исходом, поэтому эмоционально цепляться за одну сделку бессмысленно. Книга перестраивает систему убеждений, помогает избавиться от страха и жадности и стабильно исполнять правила.',
        en: 'Market success is mindset, not analysis. Douglas explains "probabilistic thinking": each trade is an independent event with an unknown outcome, so clinging to any single trade is pointless. The book rebuilds your belief system, frees you from fear and greed, and lets you execute your rules consistently.',
      ),
      book(
        id: 'b-002', title: 'The Disciplined Trader', author: 'Mark Douglas',
        year: 1990, rating: 4.05, profile: GallupProfile.hope, isbn: '0132157578',
        url: 'https://www.goodreads.com/book/show/588138.The_Disciplined_Trader',
        kk: 'Дугластың трейдер психологиясы туралы алғашқы классигі. Жеңімпаз көзқарас сенімнен туады, ал сенімділік пен қорқыныш қатар тұра алмайды. Кітап ойлау қателерін тауып, тәртіпті дағдыға айналдыруға — жоспарсыз кіру мен SL-ді жылжыту әдеттерін жоюға көмектеседі.',
        ru: 'Первая классика Дугласа о психологии трейдера. Выигрышное отношение рождается из уверенности, а уверенность и страх несовместимы. Книга помогает выявить ментальные ошибки и превратить дисциплину в навык — избавляет от входов без плана и привычки двигать SL.',
        en: 'Douglas\'s first classic on trader psychology. A winning attitude is born of confidence, and confidence and fear cannot coexist. It helps you spot mental errors and turn discipline into a habit — curing entries without a plan and the urge to move your SL.',
      ),
      book(
        id: 'b-003', title: 'The Psychology of Trading', author: 'Brett Steenbarger',
        year: 2002, rating: 3.96, profile: GallupProfile.revenge, isbn: '0471267619',
        url: 'https://www.goodreads.com/book/show/263506.The_Psychology_of_Trading',
        kk: 'Эмоция — қарсылас емес, сигнал. Психотерапевт әрі трейдер Стинбаргер шығынға эмоциялық реакцияны нақты процеске айналдыруды үйретеді: триггерді тану, паузаны енгізу, журналға жазу. Нәтижесінде «қайтару» рефлексі бақыланады.',
        ru: 'Эмоция — не враг, а сигнал. Психотерапевт и трейдер Стинбаргер учит превращать эмоциональную реакцию на убыток в конкретный процесс: распознать триггер, сделать паузу, записать в журнал. В итоге рефлекс «отыграться» берётся под контроль.',
        en: 'Emotion is a signal, not an enemy. Steenbarger — a psychologist and trader — shows how to turn emotional reactions to loss into a concrete process: name the trigger, pause, journal it. The "revenge" reflex comes under control.',
      ),
      book(
        id: 'b-004', title: 'The Daily Trading Coach', author: 'Brett Steenbarger',
        year: 2009, rating: 4.21, profile: GallupProfile.disciplined, isbn: '0470398566',
        url: 'https://www.goodreads.com/book/show/6328024-the-daily-trading-coach',
        kk: 'Өз-өзіңе коуч болудың 101 қысқа сабағы. Стинбаргер күнделікті рефлексия, журнал жүргізу мен кіші эксперименттер арқылы тұрақты прогреске жетуді көрсетеді. Психологты алмастыратын практикалық құрал.',
        ru: '101 короткий урок самокоучинга. Стинбаргер показывает, как через ежедневную рефлексию, журнал и маленькие эксперименты добиваться стабильного прогресса. Практичный инструмент, заменяющий психолога.',
        en: '101 short self-coaching lessons. Steenbarger shows how daily reflection, journaling and small experiments produce steady progress. A practical tool that stands in for a therapist.',
      ),
      book(
        id: 'b-005', title: 'Reminiscences of a Stock Operator', author: 'Edwin Lefèvre',
        year: 1923, rating: 4.17, profile: GallupProfile.hope, isbn: '0471770884',
        url: 'https://www.goodreads.com/book/show/97047.Reminiscences_of_a_Stock_Operator',
        kk: 'Аты аталмаған Джесси Ливермордың өмірі негізіндегі классика. «Нарық ешқашан қателеспейді, пікірлер жиі қателеседі» — мұнда трейдингтің мәңгілік сабақтары: тренд бойымен жүру, шыдамдылық, эмоция мен ашкөздіктің қаупі. Бір ғасыр өтсе де өзекті.',
        ru: 'Классика на основе жизни Джесси Ливермора (под вымышленным именем). «Рынок никогда не ошибается, ошибаются мнения» — здесь вечные уроки трейдинга: идти за трендом, терпение, опасность эмоций и жадности. Актуально и спустя век.',
        en: 'A classic based on the life of Jesse Livermore (under a pseudonym). "The market is never wrong; opinions often are" — timeless lessons: follow the trend, be patient, beware emotion and greed. Still relevant a century later.',
      ),
      book(
        id: 'b-006', title: 'Market Wizards', author: 'Jack Schwager',
        year: 1989, rating: 4.20, profile: GallupProfile.disciplined, isbn: '1118273052',
        url: 'https://www.goodreads.com/book/show/598680.Market_Wizards',
        kk: 'Әлемнің үздік трейдерлерімен сұхбаттар жинағы. Стильдер әртүрлі болса да, ортақ нәрсе — стратегия емес, қатаң тәуекел-менеджмент, дисциплина мен өз edge-іне адалдық. Әр сұхбаттан нақты практикалық сабақ алуға болады.',
        ru: 'Сборник интервью с лучшими трейдерами мира. Стили разные, но общее у них не стратегия, а жёсткий риск-менеджмент, дисциплина и верность своему edge. Из каждого интервью можно вынести конкретный практический урок.',
        en: "Interviews with the world's best traders. Their styles differ, but what they share is not strategy — it is strict risk management, discipline and loyalty to their edge. Every interview yields a concrete, practical lesson.",
      ),
      book(
        id: 'b-007', title: 'The New Market Wizards', author: 'Jack Schwager',
        year: 1992, rating: 4.21, profile: GallupProfile.disciplined,
        url: 'https://www.goodreads.com/book/show/598679.The_New_Market_Wizards',
        kk: 'Market Wizards жалғасы — жаңа буын трейдерлер мен жүйелі қорлар. Edge-ті табу, оны backtest-пен растау және эмоциясыз ұстанудың нақты тәжірибелері. Бірінші бөлімнің идеяларын тереңдетеді.',
        ru: 'Продолжение Market Wizards — новое поколение трейдеров и системные фонды. Практика поиска edge, его подтверждения бэктестом и следования без эмоций. Углубляет идеи первой части.',
        en: 'The sequel — a new generation of traders and systematic funds. Real practice of finding an edge, validating it by backtest, and following it without emotion. It deepens the ideas of the first book.',
      ),
      book(
        id: 'b-008', title: 'Trading for a Living', author: 'Alexander Elder',
        year: 1993, rating: 4.13, profile: GallupProfile.uncontrolledRisk, isbn: '0471592242',
        url: 'https://www.goodreads.com/book/show/771364.Trading_for_a_Living',
        kk: 'Үш «M»: Mind (психология), Method (талдау), Money (тәуекел). Әр сделкаға 2%-дан аспайтын тәуекел ережесінің классикалық дереккөзі әрі техникалық талдау мен журналдың негіздері. Жаңадан бастаушыға толық карта.',
        ru: 'Три «M»: Mind (психология), Method (анализ), Money (риск). Классический источник правила «не более 2% риска на сделку», а также основы теханализа и журнала. Полная карта для начинающего.',
        en: 'Three M\'s: Mind (psychology), Method (analysis), Money (risk). The classic source of the "risk no more than 2% per trade" rule, plus the basics of technical analysis and journaling. A complete map for beginners.',
      ),
      book(
        id: 'b-009', title: 'Fooled by Randomness', author: 'Nassim Taleb',
        year: 2001, rating: 4.10, profile: GallupProfile.uncontrolledRisk, isbn: '0812975219',
        url: 'https://www.goodreads.com/book/show/38315.Fooled_by_Randomness',
        kk: 'Жеңіс ≠ шеберлік. Талеб үлкен ұтыстың көбі кездейсоқтық екенін көрсетеді: бір рет «болжап» ұту артық сенімділікке, ол келесіде талқандалуға әкеледі. Нәтижені емес, шешімнің сапасын бағалауға үйретеді.',
        ru: 'Победа ≠ мастерство. Талеб показывает, что большой выигрыш часто случаен: «угадал» однажды — рождается сверхуверенность, а за ней разнос. Учит оценивать качество решения, а не результат.',
        en: 'Winning ≠ skill. Taleb shows big wins are often randomness: one lucky guess breeds overconfidence, and the next blow-up follows. It teaches you to judge decision quality, not the outcome.',
      ),
      book(
        id: 'b-010', title: 'The Black Swan', author: 'Nassim Taleb',
        year: 2007, rating: 4.10, profile: GallupProfile.uncontrolledRisk, isbn: '081297381X',
        url: 'https://www.goodreads.com/book/show/242472.The_Black_Swan',
        kk: 'Тарихтың ең үлкен қозғалыстары — болжанбайтын «қара аққулар». Талеб неге сирек, бірақ апатты оқиғаларды модельдер елемейтінін түсіндіреді әрі олардан аман қалуды үйретеді. Қорытынды: әрқашан SL, лимиттелген тәуекел.',
        ru: 'Крупнейшие движения истории — непредсказуемые «чёрные лебеди». Талеб объясняет, почему модели игнорируют редкие, но катастрофические события, и учит их переживать. Вывод: всегда SL и ограниченный риск.',
        en: "History's biggest moves are unpredictable Black Swans. Taleb explains why models ignore rare but catastrophic events, and how to survive them. The takeaway: always use an SL and cap your risk.",
      ),
      book(
        id: 'b-011', title: 'Antifragile', author: 'Nassim Taleb',
        year: 2012, rating: 4.13, profile: GallupProfile.uncontrolledRisk,
        url: 'https://www.goodreads.com/book/show/13530973-antifragile',
        kk: 'Антихрупкость — ретсіздік пен стрестен ұтатын жүйелер. Талеб портфельді шокқа төзіп қана қоймай, одан күшейетін етіп құруды ұсынады: кіші тұрақты шығынды қабылдап, сирек үлкен пайдаға ашық болу. Тәуекелді асимметриялы ойлаудың философиясы.',
        ru: 'Антихрупкость — системы, выигрывающие от хаоса и стресса. Талеб предлагает строить портфель так, чтобы он не просто переживал шок, а усиливался: принимать малые регулярные убытки и оставаться открытым к редкой крупной прибыли. Философия асимметричного отношения к риску.',
        en: 'Antifragility — systems that gain from disorder and stress. Taleb argues for building a book that doesn\'t just survive shocks but benefits from them: accept small regular losses while staying open to rare large gains. A philosophy of asymmetric risk.',
      ),
      book(
        id: 'b-012', title: 'Thinking in Bets', author: 'Annie Duke',
        year: 2018, rating: 3.93, profile: GallupProfile.hope, isbn: '0735216355',
        url: 'https://www.goodreads.com/book/show/35957157-thinking-in-bets',
        kk: 'Шешімді нәтижеден ажырату («resulting» қатесі). Покер чемпионы Энни Дьюк белгісіздік жағдайында ставка ретінде ойлауды үйретеді: «менде қанша сенім бар?» деп сұрау. Жақсы шешім нашар нәтиже бере алады — сондықтан процесті бағала.',
        ru: 'Отделять решение от результата (ошибка «resulting»). Чемпионка покера Энни Дьюк учит мыслить ставками в условиях неопределённости: спрашивать «насколько я уверена?». Хорошее решение может дать плохой исход — поэтому оценивай процесс.',
        en: 'Separate the decision from the outcome (the "resulting" error). Poker champ Annie Duke teaches betting-style thinking under uncertainty: ask "how sure am I?". A good decision can yield a bad outcome — so judge the process.',
      ),
      book(
        id: 'b-013', title: 'Thinking, Fast and Slow', author: 'Daniel Kahneman',
        year: 2011, rating: 4.18, profile: GallupProfile.hope, isbn: '0374533555',
        url: 'https://www.goodreads.com/book/show/11468377-thinking-fast-and-slow',
        kk: 'Ойлаудың екі жүйесі: жылдам, автоматты интуиция (System 1) мен баяу, талғампаз логика (System 2). Нобель лауреаты Канеман трейдерге зиян келтіретін когнитивтік қателерді ашады: anchoring, loss aversion, overconfidence. Қатені тану — оны бейтараптандырудың бірінші қадамы.',
        ru: 'Две системы мышления: быстрая автоматическая интуиция (System 1) и медленная аналитическая логика (System 2). Нобелевский лауреат Канеман вскрывает когнитивные искажения, вредящие трейдеру: anchoring, loss aversion, overconfidence. Узнать искажение — первый шаг к его нейтрализации.',
        en: 'Two systems of thought: fast automatic intuition (System 1) and slow analytical logic (System 2). Nobel laureate Kahneman exposes the biases that hurt traders: anchoring, loss aversion, overconfidence. Naming a bias is the first step to neutralizing it.',
      ),
      book(
        id: 'b-014', title: 'Trade Your Way to Financial Freedom', author: 'Van K. Tharp',
        year: 1998, rating: 4.04, profile: GallupProfile.disciplined, isbn: '0071478710',
        url: 'https://www.goodreads.com/book/show/179835.Trade_Your_Way_to_Financial_Freedom',
        kk: 'Пайданың үлкен бөлігін position sizing анықтайды, entry емес. Тарп жүйеңізді expectancy (күтілетін нәтиже) арқылы өлшеп, лот мөлшері мен risk-of-ruin есебіне шоғырлануды үйретеді. Әр трейдерге сай жеке жүйе құру әдістемесі.',
        ru: 'Большую часть результата определяет position sizing, а не вход. Тарп учит измерять систему через expectancy и фокусироваться на размере лота и risk-of-ruin. Методика построения собственной системы под свой характер.',
        en: 'Position sizing, not the entry, drives most of the result. Tharp teaches measuring your system by expectancy and focusing on lot size and risk-of-ruin. A method for building a personal system that fits you.',
      ),
      book(
        id: 'b-015', title: 'Trend Following', author: 'Michael Covel',
        year: 2004, rating: 3.92, profile: GallupProfile.disciplined, isbn: '0136137180',
        url: 'https://www.goodreads.com/book/show/356171.Trend_Following',
        kk: 'Болжамаймыз — реакция жасаймыз. Ковел ондаған жыл бойы пайда тапқан трендті ұстанушылардың жүйесін көрсетеді: HTF bias, breakout entry, trailing stop, пайданы өсуге қалдыру. Эмоцияны алып тастайтын механикалық, қайталанатын процесс.',
        ru: 'Не предсказываем — реагируем. Ковел показывает систему трендовиков, зарабатывавших десятилетиями: HTF bias, вход на пробой, trailing stop, давать прибыли расти. Механический, воспроизводимый процесс, убирающий эмоции.',
        en: 'You don\'t predict — you respond. Covel presents the system of trend followers who profited for decades: HTF bias, breakout entry, trailing stop, letting winners run. A mechanical, repeatable process that removes emotion.',
      ),
      book(
        id: 'b-016', title: 'How to Day Trade for a Living', author: 'Andrew Aziz',
        year: 2016, rating: 3.99, profile: GallupProfile.disciplined, isbn: '1535585951',
        url: 'https://www.goodreads.com/book/show/31247206-how-to-day-trade-for-a-living',
        kk: 'Күнделікті дей-трейдинг процесін қадам-қадаммен көрсетеді: HTF bias, watchlist құру, setup критерийі, sizing, журнал жүргізу. Азиз нақты стратегиялармен (ABCD, reversal) бастаушыға таза әрі тәртіпті бастау береді.',
        ru: 'Пошагово показывает ежедневный процесс дей-трейдинга: HTF bias, составление watchlist, критерии сетапа, sizing, журнал. Азиз с конкретными стратегиями (ABCD, reversal) даёт новичку чистый и дисциплинированный старт.',
        en: 'Walks through the daily day-trading process step by step: HTF bias, building a watchlist, setup criteria, sizing, journaling. With concrete strategies (ABCD, reversal), Aziz gives beginners a clean, disciplined start.',
      ),
      book(
        id: 'b-017', title: 'Atomic Habits', author: 'James Clear',
        year: 2018, rating: 4.34, profile: GallupProfile.disciplined, isbn: '0735211299',
        url: 'https://www.goodreads.com/book/show/40121378-atomic-habits',
        kk: 'Күнделікті 1% жақсаруларды жүйеге айналдыру. Клир дисциплина мотивациядан емес, кіші әрі қайталанатын әдеттер мен ортадан туатынын көрсетеді. Трейдерге қатысты: журнал, pre-trade checklist пен паузаны автоматты дағдыға айналдыру.',
        ru: 'Превратить ежедневные улучшения на 1% в систему. Клир показывает, что дисциплина рождается не из мотивации, а из малых повторяемых привычек и окружения. Для трейдера: сделать журнал, pre-trade чек-лист и паузу автоматическими привычками.',
        en: 'Turn daily 1% improvements into a system. Clear shows discipline comes not from motivation but from small repeated habits and environment design. For a trader: make journaling, a pre-trade checklist and the pause automatic.',
      ),
      book(
        id: 'b-018', title: 'One Good Trade', author: 'Mike Bellafiore',
        year: 2010, rating: 4.13, profile: GallupProfile.disciplined, isbn: '0470529407',
        url: 'https://www.goodreads.com/book/show/8124269-one-good-trade',
        kk: 'Нью-Йорк prop-дескінің ішкі көрінісі (SMB Capital). Беллафиоре «бір сапалы сделка» философиясын ашады: нәтиже емес, процесс маңызды. Кітапта нақты setup-тар, тәуекелді басқару және жаңа трейдерлерді дайындау жүйесі бар.',
        ru: 'Взгляд изнутри prop-деска Нью-Йорка (SMB Capital). Беллафиоре раскрывает философию «одной хорошей сделки»: важен процесс, а не результат. В книге — конкретные сетапы, управление риском и система подготовки новых трейдеров.',
        en: 'An inside look at a NYC prop desk (SMB Capital). Bellafiore unpacks the "one good trade" philosophy: process matters, not the outcome. The book gives concrete setups, risk management and a system for training new traders.',
      ),
      book(
        id: 'b-019', title: 'Technical Analysis of the Financial Markets', author: 'John J. Murphy',
        year: 1999, rating: 4.21, profile: GallupProfile.disciplined, isbn: '0735200661',
        url: 'https://www.goodreads.com/book/show/171258.Technical_Analysis_of_the_Financial_Markets',
        kk: 'Техникалық талдаудың «киелі кітабы» — Мерфидің толық анықтамалығы. Тренд, қолдау/қарсылық, графикалық паттерндер, индикаторлар, интермаркет талдау — бәрі құрылымды түрде. Кез келген трейдер сөресінде болуға тиіс негіз.',
        ru: '«Библия» технического анализа — полный справочник Мерфи. Тренд, поддержка/сопротивление, графические паттерны, индикаторы, межрыночный анализ — всё структурированно. Фундамент, который должен быть на полке любого трейдера.',
        en: 'The "bible" of technical analysis — Murphy\'s complete reference. Trend, support/resistance, chart patterns, indicators, intermarket analysis — all structured. A foundation that belongs on every trader\'s shelf.',
      ),
      book(
        id: 'b-020', title: 'Japanese Candlestick Charting Techniques', author: 'Steve Nison',
        year: 1991, rating: 4.10, profile: GallupProfile.disciplined, isbn: '0735201811',
        url: 'https://www.goodreads.com/book/show/172739.Japanese_Candlestick_Charting_Techniques',
        kk: 'Жапон шамдарын Батысқа танытқан Нисонның классигі. Doji, hammer, engulfing сияқты формациялар арқылы баға әрекеті мен нарық психологиясын оқуды үйретеді. XAU/USD сияқты ликвидті активте reversal/continuation сигналдарын тануға таптырмас.',
        ru: 'Классика Нисона, открывшая Западу японские свечи. Учит читать price action и психологию рынка через формации: doji, hammer, engulfing. Незаменимо для распознавания reversal/continuation на ликвидном активе вроде XAU/USD.',
        en: 'Nison\'s classic that introduced candlesticks to the West. Teaches reading price action and market psychology through formations: doji, hammer, engulfing. Invaluable for spotting reversals/continuations on a liquid asset like XAU/USD.',
      ),
      book(
        id: 'b-021', title: 'The Intelligent Investor', author: 'Benjamin Graham',
        year: 1949, rating: 4.24, profile: GallupProfile.uncontrolledRisk, isbn: '0060555661',
        url: 'https://www.goodreads.com/book/show/106835.The_Intelligent_Investor',
        kk: 'Грэмнің «құнды инвестордың інжілі». «Қауіпсіздік маржасы» мен «Mr. Market» түсініктерін енгізеді: нарықтың көңіл-күйіне емес, құнға сүйену. Басты сабақ — капиталды сақтау табыстан бұрын тұрады, бұл трейдерге де тікелей қатысты.',
        ru: '«Библия стоимостного инвестора» Грэма. Вводит понятия «маржа безопасности» и «Mr. Market»: опираться на стоимость, а не на настроение рынка. Главный урок — сохранение капитала важнее прибыли, и это прямо касается трейдера.',
        en: 'Graham\'s "bible of value investing". Introduces the "margin of safety" and "Mr. Market": rely on value, not market mood. The core lesson — capital preservation before profit — applies directly to traders too.',
      ),
      book(
        id: 'b-022', title: 'Way of the Turtle', author: 'Curtis Faith',
        year: 2007, rating: 3.94, profile: GallupProfile.disciplined,
        url: 'https://www.goodreads.com/book/show/13539.Way_of_the_Turtle',
        kk: '«Тасбақалар» атақты экспериментінің ішкі тарихы: трейдингке үйретуге бола ма? Фейт механикалық тренд-жүйенің нақты ережелерін — entry, sizing, exit — ашады әрі бір жүйеге әртүрлі адамдардың неге әртүрлі нәтиже алатынын талдайды. Жауабы — дисциплинада.',
        ru: 'Внутренняя история знаменитого эксперимента «Черепах»: можно ли научить трейдингу? Фейт раскрывает конкретные правила механической трендовой системы — entry, sizing, exit — и анализирует, почему по одной системе у разных людей разный результат. Ответ — в дисциплине.',
        en: 'The inside story of the famous "Turtles" experiment: can trading be taught? Faith reveals the exact rules of a mechanical trend system — entry, sizing, exit — and analyzes why the same system gives different people different results. The answer is discipline.',
      ),

      book(
        id: 'b-023', title: 'The Most Important Thing', author: 'Howard Marks',
        year: 2011, rating: 4.23, profile: GallupProfile.disciplined, isbn: '0231153686',
        url: 'https://www.goodreads.com/book/show/10127019-the-most-important-thing',
        kk: 'Тәуекелді түсіну — ең маңызды нәрсе. Бағаны емес, асимметрия мен қателесу ықтималдығын бағала.',
        ru: 'Понимание риска — самое важное. Оцени не цену, а асимметрию и вероятность ошибиться.',
        en: 'Understanding risk is the most important thing. Judge asymmetry and the odds of being wrong, not price.',
      ),
      book(
        id: 'b-024', title: 'When Genius Failed', author: 'Roger Lowenstein',
        year: 2000, rating: 4.13, profile: GallupProfile.uncontrolledRisk, isbn: '0375758259',
        url: 'https://www.goodreads.com/book/show/10669.When_Genius_Failed',
        kk: 'LTCM хедж-қорының құлауы: Нобель лауреаттары да шамадан тыс leverage-тен талқандалады.',
        ru: 'Крах хедж-фонда LTCM: даже нобелевские лауреаты гибнут от чрезмерного плеча.',
        en: 'The collapse of LTCM: even Nobel laureates blow up on excessive leverage.',
      ),
      book(
        id: 'b-025', title: "Liar's Poker", author: 'Michael Lewis',
        year: 1989, rating: 4.17, profile: GallupProfile.uncontrolledRisk, isbn: '039333869X',
        url: 'https://www.goodreads.com/book/show/7865083-liar-s-poker',
        kk: '80-жылдардағы Уолл-стриттің ішкі көрінісі. Тәуекел мәдениеті мен бонустардың азғыруы.',
        ru: 'Взгляд изнутри на Уолл-стрит 80-х. Культура риска и соблазн бонусов.',
        en: 'An inside look at 1980s Wall Street. The culture of risk and the lure of bonuses.',
      ),
      book(
        id: 'b-026', title: 'The Big Short (book)', author: 'Michael Lewis',
        year: 2010, rating: 4.18, profile: GallupProfile.disciplined, isbn: '0393338827',
        url: 'https://www.goodreads.com/book/show/7104915-the-big-short',
        kk: '2008 ипотека дағдарысын болжаған контр-консенсус трейдерлер туралы. Research пен сабырлылық.',
        ru: 'О трейдерах против консенсуса, предсказавших ипотечный кризис 2008. Исследование и терпение.',
        en: 'About contrarian traders who foresaw the 2008 mortgage crisis. Research and patience.',
      ),
      book(
        id: 'b-027', title: 'Flash Boys', author: 'Michael Lewis',
        year: 2014, rating: 4.04, profile: GallupProfile.uncontrolledRisk, isbn: '0393351599',
        url: 'https://www.goodreads.com/book/show/18085523-flash-boys',
        kk: 'Жоғары жиілікті сауда (HFT) мен нарық құрылымы. Жылдамдық кімге пайда, кімге зиян.',
        ru: 'Высокочастотная торговля (HFT) и структура рынка. Кому скорость на пользу, кому во вред.',
        en: 'High-frequency trading and market structure. Who speed helps, and who it hurts.',
      ),
      book(
        id: 'b-028', title: 'One Up On Wall Street', author: 'Peter Lynch',
        year: 1989, rating: 4.23, profile: GallupProfile.hope, isbn: '0743200403',
        url: 'https://www.goodreads.com/book/show/762462.One_Up_On_Wall_Street',
        kk: 'Күнделікті өмірден компания таңдау. «Не білесің, соны ал» — бірақ зерттеуден кейін ғана.',
        ru: 'Выбор компаний из повседневной жизни. «Покупай то, что знаешь» — но только после анализа.',
        en: 'Picking companies from everyday life. "Buy what you know" — but only after research.',
      ),
      book(
        id: 'b-029', title: 'A Random Walk Down Wall Street', author: 'Burton Malkiel',
        year: 1973, rating: 4.07, profile: GallupProfile.uncontrolledRisk,
        url: 'https://www.goodreads.com/book/show/661564.A_Random_Walk_Down_Wall_Street',
        kk: 'Нарықты тұрақты жеңу қиын. Кездейсоқтық, диверсификация және ұзақ мерзімді тәртіп туралы.',
        ru: 'Стабильно обыгрывать рынок трудно. О случайности, диверсификации и долгосрочной дисциплине.',
        en: 'Consistently beating the market is hard. On randomness, diversification and long-term discipline.',
      ),
      book(
        id: 'b-030', title: 'The Little Book of Common Sense Investing', author: 'John C. Bogle',
        year: 2007, rating: 4.16, profile: GallupProfile.disciplined, isbn: '1119404509',
        url: 'https://www.goodreads.com/book/show/186650.The_Little_Book_of_Common_Sense_Investing',
        kk: 'Индекс қорлары мен төмен шығынның күші. Қарапайымдылық пен сабыр — ұзақ мерзімде жеңеді.',
        ru: 'Сила индексных фондов и низких издержек. Простота и терпение выигрывают на дистанции.',
        en: 'The power of index funds and low costs. Simplicity and patience win over the long run.',
      ),
      book(
        id: 'b-031', title: 'The Mental Game of Trading', author: 'Jared Tendler',
        year: 2021, rating: 4.40, profile: GallupProfile.revenge,
        url: 'https://www.goodreads.com/book/show/57603284-the-mental-game-of-trading',
        kk: 'Tilt, ашу, қорқыныш пен ашкөздіктің түбірін тауып жою. Эмоцияны жүйелі түрде картаға түсіру.',
        ru: 'Найти и устранить корень tilt, гнева, страха и жадности. Системно картировать эмоции.',
        en: 'Find and fix the root of tilt, anger, fear and greed. Map your emotions systematically.',
      ),
      book(
        id: 'b-032', title: 'Best Loser Wins', author: 'Tom Hougaard',
        year: 2022, rating: 4.34, profile: GallupProfile.revenge,
        url: 'https://www.goodreads.com/book/show/60549362-best-loser-wins',
        kk: 'Көпшілікке қарсы ойлау. Ұтылуды дұрыс басқарған трейдер ұзақ мерзімде ұтады.',
        ru: 'Мыслить против толпы. Кто умеет правильно проигрывать, тот выигрывает на дистанции.',
        en: 'Think against the crowd. The trader who loses well is the one who wins long-term.',
      ),
      book(
        id: 'b-033', title: 'The Alchemy of Finance', author: 'George Soros',
        year: 1987, rating: 3.86, profile: GallupProfile.uncontrolledRisk,
        url: 'https://www.goodreads.com/book/show/1351805-the-alchemy-of-finance',
        kk: 'Рефлексивтілік теориясы: нарық пен қатысушылар бір-біріне әсер етеді. Сорос көзқарасы.',
        ru: 'Теория рефлексивности: рынок и участники влияют друг на друга. Взгляд Сороса.',
        en: 'The theory of reflexivity: markets and participants shape each other. Soros\'s lens.',
      ),
      book(
        id: 'b-034', title: 'Margin of Safety', author: 'Seth Klarman',
        year: 1991, rating: 4.27, profile: GallupProfile.disciplined,
        url: 'https://www.goodreads.com/book/show/494168.Margin_of_Safety',
        kk: 'Құнды инвестордың классигі. Қауіпсіздік маржасы — капиталды жоғалтпаудың кепілі.',
        ru: 'Классика стоимостного инвестора. Маржа безопасности — гарантия не потерять капитал.',
        en: 'A value-investing classic. The margin of safety is your guarantee against losing capital.',
      ),
      book(
        id: 'b-035', title: 'Common Stocks and Uncommon Profits', author: 'Philip A. Fisher',
        year: 1958, rating: 4.16, profile: GallupProfile.disciplined,
        url: 'https://www.goodreads.com/book/show/757895.Common_Stocks_and_Uncommon_Profits_and_Other_Writings',
        kk: 'Сапалы компанияны зерттеудің 15 нүктесі. Сапа мен ұзақ мерзімді ұстау философиясы.',
        ru: '15 пунктов анализа качественной компании. Философия качества и долгого удержания.',
        en: 'Fifteen points for analyzing a quality company. The philosophy of quality and long holding.',
      ),
      book(
        id: 'b-036', title: 'The Essays of Warren Buffett', author: 'Lawrence Cunningham',
        year: 1997, rating: 4.23, profile: GallupProfile.disciplined,
        url: 'https://www.goodreads.com/book/show/105099.The_Essays_of_Warren_Buffett',
        kk: 'Баффеттің акционерлерге хаттарының жинағы. Тәртіп, шыдамдылық және ұзақ көзқарас.',
        ru: 'Сборник писем Баффета акционерам. Дисциплина, терпение и долгосрочный взгляд.',
        en: "A curated collection of Buffett's shareholder letters. Discipline, patience and the long view.",
      ),
      book(
        id: 'b-037', title: 'Mastering the Trade', author: 'John F. Carter',
        year: 2005, rating: 4.05, profile: GallupProfile.disciplined,
        url: 'https://www.goodreads.com/book/show/255017.Mastering_the_Trade',
        kk: 'Күнделікті сетаптар, кіру-шығу ережелері мен психология. Практикалық intraday жүйе.',
        ru: 'Дневные сетапы, правила входа-выхода и психология. Практичная intraday-система.',
        en: 'Daily setups, entry/exit rules and psychology. A practical intraday system.',
      ),
      book(
        id: 'b-038', title: 'Come Into My Trading Room', author: 'Alexander Elder',
        year: 2002, rating: 4.07, profile: GallupProfile.uncontrolledRisk,
        url: 'https://www.goodreads.com/book/show/771360.Come_Into_My_Trading_Room',
        kk: 'Trading for a Living жалғасы. Money management мен сделка жазбасына терең тоқталу.',
        ru: 'Продолжение Trading for a Living. Глубоко о money management и журнале сделок.',
        en: 'The sequel to Trading for a Living. A deep dive into money management and trade records.',
      ),
      book(
        id: 'b-039', title: 'Den of Thieves', author: 'James B. Stewart',
        year: 1991, rating: 4.15, profile: GallupProfile.uncontrolledRisk,
        url: 'https://www.goodreads.com/book/show/61153.Den_of_Thieves',
        kk: '80-жылдардағы инсайдер-сауда скандалдары. Ережесіз тәуекелдің заңды салдары.',
        ru: 'Скандалы инсайдерской торговли 80-х. Юридические последствия риска без правил.',
        en: 'The insider-trading scandals of the 1980s. The legal consequences of lawless risk.',
      ),
      book(
        id: 'b-040', title: 'Mastering the Market Cycle', author: 'Howard Marks',
        year: 2018, rating: 4.06, profile: GallupProfile.disciplined,
        url: 'https://www.goodreads.com/book/show/38821039-mastering-the-market-cycle',
        kk: 'Нарық циклдерін тану. «Қазір циклдің қай жерінде тұрмыз?» сұрағы тәуекелді басқарады.',
        ru: 'Распознавание рыночных циклов. Вопрос «где мы в цикле?» управляет риском.',
        en: 'Recognizing market cycles. The question "where are we in the cycle?" governs your risk.',
      ),

      // ─────────────────────────── FILMS (22) ───────────────────────────
      film(
        id: 'f-001', title: 'The Wolf of Wall Street', author: 'Martin Scorsese',
        year: 2013, rating: 8.2, profile: GallupProfile.uncontrolledRisk, imdb: 'tt0993846',
        kk: 'Джордан Белфорттың шынайы тарихы — нөлден миллионерге, сосын құлдырау. Скорсезе ашкөздік, бақыланбайтын тәуекел мен мансапты жоятын эйфорияны көрсетеді. Трейдерге айна: эмоция мен шектен шыққан leverage қайда апаратынының ескертуі.',
        ru: 'Реальная история Джордана Белфорта — от нуля к миллионам и затем падение. Скорсезе показывает жадность, неконтролируемый риск и эйфорию, разрушающую карьеру. Зеркало для трейдера: куда ведут эмоции и чрезмерное плечо.',
        en: 'The true story of Jordan Belfort — from nothing to millions, then collapse. Scorsese shows greed, uncontrolled risk and the euphoria that wrecks a career. A mirror for traders: where emotion and excess leverage lead.',
      ),
      film(
        id: 'f-002', title: 'The Big Short', author: 'Adam McKay',
        year: 2015, rating: 7.8, profile: GallupProfile.disciplined, imdb: 'tt1596363',
        kk: '2008 ипотека дағдарысын алдын ала көрген бірнеше контр-консенсус трейдер туралы. Олар көпшілікке қарсы тұрып, терең research жасап, ауыр сабырлылықпен позицияны ұстады. Edge — топпен емес, фактімен бірге болуда деген сабақ.',
        ru: 'О нескольких трейдерах против консенсуса, предсказавших ипотечный кризис 2008. Они шли против толпы, провели глубокий research и держали позицию с тяжёлым терпением. Урок: edge — не в толпе, а в фактах.',
        en: 'About a handful of contrarian traders who foresaw the 2008 mortgage crisis. They went against the crowd, did deep research, and held with painful patience. The lesson: edge lies with the facts, not the crowd.',
      ),
      film(
        id: 'f-003', title: 'Margin Call', author: 'J.C. Chandor',
        year: 2011, rating: 7.1, profile: GallupProfile.revenge, imdb: 'tt1615147',
        kk: 'Ірі банктегі дағдарыс қарсаңындағы 24 сағат. Тәуекелдің ашылуы мен эмоциясыз, бірақ ауыр шешімдер туралы. «Шектен шығу нүктесі» мен залалды дер кезінде мойындаудың құнын көрсетеді.',
        ru: '24 часа в крупном банке накануне кризиса. О раскрытии риска и хладнокровных, но тяжёлых решениях. Показывает «точку остановки» и цену своевременного признания убытка.',
        en: '24 hours inside a big bank on the eve of the crisis. About risk coming to light and cold but painful decisions. It shows the cut-off point and the value of admitting a loss in time.',
      ),
      film(
        id: 'f-004', title: 'Wall Street', author: 'Oliver Stone',
        year: 1987, rating: 7.4, profile: GallupProfile.uncontrolledRisk, imdb: 'tt0094291',
        kk: '«Ашкөздік — жақсы» дәуірінің символы. Гордон Гекко жас брокерді жылдам байлық пен инсайдер-саудаға азғырады. Этика мен қысқа мерзімді пайданың арасындағы таңдау — әр нарық қатысушысына таныс сынақ.',
        ru: 'Символ эпохи «жадность — это хорошо». Гордон Гекко соблазняет молодого брокера быстрым богатством и инсайдерской торговлей. Выбор между этикой и краткосрочной прибылью — знакомое испытание для любого участника рынка.',
        en: 'The icon of the "greed is good" era. Gordon Gekko lures a young broker with fast money and insider trading. The choice between ethics and short-term profit — a familiar test for any market participant.',
      ),
      film(
        id: 'f-005', title: 'Rogue Trader', author: 'James Dearden',
        year: 1999, rating: 6.3, profile: GallupProfile.uncontrolledRisk, imdb: 'tt0131566',
        kk: 'Ник Лисонның шынайы тарихы: жасырын шотта averaging-down жасап, \$1.3 млрд жоғалтып, 233 жасар Barings банкін құлатады. Дисциплинасыз тәуекел мен залалды жасырудың қандай апатқа әкелетінінің ең күшті мысалы.',
        ru: 'Реальная история Ника Лисона: averaging-down на скрытом счёте, потеря \$1.3 млрд и банкротство 233-летнего банка Barings. Сильнейший пример того, к какой катастрофе ведут риск без дисциплины и сокрытие убытка.',
        en: 'The true story of Nick Leeson: averaging-down on a hidden account, losing \$1.3bn and bankrupting the 233-year-old Barings. The starkest example of where undisciplined risk and hiding losses lead.',
      ),
      film(
        id: 'f-006', title: 'Boiler Room', author: 'Ben Younger',
        year: 2000, rating: 7.0, profile: GallupProfile.hope, imdb: 'tt0181984',
        kk: 'Жалған брокерлік контораның ішкі көрінісі. Тез байлық уәдесі, агрессивті сату мен «үмітпен сатудың» қараңғы жағы. Инвесторды қалай манипуляциялайтынын біліп, осындай схемалардан сақтануға үйретеді.',
        ru: 'Взгляд изнутри на мошенническую брокерскую контору. Обещание быстрого богатства, агрессивные продажи и тёмная сторона «продажи надежды». Учит распознавать манипуляции и беречься подобных схем.',
        en: 'An inside look at a fraudulent brokerage. The promise of fast riches, hard selling and the dark side of "selling hope". Teaches you to spot the manipulation and avoid such schemes.',
      ),
      film(
        id: 'f-007', title: 'Inside Job', author: 'Charles Ferguson',
        year: 2010, rating: 8.2, profile: GallupProfile.disciplined, imdb: 'tt1645089',
        kk: 'Оскар алған деректі фильм 2008 дағдарысының жүйелік себептерін талдайды: реттеудің әлсіздігі, мүдделер қақтығысы, тәуекелді жаппай елемеу. Жеке трейдерге де сабақ — тәуекелді елемеу ертең міндетті түрде есеп сұрайды.',
        ru: 'Оскароносный документальный фильм разбирает системные причины кризиса 2008: слабость регулирования, конфликт интересов, массовое игнорирование риска. Урок и для частного трейдера: пренебрежение риском завтра обязательно спросит.',
        en: 'The Oscar-winning documentary dissects the systemic causes of the 2008 crisis: weak regulation, conflicts of interest, mass ignoring of risk. A lesson for the individual trader too: neglected risk always comes due.',
      ),
      film(
        id: 'f-008', title: 'Too Big to Fail', author: 'Curtis Hanson',
        year: 2011, rating: 7.3, profile: GallupProfile.disciplined, imdb: 'tt1742683',
        kk: '2008 жылы Lehman Brothers құлауы мен үкімет пен банктердің құтқару шешімдерінің ішкі көрінісі. Жүйелік тәуекелдің не екенін әрі бір тораптың құлауы бүкіл жүйені қалай шайқалтатынын көрсетеді.',
        ru: 'Взгляд изнутри на крах Lehman Brothers в 2008 и решения правительства и банков о спасении. Показывает, что такое системный риск и как падение одного узла раскачивает всю систему.',
        en: 'An inside view of the 2008 Lehman Brothers collapse and the rescue decisions by government and banks. It shows what systemic risk is and how one node\'s failure shakes the whole system.',
      ),
      film(
        id: 'f-009', title: 'The Wizard of Lies', author: 'Barry Levinson',
        year: 2017, rating: 6.8, profile: GallupProfile.uncontrolledRisk, imdb: 'tt1933667',
        kk: 'Берни Мэдоффтың тарихтағы ең ірі Ponzi-схемасы. «Тұрақты, жоғары пайыз» уәдесінің артындағы алаяқтық пен оның құрбандары. Сабақ: тым жақсы болып көрінетін «кепілді табыс» — әрқашан қызыл жалау.',
        ru: 'Крупнейшая в истории схема Понци Берни Мэдоффа. Мошенничество за обещанием «стабильной высокой доходности» и его жертвы. Урок: слишком хорошая «гарантированная доходность» — всегда красный флаг.',
        en: 'Bernie Madoff\'s largest-ever Ponzi scheme. The fraud behind a promise of "steady high returns" and its victims. The lesson: a too-good "guaranteed return" is always a red flag.',
      ),
      film(
        id: 'f-010', title: 'Trading Places', author: 'John Landis',
        year: 1983, rating: 7.5, profile: GallupProfile.hope, imdb: 'tt0086465',
        kk: 'Биржа мен тауар фьючерстері туралы классикалық комедия. Жеңіл түрде нарық механикасын, адам табиғаты мен инсайдер ақпараттың күшін көрсетеді. Күлкілі, бірақ нарық туралы дәл байқаулары бар.',
        ru: 'Классическая комедия о бирже и товарных фьючерсах. В лёгкой форме показывает механику рынка, человеческую природу и силу инсайдерской информации. Смешно, но с точными наблюдениями о рынке.',
        en: 'A classic comedy about the exchange and commodity futures. It lightly shows market mechanics, human nature and the power of inside information. Funny, but with sharp observations about markets.',
      ),
      film(
        id: 'f-011', title: 'Enron: The Smartest Guys in the Room', author: 'Alex Gibney',
        year: 2005, rating: 7.6, profile: GallupProfile.disciplined, imdb: 'tt1016268',
        kk: 'Enron энергетикалық алыбының құлауы туралы Оскарға ұсынылған деректі фильм. Есепті бұрмалау, жасырын борыш пен корпоративтік ашкөздіктің ақыры. Ашықтық пен шынайы есеп неге маңызды екенінің сабағы.',
        ru: 'Номинированный на «Оскар» документальный фильм о крахе энергетического гиганта Enron. Чем кончаются искажение отчётности, скрытый долг и корпоративная жадность. Урок о важности прозрачности и честной отчётности.',
        en: 'An Oscar-nominated documentary on the collapse of energy giant Enron. Where cooked books, hidden debt and corporate greed end up. A lesson on why transparency and honest accounting matter.',
      ),
      film(
        id: 'f-012', title: 'Floored', author: 'James Allen Smith',
        year: 2009, rating: 6.9, profile: GallupProfile.disciplined, imdb: 'tt1372701',
        kk: 'Чикаго pit (биржа еденіндегі) трейдерлері туралы деректі фильм. Электронды саудаға көшу дәуіріндегі эмоция, тәуекел мен өзін-өзі бақылаудың құны. Технология өзгерсе де, трейдер психологиясы сол күйінде қалатынын көрсетеді.',
        ru: 'Документальный фильм о трейдерах чикагского пита (биржевого пола). Эмоции, риск и цена самоконтроля в эпоху перехода к электронной торговле. Показывает: технологии меняются, а психология трейдера остаётся прежней.',
        en: 'A documentary on Chicago pit traders. Emotion, risk and the price of self-control as the floor gives way to electronic trading. It shows that technology changes but trader psychology stays the same.',
      ),

      film(
        id: 'f-013', title: 'Wall Street: Money Never Sleeps', author: 'Oliver Stone',
        year: 2010, rating: 6.3, profile: GallupProfile.uncontrolledRisk, imdb: 'tt1027718',
        kk: 'Гордон Гекконың түрмеден кейінгі оралуы — 2008 дағдарысы аясында. Ашкөздік, кек пен шамадан тыс leverage қайта оралады. Жаңа буын да ескі қателерді қайталайтынының ескертуі.',
        ru: 'Возвращение Гордона Гекко после тюрьмы на фоне кризиса 2008. Жадность, месть и чрезмерное плечо возвращаются. Напоминание о том, что новое поколение повторяет старые ошибки.',
        en: 'Gordon Gekko returns after prison, against the 2008 crisis. Greed, revenge and excess leverage come back around. A reminder that a new generation repeats the old mistakes.',
      ),
      film(
        id: 'f-014', title: 'The Pursuit of Happyness', author: 'Gabriele Muccino',
        year: 2006, rating: 8.0, profile: GallupProfile.hope, imdb: 'tt0454921',
        kk: 'Үйсіз қалса да брокер болуға ұмтылған Крис Гарднердің шынайы тарихы. Табандылық, тәртіп пен орынды үміттің күші туралы шабыттандыратын фильм. Сәтсіздіктен өту мен мақсатқа адалдықтың үлгісі.',
        ru: 'Реальная история Криса Гарднера, который, даже оставшись без дома, стремился стать брокером. Вдохновляющий фильм о силе настойчивости, дисциплины и здоровой надежды. Пример прохождения через неудачи и верности цели.',
        en: 'The true story of Chris Gardner, who chased a stockbroking career even while homeless. An inspiring film about persistence, discipline and healthy hope. A model of pushing through failure and staying loyal to a goal.',
      ),
      film(
        id: 'f-015', title: 'Limitless', author: 'Neil Burger',
        year: 2011, rating: 7.4, profile: GallupProfile.uncontrolledRisk, imdb: 'tt1219289',
        kk: 'Кейіпкер дәрі арқылы миын толық ашып, нарықта тез байиды — бірақ бақыланбайтын тәуекелге тап болады. «Бәрін білем» мен артық сенімділіктің қауіпі туралы метафора. Шектеусіз сенім — шектеусіз тәуекелдің бастауы.',
        ru: 'Герой через препарат раскрывает мозг и быстро богатеет на рынке — но попадает в неконтролируемый риск. Метафора об опасности чувства «я всё знаю» и сверхуверенности. Безграничная уверенность — начало безграничного риска.',
        en: 'The hero unlocks his brain via a drug and gets rich fast in the markets — but lands in uncontrolled risk. A metaphor for the danger of "I know everything" and overconfidence. Limitless confidence is the start of limitless risk.',
      ),
      film(
        id: 'f-016', title: 'Gold', author: 'Stephen Gaghan',
        year: 2016, rating: 6.6, profile: GallupProfile.uncontrolledRisk, imdb: 'tt1800302',
        kk: 'Индонезиядағы алтын кенішіне бәрін тіккен авантюристің тарихы. XAU тақырыбына тікелей жақын: ашкөздік, елес пен «алтын безгегі». Тым жақсы болып көрінетін мүмкіндіктің артында не жасырынуы мүмкін екенінің ескертуі.',
        ru: 'История авантюриста, поставившего всё на золотой прииск в Индонезии. Прямо в тему XAU: жадность, иллюзия и «золотая лихорадка». Напоминание о том, что может скрываться за слишком хорошей возможностью.',
        en: 'The story of a wildcatter betting everything on an Indonesian gold mine. Right on the XAU theme: greed, illusion and "gold fever". A warning about what can hide behind a too-good opportunity.',
      ),
      film(
        id: 'f-017', title: 'Money Monster', author: 'Jodie Foster',
        year: 2016, rating: 6.5, profile: GallupProfile.hope, imdb: 'tt2241351',
        kk: 'Алгоритм «қателігінен» бәрін жоғалтқан инвестор теле-гуруды кепілге алады. «Кепілдік берілген пайда» уәдесі мен соқыр сенімнің бағасы. Бөгде біреудің кеңесіне толық сенудің қаупін көрсетеді.',
        ru: 'Инвестор, потерявший всё из-за «сбоя» алгоритма, берёт телегуру в заложники. Цена обещания «гарантированной прибыли» и слепого доверия. Показывает опасность полного доверия чужому совету.',
        en: 'An investor who lost everything to an algorithm "glitch" takes a TV guru hostage. The price of a "guaranteed profit" promise and blind trust. It shows the danger of fully trusting someone else\'s advice.',
      ),
      film(
        id: 'f-018', title: 'Arbitrage', author: 'Nicholas Jarecki',
        year: 2012, rating: 6.6, profile: GallupProfile.uncontrolledRisk, imdb: 'tt1764234',
        kk: 'Шотындағы үлкен шығынды жасырып, мәмілені жабуға тырысқан хедж-қор магнаты. Жасырын тәуекел мен бір өтіріктің артынан тізбектеле туатын жаңа өтіріктер. Залалды дер кезінде мойындамаудың адами әрі қаржылық бағасы.',
        ru: 'Магнат хедж-фонда, скрывающий крупный убыток на счёте и пытающийся закрыть сделку. Скрытый риск и цепочка новой лжи вслед за одной. Человеческая и финансовая цена непризнанного вовремя убытка.',
        en: 'A hedge-fund magnate hiding a large loss while trying to close a deal. Concealed risk and a chain of new lies following one. The human and financial price of a loss not admitted in time.',
      ),
      film(
        id: 'f-019', title: '99 Homes', author: 'Ramin Bahrani',
        year: 2014, rating: 7.1, profile: GallupProfile.uncontrolledRisk, imdb: 'tt2891174',
        kk: 'Үйінен айырылған адам оны қуып шығарған риелтордың серігіне айналады. 2008 жылжымайтын мүлік дағдарысы мен ашкөздіктің адами бағасы. Этика мен жылдам пайданың арасындағы ауыр таңдау.',
        ru: 'Человек, потерявший дом, становится напарником риелтора, который его выселил. Кризис недвижимости 2008 и человеческая цена жадности. Тяжёлый выбор между этикой и быстрой прибылью.',
        en: 'A man who lost his home becomes the partner of the realtor who evicted him. The 2008 housing crisis and the human cost of greed. The hard choice between ethics and fast profit.',
      ),
      film(
        id: 'f-020', title: 'Dumb Money', author: 'Craig Gillespie',
        year: 2023, rating: 6.7, profile: GallupProfile.hope,
        kk: 'GameStop акциясының 2021 жылғы short squeeze тарихы. Reddit арқылы біріккен жеке инвесторлар, топтың үміті, FOMO мен әлеуметтік желінің күші. Эйфория мен тәуекелдің заманауи мысалы.',
        ru: 'История short squeeze акций GameStop в 2021. Частные инвесторы, объединившиеся через Reddit, надежда толпы, FOMO и сила соцсетей. Современный пример эйфории и риска.',
        en: 'The 2021 GameStop short-squeeze story. Retail investors uniting via Reddit, crowd hope, FOMO and the power of social media. A modern example of euphoria and risk.',
      ),
      film(
        id: 'f-021', title: 'Becoming Warren Buffett', author: 'Peter Kunhardt',
        year: 2017, rating: 7.6, profile: GallupProfile.disciplined,
        kk: 'Уоррен Баффеттің өмірі мен ойлау тәсілі туралы HBO деректі фильмі. Тәртіп, шыдамдылық, қарапайым өмір мен compound пайыздың құдіреті. Ұзақ мерзімді ойлаудың әрі сабырлылықтың үлгісі.',
        ru: 'Документальный фильм HBO о жизни и образе мышления Уоррена Баффета. Дисциплина, терпение, скромный быт и сила сложного процента. Образец долгосрочного мышления и спокойствия.',
        en: 'An HBO documentary on Warren Buffett\'s life and way of thinking. Discipline, patience, a modest lifestyle and the power of compounding. A model of long-term thinking and calm.',
      ),
      film(
        id: 'f-022', title: 'Capitalism: A Love Story', author: 'Michael Moore',
        year: 2009, rating: 6.9, profile: GallupProfile.disciplined,
        kk: 'Майкл Мурдың 2008 дағдарысы мен жүйелік ашкөздікке деген сыни көзқарасы. Қаржы жүйесінің әлсіз тұстары мен оның қарапайым адамдарға әсерін қарастырады. Пікірталас тудырса да, тәуекел мен жауапкершілік туралы ойландырады.',
        ru: 'Критический взгляд Майкла Мура на кризис 2008 и системную жадность. Рассматривает уязвимости финансовой системы и их влияние на обычных людей. Спорно, но заставляет задуматься о риске и ответственности.',
        en: 'Michael Moore\'s critical look at the 2008 crisis and systemic greed. It examines the financial system\'s vulnerabilities and their impact on ordinary people. Provocative, but it makes you think about risk and responsibility.',
      ),

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
    return [...kBooksCatalogA, ...kBooksCatalogB, ...kFilmsCatalog, ...mixed];
  }
}
