// Маркетингтік қабат: сабақтарға қызықтыратын (hook) тақырыптар, эмодзи,
// субтитр-ілмек және ұзақтық. Мазмұн (blocks) courses_data.dart-та қалады —
// бұл файл тек «сатылатын» сыртқы көрінісін береді (repository қолданады).
import '../../../shared/models/course.dart';

/// Тақырып бойынша фильм/сериал/кітап ұсынысы (repository сабақ соңына қосады).
// kind: film | series | book | doc. Атаулар әмбебап, түсініктеме RU-да.
typedef MediaRecData = ({MediaKind kind, String title, String meta, String note});

const Map<String, MediaRecData> lessonMedia = {
  'l1_1': (kind: MediaKind.book, title: 'Sapiens. Краткая история человечества', meta: 'Юваль Ной Харари, 2011', note: 'Глава о деньгах: как доверие племени превратилось в универсальную валюту, объединившую планету.'),
  'l1_2': (kind: MediaKind.doc, title: 'Money for Nothing: Inside the Federal Reserve', meta: 'док. фильм, 2013', note: 'Как печатается мировая резервная валюта и почему весь мир зависит от решений ФРС.'),
  'l2_3': (kind: MediaKind.film, title: 'Слишком крут для неудачи (Too Big to Fail)', meta: 'HBO, 2011', note: 'Как ФРС и Минфин в реальном времени тушили пожар кризиса 2008 года.'),
  'l4_1': (kind: MediaKind.book, title: '思in Bets: Ставки на неопределённость', meta: 'Энни Дьюк', note: 'Чемпионка по покеру учит отделять качество решения от результата — главный навык трейдера.'),
  'l4_7': (kind: MediaKind.book, title: 'Антихрупкость', meta: 'Нассим Талеб', note: 'Как извлекать выгоду из хаоса и редких катастроф — фундамент этого урока.'),
  'l5_2': (kind: MediaKind.film, title: 'Default / 국가부도의 날 (День национального банкротства)', meta: 'Южная Корея, 2018, реж. Чхве Кук Хи', note: 'Реальная история азиатского кризиса 1997 и прихода МВФ — как работает кредитор последней инстанции.'),
  'l5_4': (kind: MediaKind.doc, title: 'American Factory', meta: 'Netflix, 2019, Оскар', note: 'Китайский завод в США: столкновение двух экономических моделей вживую.'),
  'l6_1': (kind: MediaKind.book, title: 'Думай медленно… решай быстро', meta: 'Даниэль Канеман', note: 'Нобелевский лауреат о том, как две системы мышления управляют твоими решениями (и ошибками).'),
  'l6_2': (kind: MediaKind.film, title: 'Предел риска (Margin Call)', meta: '2011', note: 'Одна ночь в банке перед крахом — страх и жадность крупным планом.'),
  'l9_1': (kind: MediaKind.doc, title: 'How The Economic Machine Works', meta: 'Рэй Далио, 30 мин (YouTube)', note: 'Сам Далио за полчаса объясняет долговые циклы — обязательный просмотр к уроку.'),
  'l10_1': (kind: MediaKind.book, title: 'Великий крах 1929 года', meta: 'Джон Кеннет Гэлбрейт', note: 'Классика о том, как надувался и лопнул крупнейший пузырь истории.'),
  'l10_2': (kind: MediaKind.book, title: 'Алхимия финансов', meta: 'Джордж Сорос', note: 'Сам Сорос о теории рефлексивности — как восприятие формирует реальность рынка.'),
  'l10_3': (kind: MediaKind.film, title: 'Игра на понижение (The Big Short)', meta: '2015', note: 'Как горстка аутсайдеров поставила против ипотечной системы и выиграла. Есть и книга М. Льюиса.'),
  'l10_5': (kind: MediaKind.film, title: 'Уолл-стрит (Wall Street)', meta: '1987', note: '«Жадность — это хорошо»: анатомия эйфории и пузыря на все времена.'),
};

// Модуль мұқабасының эмодзиі.
const Map<String, String> moduleEmoji = {
  'm1': '⚙️',
  'm2': '📰',
  'm3': '🥇',
  'm4': '🎲',
  'm5': '🌍',
  'm6': '🧠',
  'm7': '📊',
  'm8': '🛡️',
  'm9': '🔄',
  'm10': '💥',
};

typedef LessonMeta = ({String emoji, String title, String hook, int minutes});

