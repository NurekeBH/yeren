// Структурированный контент библиотеки (genre / основные идеи / заключение)
// для книг и фильмов. Локализация по коду языка: kk, ru, en.
// Подкасты сюда не входят (у них видео-плеер вместо разбора).

class LibContent {
  const LibContent({required this.genre, required this.ideas, required this.conclusion});

  /// Жанр: {kk, ru, en}.
  final Map<String, String> genre;

  /// Негізгі идеялар: {kk: [...], ru: [...], en: [...]}.
  final Map<String, List<String>> ideas;

  /// Қорытынды: {kk, ru, en}.
  final Map<String, String> conclusion;
}

/// id → структурированный разбор. Используется в [LibraryFixtures].
const Map<String, LibContent> kLibraryContent = {
  // ─────────────────────────── BOOKS b-001..b-020 ───────────────────────────
  'b-001': LibContent(
    genre: {'kk': "Трейдинг психологиясы", 'ru': "Психология трейдинга", 'en': "Trading Psychology"},
    ideas: {
      'kk': [
        "Нарық кездейсоқ нәтижелер тізбегін береді, сондықтан әр жеке мәміленің қорытындысын алдын ала білу мүмкін емес.",
        "Тұрақты табыс техникадан емес, сенімсіздікті қабылдайтын ұтқыр ой-сананы қалыптастырудан туады.",
        "Қателер мен зияндар бизнестің табиғи шығыны ретінде қабылданса, қорқыныш пен қателер де жойылады."
      ],
      'ru': [
        "Рынок выдаёт случайную последовательность исходов, поэтому результат любой отдельной сделки предсказать невозможно.",
        "Стабильная прибыль рождается не из техники, а из мышления, принимающего неопределённость как данность.",
        "Когда убытки воспринимаются как естественная издержка бизнеса, страх и торговые ошибки исчезают сами собой."
      ],
      'en': [
        "The market produces a random sequence of outcomes, so the result of any single trade is unpredictable.",
        "Consistent profit comes not from technique but from a mindset that fully accepts uncertainty.",
        "When losses are accepted as a natural cost of business, fear and trading errors disappear."
      ],
    },
    conclusion: {'kk': "Әр мәмілеге ықтималдық тұрғысынан қарап, нәтижеге емес, процеске берілгендік табысқа жеткізеді.", 'ru': "Относитесь к каждой сделке вероятностно и будьте преданы процессу, а не исходу — это путь к успеху.", 'en': "Treat each trade as a probability and commit to the process rather than the outcome to succeed."},
  ),
  'b-002': LibContent(
    genre: {'kk': "Трейдинг психологиясы", 'ru': "Психология трейдинга", 'en': "Trading Psychology"},
    ideas: {
      'kk': [
        "Трейдер табысқа жетпес бұрын өзін-өзі бақылау мен тәртіпке негізделген ішкі психологиялық құрылым жасауы керек.",
        "Нарық шектеу қоймайды, сондықтан ережелер мен шектеулерді трейдер өзіне өзі белгілеуге міндетті.",
        "Қорқыныш, ашкөздік және үміт сияқты сезімдер шынайылықты бұрмалап, дұрыс шешім қабылдауға кедергі жасайды."
      ],
      'ru': [
        "Прежде чем стать успешным, трейдер должен выстроить внутреннюю психологическую структуру самодисциплины и самоконтроля.",
        "Рынок не накладывает ограничений, поэтому правила и границы трейдер обязан устанавливать себе сам.",
        "Эмоции вроде страха, жадности и надежды искажают восприятие реальности и мешают принимать верные решения."
      ],
      'en': [
        "Before succeeding, a trader must build an inner psychological framework of self-discipline and self-control.",
        "The market imposes no limits, so the trader must set rules and boundaries for himself.",
        "Emotions like fear, greed and hope distort perception of reality and block sound decisions."
      ],
    },
    conclusion: {'kk': "Тәртіпті трейдер болу үшін алдымен өз ойлауыңды қайта бағдарлап, ережелерге бағынуды әдетке айналдыр.", 'ru': "Чтобы стать дисциплинированным трейдером, сначала перепрограммируйте мышление и сделайте следование правилам привычкой.", 'en': "To become a disciplined trader, first reprogram your thinking and make following your rules a habit."},
  ),
  'b-003': LibContent(
    genre: {'kk': "Трейдинг психологиясы", 'ru': "Психология трейдинга", 'en': "Trading Psychology"},
    ideas: {
      'kk': [
        "Трейдинг проблемалары көбіне терең психологиялық дағдарыс емес, өзгертуге болатын мінез-құлық үлгілерінен туады.",
        "Трейдер өзін бақылап, эмоциясын жазып отырса, өз ішіндегі түрлі «менді» танып, оларды басқара алады.",
        "Қысқа мерзімді шешімді терапия әдістері трейдингтегі деструктивті әдеттерді тез өзгертуге көмектеседі."
      ],
      'ru': [
        "Проблемы в трейдинге чаще рождаются из изменяемых поведенческих паттернов, а не из глубоких психологических травм.",
        "Наблюдая за собой и фиксируя эмоции, трейдер распознаёт свои внутренние «я» и учится ими управлять.",
        "Методы краткосрочной терапии решений помогают быстро менять деструктивные привычки в торговле."
      ],
      'en': [
        "Trading problems usually arise from changeable behavioral patterns rather than deep psychological traumas.",
        "By observing himself and logging emotions, a trader recognizes his inner selves and learns to manage them.",
        "Brief solution-focused therapy techniques help rapidly change destructive trading habits."
      ],
    },
    conclusion: {'kk': "Өзіңе зерттеуші ретінде қарап, эмоцияңды бақыла да, нарық емес, өз әрекетіңді өзгертуге кіріс.", 'ru': "Станьте исследователем самого себя, отслеживайте эмоции и меняйте собственное поведение, а не рынок.", 'en': "Become a researcher of yourself, track your emotions, and change your own behavior rather than the market."},
  ),
  'b-004': LibContent(
    genre: {'kk': "Трейдинг психологиясы", 'ru': "Психология трейдинга", 'en': "Trading Psychology"},
    ideas: {
      'kk': [
        "Трейдер өзінің жеке коучы бола алады, әр күнгі шағын қадамдар арқылы тұрақты түрде жетіле түседі.",
        "Кітаптағы 101 қысқа сабақ когнитивтік, мінез-құлықтық және психодинамикалық әдістерді практикалық жаттығуларға айналдырады.",
        "Күнделік жүргізу мен өз нәтижеңді талдау трейдерге өзінің ең жақсы үлгілерін қайталауға мүмкіндік береді."
      ],
      'ru': [
        "Трейдер может стать собственным коучем, совершенствуясь стабильно через маленькие ежедневные шаги.",
        "101 короткий урок книги превращают когнитивные, поведенческие и психодинамические методы в практические упражнения.",
        "Ведение дневника и анализ собственных результатов позволяют трейдеру воспроизводить свои лучшие паттерны."
      ],
      'en': [
        "A trader can become his own coach, improving steadily through small daily steps.",
        "The book's 101 brief lessons turn cognitive, behavioral and psychodynamic methods into practical exercises.",
        "Journaling and reviewing your own results let a trader reproduce his best patterns."
      ],
    },
    conclusion: {'kk': "Өзіңе күнделікті коуч бол: кішкене мақсаттар қой, нәтижеңді жазып отыр да, үздіксіз жетіл.", 'ru': "Станьте себе ежедневным коучем: ставьте малые цели, фиксируйте результаты и непрерывно совершенствуйтесь.", 'en': "Be your own daily coach: set small goals, log your results, and improve continuously."},
  ),
  'b-005': LibContent(
    genre: {'kk': "Мемуар", 'ru': "Мемуары", 'en': "Memoir"},
    ideas: {
      'kk': [
        "Адам табиғаты өзгермейтіндіктен, нарықтағы алып-сатарлық қателер мен эмоциялар ғасырлар бойы қайталанып отырады.",
        "Ірі пайда нақты сауда-саттықтан емес, дұрыс позицияны ұстап, шыдамды отырудан келеді деп Ливермор айтады.",
        "Нарықта «адасу» жоқ — баға бағытына қарсы тұрып, өз қателігіңді мойындамау ең қымбат қателік болып табылады."
      ],
      'ru': [
        "Поскольку человеческая природа неизменна, спекулятивные ошибки и эмоции на рынке повторяются веками.",
        "Большие деньги, говорит Ливермор, приносит не сама торговля, а умение удерживать верную позицию и сидеть терпеливо.",
        "На рынке нет места упрямству — идти против цены и не признавать ошибку обходится дороже всего."
      ],
      'en': [
        "Because human nature never changes, speculative mistakes and emotions repeat in markets across the centuries.",
        "Big money, Livermore says, comes not from trading but from holding the right position and sitting tight.",
        "There is no room for stubbornness — fighting the price and refusing to admit error is the costliest mistake."
      ],
    },
    conclusion: {'kk': "Зияныңды тез кес, ұтысты ұстап отыр да, жаппай нарық бағытына қарсы шықпа.", 'ru': "Быстро режьте убытки, удерживайте прибыль и никогда не идите против общего направления рынка.", 'en': "Cut losses quickly, let winners run, and never trade against the broad market trend."},
  ),
  'b-006': LibContent(
    genre: {'kk': "Сұхбаттар", 'ru': "Интервью", 'en': "Interviews"},
    ideas: {
      'kk': [
        "Әртүрлі стиль қолданса да, ең үздік трейдерлер тәуекелді қатаң басқару мен тәртіпте бір ауыздан келіседі.",
        "Жеңіске жетудің жалғыз дұрыс әдісі жоқ — әркім өз тұлғасына сай сауда жүйесін табуы керек.",
        "Жоғалтуды кішірейтіп, табысты өсіру — ұтыс пайызынан гөрі маңыздырақ деген ой бүкіл кітапты бойлайды."
      ],
      'ru': [
        "При всём различии стилей лучшие трейдеры единодушны в жёстком управлении риском и дисциплине.",
        "Единственно верного способа выигрывать нет — каждый должен найти систему, подходящую его личности.",
        "Минимизировать потери и наращивать прибыль важнее процента выигрышных сделок — эта мысль пронизывает всю книгу."
      ],
      'en': [
        "Despite differing styles, the best traders unanimously agree on strict risk management and discipline.",
        "There is no single right way to win — each must find a system suited to his personality.",
        "Minimizing losses and growing winners matters more than win rate — this idea runs through the whole book."
      ],
    },
    conclusion: {'kk': "Өз тұлғаңа сай жүйе тауып, тәуекелді қатаң басқар да, тәртіпті ұстануды ең басты заңға айналдыр.", 'ru': "Найдите систему под свою личность, жёстко управляйте риском и сделайте дисциплину главным законом.", 'en': "Find a system that fits your personality, manage risk strictly, and make discipline your highest law."},
  ),
  'b-007': LibContent(
    genre: {'kk': "Сұхбаттар", 'ru': "Интервью", 'en': "Interviews"},
    ideas: {
      'kk': [
        "Жаңа буын трейдерлер де табыстың кілті жүйеде емес, оны ұстанудағы психологиялық беріктікте екенін растайды.",
        "Күтілетін математикалық артықшылығы жоқ кез келген сауда жүйесі ұзақ мерзімде зиянға ұшырайды.",
        "Жақсы трейдер қателіктен қашпайды — ол тез мойындап, кішкене зиянмен шығып, капиталын сақтап қалады."
      ],
      'ru': [
        "Новое поколение трейдеров подтверждает: ключ к успеху не в системе, а в психологической стойкости её соблюдать.",
        "Любая торговая система без положительного математического ожидания в долгосроке ведёт к убыткам.",
        "Хороший трейдер не бежит от ошибки — он быстро признаёт её, выходит с малым убытком и сохраняет капитал."
      ],
      'en': [
        "A new generation of traders confirms the key to success lies not in a system but in the discipline to follow it.",
        "Any trading system without a positive mathematical expectancy leads to losses over the long run.",
        "A good trader does not flee from a mistake — he admits it fast, exits small, and preserves capital."
      ],
    },
    conclusion: {'kk': "Математикалық артықшылығы бар жүйені тауып, оны психологиялық тұрақтылықпен мүлтіксіз орында.", 'ru': "Найдите систему с положительным ожиданием и исполняйте её безупречно с психологической устойчивостью.", 'en': "Find a system with positive expectancy and execute it flawlessly with psychological steadiness."},
  ),
  'b-008': LibContent(
    genre: {'kk': "Трейдинг оқулығы", 'ru': "Учебник по трейдингу", 'en': "Trading Guide"},
    ideas: {
      'kk': [
        "Табысты трейдинг үш М-ге сүйенеді: Mind ой-сана, Method әдіс, Money капиталды басқару.",
        "Трейдер нарыққа тәуелді емес, жеке тәртіппен жұмыс істейтін кәсіби маман ретінде өзін ұстауы керек.",
        "Әр мәмілеге капиталдың 2 пайызынан аспайтын тәуекелді салу шотты толық апаттан сақтайды."
      ],
      'ru': [
        "Успешный трейдинг опирается на три М: Mind разум, Method метод и Money управление капиталом.",
        "Трейдер должен вести себя как профессионал, работающий по строгой дисциплине, а не зависящий от рынка.",
        "Риск не более 2 процентов капитала на сделку защищает счёт от полного разорения."
      ],
      'en': [
        "Successful trading rests on three M's: Mind, Method, and Money management.",
        "A trader must behave as a professional working by strict discipline, not as someone dependent on the market.",
        "Risking no more than 2 percent of capital per trade protects the account from total ruin."
      ],
    },
    conclusion: {'kk': "Ой-сана, әдіс және капиталды басқаруды теңестіріп, әр мәмілеге тәуекелді қатаң шектеп ұста.", 'ru': "Балансируйте разум, метод и управление капиталом, строго ограничивая риск на каждую сделку.", 'en': "Balance mind, method, and money management, strictly limiting your risk on every trade."},
  ),
  'b-009': LibContent(
    genre: {'kk': "Мінез-құлық экономикасы", 'ru': "Поведенческая экономика", 'en': "Behavioral Economics"},
    ideas: {
      'kk': [
        "Адамдар табысты дағдыға, ал сәтсіздікті бақытсыздыққа жатқызып, кездейсоқтықтың рөлін жүйелі түрде бағаламайды.",
        "Бір рет байыған трейдер шеберлік емес, көбіне жай ғана жолы болғыштықтың құрбаны болуы мүмкін.",
        "Сирек, бірақ апатты оқиғалар елеусіз қалады, өйткені біз тек көрінетін тарихты ғана есепке аламыз."
      ],
      'ru': [
        "Люди приписывают успех мастерству, а провал невезению, систематически недооценивая роль случайности.",
        "Разбогатевший однажды трейдер может быть жертвой не мастерства, а простого везения.",
        "Редкие, но катастрофические события игнорируются, ведь мы учитываем лишь видимую историю."
      ],
      'en': [
        "People credit success to skill and failure to bad luck, systematically underestimating the role of randomness.",
        "A trader who got rich once may be a victim of luck rather than skill.",
        "Rare but catastrophic events are ignored because we count only the visible, surviving history."
      ],
    },
    conclusion: {'kk': "Нәтижеге емес, шешімнің сапасына қарап, кездейсоқтық пен сирек тәуекелден өзіңді қорғап ұста.", 'ru': "Оценивайте качество решений, а не исход, и защищайте себя от случайности и редких рисков.", 'en': "Judge decision quality, not outcomes, and protect yourself against randomness and rare, hidden risks."},
  ),
  'b-010': LibContent(
    genre: {'kk': "Мінез-құлық экономикасы", 'ru': "Поведенческая экономика", 'en': "Behavioral Economics"},
    ideas: {
      'kk': [
        "Қара аққу — болжанбайтын, орасан әсерлі әрі болғаннан кейін ғана түсіндірілетін сирек оқиға.",
        "Қалыпты үлестірімге сүйенетін қаржы модельдері экстремалды оқиғаларды елемейді де, жаппай күйреуге апарады.",
        "Болашақты болжай алмаймыз, сондықтан осалдықты азайтып, күтпеген соққыға төзімді болуға күш салу керек."
      ],
      'ru': [
        "Чёрный лебедь — редкое событие, непредсказуемое, с огромными последствиями и объяснимое лишь задним числом.",
        "Финансовые модели на основе нормального распределения игнорируют экстремальные события и ведут к масштабным крахам.",
        "Будущее предсказать нельзя, поэтому нужно снижать уязвимость и быть устойчивым к неожиданным ударам."
      ],
      'en': [
        "A Black Swan is a rare event that is unpredictable, hugely impactful, and explained only in hindsight.",
        "Financial models based on the normal distribution ignore extreme events and lead to massive collapses.",
        "The future cannot be predicted, so reduce vulnerability and stay robust to unexpected shocks."
      ],
    },
    conclusion: {'kk': "Болжауға сенбе — портфеліңді сирек, бірақ апатты оқиғалардан қорғап, шектеулі зиянмен үлкен ұтысқа ашық бол.", 'ru': "Не полагайтесь на прогнозы — защитите портфель от редких катастроф и оставайтесь открыты большой асимметричной прибыли.", 'en': "Do not rely on forecasts — shield your portfolio from rare disasters while staying open to large asymmetric gains."},
  ),
  'b-011': LibContent(
    genre: {'kk': "Мінез-құлық экономикасы", 'ru': "Поведенческая экономика", 'en': "Behavioral Economics"},
    ideas: {
      'kk': [
        "Антихрупкость — сынғыштықтың қарама-қарсысы: кейбір жүйелер күйзеліс пен бей-берекеттіктен әлсіремей, керісінше күшейеді.",
        "Кіші зияндарға шектеулі ашықтық пен үлкен ұтысқа шексіз мүмкіндік беретін штанга стратегиясы тәуекелді тиімді етеді.",
        "Болжаудың орнына жүйені антихрупкий етіп құрсаң, белгісіздіктің өзі сенің пайдаңа жұмыс істей бастайды."
      ],
      'ru': [
        "Антихрупкость — противоположность хрупкости: некоторые системы не просто терпят хаос, а усиливаются от него.",
        "Стратегия штанги с ограниченным риском малых потерь и неограниченным потенциалом выигрыша делает риск выгодным.",
        "Вместо прогнозирования сделайте систему антихрупкой, и сама неопределённость начнёт работать на вас."
      ],
      'en': [
        "Antifragility is the opposite of fragility: some systems do not merely endure disorder but gain from it.",
        "A barbell strategy with capped small losses and unlimited upside makes risk work in your favor.",
        "Instead of forecasting, make your system antifragile so that uncertainty itself starts working for you."
      ],
    },
    conclusion: {'kk': "Штанга стратегиясын қолдан: зияныңды шектеп, шексіз ұтысқа ашық бол да, белгісіздіктен пайда тап.", 'ru': "Применяйте стратегию штанги: ограничьте убытки, оставайтесь открыты безграничной прибыли и выигрывайте от неопределённости.", 'en': "Use a barbell strategy: cap your losses, stay open to unlimited upside, and profit from uncertainty."},
  ),
  'b-012': LibContent(
    genre: {'kk': "Шешім қабылдау", 'ru': "Принятие решений", 'en': "Decision Making"},
    ideas: {
      'kk': [
        "Әр шешім — толық ақпарат жоқ жағдайдағы бәс, сондықтан оны жақсы немесе жаман нәтижемен теңестіруге болмайды.",
        "Нәтижеге қарап шешімді бағалау «resulting» қателігі дұрыс процесті бұрмалап, жалған сабақтар үйретеді.",
        "Ықтималдықпен ойлап, өз сенімдеріңді пайызбен өрнектеу белгісіздікте сапалы шешім қабылдауды жақсартады."
      ],
      'ru': [
        "Каждое решение — это ставка в условиях неполной информации, поэтому его нельзя приравнивать к исходу.",
        "Оценка решения по результату — ошибка «резалтинга», искажающая верный процесс и навязывающая ложные уроки.",
        "Мышление вероятностями и выражение убеждений в процентах улучшают качество решений в условиях неопределённости."
      ],
      'en': [
        "Every decision is a bet under incomplete information, so it must not be equated with its outcome.",
        "Judging a decision by its result is resulting — an error that distorts good process and teaches false lessons.",
        "Thinking in probabilities and expressing beliefs as percentages improves decision quality under uncertainty."
      ],
    },
    conclusion: {'kk': "Нәтижені емес, шешім процесінің сапасын бағала да, әр сауданы ықтималдық бәсі ретінде қара.", 'ru': "Оценивайте качество процесса принятия решений, а не исход, и относитесь к каждой сделке как к ставке.", 'en': "Judge the quality of your decision process, not the outcome, and treat each trade as a probabilistic bet."},
  ),
  'b-013': LibContent(
    genre: {'kk': "Когнитивтік психология", 'ru': "Когнитивная психология", 'en': "Cognitive Psychology"},
    ideas: {
      'kk': [
        "Ой-сана екі жүйеден тұрады: жылдам әрі интуитивті Жүйе 1 және баяу, ойланып еңбектенетін Жүйе 2.",
        "Адамдар зиянды теңдей пайдадан әлдеқайда ауыр сезінеді, бұл шешімдерде жүйелі асимметрия туғызады.",
        "Қол жетімділік пен бекіту сияқты когнитивтік бұрмалаулар интуитивті бағаны жүйелі түрде қателікке итермелейді."
      ],
      'ru': [
        "Мышление состоит из двух систем: быстрой интуитивной Системы 1 и медленной, рассудительной Системы 2.",
        "Люди ощущают потерю гораздо болезненнее равной по размеру прибыли, что создаёт системную асимметрию в решениях.",
        "Когнитивные искажения вроде доступности и якорения систематически уводят интуитивные оценки в ошибку."
      ],
      'en': [
        "The mind runs on two systems: the fast, intuitive System 1 and the slow, effortful System 2.",
        "People feel a loss far more painfully than an equal gain, creating a systematic asymmetry in decisions.",
        "Cognitive biases like availability and anchoring systematically push intuitive judgments into error."
      ],
    },
    conclusion: {'kk': "Жылдам интуицияңа күдікпен қарап, маңызды сауда шешімдерінде баяу да саналы ойлауды қос.", 'ru': "Не доверяйте слепо быстрой интуиции и подключайте медленное осознанное мышление в важных торговых решениях.", 'en': "Distrust your fast intuition and engage slow, deliberate thinking for important trading decisions."},
  ),
  'b-014': LibContent(
    genre: {'kk': "Сауда жүйелері", 'ru': "Торговые системы", 'en': "Trading Systems"},
    ideas: {
      'kk': [
        "Жүйенің табыстылығын ұтыс пайызы емес, оның күтілетін математикалық артықшылығы (expectancy) анықтайды.",
        "Позиция мөлшерін дұрыс есептеу — мақсатқа жетудің ең шешуші, бірақ ең көп еленбейтін бөлігі.",
        "Сіз нарықпен емес, нарық туралы өз сенімдеріңізбен сауда жасайсыз, сондықтан жүйе тұлғаңызға сай болуы керек."
      ],
      'ru': [
        "Прибыльность системы определяет не процент выигрышей, а её математическое ожидание (expectancy).",
        "Правильный расчёт размера позиции — самая решающая, но чаще всего недооценённая часть достижения цели.",
        "Вы торгуете не рынком, а своими убеждениями о нём, поэтому система должна подходить вашей личности."
      ],
      'en': [
        "A system's profitability is determined not by win rate but by its mathematical expectancy.",
        "Correct position sizing is the most decisive yet most overlooked part of reaching your objective.",
        "You trade not the market but your beliefs about it, so the system must fit your personality."
      ],
    },
    conclusion: {'kk': "Оң күтілетін артықшылығы бар жүйе құрып, позиция мөлшерлеуді мақсатыңа сай дұрыс есепте.", 'ru': "Постройте систему с положительным ожиданием и правильно рассчитывайте размер позиции под свою цель.", 'en': "Build a system with positive expectancy and size your positions correctly to reach your objective."},
  ),
  'b-015': LibContent(
    genre: {'kk': "Сауда стратегиясы", 'ru': "Торговая стратегия", 'en': "Trading Strategy"},
    ideas: {
      'kk': [
        "Тренд бойынша сауда болжамды емес, тек бағаны ұстана отырып, ірі әрі ұзақ қозғалыстардан пайда табады.",
        "Бұл стратегияда зияндар жиі, бірақ кішкентай, ал ұтыстар сирек, бірақ алып болады деген принцип жатыр.",
        "Эмоция мен болжамнан бас тартып, нақты ережелерге механикалық бағыну тренд-фолловерді табысқа жеткізеді."
      ],
      'ru': [
        "Торговля по тренду не прогнозирует, а лишь следует за ценой, извлекая прибыль из крупных длительных движений.",
        "В основе стратегии — принцип частых, но малых убытков и редких, но огромных выигрышей.",
        "Отказ от эмоций и прогнозов и механическое следование чётким правилам приводят трендфолловера к успеху."
      ],
      'en': [
        "Trend following does not predict but merely follows price, profiting from large, sustained moves.",
        "The strategy rests on frequent small losses and rare but enormous winners.",
        "Abandoning emotion and prediction and mechanically obeying clear rules brings the trend follower success."
      ],
    },
    conclusion: {'kk': "Болжаудан бас тарт: трендті механикалық түрде ұста, кіші зияндарға көн де, үлкен ұтыстарды соза бер.", 'ru': "Откажитесь от прогнозов: механически следуйте тренду, мирясь с малыми убытками и давая прибыли расти.", 'en': "Abandon prediction: follow the trend mechanically, accept small losses, and let your big winners run."},
  ),
  'b-016': LibContent(
    genre: {'kk': "Дейтрейдинг", 'ru': "Дейтрейдинг", 'en': "Day Trading"},
    ideas: {
      'kk': [
        "Дейтрейдер ең алдымен капиталды қорғауды, содан кейін ғана пайданы ойлап, әр мәмілеге қатаң стоп қоюы керек.",
        "Нақты енгізу мен шығу ережелері бар бірнеше тексерілген стратегияны меңгеру кездейсоқ саудадан әлдеқайда тиімді.",
        "Симулятордағы жаттығу мен шағын мөлшерден бастау жаңадан бастаған трейдерді ірі шығыннан сақтайды."
      ],
      'ru': [
        "Дейтрейдер прежде всего защищает капитал, и лишь затем думает о прибыли, ставя жёсткий стоп на каждую сделку.",
        "Освоение нескольких проверенных стратегий с чёткими правилами входа и выхода эффективнее хаотичной торговли.",
        "Практика на симуляторе и старт с малых объёмов уберегают новичка от крупных потерь."
      ],
      'en': [
        "A day trader protects capital first and profit second, placing a strict stop on every trade.",
        "Mastering a few proven strategies with clear entry and exit rules beats chaotic trading.",
        "Practicing on a simulator and starting with small size protect the beginner from large losses."
      ],
    },
    conclusion: {'kk': "Капиталды қорғауды бірінші қой, бірнеше нақты стратегияны меңгер де, әр мәмілеге қатаң стоп орнат.", 'ru': "Ставьте защиту капитала на первое место, освойте несколько чётких стратегий и ставьте жёсткий стоп на каждую сделку.", 'en': "Put capital protection first, master a few clear strategies, and set a strict stop on every trade."},
  ),
  'b-017': LibContent(
    genre: {'kk': "Әдеттер психологиясы", 'ru': "Психология привычек", 'en': "Habits Psychology"},
    ideas: {
      'kk': [
        "Ірі нәтиже кенеттен емес, күн сайынғы бір пайыздық кішкене жақсарулардың жинақталуынан туады.",
        "Әдет төрт заңнан тұрады: оны айқын, тартымды, оңай әрі қанағаттанарлық ету арқылы қалыптастыруға болады.",
        "Мақсатқа емес, жүйеге шоғырлан — сен мақсат деңгейіне емес, жүйелерің деңгейіне дейін құлдырайсың."
      ],
      'ru': [
        "Большой результат рождается не внезапно, а из накопления крошечных ежедневных улучшений на один процент.",
        "Привычка строится на четырёх законах: сделать её очевидной, привлекательной, лёгкой и приносящей удовлетворение.",
        "Сосредоточьтесь не на целях, а на системах — вы падаете не до уровня целей, а до уровня своих систем."
      ],
      'en': [
        "Big results come not suddenly but from compounding tiny one-percent improvements made every day.",
        "A habit is built on four laws: make it obvious, attractive, easy, and satisfying.",
        "Focus on systems rather than goals — you fall not to your goals but to the level of your systems."
      ],
    },
    conclusion: {'kk': "Тәртіпті процесті кішкене әдеттерге бөліп, оларды оңай әрі айқын етіп, күнделікті қайтала.", 'ru': "Разбейте дисциплинированный процесс на маленькие привычки, сделайте их лёгкими и очевидными и повторяйте ежедневно.", 'en': "Break a disciplined process into tiny habits, make them easy and obvious, and repeat them daily."},
  ),
  'b-018': LibContent(
    genre: {'kk': "Дейтрейдинг", 'ru': "Дейтрейдинг", 'en': "Day Trading"},
    ideas: {
      'kk': [
        "«Бір жақсы мәміле» — пайдасына емес, процестің мүлтіксіздігіне қарай бағаланатын дұрыс орындалған сауда.",
        "Кәсіби проп-трейдер табысқа табандылық, өзін-өзі бағалау және үздіксіз жұмыс арқылы жетеді деген ой алға тартылады.",
        "Нарықты оқу, тәуекелді басқару және қателіктен сабақ алу шеберлікке айналдыратын күнделікті дағдылар болып табылады."
      ],
      'ru': [
        "«Одна хорошая сделка» — это верно исполненная торговля, оцениваемая по безупречности процесса, а не по прибыли.",
        "Профессиональный проп-трейдер достигает успеха упорством, самооценкой и непрерывной работой над собой.",
        "Чтение рынка, управление риском и извлечение уроков из ошибок — ежедневные навыки, превращающиеся в мастерство."
      ],
      'en': [
        "One good trade is a correctly executed trade judged by the soundness of the process, not by its profit.",
        "A professional prop trader achieves success through persistence, self-review, and relentless work on himself.",
        "Reading the tape, managing risk, and learning from mistakes are daily skills that grow into mastery."
      ],
    },
    conclusion: {'kk': "Пайдаға емес, әр мәмілені дұрыс орындауға шоғырлан да, қателіктен үздіксіз сабақ алып, шеберлікке ұмтыл.", 'ru': "Сосредоточьтесь не на прибыли, а на верном исполнении каждой сделки, постоянно учась на ошибках и оттачивая мастерство.", 'en': "Focus not on profit but on executing each trade correctly, learning continuously from mistakes toward mastery."},
  ),
  'b-019': LibContent(
    genre: {'kk': "Техникалық талдау", 'ru': "Технический анализ", 'en': "Technical Analysis"},
    ideas: {
      'kk': [
        "Техникалық талдау барлық белгілі ақпарат бағада көрініс табады деген қағидаға негізделеді.",
        "Трендтер, қолдау мен қарсылық деңгейлері және графикалық фигуралар нарықтың болашақ қозғалысын болжауға көмектеседі.",
        "Көлем мен импульс индикаторлары баға қозғалысын растап, трендтің күші мен бұрылыс нүктелерін көрсетеді."
      ],
      'ru': [
        "Технический анализ строится на принципе, что вся известная информация уже отражена в цене.",
        "Тренды, уровни поддержки и сопротивления и графические фигуры помогают прогнозировать будущее движение рынка.",
        "Индикаторы объёма и импульса подтверждают движение цены, показывая силу тренда и точки разворота."
      ],
      'en': [
        "Technical analysis rests on the principle that all known information is already reflected in the price.",
        "Trends, support and resistance levels, and chart patterns help forecast the market's future movement.",
        "Volume and momentum indicators confirm price action, revealing the strength of a trend and turning points."
      ],
    },
    conclusion: {'kk': "Трендті, деңгейлерді және фигураларды көлеммен растай отырып оқып, нарыққа жүйелі техникалық тұрғыдан қара.", 'ru': "Читайте тренды, уровни и фигуры, подтверждая их объёмом, и подходите к рынку системно через технический анализ.", 'en': "Read trends, levels, and patterns confirmed by volume, and approach the market systematically through technical analysis."},
  ),
  'b-020': LibContent(
    genre: {'kk': "Техникалық талдау", 'ru': "Технический анализ", 'en': "Technical Analysis"},
    ideas: {
      'kk': [
        "Жапон шамдары әр кезеңнің ашылу, жабылу, жоғары және төмен бағасын көрсетіп, нарық эмоциясын айқын бейнелейді.",
        "Doji, hammer және engulfing сияқты шам үлгілері трендтің бұрылуы немесе жалғасуы туралы сигнал береді.",
        "Шам талдауын батыстық техникалық индикаторлармен ұштастыру сауда сигналдарының сенімділігін арттырады."
      ],
      'ru': [
        "Японские свечи показывают цену открытия, закрытия, максимум и минимум периода, ярко отражая эмоции рынка.",
        "Свечные модели вроде доджи, молота и поглощения сигнализируют о развороте или продолжении тренда.",
        "Сочетание свечного анализа с западными техническими индикаторами повышает надёжность торговых сигналов."
      ],
      'en': [
        "Japanese candlesticks show the open, close, high, and low of each period, vividly reflecting market emotion.",
        "Candle patterns like the doji, hammer, and engulfing signal a reversal or continuation of the trend.",
        "Combining candlestick analysis with Western technical indicators increases the reliability of trading signals."
      ],
    },
    conclusion: {'kk': "Шам үлгілерін бұрылыс сигналы ретінде оқып, оларды басқа индикаторлармен растап барып сауда шешімін қабылда.", 'ru': "Читайте свечные модели как сигналы разворота и подтверждайте их другими индикаторами перед принятием торгового решения.", 'en': "Read candle patterns as reversal signals and confirm them with other indicators before making a trading decision."},
  ),

  // ─────────────────────────── BOOKS b-021..b-040 ───────────────────────────
  'b-021': LibContent(
    genre: {'kk': "Құндылық инвестициясы", 'ru': "Стоимостное инвестирование", 'en': "Value Investing"},
    ideas: {
      'kk': [
        "Нарық — эмоцияға берілген мистер Маркет, оның бағаларын құлдыққа емес, мүмкіндік ретінде пайдалану керек.",
        "Қауіпсіздік маржасы — акцияны ішкі құнынан әлдеқайда арзан сатып алу инвестордың басты қорғаны.",
        "Инвестор мен спекулянтты ажырату керек: біріншісі іргелі талдауға, екіншісі баға қозғалысына сүйенеді.",
      ],
      'ru': [
        "Рынок — это эмоциональный мистер Маркет, чьи цены надо использовать как возможность, а не как руководство.",
        "Маржа безопасности, то есть покупка акций намного дешевле их внутренней стоимости, защищает инвестора от ошибок.",
        "Важно различать инвестора и спекулянта: первый опирается на фундаментал, второй — на движение цены.",
      ],
      'en': [
        "The market is an emotional Mr. Market whose prices should be exploited as opportunity, never obeyed as guidance.",
        "A margin of safety, buying stocks far below their intrinsic value, is the investor's core protection against error.",
        "Distinguish the investor from the speculator: the former relies on fundamentals, the latter on price movement.",
      ],
    },
    conclusion: {'kk': "Эмоцияны өшіріп, тек қауіпсіздік маржасы бар, нақты құнға негізделген мәмілелерге кіріңіз.", 'ru': "Отключите эмоции и входите только в сделки с реальной стоимостью и запасом прочности.", 'en': "Silence emotion and enter only trades grounded in real value with a built-in margin of safety."},
  ),
  'b-022': LibContent(
    genre: {'kk': "Трейдинг жүйесі", 'ru': "Торговые системы", 'en': "Trading Systems"},
    ideas: {
      'kk': [
        "Табысты трейдинг туа біткен дарын емес, нақты ережелермен үйретуге болатын жүйе екенін Тасбақалар дәлелдеді.",
        "Тренд бойынша жүру жүйесі ұтылыстарды кішкентай, ал жеңістерді ұзақ қалдыруға негізделген.",
        "Жүйенің пайдасынан гөрі трейдердің тәртібі мен оны дәл орындауы нәтижені шешеді.",
      ],
      'ru': [
        "Эксперимент «Черепах» доказал, что прибыльную торговлю можно воспитать чёткими правилами, а не врождённым талантом.",
        "Следование за трендом строится на коротких убытках и долгом удержании прибыльных позиций.",
        "Результат решает не сама система, а дисциплина трейдера и точность её исполнения.",
      ],
      'en': [
        "The Turtle experiment proved profitable trading can be taught through explicit rules rather than innate talent.",
        "Trend following works by cutting losses short and letting winning positions run for a long time.",
        "Not the system itself but the trader's discipline and precise execution decide the outcome.",
      ],
    },
    conclusion: {'kk': "Механикалық ережелер жиынтығын құрыңыз да, оны эмоциясыз, дәл орындауды үйреніңіз.", 'ru': "Создайте набор механических правил и научитесь исполнять их точно и без эмоций.", 'en': "Build a set of mechanical rules and learn to execute them precisely, without emotion."},
  ),
  'b-023': LibContent(
    genre: {'kk': "Инвестициялық философия", 'ru': "Инвестиционная философия", 'en': "Investment Philosophy"},
    ideas: {
      'kk': [
        "Ең маңыздысы — нарықтың қай циклінде тұрғаныңды сезіну және басқалардан өзгеше, тереңірек ойлау.",
        "Тәуекелді басқару дегеніміз — табысты қуу емес, ықтимал зиянды түсініп, оны бақылауда ұстау.",
        "Екінші деңгейлі ойлау тобырдан ерекшеленуді талап етеді, өйткені бәрі білетін нәрсе бағаға енген.",
      ],
      'ru': [
        "Самое важное — понимать, в какой точке цикла находится рынок, и мыслить глубже толпы.",
        "Управление риском — это не погоня за доходностью, а осознание и контроль возможных потерь.",
        "Мышление второго уровня требует отличаться от толпы, ведь общеизвестное уже заложено в цене.",
      ],
      'en': [
        "The most important thing is sensing where the market sits in its cycle and thinking deeper than the crowd.",
        "Managing risk means not chasing returns but understanding and controlling potential losses.",
        "Second-level thinking demands differing from the crowd, since what everyone knows is already in the price.",
      ],
    },
    conclusion: {'kk': "Тобырдан тереңірек ойлап, табыстан бұрын тәуекелді бағалауды әдетке айналдырыңыз.", 'ru': "Думайте глубже толпы и оценивайте риск раньше, чем потенциальную доходность.", 'en': "Think deeper than the crowd and assess risk before you ever assess potential reward."},
  ),
  'b-024': LibContent(
    genre: {'kk': "Қаржы журналистикасы", 'ru': "Финансовая журналистика", 'en': "Financial Journalism"},
    ideas: {
      'kk': [
        "LTCM-нің құлауы ең дарынды математиктер мен Нобель лауреаттарының да нарықты бағындыра алмайтынын көрсетті.",
        "Шектен тыс левередж кішкентай қателікті де апатты дәрежеге дейін үлкейтіп жібереді.",
        "Тарихи модельдер «мүмкін емес» деген оқиғалар нарықта ойлағаннан жиі болатынын ескермейді.",
      ],
      'ru': [
        "Крах LTCM показал, что даже гениальные математики и нобелевские лауреаты не могут подчинить рынок.",
        "Чрезмерное кредитное плечо превращает даже мелкую ошибку в катастрофу.",
        "Исторические модели игнорируют, что «невозможные» события случаются на рынке гораздо чаще, чем кажется.",
      ],
      'en': [
        "LTCM's collapse showed that even brilliant mathematicians and Nobel laureates cannot tame the market.",
        "Excessive leverage magnifies even a small error into a catastrophe.",
        "Historical models ignore that supposedly impossible events occur in markets far more often than assumed.",
      ],
    },
    conclusion: {'kk': "Левереджді шектеп, ешбір модель сирек апаттардан толық қорғамайтынын ұмытпаңыз.", 'ru': "Ограничивайте плечо и помните, что никакая модель не защищает от редких катастроф.", 'en': "Limit leverage and remember that no model fully protects you from rare catastrophes."},
  ),
  'b-025': LibContent(
    genre: {'kk': "Қаржылық мемуар", 'ru': "Финансовые мемуары", 'en': "Financial Memoir"},
    ideas: {
      'kk': [
        "1980-жылдардағы Уолл-стрит облигация сатушыларының ашкөздігі мен мәдениетін автор іштен көрсетеді.",
        "Клиенттердің мүддесінен гөрі комиссия мен бонусқа құрылған жүйенің табиғаты ашып салынады.",
        "Қаржы әлеміндегі табыс көбіне білімнен емес, батылдық пен блефтен туындайтыны суреттеледі.",
      ],
      'ru': [
        "Автор изнутри показывает жадность и культуру продавцов облигаций Уолл-стрит 1980-х годов.",
        "Раскрывается природа системы, построенной на комиссиях и бонусах, а не на интересах клиентов.",
        "Показано, что успех в финансах часто рождается не из знаний, а из смелости и блефа.",
      ],
      'en': [
        "The author exposes from within the greed and culture of 1980s Wall Street bond salesmen.",
        "It reveals a system built on commissions and bonuses rather than clients' interests.",
        "Success in finance, it shows, often springs not from knowledge but from nerve and bluff.",
      ],
    },
    conclusion: {'kk': "Сізге кеңес беретін брокердің мотиві сіздің пайдаңыз емес, өз комиссиясы болуы мүмкін екенін ескеріңіз.", 'ru': "Помните, что мотив советующего вам брокера — его комиссия, а не ваша прибыль.", 'en': "Remember that the broker advising you may be driven by his commission, not your profit."},
  ),
  'b-026': LibContent(
    genre: {'kk': "Қаржы журналистикасы", 'ru': "Финансовая журналистика", 'en': "Financial Journalism"},
    ideas: {
      'kk': [
        "Бірнеше аутсайдер ипотекалық нарықтың ішкі шіріктігін көріп, оған қарсы ставка жасап байыды.",
        "2008 дағдарысы тұтас жүйенің тәуекелді түсінбеуінен әрі рейтинг агенттіктерінің сатылуынан туды.",
        "Күрделі қаржы құралдары шынайы тәуекелді жасырып, оны қарапайым адамдарға аударып жіберді.",
      ],
      'ru': [
        "Несколько аутсайдеров разглядели гниль ипотечного рынка и заработали, поставив против него.",
        "Кризис 2008 года вырос из непонимания риска всей системой и продажности рейтинговых агентств.",
        "Сложные финансовые инструменты скрывали реальный риск и перекладывали его на обычных людей.",
      ],
      'en': [
        "A few outsiders saw the rot inside the mortgage market and grew rich betting against it.",
        "The 2008 crisis grew from the whole system misunderstanding risk and from corrupt rating agencies.",
        "Complex financial instruments hid the real risk and shifted it onto ordinary people.",
      ],
    },
    conclusion: {'kk': "Көпшілік сенген нәрсеге күмәнмен қарап, түсінбейтін күрделі құралдардан аулақ болыңыз.", 'ru': "Сомневайтесь в том, во что верит толпа, и избегайте сложных инструментов, которых не понимаете.", 'en': "Doubt what the crowd believes and avoid complex instruments you do not truly understand."},
  ),
  'b-027': LibContent(
    genre: {'kk': "Қаржы журналистикасы", 'ru': "Финансовая журналистика", 'en': "Financial Journalism"},
    ideas: {
      'kk': [
        "Жоғары жиілікті трейдерлер миллисекундтық артықшылықпен қарапайым инвесторлардың алдынан баға жеп отырады.",
        "Қор биржалары жылдамдықты сатып, ашықтық пен әділдіктің орнына жасырын артықшылықтар құрды.",
        "Бір топ адам IEX биржасын құрып, нарықты алаяқтыққа қарсы әділ ету жолын көрсетті.",
      ],
      'ru': [
        "Высокочастотные трейдеры с преимуществом в миллисекунды опережают обычных инвесторов и снимают с них прибыль.",
        "Биржи торговали скоростью, создавая скрытые привилегии вместо прозрачности и справедливости.",
        "Группа людей создала биржу IEX, показав путь к честному рынку против манипуляций.",
      ],
      'en': [
        "High-frequency traders use a millisecond edge to front-run ordinary investors and skim their profits.",
        "Exchanges sold speed, creating hidden privileges instead of transparency and fairness.",
        "A small group built the IEX exchange, showing a path to a fair market against manipulation.",
      ],
    },
    conclusion: {'kk': "Ультра-қысқа мерзімде жылдамдыққа ие жүйелермен жарыспай, ұзақ мерзімді көзқарасты ұстаныңыз.", 'ru': "Не соревнуйтесь по скорости с HFT-системами, а придерживайтесь долгосрочного подхода.", 'en': "Do not race HFT systems on speed; hold to a longer-term approach where their edge fades."},
  ),
  'b-028': LibContent(
    genre: {'kk': "Құндылық инвестициясы", 'ru': "Стоимостное инвестирование", 'en': "Value Investing"},
    ideas: {
      'kk': [
        "Қарапайым инвестор кәсіби қорлардан бұрын тауарды күнделікті өмірден байқап, артықшылыққа ие бола алады.",
        "Не сатып алғаныңды біл: бизнесін түсінбейтін компанияға ақша салмау керек.",
        "Лынч компанияларды өсу қарқыны мен оқиғасына қарай түрлі санаттарға бөліп талдауды ұсынады.",
      ],
      'ru': [
        "Обычный инвестор может опередить профессионалов, замечая хорошие компании в повседневной жизни.",
        "Знай, что покупаешь: не вкладывай деньги в компанию, чей бизнес тебе непонятен.",
        "Линч предлагает делить компании на категории по темпу роста и их истории.",
      ],
      'en': [
        "An ordinary investor can beat professionals by spotting great companies in everyday life first.",
        "Know what you own: never invest in a company whose business you do not understand.",
        "Lynch sorts companies into categories by their growth rate and underlying story.",
      ],
    },
    conclusion: {'kk': "Өзіңіз түсінетін, күнделікті көріп жүрген бизнестерге назар салып, әрқайсысының оқиғасын зерттеңіз.", 'ru': "Сосредоточьтесь на понятных вам бизнесах из повседневной жизни и изучайте историю каждого.", 'en': "Focus on businesses you understand from everyday life and study the story behind each one."},
  ),
  'b-029': LibContent(
    genre: {'kk': "Инвестициялық теория", 'ru': "Инвестиционная теория", 'en': "Investment Theory"},
    ideas: {
      'kk': [
        "Бағалар кездейсоқ серуендейді, сондықтан өткен қозғалыстан болашақты дәл болжау мүмкін емес.",
        "Белсенді басқарушылардың көбі ұзақ мерзімде кең нарық индексінен асып түсе алмайды.",
        "Арзан индекс қорына салынған пассивті инвестиция орташа инвестор үшін ең тиімді стратегия.",
      ],
      'ru': [
        "Цены движутся случайным блужданием, поэтому будущее нельзя точно предсказать по прошлым движениям.",
        "Большинство активных управляющих в долгосроке не способны обыграть широкий рыночный индекс.",
        "Пассивные вложения в дешёвый индексный фонд — лучшая стратегия для среднего инвестора.",
      ],
      'en': [
        "Prices follow a random walk, so the future cannot be reliably predicted from past movements.",
        "Most active managers fail to beat the broad market index over the long run.",
        "Passive investment in a cheap index fund is the best strategy for the average investor.",
      ],
    },
    conclusion: {'kk': "Нарықты ұту әрекетінен бас тартып, арзан индекс қорына ұзақ мерзімге салым салыңыз.", 'ru': "Откажитесь от попыток обыграть рынок и вкладывайте надолго в дешёвый индексный фонд.", 'en': "Stop trying to beat the market and invest long-term in a cheap, broad index fund."},
  ),
  'b-030': LibContent(
    genre: {'kk': "Индекстік инвестиция", 'ru': "Индексное инвестирование", 'en': "Index Investing"},
    ideas: {
      'kk': [
        "Бүкіл нарықты ұстайтын индекс қоры комиссияны азайтып, инвесторға ұзақ мерзімде ең үлкен үлесті береді.",
        "Комиссиялар мен айналым шығындары инвестордың табысын үнсіз, бірақ үздіксіз жеп отырады.",
        "Нарықты ұтуға тырысу — нөлдік қосынды ойын, оны жалпы шығындар минусқа айналдырады.",
      ],
      'ru': [
        "Индексный фонд на весь рынок снижает издержки и отдаёт инвестору наибольшую долю прибыли в долгосроке.",
        "Комиссии и торговые издержки тихо, но непрерывно съедают доходность инвестора.",
        "Попытки обыграть рынок — игра с нулевой суммой, которую издержки делают убыточной.",
      ],
      'en': [
        "A total-market index fund cuts costs and hands the investor the largest share of long-term returns.",
        "Fees and trading costs quietly but relentlessly erode an investor's returns.",
        "Trying to beat the market is a zero-sum game that costs turn into a loss.",
      ],
    },
    conclusion: {'kk': "Шығынды барынша азайтып, бүкіл нарықты ұстайтын индекс қорын сатып алып, ұзақ уақыт ұстаңыз.", 'ru': "Минимизируйте издержки, купите индексный фонд на весь рынок и держите его долго.", 'en': "Minimize costs, buy a total-market index fund, and simply hold it for the long term."},
  ),
  'b-031': LibContent(
    genre: {'kk': "Трейдинг психологиясы", 'ru': "Психология трейдинга", 'en': "Trading Psychology"},
    ideas: {
      'kk': [
        "Психологиялық қателіктер кездейсоқ емес, олардың нақты үлгілері бар әрі оны жүйелі түрде емдеуге болады.",
        "Қорқыныш, ашкөздік пен ашу-ыза — әрқайсысы өз тамырынан туатын бөлек проблемалар, оларды бөлек шешу керек.",
        "Эмоция — жау емес, ол сіздің ойлауыңыздағы терең олқылықты көрсететін сигнал.",
      ],
      'ru': [
        "Психологические ошибки не случайны: у них есть закономерности, и их можно системно устранять.",
        "Страх, жадность и гнев — отдельные проблемы со своими корнями, и решать их надо по отдельности.",
        "Эмоция — не враг, а сигнал о глубоком изъяне в вашем мышлении.",
      ],
      'en': [
        "Psychological mistakes are not random; they follow patterns and can be fixed systematically.",
        "Fear, greed, and anger are distinct problems with their own roots and must be solved separately.",
        "Emotion is not the enemy but a signal pointing to a deeper flaw in your thinking.",
      ],
    },
    conclusion: {'kk': "Эмоцияңызды басу емес, оны түбірлік себебін тауып, жүйелі түрде жоюды мақсат етіңіз.", 'ru': "Не подавляйте эмоции, а находите их первопричину и устраняйте её системно.", 'en': "Do not suppress emotions; find their root cause and resolve it systematically."},
  ),
  'b-032': LibContent(
    genre: {'kk': "Трейдинг психологиясы", 'ru': "Психология трейдинга", 'en': "Trading Psychology"},
    ideas: {
      'kk': [
        "Жеңіске жету үшін көпшілікке қарсы, табиғи инстинктіңізге қайшы ойлап, ұтылуды дұрыс қабылдау керек.",
        "Кәсіби трейдер ұтылыстан қашпайды, оны бизнестің қалыпты шығыны ретінде сабырмен қабылдайды.",
        "Адамның миы трейдингке бейімделмеген, сондықтан табыс эмоцияны басқарудан басталады.",
      ],
      'ru': [
        "Чтобы побеждать, нужно идти против толпы и инстинктов и правильно принимать проигрыши.",
        "Профессионал не бежит от убытков, а спокойно принимает их как нормальные издержки бизнеса.",
        "Мозг человека не приспособлен к трейдингу, поэтому успех начинается с управления эмоциями.",
      ],
      'en': [
        "To win you must go against the crowd and instinct and learn to accept losing well.",
        "A professional does not flee losses but calmly accepts them as a normal cost of business.",
        "The human brain is not built for trading, so success begins with mastering emotion.",
      ],
    },
    conclusion: {'kk': "Ұтылудан қорықпай, оны кәсіптің бөлігі ретінде сабырмен қабылдауды үйренсеңіз, нағыз жеңіске жетесіз.", 'ru': "Научитесь спокойно принимать убытки как часть профессии — и вы начнёте по-настоящему выигрывать.", 'en': "Learn to accept losses calmly as part of the craft, and you will truly start to win."},
  ),
  'b-033': LibContent(
    genre: {'kk': "Қаржы теориясы", 'ru': "Финансовая теория", 'en': "Financial Theory"},
    ideas: {
      'kk': [
        "Рефлексивтілік: инвесторлардың сенімі бағаны, ал баға өз кезегінде инвесторлардың сенімін өзгертіп отырады.",
        "Нарық ешқашан тепе-теңдікте болмайды, өйткені қатысушылардың түсінігі шындықты бұрмалап тұрады.",
        "Көпіршіктер мен апаттар осы өзара кері байланыс циклінен туындайды, оны ерте тану пайда береді.",
      ],
      'ru': [
        "Рефлексивность: убеждения инвесторов влияют на цены, а цены в свою очередь меняют убеждения.",
        "Рынок никогда не находится в равновесии, ведь восприятие участников искажает реальность.",
        "Пузыри и крахи рождаются из этой петли обратной связи, и раннее её распознавание приносит прибыль.",
      ],
      'en': [
        "Reflexivity: investors' beliefs move prices, and prices in turn reshape investors' beliefs.",
        "Markets are never in equilibrium because participants' perceptions distort the reality they observe.",
        "Bubbles and crashes arise from this feedback loop, and recognizing it early brings profit.",
      ],
    },
    conclusion: {'kk': "Баға мен сенімнің өзара әсерін бақылап, көпіршік циклін ерте танып, соған сай әрекет етіңіз.", 'ru': "Следите за взаимовлиянием цен и убеждений, распознавайте цикл пузыря рано и действуйте сообразно.", 'en': "Track how prices and beliefs feed each other, spot the bubble cycle early, and act accordingly."},
  ),
  'b-034': LibContent(
    genre: {'kk': "Құндылық инвестициясы", 'ru': "Стоимостное инвестирование", 'en': "Value Investing"},
    ideas: {
      'kk': [
        "Капиталды сақтау бірінші орында: жоғары табыстан бұрын зиян шекпеуді ойлау керек.",
        "Қауіпсіздік маржасы — болжамдағы қателіктерден қорғайтын, арзан бағамен сатып алудан туатын қор.",
        "Нарық тиімсіз болған сәттерде, басқалар қорыққанда сатып алу ең үлкен мүмкіндік береді.",
      ],
      'ru': [
        "Сохранение капитала превыше всего: думать о том, как не потерять, важнее, чем о доходности.",
        "Маржа безопасности — запас от ошибок прогноза, который даёт покупка по заниженной цене.",
        "Лучшие возможности возникают в моменты неэффективности рынка, когда другие охвачены страхом.",
      ],
      'en': [
        "Preserving capital comes first: avoiding loss matters more than chasing high returns.",
        "A margin of safety is a buffer against forecasting error, created by buying at a discount.",
        "The best opportunities arise in moments of market inefficiency, when others are gripped by fear.",
      ],
    },
    conclusion: {'kk': "Алдымен капиталды қорғаңыз да, басқалар қорыққан сәтте, нақты маржамен ғана сатып алыңыз.", 'ru': "Сначала защитите капитал и покупайте лишь с реальным запасом, когда другие в страхе.", 'en': "Protect capital first, and buy only with a real margin of safety when others are fearful."},
  ),
  'b-035': LibContent(
    genre: {'kk': "Өсу инвестициясы", 'ru': "Инвестирование в рост", 'en': "Growth Investing"},
    ideas: {
      'kk': [
        "Ең жақсы акциялар — басшылығы мықты, зерттеуге салынатын, ұзақ өсуге қабілетті ерекше компаниялар.",
        "Скаттлбатт әдісі: компанияны бәсекелестерінен, клиенттерінен және жеткізушілерінен сұрап тереңірек тану.",
        "Шынында тамаша компанияны сатудың дұрыс уақыты — ешқашан, тек негізгі болжам бұзылмаса.",
      ],
      'ru': [
        "Лучшие акции — это исключительные компании с сильным менеджментом, вложениями в исследования и потенциалом долгого роста.",
        "Метод «скаттлбатт»: глубже узнавать компанию, расспрашивая её конкурентов, клиентов и поставщиков.",
        "Правильное время продать по-настоящему великую компанию — почти никогда, если тезис не сломан.",
      ],
      'en': [
        "The best stocks are exceptional companies with strong management, R&D investment, and long runways for growth.",
        "The scuttlebutt method: learn a company deeply by questioning its competitors, customers, and suppliers.",
        "The right time to sell a truly great company is almost never, unless the core thesis breaks.",
      ],
    },
    conclusion: {'kk': "Терең зерттеп тапқан, шынайы өсу әлеуеті бар сапалы компанияны табыңыз да, оны ұзақ ұстаңыз.", 'ru': "Найдите через глубокое исследование качественную растущую компанию и держите её очень долго.", 'en': "Find a quality growth company through deep research and hold it for the very long term."},
  ),
  'b-036': LibContent(
    genre: {'kk': "Инвестициялық даналық", 'ru': "Инвестиционная мудрость", 'en': "Investment Wisdom"},
    ideas: {
      'kk': [
        "Акция — қағаз емес, нақты бизнестің бөлігі, сондықтан компанияны иеленуші ретінде ойлау керек.",
        "Өзіңнің құзырет шеңберіңде қал: түсінетін бизнеске ғана ақша сал.",
        "Нарықтың тербелісі инвестордың қызметшісі болуы тиіс, оның қожайыны емес.",
      ],
      'ru': [
        "Акция — не бумага, а доля в реальном бизнесе, поэтому думать надо как владелец компании.",
        "Оставайся в круге своей компетенции: вкладывай только в понятный тебе бизнес.",
        "Колебания рынка должны быть слугой инвестора, а не его хозяином.",
      ],
      'en': [
        "A stock is not paper but a piece of a real business, so think like an owner.",
        "Stay within your circle of competence: invest only in businesses you understand.",
        "Market fluctuations should be the investor's servant, never his master.",
      ],
    },
    conclusion: {'kk': "Акцияны бизнес ретінде көріп, өз құзырет шеңберіңде қалып, нарық көңіл-күйін қызметшіңіз етіңіз.", 'ru': "Смотрите на акцию как на бизнес, оставайтесь в круге компетенции и используйте настроение рынка.", 'en': "See a stock as a business, stay within your competence, and make market mood serve you."},
  ),
  'b-037': LibContent(
    genre: {'kk': "Трейдинг стратегиялары", 'ru': "Торговые стратегии", 'en': "Trading Strategies"},
    ideas: {
      'kk': [
        "Табысты трейдер нақты сетаптарды, кіру мен шығу ережелерін жүйеге айналдырып, оны қайталап қолданады.",
        "Тәуекелді басқару — позиция көлемін есептеу мен стоп-лоссты дұрыс қою сауданың өзегі.",
        "Трейдингтің психологиялық жағы техникалық дағдыдан кем емес, тіпті маңыздырақ.",
      ],
      'ru': [
        "Успешный трейдер превращает конкретные сетапы и правила входа-выхода в повторяемую систему.",
        "Управление риском — расчёт размера позиции и грамотный стоп-лосс — это сердце торговли.",
        "Психологическая сторона трейдинга не менее, а часто и более важна, чем техническая.",
      ],
      'en': [
        "A successful trader turns specific setups and entry-exit rules into a repeatable system.",
        "Risk management, position sizing and well-placed stops, is the heart of trading.",
        "The psychological side of trading is no less, and often more, important than the technical.",
      ],
    },
    conclusion: {'kk': "Нақты сетаптарды позиция көлемі мен стоп-лосс ережелерімен біріктіріп, оны тәртіппен қайталаңыз.", 'ru': "Объедините конкретные сетапы с правилами размера позиции и стоп-лосса и дисциплинированно повторяйте.", 'en': "Combine specific setups with position-sizing and stop rules, then repeat them with discipline."},
  ),
  'b-038': LibContent(
    genre: {'kk': "Трейдинг оқулығы", 'ru': "Учебник трейдинга", 'en': "Trading Manual"},
    ideas: {
      'kk': [
        "Табысты трейдинг үш М-ге сүйенеді: Mind (ақыл), Method (әдіс) және Money (ақша-менеджмент).",
        "Әр мәміленің тәуекелін шектейтін екі ереже бар: бір мәмілеге және бір айға арналған шек.",
        "Трейдингтік журнал жүргізу — өз қателіктеріңнен үйреніп, тәртіпті дамытудың басты құралы.",
      ],
      'ru': [
        "Успешная торговля стоит на трёх «М»: Mind (разум), Method (метод) и Money (управление капиталом).",
        "Риск каждой сделки ограничивают два правила: лимит на одну сделку и лимит на месяц.",
        "Ведение торгового дневника — главный инструмент обучения на ошибках и развития дисциплины.",
      ],
      'en': [
        "Successful trading rests on three M's: Mind, Method, and Money management.",
        "Two rules cap your risk: a limit per single trade and a limit per month.",
        "Keeping a trading journal is the key tool for learning from mistakes and building discipline.",
      ],
    },
    conclusion: {'kk': "Ақыл, әдіс пен ақша-менеджментті теңестіріп, тәуекел шектерін сақтаңыз да, журнал жүргізіңіз.", 'ru': "Балансируйте разум, метод и капитал, соблюдайте лимиты риска и ведите дневник сделок.", 'en': "Balance mind, method, and money, respect your risk limits, and keep a trading journal."},
  ),
  'b-039': LibContent(
    genre: {'kk': "Қаржы журналистикасы", 'ru': "Финансовая журналистика", 'en': "Financial Journalism"},
    ideas: {
      'kk': [
        "1980-жылдардағы Уолл-стриттегі инсайдерлік сауда мен қаржы алаяқтығының кең таралған желісі ашылады.",
        "Майкл Милкен сынды тұлғалар арқылы ашкөздік пен заңсыздықтың жүйелі сипаты көрсетіледі.",
        "Заңсыз пайда қаншама үлкен болса да, ақыры әшкереленіп, заң алдында жауап беретіні дәлелденеді.",
      ],
      'ru': [
        "Раскрывается разветвлённая сеть инсайдерской торговли и финансовых махинаций Уолл-стрит 1980-х.",
        "Через фигуры вроде Майкла Милкена показан системный характер жадности и беззакония.",
        "Доказывается, что сколь угодно крупная незаконная прибыль в итоге раскрывается и карается.",
      ],
      'en': [
        "It exposes the sprawling web of insider trading and financial fraud on 1980s Wall Street.",
        "Through figures like Michael Milken it shows the systemic nature of greed and lawlessness.",
        "It proves that however large illegal gains may be, they are eventually exposed and punished.",
      ],
    },
    conclusion: {'kk': "Жылдам әрі заңсыз пайдадан аулақ болыңыз, ол ерте ме, кеш пе апатқа айналады.", 'ru': "Держитесь подальше от быстрой незаконной прибыли — рано или поздно она оборачивается крахом.", 'en': "Stay far from fast illegal profit; sooner or later it turns into ruin."},
  ),
  'b-040': LibContent(
    genre: {'kk': "Инвестициялық философия", 'ru': "Инвестиционная философия", 'en': "Investment Philosophy"},
    ideas: {
      'kk': [
        "Нарық циклдары қайталанады, сондықтан қазір циклдің қай нүктесінде тұрғаныңды бағалау басты шеберлік.",
        "Циклды дөп болжау мүмкін емес, бірақ маятниктің шектен шыққанын сезіну артықшылық береді.",
        "Басқалар сараңдыққа берілгенде сақ болып, олар қорыққанда батыл болу — циклмен жұмыс істеудің мәні.",
      ],
      'ru': [
        "Рыночные циклы повторяются, поэтому ключевое умение — оценивать, в какой точке цикла мы сейчас.",
        "Точно предсказать цикл нельзя, но ощущение крайностей маятника даёт преимущество.",
        "Быть осторожным при жадности других и смелым при их страхе — суть работы с циклом.",
      ],
      'en': [
        "Market cycles repeat, so the key skill is gauging where in the cycle we now stand.",
        "You cannot time a cycle precisely, but sensing the pendulum's extremes gives an edge.",
        "Being cautious when others are greedy and bold when they fear is the essence of cycle work.",
      ],
    },
    conclusion: {'kk': "Циклдің қай нүктесінде тұрғаныңды бағалап, маятник шетке жеткенде тобырға қарсы әрекет етіңіз.", 'ru': "Оценивайте, в какой точке цикла вы находитесь, и при крайностях маятника идите против толпы.", 'en': "Gauge where in the cycle you stand, and at the pendulum's extremes act against the crowd."},
  ),

  // ─────────────────────────── FILMS f-001..f-011 ───────────────────────────
  'f-001': LibContent(
    genre: {'kk': "Биографиялық драма", 'ru': "Биографическая драма", 'en': "Biographical drama"},
    ideas: {
      'kk': [
        "Джордан Белфорт пенни-акцияларды агрессивті телефон арқылы сатуды алаяқтыққа айналдырып, инвесторларды жалған уәделермен тонап байыды.",
        "Шектен тыс ашкөздік, есірткі мен өзін-өзі бақыламау трейдерді сөзсіз күйреуге және түрмеге апаратынын фильм айқын көрсетеді.",
        "Қысым жасайтын сатушы сізге белсенді ұсынатын актив әдетте оның мүддесі үшін, сіздің пайдаңыз үшін емес екенін ұмытпаңыз.",
      ],
      'ru': [
        "Джордан Белфорт превратил агрессивные телефонные продажи дешёвых акций в мошенничество, обирая инвесторов ложными обещаниями быстрой прибыли.",
        "Безудержная жадность, наркотики и отсутствие самоконтроля неизбежно ведут трейдера к краху, тюрьме и потере всего.",
        "Актив, который вам настойчиво навязывает продавец под давлением, почти всегда выгоден ему, а не вам.",
      ],
      'en': [
        "Jordan Belfort turned aggressive cold-calling of cheap stocks into outright fraud, robbing investors with false promises of riches.",
        "Unchecked greed, drugs and zero self-control inevitably drive a trader toward collapse, prison and losing everything he built.",
        "An asset a salesman pushes hard under pressure is almost always good for him, not for you.",
      ],
    },
    conclusion: {'kk': "Жылдам байлық уәдесі мен қысыммен сатуға сенбеңіз, тәртіп пен адалдық ұзақ мерзімде ғана сақтайды.", 'ru': "Не верьте обещаниям быстрого богатства и продажам под давлением: в долгосрочной перспективе спасают только дисциплина и честность.", 'en': "Distrust promises of fast riches and high-pressure sales; only discipline and honesty protect you over the long run."},
  ),
  'f-002': LibContent(
    genre: {'kk': "Биографиялық драма", 'ru': "Биографическая драма", 'en': "Biographical drama"},
    ideas: {
      'kk': [
        "Бірнеше аутсайдер ипотекалық облигациялардың іштей шіріп тұрғанын байқап, нарыққа қарсы ставка жасап, 2008 дағдарысында ұтып шықты.",
        "Көпшілік сенетін «қауіпсіз» актив шын мәнінде уытты болуы мүмкін, өз бетіңізше тереңдеп зерттеу жүргізу маңызды.",
        "Дұрыс болсаңыз да нарық сізден ұзақ уақыт қисынсыз қалуы мүмкін, ставка ақталғанша шыдамдылық пен капитал керек.",
      ],
      'ru': [
        "Несколько аутсайдеров разглядели гниль внутри ипотечных облигаций и сыграли против рынка, заработав на крахе 2008 года.",
        "Актив, который все считают «безопасным», может быть токсичным; важно самому копать глубоко и проверять факты.",
        "Даже будучи правым, можно ждать долго: рынок остаётся иррациональным дольше, чем хватает терпения и капитала.",
      ],
      'en': [
        "A few outsiders spotted the rot inside mortgage bonds and bet against the market, profiting from the 2008 crash.",
        "An asset everyone calls «safe» can be toxic; doing your own deep research and checking facts is vital.",
        "Even when right, you may wait long: the market can stay irrational longer than your patience and capital last.",
      ],
    },
    conclusion: {'kk': "Тобырдан тәуелсіз ойлаңыз, фактілерді өзіңіз тексеріңіз, бірақ дұрыс ставканың да ұзақ сабырлықты талап ететінін біліңіз.", 'ru': "Думайте независимо от толпы и проверяйте факты сами, но помните, что даже верная ставка требует долгого терпения.", 'en': "Think independently of the crowd and verify facts yourself, but remember even a correct bet demands long patience."},
  ),
  'f-003': LibContent(
    genre: {'kk': "Қаржылық триллер", 'ru': "Финансовый триллер", 'en': "Financial thriller"},
    ideas: {
      'kk': [
        "Инвестбанк бір түнде өзінің активтері уытты екенін біліп, шығынды клиенттерге аудару үшін бәрін бірінші болып сатуды шешеді.",
        "Тәуекелді ерте байқаған жас талдаушының дабылы фирманы құтқарады, сандарды мұқият оқу өмірлік маңызды дағды.",
        "Дағдарыста ірі ойыншылар «бірінші, ақылдырақ немесе алаяқ бол» қағидасымен әрекет етеді, кішкентай инвестор соңғы болып қалады.",
      ],
      'ru': [
        "За одну ночь инвестбанк понимает, что его активы токсичны, и решает первым сбросить всё, переложив убытки на клиентов.",
        "Тревогу поднимает молодой аналитик, разглядевший риск рано; умение внимательно читать цифры спасает фирму.",
        "В кризис крупные игроки действуют по принципу «будь первым, умнее или мошенником», а мелкий инвестор остаётся последним.",
      ],
      'en': [
        "Overnight an investment bank realizes its assets are toxic and decides to dump everything first, offloading losses onto clients.",
        "A young analyst who spots the risk early raises the alarm; reading the numbers carefully saves the firm.",
        "In a crisis big players follow «be first, be smarter or cheat», leaving the small investor holding the bag.",
      ],
    },
    conclusion: {'kk': "Нарықта ірі ойыншылар сізді хабардар етпей бұрын шығады, сол себепті тәуекелді өзіңіз ерте бағалап, жылдам әрекет етіңіз.", 'ru': "Крупные игроки выходят раньше, не предупредив вас, поэтому оценивайте риск сами заранее и действуйте быстро.", 'en': "Big players exit first without warning you, so assess risk early yourself and act fast when the picture changes."},
  ),
  'f-004': LibContent(
    genre: {'kk': "Драма", 'ru': "Драма", 'en': "Drama"},
    ideas: {
      'kk': [
        "Жас брокер Бад Фокс табысқа ұмтылып, Гордон Геккоға инсайдерлік ақпарат беріп, заңсыз байлық жолына түседі.",
        "«Ашкөздік жақсы» ұраны қысқа мерзімде тартымды көрінгенімен, ақыры адамды құртатын этикалық тұзақ болып шығады.",
        "Инсайдерлік сауда мен заңсыз әрекеттер жылдам пайда берсе де, бәрі ашылып, бостандық пен мансаппен төленеді.",
      ],
      'ru': [
        "Молодой брокер Бад Фокс ради успеха снабжает Гордона Гекко инсайдом и вступает на путь незаконного обогащения.",
        "Лозунг «жадность — это хорошо» кажется привлекательным на короткой дистанции, но оборачивается этической ловушкой и крахом.",
        "Инсайдерская торговля и нарушения закона дают быструю прибыль, но всё вскрывается и оплачивается свободой и карьерой.",
      ],
      'en': [
        "Young broker Bud Fox chases success by feeding Gordon Gekko inside information, stepping onto a path of illegal wealth.",
        "The slogan «greed is good» looks appealing short term but turns into an ethical trap that destroys the man.",
        "Insider trading and breaking the law bring fast profit, but everything surfaces and is paid for with freedom.",
      ],
    },
    conclusion: {'kk': "Заңсыз ақпарат пен этикасыз пайда уақытша ғана, ұзақ мансап тек адал әрі заңды әрекеттермен ғана сақталады.", 'ru': "Незаконная информация и неэтичная прибыль временны: долгая карьера держится только на честных и законных действиях.", 'en': "Illegal information and unethical profit are temporary; a lasting career rests only on honest, lawful conduct."},
  ),
  'f-005': LibContent(
    genre: {'kk': "Биографиялық драма", 'ru': "Биографическая драма", 'en': "Biographical drama"},
    ideas: {
      'kk': [
        "Ник Лисон шығындарын жасырын «88888» шотына тығып, оларды қуып жетуге тырысып, Barings банкін біржола күйретеді.",
        "Жоғалтуды мойындамай, ставканы екі есе арттыру тәуекелді бақылауды жойып, кішкене қатені апатқа айналдырады.",
        "Бақылау мен тәуекел-менеджментінің жоқтығы бір трейдерге ғасырлық банкті жалғыз өзі құлатуға мүмкіндік берді.",
      ],
      'ru': [
        "Ник Лисон прячет убытки на тайном счёте «88888» и, пытаясь их отыграть, окончательно разрушает банк Barings.",
        "Отказ признать потерю и удвоение ставки уничтожают контроль над риском, превращая мелкую ошибку в катастрофу.",
        "Отсутствие надзора и риск-менеджмента позволило одному трейдеру в одиночку обанкротить старейший банк.",
      ],
      'en': [
        "Nick Leeson hides losses in a secret «88888» account and, trying to win them back, finally destroys Barings Bank.",
        "Refusing to admit a loss and doubling the bet destroys risk control, turning a small error into catastrophe.",
        "The absence of oversight and risk management let a single trader bankrupt a centuries-old bank all by himself.",
      ],
    },
    conclusion: {'kk': "Шығынды дереу мойындап, кесіп тастаңыз; жасырылған және ұлғайтылған жоғалту трейдер мен бүкіл фирманы құртады.", 'ru': "Признавайте и режьте убыток сразу: спрятанная и наращиваемая потеря губит и трейдера, и всю фирму.", 'en': "Admit and cut a loss immediately; a hidden, escalating loss destroys both the trader and the entire firm."},
  ),
  'f-006': LibContent(
    genre: {'kk': "Драма", 'ru': "Драма", 'en': "Drama"},
    ideas: {
      'kk': [
        "Жас жігіт оңай ақша іздеп, жалған брокерлік фирмаға кіреді, ол клиенттерге жоқ акцияларды агрессивті түрде сатады.",
        "«Pump and dump» сұлбасында брокерлер бағаны жасанды көтеріп, өздері шығып, инвесторларды құнсыз қағазбен қалдырады.",
        "Сізге қоңырау шалып, кепілдік берілген пайдаға акция ұсынса, бұл әрдайым алаяқтықтың айқын белгісі екенін біліңіз.",
      ],
      'ru': [
        "Молодой парень в поисках лёгких денег попадает в фиктивную брокерскую фирму, агрессивно впаривающую клиентам несуществующие акции.",
        "В схеме «pump and dump» брокеры искусственно вздувают цену, выходят сами и оставляют инвесторов с пустыми бумагами.",
        "Если вам звонят и предлагают акции с гарантированной прибылью, это всегда явный признак мошенничества.",
      ],
      'en': [
        "A young man chasing easy money joins a fake brokerage that aggressively pushes nonexistent stocks onto its clients.",
        "In a «pump and dump» scheme brokers artificially inflate a price, exit themselves, and leave investors with worthless shares.",
        "If someone cold-calls offering stocks with guaranteed profit, that is always a clear sign of fraud.",
      ],
    },
    conclusion: {'kk': "Кепілдендірілген пайда мен қоңыраумен ұсынылған акциялардан аулақ болыңыз, мұндай оңай ақша әрдайым алаяқтық болып шығады.", 'ru': "Избегайте акций с гарантированной прибылью, навязанных по телефону: такие лёгкие деньги всегда оказываются мошенничеством.", 'en': "Avoid stocks with guaranteed profit pitched by cold calls; such easy money always turns out to be fraud."},
  ),
  'f-007': LibContent(
    genre: {'kk': "Деректі фильм", 'ru': "Документальное кино", 'en': "Documentary"},
    ideas: {
      'kk': [
        "Фильм 2008 дағдарысының жүйелік себептерін: реттеудің әлсіздігін, ашкөздікті және банктер мен рейтинг агенттіктерінің сыбайластығын ашады.",
        "Уытты ипотекалық өнімдерге жоғары рейтинг берген агенттіктер мен реттеушілер дағдарысты болдырмай, оны асқындырды.",
        "Жеке инвестор жүйенің өзіне қарсы құрылғанын түсініп, ресми рейтинг пен сенімге соқыр сенбеуі керек екенін көрсетеді.",
      ],
      'ru': [
        "Фильм вскрывает системные причины кризиса 2008: слабость регулирования, жадность и сговор банков с рейтинговыми агентствами.",
        "Агентства и регуляторы, присваивавшие высокий рейтинг токсичным ипотечным продуктам, не предотвратили кризис, а усугубили его.",
        "Частный инвестор должен понимать, что система устроена против него, и не верить слепо официальным рейтингам.",
      ],
      'en': [
        "The film exposes the systemic causes of the 2008 crisis: weak regulation, greed and collusion between banks and rating agencies.",
        "Agencies and regulators that stamped toxic mortgage products with top ratings did not prevent the crisis but deepened it.",
        "An individual investor must grasp that the system is built against him and not blindly trust official ratings.",
      ],
    },
    conclusion: {'kk': "Ресми рейтинг пен реттеушілерге соқыр сенбеңіз, жүйе сіздің мүддеңізді қорғамайды, сондықтан тәуекелді өз бетіңізше бағалаңыз.", 'ru': "Не доверяйте слепо рейтингам и регуляторам: система не защищает ваши интересы, поэтому оценивайте риск самостоятельно.", 'en': "Do not blindly trust ratings and regulators; the system does not protect your interests, so assess risk yourself."},
  ),
  'f-008': LibContent(
    genre: {'kk': "Қаржылық драма", 'ru': "Финансовая драма", 'en': "Financial drama"},
    ideas: {
      'kk': [
        "Фильм 2008 жылы Lehman Brothers құлап, билік пен банктер жүйені құтқаруға тырысқан дағдарыс күндерін іштен көрсетеді.",
        "«Too big to fail» қағидасы бір институттың құлауы бүкіл қаржы жүйесін тізбекті түрде құлатуы мүмкін екенін білдіреді.",
        "Дағдарыс кезінде шешімдер үрей мен саясат қысымымен қабылданады, нарық таза логикаға ғана бағынбайтынын ұмытпаңыз.",
      ],
      'ru': [
        "Фильм изнутри показывает дни кризиса 2008 года, когда рухнул Lehman Brothers и власти с банками спасали систему.",
        "Принцип «too big to fail» означает, что падение одного института может цепной реакцией обрушить всю финансовую систему.",
        "В кризис решения принимаются под давлением паники и политики; рынок подчиняется не только чистой логике.",
      ],
      'en': [
        "The film shows from inside the days of the 2008 crisis, when Lehman Brothers fell and authorities and banks scrambled to save the system.",
        "The «too big to fail» principle means one institution's collapse can bring down the whole financial system in a chain reaction.",
        "In a crisis, decisions are made under panic and political pressure; remember the market obeys more than pure logic.",
      ],
    },
    conclusion: {'kk': "Жүйелік тәуекелді бағалаңыз және дағдарыста нарықты үрей мен саясат билейтінін ескеріп, өзіңіздің капиталыңызды қорғаңыз.", 'ru': "Учитывайте системный риск и помните, что в кризис рынком правят паника и политика, защищая собственный капитал.", 'en': "Account for systemic risk and remember that in a crisis panic and politics rule the market, so protect your own capital."},
  ),
  'f-009': LibContent(
    genre: {'kk': "Биографиялық драма", 'ru': "Биографическая драма", 'en': "Biographical drama"},
    ideas: {
      'kk': [
        "Берни Мейдофф ондаған жыл бойы тұрақты пайда уәде еткен алып Понци-сұлбасын құрып, мыңдаған инвесторды алдады.",
        "Шектен тыс тұрақты және «тым жақсы» табыс әрдайым алаяқтықтың белгісі, нақты нарықта мұндай кіріс болмайды.",
        "Беделі мен абыройына сүйеніп біреуге толық сенім арту инвесторды ең үлкен қаржылық апатқа апаруы мүмкін.",
      ],
      'ru': [
        "Берни Мэдофф десятилетиями строил гигантскую схему Понци, обещая стабильную доходность и обманув тысячи инвесторов.",
        "Чрезмерно стабильная и «слишком хорошая» доходность всегда признак мошенничества: на реальном рынке такого не бывает.",
        "Полное доверие к человеку из-за его репутации и статуса может привести инвестора к крупнейшей финансовой катастрофе.",
      ],
      'en': [
        "Bernie Madoff spent decades building a giant Ponzi scheme, promising steady returns and deceiving thousands of investors.",
        "Excessively stable and «too good» returns are always a sign of fraud; on a real market such consistency does not exist.",
        "Trusting someone completely because of his reputation and status can lead an investor to the greatest financial disaster.",
      ],
    },
    conclusion: {'kk': "Тұрақты тым жақсы табысқа және беделге соқыр сенбеңіз, кірісті тексеріп, ашықтығы жоқ қорлардан аулақ болыңыз.", 'ru': "Не верьте слепо стабильно высокой доходности и репутации: проверяйте отдачу и избегайте фондов без прозрачности.", 'en': "Never blindly trust steady high returns or reputation; verify performance and avoid funds that lack transparency."},
  ),
  'f-010': LibContent(
    genre: {'kk': "Комедия", 'ru': "Комедия", 'en': "Comedy"},
    ideas: {
      'kk': [
        "Екі бай ағайынды адамның тағдыры тек ортасына байланысты ма деген бәс үшін кедей мен брокердің орнын ауыстырады.",
        "Кульминацияда кейіпкерлер апельсин шырынының фьючерстерінде инсайдпен ойнап, ашкөз ағайындыларды биржада ойсырата жеңеді.",
        "Нарық эмоция мен үрейге толы, ал ақпарат пен суық есеп дұрыс сәтте бәсекелесті жеңудің кілті болады.",
      ],
      'ru': [
        "Двое богатых братьев ради спора, всё ли решает среда, меняют местами бедняка и брокера, ломая обе судьбы.",
        "В кульминации герои играют на фьючерсах на апельсиновый сок с инсайдом и громят жадных братьев на бирже.",
        "Рынок полон эмоций и паники, а информация и холодный расчёт в нужный момент становятся ключом к победе.",
      ],
      'en': [
        "Two rich brothers swap a poor man and a broker over a bet on whether environment decides everything, ruining both lives.",
        "At the climax the heroes trade orange juice futures on inside knowledge and crush the greedy brothers on the exchange.",
        "The market is full of emotion and panic, while information and cold calculation at the right moment are the key to winning.",
      ],
    },
    conclusion: {'kk': "Нарық эмоцияға толы, сондықтан суық есеп, ақпарат артықшылығы және дұрыс уақытты таңдау жеңіске жеткізеді.", 'ru': "Рынок полон эмоций, поэтому к победе ведут холодный расчёт, информационное преимущество и точный выбор момента.", 'en': "The market is full of emotion, so cold calculation, an information edge and precise timing are what lead to victory."},
  ),
  'f-011': LibContent(
    genre: {'kk': "Деректі фильм", 'ru': "Документальное кино", 'en': "Documentary"},
    ideas: {
      'kk': [
        "Enron энергетикалық алыбы есепті бұрмалап, шығынын жасырып, жасанды пайда көрсетіп, ақыры тарихтағы ең ірі банкроттыққа ұшырады.",
        "Mark-to-market есебі мен жасырын серіктестіктер арқылы компания нақты болмаған пайданы кітапқа жазып, инвесторларды алдады.",
        "Бағасы өсіп тұрған, бірақ қаржысы түсініксіз компаниядан сақтаныңыз, ашықтықтың жоқтығы әрдайым елеулі ескерту белгісі.",
      ],
      'ru': [
        "Энергогигант Enron искажал отчётность, скрывал убытки и рисовал прибыль, что привело к крупнейшему на тот момент банкротству.",
        "Через учёт mark-to-market и скрытые партнёрства компания записывала несуществующую прибыль и обманывала инвесторов.",
        "Остерегайтесь компании с растущей ценой, но непрозрачными финансами: отсутствие ясности всегда серьёзный тревожный сигнал.",
      ],
      'en': [
        "Energy giant Enron distorted its accounts, hid losses and fabricated profit, leading to the largest bankruptcy of its time.",
        "Through mark-to-market accounting and hidden partnerships the company booked nonexistent profit and deceived its investors.",
        "Beware a company with a rising price but opaque finances; a lack of clarity is always a serious warning sign.",
      ],
    },
    conclusion: {'kk': "Қаржысы түсініксіз, есебі күрделі компаниялардан аулақ болыңыз, ашықтық пен тексерілетін пайда сенімді инвестицияның негізі.", 'ru': "Избегайте компаний с непрозрачными финансами и запутанной отчётностью: прозрачность и проверяемая прибыль — основа надёжных вложений.", 'en': "Avoid companies with opaque finances and convoluted accounting; transparency and verifiable profit are the basis of sound investing."},
  ),

  // ─────────────────────────── FILMS f-012..f-022 ───────────────────────────
  'f-012': LibContent(
    genre: {'kk': "Деректі фильм", 'ru': "Документальное кино", 'en': "Documentary"},
    ideas: {
      'kk': [
        "Питтегі айқай-шудан электронды саудаға көшу дәуірі қалай тұтас кәсіптерді бір түнде жойып жібергенін көрсетеді.",
        "Трейдерлердің табысы тәртіпке емес, тәуекелге салынған агрессиясына негізделгенде, нарық өзгерген сәтте олар құлдырайды.",
        "Бейімделмеген маман технологиялық ауысуға дайын болмаса, бұрынғы шеберлігі оны құтқара алмайтынын ескертеді.",
      ],
      'ru': [
        "Показывает, как переход от голосовых ям к электронной торговле за считанные годы уничтожил целые профессии и судьбы.",
        "Когда успех трейдера держится на агрессии и риске, а не на дисциплине, смена рынка ломает его.",
        "Предупреждает, что без адаптации к технологическим переменам прежнее мастерство не спасает трейдера от краха.",
      ],
      'en': [
        "Shows how the shift from open-outcry pits to electronic trading wiped out entire professions and lives within a few years.",
        "When a trader's success rests on aggression and gambling rather than discipline, a market regime change destroys him.",
        "Warns that without adapting to technological change, a trader's former skill cannot save him from ruin.",
      ],
    },
    conclusion: {'kk': "Нарық пен технология өзгереді, сондықтан трейдер ескі дағдыға тәуелді болмай, үнемі бейімделуге тиіс.", 'ru': "Рынок и технологии меняются, поэтому трейдер не должен зависеть от старых навыков и обязан постоянно адаптироваться.", 'en': "Markets and technology change, so a trader must keep adapting instead of clinging to old habits and skills."},
  ),
  'f-013': LibContent(
    genre: {'kk': "Қаржылық драма", 'ru': "Финансовая драма", 'en': "Financial drama"},
    ideas: {
      'kk': [
        "2008 жылғы дағдарыс ашкөздік пен жүйелік тәуекелдің бүкіл банк жүйесін қалай шегіне жеткізгенін көрсетеді.",
        "Кек пен пайда қуғаны қарым-қатынасты бұзады, ал нарықта эмоция мен ашу нашар шешімдерге жетелейді.",
        "«Спекуляция — нөлдік ойын» деген ой ұзақмерзімді мақсат пен жылдам пайданың арасындағы таңдауды еске салады.",
      ],
      'ru': [
        "Показывает, как жадность и системный риск довели до краха весь банковский сектор в кризис 2008 года.",
        "Погоня за местью и прибылью разрушает отношения, а на рынке эмоции и злость ведут к плохим решениям.",
        "Идея «спекуляция — игра с нулевой суммой» напоминает о выборе между долгой целью и быстрой наживой.",
      ],
      'en': [
        "Shows how greed and systemic risk pushed the entire banking sector to collapse during the 2008 crisis.",
        "Chasing revenge and profit destroys relationships, and in markets emotion and anger lead to poor decisions.",
        "The line «speculation is a zero-sum game» reminds traders to weigh long-term goals against fast gains.",
      ],
    },
    conclusion: {'kk': "Қысқа мерзімді пайда мен кек үшін емес, ұзақмерзімді мақсат пен сенім үшін сауда жасаған дұрыс.", 'ru': "Торговать стоит ради долгосрочной цели и доверия, а не ради краткосрочной прибыли и мести.", 'en': "Trade for long-term goals and trust, not for short-term profit and revenge."},
  ),
  'f-014': LibContent(
    genre: {'kk': "Өмірбаяндық драма", 'ru': "Биографическая драма", 'en': "Biographical drama"},
    ideas: {
      'kk': [
        "Крис Гарднердің әңгімесі мақсатқа деген табандылық пен бас тартпау нарықтағы ұзақ жолда шешуші екенін көрсетеді.",
        "Қаржылық түбіне жеткен жағдайда да эмоцияны басқарып, әр мүмкіндікті дайындықпен қарсы алу маңызды.",
        "Брокер болу үшін өткен сынақ кезеңі шыдамдылық пен үздіксіз оқудың нәтиже беретінін айқын дәлелдейді.",
      ],
      'ru': [
        "История Криса Гарднера показывает, что упорство и отказ сдаваться решают исход долгого пути на рынке.",
        "Даже на финансовом дне важно управлять эмоциями и встречать каждую возможность во всеоружии и с подготовкой.",
        "Стажировка ради места брокера доказывает, что терпение и непрерывное обучение в итоге приносят результат.",
      ],
      'en': [
        "Chris Gardner's story shows that persistence and refusing to quit decide the outcome of a long market journey.",
        "Even at financial rock bottom, managing emotions and meeting every opportunity well-prepared remains essential.",
        "The unpaid internship for a broker seat proves that patience and constant learning eventually pay off.",
      ],
    },
    conclusion: {'kk': "Табандылық, эмоцияны басқару және үздіксіз оқу трейдерді ең ауыр кезеңнен де алып шығады.", 'ru': "Упорство, контроль эмоций и постоянное обучение выведут трейдера даже из самого тяжёлого периода.", 'en': "Persistence, emotional control and continuous learning carry a trader through even the hardest period."},
  ),
  'f-015': LibContent(
    genre: {'kk': "Фантастикалық триллер", 'ru': "Фантастический триллер", 'en': "Sci-fi thriller"},
    ideas: {
      'kk': [
        "Шексіз ақпарат пен қабілет те тәуекелді жоймайды; басқарылмаған артықшылық трейдерді қауіпті борышқа батырады.",
        "Жылдам табыс пен дереу нәтиже іздеу жасанды демеуге тәуелділік тудырып, тұрақсыз стратегияға айналады.",
        "Эдди Морраның тарихы білім мен есеп-қисап шектен тыс өзіне сенімділіксіз ғана пайдалы екенін көрсетеді.",
      ],
      'ru': [
        "Даже безграничная информация и способности не убирают риск; неконтролируемое преимущество топит трейдера в опасных долгах.",
        "Погоня за быстрым успехом и мгновенным результатом рождает зависимость от искусственной подпитки и шаткую стратегию.",
        "История Эдди Морры показывает, что знание и расчёт полезны лишь без чрезмерной самоуверенности.",
      ],
      'en': [
        "Even limitless information and ability do not remove risk; an uncontrolled edge sinks the trader into dangerous debt.",
        "Chasing fast success and instant results breeds dependence on artificial boosts and a fragile strategy.",
        "Eddie Morra's arc shows that knowledge and calculation only help when free of reckless overconfidence.",
      ],
    },
    conclusion: {'kk': "Ең күшті артықшылықтың өзі тәуекелді басқарусыз және өзін-өзі бақылаусыз трейдерді апатқа жетелейді.", 'ru': "Даже сильнейшее преимущество без управления риском и самоконтроля приводит трейдера к катастрофе.", 'en': "Even the strongest edge leads a trader to disaster without risk management and self-control."},
  ),
  'f-016': LibContent(
    genre: {'kk': "Өмірбаяндық драма", 'ru': "Биографическая драма", 'en': "Biographical drama"},
    ideas: {
      'kk': [
        "Алтын кенішіне құмарлық пен жалған үміт инвесторлардың ашкөздігін қалай тұтандыратынын және алдауға жол ашатынын көрсетеді.",
        "Жеткіліксіз тексеру мен due diligence-тің жоқтығы бір ғана алаяқтық есеп бүкіл капиталды құртуға жетеді.",
        "Кенни Уэллстің тарихы үлкен табыстың артында көбіне расталмаған деректер мен елес жатқанын ескертеді.",
      ],
      'ru': [
        "Показывает, как одержимость золотой жилой и ложная надежда разжигают жадность инвесторов и открывают дорогу обману.",
        "Отсутствие проверки и due diligence: одной поддельной пробы хватает, чтобы уничтожить весь капитал.",
        "История Кенни Уэллса напоминает, что за крупной прибылью часто стоят непроверенные данные и иллюзия.",
      ],
      'en': [
        "Shows how obsession with a gold strike and false hope ignite investor greed and open the door to fraud.",
        "Lack of verification and due diligence: a single faked assay is enough to wipe out all the capital.",
        "Kenny Wells's story warns that behind a huge payoff often lie unverified data and an illusion.",
      ],
    },
    conclusion: {'kk': "Кез келген «ұтымды» мәмілені мұқият тексеріп, расталмаған уәдеге капиталды тікпеу трейдерді алаяқтықтан қорғайды.", 'ru': "Тщательная проверка любой «выгодной» сделки и отказ вкладывать в непроверенные обещания защищают трейдера от мошенничества.", 'en': "Carefully verifying every «great» deal and refusing to fund unproven promises protect a trader from fraud."},
  ),
  'f-017': LibContent(
    genre: {'kk': "Қаржылық триллер", 'ru': "Финансовый триллер", 'en': "Financial thriller"},
    ideas: {
      'kk': [
        "Теледидардағы «ыстық» кеңеске соқыр сеніп бар қаражатын салу инвесторды толық күйреуге апаратынын көрсетеді.",
        "«Алгоритмдегі қателік» деген сылтаудың артында жиі адамдық жауапсыздық пен жасырын манипуляция тұрады.",
        "Бір акцияға бүкіл капиталды шоғырландыру мен диверсификацияны елемеу апатты тәуекелге айналады.",
      ],
      'ru': [
        "Показывает, как слепая вера в «горячий» совет с телеэкрана и ставка всех денег ведут инвестора к краху.",
        "За оправданием «сбой алгоритма» часто стоит человеческая безответственность и скрытая манипуляция.",
        "Концентрация всего капитала в одной акции и пренебрежение диверсификацией оборачиваются катастрофическим риском.",
      ],
      'en': [
        "Shows how blind faith in a «hot» on-air tip and betting everything lead an investor to total ruin.",
        "Behind the «algorithm glitch» excuse there often lies human irresponsibility and hidden manipulation.",
        "Concentrating all capital in one stock and ignoring diversification turn into catastrophic risk.",
      ],
    },
    conclusion: {'kk': "Бұқаралық кеңеске сенбей, өз талдауыңа сүйеніп, капиталды әртараптандыру трейдерді бір соққыдан сақтайды.", 'ru': "Не доверяя публичным советам, опираясь на свой анализ и диверсифицируя капитал, трейдер защищён от одного удара.", 'en': "Distrusting public tips, relying on your own analysis and diversifying capital protect a trader from a single blow."},
  ),
  'f-018': LibContent(
    genre: {'kk': "Қаржылық триллер", 'ru': "Финансовый триллер", 'en': "Financial thriller"},
    ideas: {
      'kk': [
        "Роберт Миллердің жасырын шығыны мен жалған есебі бір өтірікті жабу үшін келесісінің керек болатынын көрсетеді.",
        "Беделі мен байлығын сақтау үшін шындықты бұрмалау ақыр соңында бүкіл құрылымды құлатуға дайын тұрады.",
        "Сатылым алдында жасырылған тәуекел инвесторларға да, отбасына да зиян келтіретін уақыт бомбасына айналады.",
      ],
      'ru': [
        "Скрытый убыток и поддельная отчётность Роберта Миллера показывают, что одна ложь требует следующей для прикрытия.",
        "Искажение правды ради сохранения репутации и богатства в итоге грозит обрушить всю конструкцию.",
        "Спрятанный перед продажей риск становится бомбой замедленного действия для инвесторов и для семьи.",
      ],
      'en': [
        "Robert Miller's hidden loss and faked books show that one lie always demands another to cover it.",
        "Distorting the truth to protect reputation and wealth eventually threatens to topple the entire structure.",
        "A risk concealed before a sale becomes a time bomb for both investors and family alike.",
      ],
    },
    conclusion: {'kk': "Шығынды жасырмай мойындау және ашықтық трейдердің беделі мен капиталын ұзақмерзімде ғана сақтайды.", 'ru': "Только честное признание убытка и прозрачность сохраняют репутацию и капитал трейдера в долгосрочной перспективе.", 'en': "Only honestly admitting losses and staying transparent preserve a trader's reputation and capital long-term."},
  ),
  'f-019': LibContent(
    genre: {'kk': "Әлеуметтік драма", 'ru': "Социальная драма", 'en': "Social drama"},
    ideas: {
      'kk': [
        "Жылжымайтын мүлік дағдарысы біреудің күйреуінен пайда тапқан адамның өзі де моральдық тұзаққа түсетінін көрсетеді.",
        "Рик Карвердің «жеңімпаздар үй сатып алмайды, оларды басқалардан тартып алады» қағидасы суық есепшілдікті паш етеді.",
        "Қарызға белшесінен батқан адамдар нарықтың төменгі циклінде ең осал буын болатынын ескертеді.",
      ],
      'ru': [
        "Ипотечный кризис показывает, что наживающийся на чужом крахе сам попадает в моральную ловушку.",
        "Принцип Рика Карвера «победители не покупают дома, а отбирают их» обнажает холодный расчёт.",
        "Люди в долгах оказываются самым уязвимым звеном на нижней фазе рыночного цикла.",
      ],
      'en': [
        "The housing crisis shows that whoever profits from another's collapse falls into a moral trap himself.",
        "Rick Carver's rule «winners don't buy houses, they take them» exposes cold, ruthless calculation.",
        "People drowning in debt become the most vulnerable link at the bottom phase of the market cycle.",
      ],
    },
    conclusion: {'kk': "Пайда табу мен принципті сақтау арасында таңдау бар, ал артық қарыз нарық құлағанда ең қауіпті болады.", 'ru': "Между прибылью и принципами всегда есть выбор, а избыточный долг опаснее всего при падении рынка.", 'en': "There is always a choice between profit and principle, and excess debt is most dangerous when markets fall."},
  ),
  'f-020': LibContent(
    genre: {'kk': "Өмірбаяндық комедия", 'ru': "Биографическая комедия", 'en': "Biographical comedy"},
    ideas: {
      'kk': [
        "GameStop оқиғасы ұйымдасқан бөлшек инвесторлар хедж-қорларға қарсы тұра алатынын, бірақ тәуекел екі жаққа да ортақ екенін көрсетеді.",
        "Қысқа позицияны «сығымдау» механизмі мен әлеуметтік желінің күші нарықта жаңа күш факторын тудырғанын паш етеді.",
        "«Ұстап тұр» эйфориясы көпшілікті шыңда ұстап қалып, кейбіреулердің бар жинағын жоғалтуымен аяқталатынын ескертеді.",
      ],
      'ru': [
        "История GameStop показывает, что организованные розничные инвесторы могут противостоять хедж-фондам, но риск общий для обеих сторон.",
        "Механика «шорт-сквиза» и сила соцсетей обнажают новый фактор силы, появившийся на рынке.",
        "Эйфория «держим до конца» удерживает толпу на пике и заканчивается потерей сбережений для части людей.",
      ],
      'en': [
        "The GameStop saga shows that organized retail investors can challenge hedge funds, but risk is shared by both sides.",
        "The short-squeeze mechanics and the power of social media reveal a new force factor in the market.",
        "The «hold the line» euphoria keeps the crowd at the peak and ends with some losing their entire savings.",
      ],
    },
    conclusion: {'kk': "Ұжымдық қозғалыс нарықты қозғай алады, бірақ эйфорияға беріліп, шегу нүктесін белгілемеу қауіпті болып қалады.", 'ru': "Коллективное движение способно двигать рынок, но поддаваться эйфории и не ставить точку выхода остаётся опасным.", 'en': "Collective momentum can move markets, but surrendering to euphoria without an exit point stays dangerous."},
  ),
  'f-021': LibContent(
    genre: {'kk': "Деректі фильм", 'ru': "Документальное кино", 'en': "Documentary"},
    ideas: {
      'kk': [
        "Уоррен Баффеттің өмірі шыдамдылық пен ұзақмерзімді компаундинг байлықтың басты қозғаушысы екенін айқын көрсетеді.",
        "Құзыреттілік шеңберінде қалып, түсінбейтін активтен бас тарту инвесторды артық тәуекелден сақтайтынын дәлелдейді.",
        "Қарапайым өмір салты мен үздіксіз оқу әдеті сәтті капитал басқарудың негізі болатынын паш етеді.",
      ],
      'ru': [
        "Жизнь Уоррена Баффетта ясно показывает, что терпение и долгосрочный компаундинг — главный двигатель богатства.",
        "Оставаться в круге компетенции и отказываться от непонятного актива защищает инвестора от лишнего риска.",
        "Скромный образ жизни и привычка постоянно учиться оказываются основой успешного управления капиталом.",
      ],
      'en': [
        "Warren Buffett's life clearly shows that patience and long-term compounding are the main engine of wealth.",
        "Staying within your circle of competence and skipping assets you don't understand shields you from excess risk.",
        "A modest lifestyle and the habit of constant reading turn out to be the basis of successful capital management.",
      ],
    },
    conclusion: {'kk': "Шыдамдылық, түсінетін активке ғана инвестициялау және үздіксіз оқу — ұзақмерзімді табыстың сенімді формуласы.", 'ru': "Терпение, инвестиции только в понятные активы и постоянное обучение — надёжная формула долгосрочного успеха.", 'en': "Patience, investing only in what you understand and continuous learning are a reliable formula for long-term success."},
  ),
  'f-022': LibContent(
    genre: {'kk': "Деректі фильм", 'ru': "Документальное кино", 'en': "Documentary"},
    ideas: {
      'kk': [
        "Фильм қаржы жүйесінің реттелмеген ашкөздігі қарапайым адамдарға жүйелік тәуекелді қалай аударатынын сынайды.",
        "2008 жылғы құтқару пакеттері пайда жекеменшіктеніп, шығын қоғамдастырылатын механизмді ашып көрсетеді.",
        "«Деривативтер» мен күрделі құралдар түсініксіз болғанда, тәуекел жасырынып, дағдарысты үдететінін ескертеді.",
      ],
      'ru': [
        "Фильм критикует, как нерегулируемая жадность финансовой системы перекладывает системный риск на простых людей.",
        "Спасательные пакеты 2008 года обнажают механизм, где прибыль приватизируется, а убытки обобществляются.",
        "Когда деривативы и сложные инструменты непонятны, риск прячется и ускоряет наступление кризиса.",
      ],
      'en': [
        "The film criticizes how the financial system's unregulated greed shifts systemic risk onto ordinary people.",
        "The 2008 bailouts expose a mechanism where profits are privatized while losses are socialized.",
        "When derivatives and complex instruments are opaque, risk hides itself and accelerates the onset of a crisis.",
      ],
    },
    conclusion: {'kk': "Трейдер жүйелік тәуекелді ескеріп, түсінбейтін күрделі құралдардан аулақ болып, өз капиталын қорғауы тиіс.", 'ru': "Трейдер должен учитывать системный риск, держаться подальше от непонятных сложных инструментов и беречь свой капитал.", 'en': "A trader must account for systemic risk, stay away from opaque complex instruments and protect their own capital."},
  ),
};