/// Сабақ id → (эмодзи, ілмекті тақырып, субтитр, минут).
const Map<String, LessonMeta> lessonMeta = {
  // ── Модуль 1 ──
  'l1_1': (emoji: '💸', title: 'Великий обман: почему деньги — это просто вера?', hook: 'Бумажка ничем не обеспечена. Почему мы всё ещё в неё верим?', minutes: 9),
  'l1_2': (emoji: '👑', title: 'Долларовая корона: почему США должны всем — и всё равно №1?', hook: '\$34 триллиона долга, а доллар сильнее всех. Как так?', minutes: 9),
  'l1_3': (emoji: '🏦', title: 'Кухня биржи: где крупный игрок прячет следы?', hook: 'Цена двигается не сама. Кто дёргает за ниточки?', minutes: 10),
  // ── Модуль 2 ──
  'l2_1': (emoji: '🔥', title: 'CPI: одна цифра, что роняет золото за 5 минут', hook: 'Почему весь рынок замирает перед выходом инфляции?', minutes: 10),
  'l2_2': (emoji: '💼', title: 'NFP: почему первая пятница — ловушка для новичков?', hook: 'Главный отчёт рынка труда выбивает стопы тысячам.', minutes: 10),
  'l2_3': (emoji: '🦅', title: 'В голове у ФРС: кто реально управляет рынками?', hook: 'Один человек словом двигает золото на сотни пунктов.', minutes: 11),
  // ── Модуль 3 ──
  'l3_1': (emoji: '🥇', title: 'Анти-доллар: деньги, которые нельзя напечатать', hook: '5000 лет золото хранит богатство. В чём секрет?', minutes: 9),
  'l3_2': (emoji: '🛢️', title: 'Чёрное золото против жёлтого: как нефть двигает цену?', hook: 'Дорогая нефть — и золото летит вверх. Почему?', minutes: 9),
  // ── Модуль 4 ──
  'l4_1': (emoji: '🎯', title: 'Как выигрывать, даже проигрывая?', hook: 'Хорошее решение и хороший результат — не одно и то же.', minutes: 10),
  'l4_2': (emoji: '⚖️', title: 'Секрет выживания: почему 90% побед могут разорить?', hook: 'Винрейт обманчив. Что реально решает судьбу депозита?', minutes: 10),
  'l4_3': (emoji: '🔄', title: 'Думай как Байес: почему упрямство убивает депозит?', hook: 'Рынок изменился, а ты держишься за старое. Это дорого.', minutes: 9),
  'l4_4': (emoji: '🧮', title: 'Формула Келли: сколько ставить, чтобы не обнулиться?', hook: 'Даже гениальная стратегия гибнет от размера ставки.', minutes: 10),
  'l4_5': (emoji: '📈', title: 'Восьмое чудо света: магия сложного процента', hook: 'Как \$1000 превращаются в состояние — без чудес.', minutes: 9),
  'l4_6': (emoji: '🎰', title: 'Ловушка казино: как стать казино, а не игроком?', hook: 'Перевес в 2.7% строит Лас-Вегас. Сделай его своим.', minutes: 9),
  'l4_7': (emoji: '🦢', title: 'Антихрупкость: как зарабатывать на хаосе?', hook: 'Что если кризис может сделать тебя богаче?', minutes: 10),
  'l4_8': (emoji: '🧭', title: 'Островки порядка: система правил против хаоса', hook: 'Будущее не угадать. Но можно перестать бояться.', minutes: 9),
  'l4_9': (emoji: '👴', title: 'Фреймворк Безоса: как решать, чтобы не жалеть?', hook: 'Один вопрос, что принимает за тебя лучшие решения.', minutes: 8),
  'l4_10': (emoji: '🎯', title: 'Сила фокуса: почему мастер бьёт универсала?', hook: '40 инструментов сразу — путь в никуда. Почему?', minutes: 8),
  'l4_11': (emoji: '⬛', title: 'Серый анализ, чёрно-белое действие', hook: 'Сомневайся до входа. После — ни одной мысли.', minutes: 8),
  // ── Модуль 5 ──
  'l5_1': (emoji: '🗽', title: 'США: как страна стала №1 в мире?', hook: 'Страна, которой нет и 250 лет — крупнейшая экономика в истории. Как?', minutes: 12),
  'l5_2': (emoji: '🗾', title: 'Япония: страна, восставшая из пепла', hook: 'Из руин — в чудо. А потом 30 лет застоя. Какой урок?', minutes: 12),
  'l5_3': (emoji: '🇸🇬', title: 'Сингапур: маленький остров — огромная сила', hook: 'Без ресурсов и воды стал богаче бывшей империи. Как?', minutes: 10),
  'l5_4': (emoji: '🐉', title: 'Китай: от нищеты до 2-й экономики мира', hook: '800 миллионов вышли из бедности за 40 лет. Какой ценой?', minutes: 15),
  'l5_5': (emoji: '🦾', title: 'Германия: мотор Европы', hook: 'Скрытые чемпионы, о которых ты не слышал, правят рынками.', minutes: 10),
  'l5_6': (emoji: '🇰🇿', title: 'Казахстан: наш путь и наш потенциал', hook: 'Ресурсы, транзит, молодость нации. Где наш шанс?', minutes: 12),
  // ── Модуль 6 ──
  'l6_1': (emoji: '🦎', title: 'Древний мозг против рынка: кто саботирует сделки?', hook: 'Твой мозг создан для саванны, а не для графиков.', minutes: 10),
  'l6_2': (emoji: '😱', title: 'Страх и жадность: два убийцы депозита', hook: 'Весь рынок — качели между двумя эмоциями.', minutes: 10),
  'l6_3': (emoji: '🔥', title: 'Тильт: как одна сделка сливает весь депозит?', hook: 'Месть рынку — самый дорогой эмоциональный сбой.', minutes: 9),
  'l6_4': (emoji: '🧩', title: 'Баги в прошивке мозга: искажения трейдера', hook: '5 ловушек мышления, на которых ты теряешь деньги.', minutes: 10),
  'l6_5': (emoji: '💪', title: 'Дисциплина как мышца: ритуалы профи', hook: 'Сила воли заканчивается. Что работает вместо неё?', minutes: 9),
  // ── Модуль 7 ──
  'l7_1': (emoji: '🏗️', title: 'Структура рынка: язык, на котором говорит цена', hook: 'Забудь индикаторы. Сначала читай саму цену.', minutes: 10),
  'l7_2': (emoji: '🎯', title: 'Охота за стопами: где лежит ликвидность?', hook: 'Твой стоп-лосс — это не защита, а мишень.', minutes: 11),
  'l7_3': (emoji: '📦', title: 'Отпечатки капитала: Order Blocks и имбалансы', hook: 'Крупный игрок оставляет следы. Научись их видеть.', minutes: 11),
  'l7_4': (emoji: '🕐', title: 'Время решает всё: сессии и киллзоны', hook: 'Торговать в 3 ночи — кормить брокера. Когда входить?', minutes: 9),
  'l7_5': (emoji: '📊', title: 'Объём не врёт: импульс или ловушка?', hook: 'Пробой без объёма — почти всегда обман.', minutes: 9),
  // ── Модуль 8 ──
  'l8_1': (emoji: '📉', title: 'Математика ямы: почему −50% требует +100%?', hook: 'Убытки и прибыль не симметричны. Это меняет всё.', minutes: 9),
  'l8_2': (emoji: '⚖️', title: 'Размер позиции: решение важнее точки входа', hook: 'Не стратегия убивает трейдера, а размер ставки.', minutes: 10),
  'l8_3': (emoji: '📓', title: 'Торговый журнал: твой детектор лжи', hook: 'Без журнала ты не трейдер, а игрок. Почему?', minutes: 9),
  'l8_4': (emoji: '🔬', title: 'Бэктест: как не обмануть самого себя?', hook: 'Идеальный бэктест часто = катастрофа в реале.', minutes: 10),
  'l8_5': (emoji: '✅', title: 'Торговый план: конституция трейдера', hook: 'Чек-лист, что спас авиацию — спасёт твой депозит.', minutes: 9),
  // ── Модуль 9 ──
  'l9_1': (emoji: '🌀', title: 'Машина Далио: как работают долговые циклы?', hook: 'Босс крупнейшего фонда объясняет экономику за 10 минут.', minutes: 12),
  'l9_2': (emoji: '⚔️', title: 'Валютные войны: почему резервные валюты умирают?', hook: 'Фунт правил 100 лет и пал. Что будет с долларом?', minutes: 10),
  'l9_3': (emoji: '🏦', title: 'Золото центробанков: тихая революция', hook: 'Кто скупает золото рекордными темпами — и зачем?', minutes: 10),
  'l9_4': (emoji: '🛢️', title: 'Реальное против бумаги: товарный суперцикл', hook: 'Где делаются состояния целого поколения?', minutes: 10),
  // ── Модуль 10 ──
  'l10_1': (emoji: '📉', title: '1929: как лопнул крупнейший пузырь истории?', hook: 'Плечо превратило коррекцию в апокалипсис.', minutes: 11),
  'l10_2': (emoji: '🦊', title: 'Сорос против Банка Англии: \$1 млрд за день', hook: 'Как один трейдер победил целое государство?', minutes: 10),
  'l10_3': (emoji: '🏠', title: '2008 и The Big Short: ставка против системы', hook: 'Горстка людей увидела крах раньше всех. И заработала.', minutes: 11),
  'l10_4': (emoji: '🦠', title: 'COVID-крах: самое быстрое падение в истории', hook: '−34% за 33 дня и мгновенный разворот. Что было?', minutes: 10),
  'l10_5': (emoji: '🫧', title: 'Анатомия пузыря: от тюльпанов до крипты', hook: 'Даже Ньютон разорился на пузыре. Как не повторить?', minutes: 11),
};

// Сабақ мәтінінің локализациясы (тек тақырып + ілмек; эмодзи/минут RU-дан).
typedef LessonText = ({String title, String hook});

const Map<String, LessonText> lessonTextKk = {
  'l1_1': (title: 'Үлкен алдау: ақша — неге жай ғана сенім?', hook: 'Қағаз ештеңемен қамтамасыз етілмеген. Неге біз әлі де сенеміз?'),
  'l1_2': (title: 'Доллар тәжі: АҚШ бәріне қарыз — бірақ №1 қалай?', hook: '\$34 трлн қарыз, ал доллар бәрінен күшті. Қалай?'),
  'l1_3': (title: 'Биржа асханасы: ірі ойыншы ізін қайда жасырады?', hook: 'Баға өздігінен қозғалмайды. Жіпті кім тартады?'),
  'l2_1': (title: 'CPI: алтынды 5 минутта түсіретін бір сан', hook: 'Инфляция шыққанша неге бүкіл нарық қатып қалады?'),
  'l2_2': (title: 'NFP: айдың бірінші жұмасы неге жаңадан бастаушыға тұзақ?', hook: 'Еңбек нарығының басты есебі мыңдаған стопты ұшырады.'),
  'l2_3': (title: 'ФРЖ басындағы ой: нарықты шын мәнінде кім басқарады?', hook: 'Бір адам сөзімен алтынды жүздеген пунктке қозғайды.'),
  'l3_1': (title: 'Анти-доллар: басып шығаруға келмейтін ақша', hook: '5000 жыл алтын байлықты сақтайды. Құпиясы неде?'),
  'l3_2': (title: 'Қара алтын мен сары алтын: мұнай бағаны қалай қозғайды?', hook: 'Мұнай қымбаттайды — алтын ұшады. Неге?'),
  'l4_1': (title: 'Ұтылып тұрып та қалай ұтуға болады?', hook: 'Жақсы шешім мен жақсы нәтиже — бір нәрсе емес.'),
  'l4_2': (title: 'Аман қалу сыры: неге 90% жеңіс банкротқа әкеледі?', hook: 'Винрейт алдамшы. Депозит тағдырын не шешеді?'),
  'l4_3': (title: 'Байес сияқты ойла: неге қыңырлық депозитті өлтіреді?', hook: 'Нарық өзгерді, ал сен ескі пікірге жабысасың. Бұл қымбат.'),
  'l4_4': (title: 'Келли формуласы: нөлге түспеу үшін қанша қою керек?', hook: 'Тамаша стратегия да қойылым мөлшерінен өледі.'),
  'l4_5': (title: 'Әлемнің сегізінші кереметі: күрделі пайыз сиқыры', hook: '\$1000 қалай байлыққа айналады — кереметсіз.'),
  'l4_6': (title: 'Казино тұзағы: ойыншы емес, казино қалай болуға болады?', hook: '2.7% артықшылық Лас-Вегасты салады. Оны өзіңдікі қыл.'),
  'l4_7': (title: 'Антисынғыштық: хаостан қалай пайда табуға болады?', hook: 'Дағдарыс сені байыта алса ше?'),
  'l4_8': (title: 'Тәртіп аралдары: хаосқа қарсы ережелер жүйесі', hook: 'Болашақты болжай алмайсың. Бірақ қорықпауды үйренуге болады.'),
  'l4_9': (title: 'Безос фреймворкі: өкінбеу үшін қалай шешу керек?', hook: 'Сенің ең дұрыс шешімдеріңді қабылдайтын бір сұрақ.'),
  'l4_10': (title: 'Фокус күші: неге маман әмбебапты жеңеді?', hook: '40 құралды қатар саудалау — еш жерге апармайды. Неге?'),
  'l4_11': (title: 'Сұр талдау, ақ-қара әрекет', hook: 'Кіргенге дейін күмәндан. Кейін — бірде-бір ой жоқ.'),
  'l5_1': (title: 'АҚШ: ел әлемде №1 қалай болды?', hook: '250 жасы жоқ ел — тарихтағы ең ірі экономика. Қалай?'),
  'l5_2': (title: 'Жапония: күлден қайта тірілген ел', hook: 'Қираудан — керемет. Сосын 30 жыл тоқырау. Қандай сабақ?'),
  'l5_3': (title: 'Сингапур: кішкентай арал — алып күш', hook: 'Ресурссыз, сусыз бұрынғы империядан бай болды. Қалай?'),
  'l5_4': (title: 'Қытай: кедейліктен әлемнің 2-ші экономикасына', hook: '800 миллион адам 40 жылда кедейліктен шықты. Қандай бағамен?'),
  'l5_5': (title: 'Германия: Еуропа моторы', hook: 'Сен естімеген жасырын чемпиондар нарықты билейді.'),
  'l5_6': (title: 'Қазақстан: біздің жол және әлеуетіміз', hook: 'Ресурс, транзит, ұлттың жастығы. Біздің мүмкіндік қайда?'),
  'l6_1': (title: 'Ежелгі ми нарыққа қарсы: сделкаларды кім бұзады?', hook: 'Сенің миың графикке емес, даланы өмір сүруге жаратылған.'),
  'l6_2': (title: 'Қорқыныш пен ашкөздік: депозиттің екі өлтірушісі', hook: 'Бүкіл нарық — екі эмоция арасындағы тербеліс.'),
  'l6_3': (title: 'Тильт: бір сделка бүкіл депозитті қалай құртады?', hook: 'Нарықтан кек алу — ең қымбат эмоциялық қателік.'),
  'l6_4': (title: 'Мидың прошивкасындағы қателер: трейдер бұрмалаулары', hook: 'Ақша жоғалтатын 5 ойлау тұзағы.'),
  'l6_5': (title: 'Тәртіп — бұлшықет: кәсіпқойлар рәсімдері', hook: 'Ерік-жігер таусылады. Оның орнына не жұмыс істейді?'),
  'l7_1': (title: 'Нарық құрылымы: баға сөйлейтін тіл', hook: 'Индикаторларды ұмыт. Алдымен бағаны оқуды үйрен.'),
  'l7_2': (title: 'Стоптарға аң аулау: өтімділік қайда жатыр?', hook: 'Сенің стоп-лоссың — қорғаныс емес, нысана.'),
  'l7_3': (title: 'Капитал іздері: Order Blocks және имбаланс', hook: 'Ірі ойыншы із қалдырады. Оны көруді үйрен.'),
  'l7_4': (title: 'Уақыт бәрін шешеді: сессиялар мен киллзоналар', hook: 'Түнгі 3-те саудалау — брокерді асырау. Қашан кіру керек?'),
  'l7_5': (title: 'Көлем өтірік айтпайды: импульс пе, тұзақ па?', hook: 'Көлемсіз пробив — әрдайым дерлік алдау.'),
  'l8_1': (title: 'Шұңқыр математикасы: неге −50% +100% талап етеді?', hook: 'Шығын мен пайда симметриялы емес. Бұл бәрін өзгертеді.'),
  'l8_2': (title: 'Позиция мөлшері: кіру нүктесінен маңыздырақ шешім', hook: 'Трейдерді стратегия емес, қойылым мөлшері өлтіреді.'),
  'l8_3': (title: 'Сауда журналы: сенің өтірік детекторың', hook: 'Журналсыз сен трейдер емес, ойыншысың. Неге?'),
  'l8_4': (title: 'Бэктест: өзіңді қалай алдамау керек?', hook: 'Мінсіз бэктест жиі = реалда апат.'),
  'l8_5': (title: 'Сауда жоспары: трейдер конституциясы', hook: 'Авиацияны құтқарған чек-лист депозитіңді де құтқарады.'),
  'l9_1': (title: 'Далио машинасы: қарыз циклдары қалай жұмыс істейді?', hook: 'Әлемдегі ең ірі қордың басшысы экономиканы 10 минутта түсіндіреді.'),
  'l9_2': (title: 'Валюталық соғыстар: неге резервтік валюталар өледі?', hook: 'Фунт 100 жыл билеп, құлады. Долларға не болады?'),
  'l9_3': (title: 'Орталық банктердің алтыны: тыныш революция', hook: 'Алтынды рекордты қарқынмен кім сатып алуда — не үшін?'),
  'l9_4': (title: 'Нақты қағазға қарсы: тауар суперциклі', hook: 'Бір ұрпақтың байлығы қайда жасалады?'),
  'l10_1': (title: '1929: тарихтағы ең ірі көпіршік қалай жарылды?', hook: 'Иық коррекцияны апокалипсиске айналдырды.'),
  'l10_2': (title: 'Сорос Англия Банкіне қарсы: бір күнде \$1 млрд', hook: 'Бір трейдер бүкіл мемлекетті қалай жеңді?'),
  'l10_3': (title: '2008 және The Big Short: жүйеге қарсы қойылым', hook: 'Бір топ адам апатты бәрінен бұрын көрді. Әрі тапты.'),
  'l10_4': (title: 'COVID-апаты: тарихтағы ең жылдам құлдырау', hook: '33 күнде −34% және лезде бетбұрыс. Не болды?'),
  'l10_5': (title: 'Көпіршік анатомиясы: қызғалдақтан криптоға дейін', hook: 'Ньютон да көпіршіктен банкрот болды. Қалай қайталамау керек?'),
};

const Map<String, LessonText> lessonTextEn = {
  'l1_1': (title: 'The great deception: why is money just belief?', hook: 'Paper is backed by nothing. Why do we still believe in it?'),
  'l1_2': (title: 'The dollar crown: the US owes everyone — yet still #1?', hook: '\$34 trillion in debt, yet the dollar reigns. How?'),
  'l1_3': (title: 'The exchange kitchen: where does the big player hide?', hook: 'Price does not move on its own. Who pulls the strings?'),
  'l2_1': (title: 'CPI: one number that drops gold in 5 minutes', hook: 'Why does the whole market freeze before inflation prints?'),
  'l2_2': (title: 'NFP: why the first Friday is a trap for beginners', hook: 'The key jobs report wipes out thousands of stops.'),
  'l2_3': (title: 'Inside the Fed: who really runs the markets?', hook: 'One person moves gold hundreds of points with a word.'),
  'l3_1': (title: 'The anti-dollar: money that cannot be printed', hook: 'For 5000 years gold has stored wealth. What is the secret?'),
  'l3_2': (title: 'Black gold vs yellow gold: how oil moves the price', hook: 'Oil gets pricey — and gold flies. Why?'),
  'l4_1': (title: 'How to win even while losing', hook: 'A good decision and a good outcome are not the same thing.'),
  'l4_2': (title: 'The survival secret: why 90% wins can ruin you', hook: 'Win rate is deceptive. What truly decides a deposit?'),
  'l4_3': (title: 'Think like Bayes: why stubbornness kills a deposit', hook: 'The market changed, but you cling to the old view. Costly.'),
  'l4_4': (title: 'The Kelly formula: how much to bet so you do not bust', hook: 'Even a brilliant strategy dies from bet sizing.'),
  'l4_5': (title: 'The eighth wonder: the magic of compound interest', hook: 'How \$1000 turns into a fortune — no miracles.'),
  'l4_6': (title: 'The casino trap: how to be the casino, not the player', hook: 'A 2.7% edge builds Las Vegas. Make it yours.'),
  'l4_7': (title: 'Antifragility: how to profit from chaos', hook: 'What if a crisis could make you richer?'),
  'l4_8': (title: 'Islands of order: a rule system against market chaos', hook: 'You cannot predict the future. But you can stop fearing it.'),
  'l4_9': (title: 'The Bezos framework: how to decide without regret', hook: 'One question that makes your best decisions for you.'),
  'l4_10': (title: 'The power of focus: why a master beats a generalist', hook: 'Trading 40 instruments at once leads nowhere. Why?'),
  'l4_11': (title: 'Grey analysis, black-and-white action', hook: 'Doubt before you enter. After — not a single thought.'),
  'l5_1': (title: 'USA: how did one country become #1 in the world?', hook: 'A country not even 250 years old — the largest economy in history. How?'),
  'l5_2': (title: 'Japan: the country that rose from the ashes', hook: 'From ruins to a miracle. Then 30 years of stagnation. The lesson?'),
  'l5_3': (title: 'Singapore: a tiny island — an enormous force', hook: 'With no resources or water it grew richer than its former empire. How?'),
  'l5_4': (title: 'China: from poverty to the #2 economy', hook: '800 million escaped poverty in 40 years. At what cost?'),
  'l5_5': (title: 'Germany: the engine of Europe', hook: 'Hidden champions you have never heard of rule their markets.'),
  'l5_6': (title: 'Kazakhstan: our path and our potential', hook: 'Resources, transit, a young nation. Where is our chance?'),
  'l6_1': (title: 'The ancient brain vs the market: who sabotages your trades?', hook: 'Your brain was built for the savanna, not for charts.'),
  'l6_2': (title: 'Fear and greed: the two killers of a deposit', hook: 'The whole market swings between two emotions.'),
  'l6_3': (title: 'Tilt: how one trade drains the whole deposit', hook: 'Revenge on the market is the costliest emotional glitch.'),
  'l6_4': (title: 'Bugs in your brain firmware: a trader\'s biases', hook: '5 thinking traps that make you lose money.'),
  'l6_5': (title: 'Discipline is a muscle: the rituals of pros', hook: 'Willpower runs out. What works instead?'),
  'l7_1': (title: 'Market structure: the language price speaks', hook: 'Forget indicators. First learn to read price itself.'),
  'l7_2': (title: 'Hunting stops: where does liquidity sit?', hook: 'Your stop-loss is not protection — it is a target.'),
  'l7_3': (title: 'Footprints of capital: Order Blocks and imbalances', hook: 'The big player leaves traces. Learn to see them.'),
  'l7_4': (title: 'Timing is everything: sessions and killzones', hook: 'Trading at 3 a.m. feeds the broker. So when do you enter?'),
  'l7_5': (title: 'Volume never lies: impulse or trap?', hook: 'A breakout without volume is almost always a fake.'),
  'l8_1': (title: 'The math of the pit: why −50% needs +100%', hook: 'Losses and gains are not symmetrical. That changes everything.'),
  'l8_2': (title: 'Position sizing: more important than the entry', hook: 'It is not strategy that kills a trader, but bet size.'),
  'l8_3': (title: 'The trading journal: your personal lie detector', hook: 'Without a journal you are a gambler, not a trader. Why?'),
  'l8_4': (title: 'Backtesting: how not to fool yourself', hook: 'A perfect backtest often means disaster in real life.'),
  'l8_5': (title: 'The trading plan: a trader\'s constitution', hook: 'The checklist that saved aviation will save your deposit.'),
  'l9_1': (title: 'Dalio\'s machine: how do debt cycles work?', hook: 'The head of the world\'s largest fund explains the economy in 10 minutes.'),
  'l9_2': (title: 'Currency wars: why do reserve currencies die?', hook: 'The pound ruled 100 years and fell. What about the dollar?'),
  'l9_3': (title: 'Central bank gold: the quiet revolution', hook: 'Who is buying gold at record pace — and why?'),
  'l9_4': (title: 'Real vs paper: the commodity supercycle', hook: 'Where are the fortunes of an entire generation made?'),
  'l10_1': (title: '1929: how did the largest bubble in history burst?', hook: 'Leverage turned a correction into an apocalypse.'),
  'l10_2': (title: 'Soros vs the Bank of England: \$1bn in a day', hook: 'How did one trader beat an entire state?'),
  'l10_3': (title: '2008 and The Big Short: betting against the system', hook: 'A handful saw the crash before everyone — and cashed in.'),
  'l10_4': (title: 'The COVID crash: the fastest fall in history', hook: '−34% in 33 days and an instant reversal. What happened?'),
  'l10_5': (title: 'Anatomy of a bubble: from tulips to crypto', hook: 'Even Newton went broke on a bubble. How to avoid it?'),
};

// Модуль тақырыбы + мақсаты локализациясы.
typedef ModuleText = ({String title, String goal});

const Map<String, ModuleText> moduleTextKk = {
  'm1': (title: 'Макроэкономикалық қозғалтқыш: жаһандық қаржы машинасы қалай құрылған', goal: 'Ақша мен қарыздың табиғатын және графиктер жаһандық деңгейде неге қозғалатынын түсіну.'),
  'm2': (title: 'Жаңалықтардың құпия коды: календарьді оқу және есептерді саудалау', goal: 'Календарьдегі қызыл жаңалықтардан қорықпай, қай сандар импульс беретінін және одан қалай пайда табуды түсіну.'),
  'm3': (title: 'XAUUSD ерекшелігі: алтын — капиталды сақтау құралы', goal: 'Алтын нарығының ішкі асханасын түсіну: металл неге өз заңдарымен өмір сүреді және оны жүйелі қалай саудалау керек.'),
  'm4': (title: 'Шешім шеберлері: ықтималдықпен ойлау (ойындар теориясы)', goal: 'Интуитивті ойыншыны салқынқанды математикке айналдыру. Тәуекелді басқару негізі — саудада да, өмірде де.'),
  'm5': (title: 'Экономикалық кереметтер анатомиясы: ТОП-5 экономика қалай көтеріліп құлады', goal: 'Нақты мысалдармен мемлекеттік шешімдер мен дағдарыстар планетадағы күштер балансын қалай өзгертетінін көрсету.'),
  'm6': (title: 'Трейдинг психологиясы: өз миыңмен соғыс', goal: 'Көп трейдер неге стратегиядан емес, психикадан ақша жоғалтатынын және миды бақылауға алуды түсіну.'),
  'm7': (title: 'Техникалық талдау және Smart Money: ірі капитал іздері', goal: 'Графикті сиқырлы сызықтар жиыны емес, ірі ойыншының ниет картасы ретінде оқуды үйрену.'),
  'm8': (title: 'Тәуекел-менеджмент және сауда жүйесі: аман қалу инженериясы', goal: 'Кездейсоқ сделкалар жиынын болжамды тәуекелі бар басқарылатын бизнеске айналдыру.'),
  'm9': (title: 'Үлкен циклдар және алтын геосаясаты', goal: 'Нарықты 100 жыл биіктігінен көру: қарыз суперциклдары, валюталық соғыстар және әлемдік тәртіп ауысуындағы алтын рөлі.'),
  'm10': (title: 'Дағдарыстар анатомиясы: байлық қанмен қалай жасалды', goal: 'Тарихтың ұлы дағдарыстарында көпшіліктің қорқынышы дайын азшылыққа қалай мүмкіндікке айналатынын көрсету.'),
};

const Map<String, ModuleText> moduleTextEn = {
  'm1': (title: 'The macro engine: how the global financial machine works', goal: 'Understand the nature of money and debt, and why charts move at the global level at all.'),
  'm2': (title: 'The secret code of news: reading the calendar and trading reports', goal: 'Stop fearing red news in the calendar and understand which numbers cause impulses and how to profit from them.'),
  'm3': (title: 'XAUUSD specifics: gold as a store of capital', goal: 'Understand the inner workings of the gold market: why the metal lives by its own laws and how to trade it systematically.'),
  'm4': (title: 'Masters of decisions: thinking in probabilities (game theory)', goal: 'Turn an intuitive gambler into a cold-blooded mathematician. The foundation of risk management — in trading and in life.'),
  'm5': (title: 'Anatomy of economic miracles: how the top-5 economies rose and fell', goal: 'Show with real examples how state decisions and crises shift the balance of power on the planet.'),
  'm6': (title: 'Trading psychology: the war with your own brain', goal: 'Understand why most traders lose money from psychology, not strategy, and how to take your brain under control.'),
  'm7': (title: 'Technical analysis and Smart Money: footprints of big capital', goal: 'Learn to read the chart as a map of the big player\'s intentions, not as a set of magic lines.'),
  'm8': (title: 'Risk management and the trading system: the engineering of survival', goal: 'Turn a set of random trades into a manageable business with predictable risk.'),
  'm9': (title: 'Big cycles and the geopolitics of gold', goal: 'See the market from 100 years up: debt supercycles, currency wars and gold\'s role in shifting the world order.'),
  'm10': (title: 'Anatomy of crises: how fortunes were made on blood', goal: 'Use history\'s great crises to show how the fear of the many becomes opportunity for the prepared few.'),
};

// Курс қабығы (атау/субтитр/сипаттама) локализациясы.
typedef CourseShell = ({String title, String subtitle, String description});

const CourseShell courseShellKk = (
  title: 'Белгісіздік қожайындары',
  subtitle: 'Жаңадан бастаушыны саналы трейдерге айналдыратын курс',
  description:
      'Басқалар графикке болжам жасап отырғанда, сен нарықтың НЕГЕ қозғалатынын түсінесің. '
      'Фундаменталды талдау, макроэкономика, психология, тәуекел-менеджмент және шешім '
      'математикасы — кәсіпқойды тобырдан ажырататынның бәрі. 10 модуль, интерактивті '
      'симуляторлар мен тесттері бар 49 сабақ. Депозитіңе өмір бойы жұмыс істейтін білім.',
);

const CourseShell courseShellEn = (
  title: 'Masters of Uncertainty',
  subtitle: 'The course that turns a beginner into a conscious trader',
  description:
      'While others guess at the chart, you will understand WHY the market moves. '
      'Fundamental analysis, macroeconomics, psychology, risk management and the math of '
      'decisions — everything that separates a pro from the crowd. 10 modules, 49 lessons '
      'with interactive simulators and tests. Knowledge that works for your deposit for life.',
);
