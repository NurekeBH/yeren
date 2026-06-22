import '../../../shared/models/course.dart';

// Белсенді тіл — buildCourses(locale) орнатады. Мазмұн осыған қарай таңдалады.
String _loc = 'ru';

/// Мәтінді тіл бойынша таңдау. kk/en берілмесе RU-ға қайтады (әлі аударылмаған).
String _L(String ru, [String? kk, String? en]) => switch (_loc) {
      'kk' => kk ?? ru,
      'en' => en ?? ru,
      _ => ru,
    };

/// Формула жолдары (List<String>) үшін тіл таңдау.
List<String> _Lf(List<String> ru, [List<String>? kk, List<String>? en]) => switch (_loc) {
      'kk' => kk ?? ru,
      'en' => en ?? ru,
      _ => ru,
    };

// Қысқа алиастар — мазмұнды оқуға ыңғайлы ету үшін.
LessonBlock _p(String t) => ParagraphBlock(t);
LessonBlock _h(String t) => HeadingBlock(t);
LessonBlock _essence(String t) => CalloutBlock(CalloutKind.essence, t);
LessonBlock _example(String t) => CalloutBlock(CalloutKind.example, t);
LessonBlock _rule(String t, {String? title}) =>
    CalloutBlock(CalloutKind.rule, t, title: title);
LessonBlock _mechanic(String t, {String? title}) =>
    CalloutBlock(CalloutKind.mechanic, t, title: title);
LessonBlock _warn(String t) => CalloutBlock(CalloutKind.warning, t);
LessonBlock _fact(String t) => CalloutBlock(CalloutKind.fact, t);
LessonBlock _story(String t, {String? title}) =>
    CalloutBlock(CalloutKind.story, t, title: title);
LessonBlock _formula(List<String> lines, {String? title}) =>
    FormulaBlock(lines, title: title);
LessonBlock _interactive(String key, {String? title}) =>
    InteractiveBlock(key, title: title);

/// Қолданбадағы барлық премиум-курстар каталогы. Тіл бойынша мазмұн құрылады
/// (сабақ денесі _L() арқылы аударылады; тақырып/субтитр repository-де meta-дан).
List<Course> buildCourses([String locale = 'ru']) {
  _loc = locale;
  return [_master()];
}

Course _master() => Course(
  id: 'masters_of_uncertainty',
  title: 'Хозяева неопределённости',
  subtitle:
      'Курс, который превращает новичка в осознанного трейдера',
  description:
      'Пока другие гадают по графику, ты будешь понимать, ПОЧЕМУ движется рынок. '
      'Фундаментальный анализ, макроэкономика, психология, риск-менеджмент и математика '
      'решений — всё, что отделяет профи от толпы. 10 модулей, 49 уроков с интерактивными '
      'симуляторами и тестами. Знания, которые работают на твой депозит всю жизнь.',
  priceBonus: 4900,
  accent: 0xFF2563EB,
  modules: [
    _module1(),
    _module2(),
    _module3(),
    _module4(),
    _module5(),
    _module6(),
    _module7(),
    _module8(),
    _module9(),
    _module10(),
  ],
);

// ════════════════════════════════════════════════════════════════════
// МОДУЛЬ 1. Макроэкономический движок
// ════════════════════════════════════════════════════════════════════
CourseModule _module1() => CourseModule(
  id: 'm1',
  index: 1,
  title: 'Макроэкономический движок: как устроена глобальная финансовая машина',
  goal:
      'Понять природу денег, природу долга и то, почему графики вообще двигаются '
      'на глобальном уровне.',
  lessons: [
    CourseLesson(
      id: 'l1_1',
      code: '1.1',
      title: 'Великий обман цивилизации: зачем человечеству деньги?',
      blocks: [
        _essence(_L(
          'Деньги — это не богатство, а технология учёта доверия. Сами по себе бумажка или '
          'цифра на счёте бесполезны: их ценность держится только на общей вере, что завтра '
          'их примут в обмен на реальные товары. Вся мировая финансовая система — это '
          'грандиозная договорённость о доверии.',
          'Ақша — байлық емес, сенімді есепке алу технологиясы. Қағаздың немесе шоттағы '
          'санның өздігінен құны жоқ: оның құны тек ортақ сенімге сүйенеді — ертең оны нақты '
          'тауарға айырбастайды деген сенімге. Бүкіл әлемдік қаржы жүйесі — сенім туралы '
          'алып келісім.',
          'Money is not wealth, it is a technology for accounting trust. A banknote or a number '
          'in an account is useless on its own: its value rests only on the shared belief that '
          'tomorrow it will be accepted in exchange for real goods. The entire global financial '
          'system is one grand agreement about trust.',
        )),
        _h(_L('Зачем вообще придумали деньги', 'Ақша неге ойлап табылды', 'Why money was invented at all')),
        _p(_L(
          'Представь мир без денег — чистый бартер. Ты сапожник и хочешь хлеба. Но пекарю '
          'не нужны сапоги — ему нужна рыба. Значит, тебе сначала надо найти рыбака, которому '
          'нужны сапоги, обменять сапоги на рыбу, и только потом рыбу на хлеб. Это называется '
          '«проблема двойного совпадения желаний», и она парализует экономику.',
          'Ақшасыз әлемді елестет — таза бартер. Сен етікшісің, нан керек. Бірақ наубайшыға '
          'етік емес, балық керек. Сонда алдымен етік керек балықшыны тауып, етікті балыққа, '
          'сосын ғана балықты нанға айырбастауың керек. Бұл «қалаулардың қос сәйкестігі '
          'мәселесі» деп аталады әрі экономиканы тұралатады.',
          'Imagine a world without money — pure barter. You are a shoemaker and you want bread. '
          'But the baker does not need shoes — he needs fish. So first you must find a fisherman '
          'who needs shoes, trade shoes for fish, and only then fish for bread. This is called '
          'the "double coincidence of wants" problem, and it paralyses an economy.',
        )),
        _p(_L(
          'Деньги решили эту проблему: они стали универсальным посредником, который примет '
          'каждый. Деньги выполняют три функции: средство обмена, мера стоимости и средство '
          'накопления.',
          'Ақша бұл мәселені шешті: оны әркім қабылдайтын әмбебап делдалға айналды. Ақшаның '
          'үш қызметі бар: айырбас құралы, құн өлшемі және жинақтау құралы.',
          'Money solved this: it became a universal intermediary that everyone accepts. Money '
          'has three functions: a medium of exchange, a measure of value and a store of value.',
        )),
        _h(_L('Три эпохи денег', 'Ақшаның үш дәуірі', 'Three eras of money')),
        _p(_L(
          '1. Товарные деньги: ракушки каури, скот, соль, зерно. Само латинское слово '
          '«salarium» (зарплата) происходит от соли, которой платили римским солдатам — '
          'отсюда английское «salary».',
          '1. Тауарлық ақша: каури қабыршақтары, мал, тұз, дән. Латынша «salarium» (жалақы) '
          'сөзі рим солдаттарына төленген тұздан шыққан — ағылшынша «salary» содан.',
          '1. Commodity money: cowrie shells, cattle, salt, grain. The Latin word "salarium" '
          '(salary) comes from the salt paid to Roman soldiers — hence the English "salary".',
        )),
        _p(_L(
          '2. Золотой стандарт: бумажные банкноты были «расписками» на золото в хранилище. '
          'До 1971 года доллар официально менялся на золото по фиксированному курсу '
          '\$35 за унцию.',
          '2. Алтын стандарты: қағаз банкноттар қоймадағы алтынға «қолхат» болды. 1971 жылға '
          'дейін доллар алтынға тұрақты бағаммен — унциясы \$35 — ресми айырбасталды.',
          '2. The gold standard: paper banknotes were "receipts" for gold in a vault. Until '
          '1971 the dollar was officially exchanged for gold at a fixed rate of \$35 per ounce.',
        )),
        _p(_L(
          '3. Фиатные деньги (с 1971 г.): «fiat» на латыни — «да будет так». Деньги обеспечены '
          'только указом и доверием к государству. Печатать их можно практически без предела.',
          '3. Фиат ақша (1971 жылдан): латынша «fiat» — «солай болсын». Ақша тек жарлықпен '
          'және мемлекетке деген сеніммен қамтамасыз етіледі. Оны шексіз дерлік басып шығаруға болады.',
          '3. Fiat money (since 1971): "fiat" is Latin for "let it be done". Money is backed only '
          'by decree and trust in the state. It can be printed almost without limit.',
        )),
        _fact(_L(
          '15 августа 1971 года президент Никсон в воскресном телеобращении «временно» отменил '
          'обмен доллара на золото («Никсоновский шок»). Это «временно» длится уже более 50 лет. '
          'С того дня ни одна валюта мира не обеспечена золотом — мы все живём в эпохе чистого фиата.',
          '1971 жылы 15 тамызда президент Никсон жексенбілік үндеуінде долларды алтынға '
          'айырбастауды «уақытша» тоқтатты («Никсон шогы»). Бұл «уақытша» 50 жылдан асты. '
          'Сол күннен бері әлемде бірде-бір валюта алтынмен қамтамасыз етілмейді — бәріміз таза '
          'фиат дәуірінде өмір сүреміз.',
          'On 15 August 1971, in a Sunday TV address, President Nixon "temporarily" ended the '
          'dollar\'s convertibility into gold (the "Nixon Shock"). That "temporarily" has lasted '
          'over 50 years. Since that day no currency on earth is backed by gold — we all live in '
          'the era of pure fiat.',
        )),
        _rule(_L(
          'Ликвидность — это лёгкость, с которой актив превращается в деньги без потери цены. '
          'Наличные абсолютно ликвидны. Квартиру можно продать за месяцы и с торгом — она '
          'неликвидна. Рынки живут и дышат ликвидностью: когда центробанки её добавляют — '
          'цены активов растут; когда изымают — случаются обвалы.',
          'Өтімділік — активтің бағасын жоғалтпай ақшаға айналу жеңілдігі. Қолма-қол ақша '
          'толық өтімді. Пәтерді айлап, сауда жасап сатуға болады — ол өтімсіз. Нарықтар '
          'өтімділікпен тыныстайды: орталық банктер оны қосқанда — актив бағасы өседі; алып '
          'тастағанда — құлдыраулар болады.',
          'Liquidity is the ease with which an asset turns into money without losing price. Cash '
          'is perfectly liquid. A flat takes months to sell and with haggling — it is illiquid. '
          'Markets live and breathe liquidity: when central banks add it, asset prices rise; when '
          'they drain it, crashes happen.'),
          title: _L('Что такое ликвидность', 'Өтімділік дегеніміз не', 'What liquidity is'),
        ),
        _story(_L(
          'Веймарская Германия, 1923 год. Чтобы платить репарации после Первой мировой, '
          'правительство включило печатный станок. Инфляция достигла такого уровня, что цены '
          'удваивались каждые ~2 дня. Люди получали зарплату дважды в день и бежали тратить её '
          'немедленно. Банкнотами топили печи — это было дешевле, чем покупать дрова. '
          'Дети строили из пачек денег домики. В Зимбабве в 2008 году напечатали купюру в '
          '100 триллионов долларов. Так вера в фиат превращается в пыль.',
          'Веймар Германиясы, 1923 жыл. Бірінші дүниежүзілік соғыстан кейінгі репарацияны '
          'төлеу үшін үкімет баспа станогын қосты. Инфляция сонша өсті — бағалар әр ~2 күнде '
          'екі еселенді. Адамдар жалақыны күніне екі рет алып, бірден жұмсауға жүгірді. '
          'Банкноттармен пеш жақты — отын сатып алғаннан арзан болды. Балалар ақша бумаларынан '
          'үй құрды. Зимбабведе 2008 жылы 100 триллион долларлық купюра басылды. Фиатқа деген '
          'сенім осылай шаңға айналады.',
          'Weimar Germany, 1923. To pay First World War reparations, the government fired up the '
          'printing press. Inflation reached a level where prices doubled roughly every 2 days. '
          'People were paid twice a day and rushed to spend it immediately. They burned banknotes '
          'for heat — cheaper than buying firewood. Children built toy houses out of stacks of '
          'cash. In Zimbabwe in 2008 a 100-trillion-dollar note was printed. That is how faith in '
          'fiat turns to dust.'),
          title: _L('Когда деньги стали мусором', 'Ақша қоқысқа айналғанда', 'When money became trash'),
        ),
        _interactive('emission', title: 'Симулятор «Эмиссия»'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Чем обеспечены современные фиатные деньги (например, доллар)?',
          'Қазіргі фиат ақша (мысалы, доллар) немен қамтамасыз етілген?',
          'What backs modern fiat money (for example, the dollar)?',
        ),
        options: [
          _L('Золотым запасом страны', 'Елдің алтын қорымен', 'The country\'s gold reserves'),
          _L('Доверием к государству и его экономике', 'Мемлекетке және оның экономикасына деген сеніммен', 'Trust in the state and its economy'),
          _L('Запасами нефти', 'Мұнай қорымен', 'Oil reserves'),
          _L('Серебром в центральном банке', 'Орталық банктегі күміспен', 'Silver in the central bank'),
        ],
        correctIndex: 1,
        explanation: _L(
          'С 1971 года (Никсоновский шок, отмена золотого стандарта) фиатные деньги не '
          'обеспечены физическим активом — только доверием к эмитенту. Поэтому чрезмерная '
          'эмиссия разрушает их покупательную способность.',
          '1971 жылдан бері (Никсон шогы, алтын стандартының жойылуы) фиат ақша физикалық '
          'активпен емес, тек эмитентке деген сеніммен қамтамасыз етіледі. Сондықтан шектен тыс '
          'эмиссия оның сатып алу қабілетін бұзады.',
          'Since 1971 (the Nixon Shock, the end of the gold standard) fiat money is not backed by '
          'a physical asset — only by trust in the issuer. That is why excessive issuance destroys '
          'its purchasing power.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l1_2',
      code: '1.2',
      title: 'Долларовая гегемония: почему USD сильнее всех при гигантском госдолге?',
      blocks: [
        _essence(_L(
          'США должны больше \$34 триллионов, печатают деньги десятилетиями — но доллар '
          'остаётся королём. Парадокс? Нет. Доллар — мировая резервная валюта: в нём торгуют '
          'нефтью, хранят золотовалютные резервы и заключают международные контракты. '
          'Глобальный спрос на доллар позволяет США экспортировать собственную инфляцию '
          'всему миру — это называют «непомерной привилегией».',
          'АҚШ \$34 триллионнан астам қарыз, ондаған жыл ақша басып шығарады — бірақ доллар '
          'король болып қалады. Парадокс па? Жоқ. Доллар — әлемдік резервтік валюта: онымен '
          'мұнай саудаланады, алтын-валюта резерві сақталады, халықаралық келісімдер жасалады. '
          'Долларға деген жаһандық сұраныс АҚШ-қа өз инфляциясын бүкіл әлемге экспорттауға '
          'мүмкіндік береді — мұны «шектен тыс артықшылық» дейді.',
          'The US owes over \$34 trillion and has printed money for decades — yet the dollar '
          'stays king. A paradox? No. The dollar is the world reserve currency: oil is traded in '
          'it, reserves are held in it, international contracts are signed in it. Global demand for '
          'dollars lets the US export its own inflation to the whole world — this is called the '
          '"exorbitant privilege".',
        )),
        _h(_L('Как доллар захватил мир', 'Доллар әлемді қалай жаулады', 'How the dollar conquered the world')),
        _p(_L(
          'Бреттон-Вудс (1944): пока в Европе ещё шла война, 44 страны договорились привязать '
          'свои валюты к доллару, а доллар — к золоту. США тогда владели ~70% мирового золота, '
          'так что выбор был логичным.',
          'Бреттон-Вудс (1944): Еуропада әлі соғыс жүріп жатқанда, 44 ел өз валюталарын долларға, '
          'ал долларды алтынға байлауға келісті. АҚШ сол кезде әлемдік алтынның ~70%-ына ие еді, '
          'сондықтан таңдау қисынды болды.',
          'Bretton Woods (1944): while war still raged in Europe, 44 countries agreed to peg their '
          'currencies to the dollar, and the dollar to gold. The US then held ~70% of the world\'s '
          'gold, so the choice was logical.',
        )),
        _p(_L(
          'Ямайская система (1976): после Никсоновского шока золотую привязку официально '
          'похоронили. Валюты стали «плавающими» — их курс определяет рынок.',
          'Ямайка жүйесі (1976): Никсон шогынан кейін алтын байламы ресми түрде жерленді. '
          'Валюталар «жүзбелі» болды — олардың бағамын нарық анықтайды.',
          'The Jamaica system (1976): after the Nixon Shock the gold peg was officially buried. '
          'Currencies became "floating" — their rate is set by the market.',
        )),
        _p(_L(
          'Нефтедоллар (1970-е): США договорились с Саудовской Аравией, что нефть будет '
          'продаваться только за доллары, а нефтедоллары будут вкладываться в гособлигации '
          'США. Это создало вечный мировой спрос на доллар: нужна нефть — нужны доллары.',
          'Мұнайдоллар (1970-ші): АҚШ Сауд Арабиясымен мұнайды тек долларға сату және '
          'мұнайдолларды АҚШ облигацияларына салу туралы келісті. Бұл долларға мәңгілік жаһандық '
          'сұраныс тудырды: мұнай керек — доллар керек.',
          'The petrodollar (1970s): the US agreed with Saudi Arabia that oil would be sold only '
          'for dollars, and petrodollars would be invested in US Treasuries. This created eternal '
          'global demand for the dollar: need oil — need dollars.',
        )),
        _fact(_L(
          'Около 60% всех мировых валютных резервов и ~88% всех валютных сделок в мире '
          'приходятся на доллар, хотя экономика США — лишь ~25% мирового ВВП. Доллар '
          'непропорционально доминирует именно из-за статуса резервной валюты.',
          'Әлемдік валюта резервтерінің шамамен 60%-ы және барлық валюта мәмілелерінің ~88%-ы '
          'долларға тиесілі, ал АҚШ экономикасы — әлемдік ЖІӨ-нің тек ~25%-ы. Доллар дәл резервтік '
          'валюта мәртебесінің арқасында пропорциясыз үстемдік етеді.',
          'About 60% of all global currency reserves and ~88% of all FX transactions are in '
          'dollars, although the US economy is only ~25% of world GDP. The dollar dominates '
          'disproportionately precisely because of its reserve-currency status.',
        )),
        _rule(_L(
          'DXY (индекс доллара) — главный барометр трейдера золота. Это сила доллара против '
          'корзины из 6 валют (евро ~58%, иена, фунт, канадский доллар, крона, франк). '
          'Для золота работает устойчивая обратная корреляция: золото номинировано в долларах, '
          'и когда доллар дорожает, золото в долларах дешевеет.',
          'DXY (доллар индексі) — алтын трейдерінің басты барометрі. Бұл доллардың 6 валюта '
          'себетіне (еуро ~58%, иена, фунт, канада доллары, крона, франк) қарсы күші. Алтын үшін '
          'тұрақты кері корреляция жұмыс істейді: алтын доллармен бағаланады, доллар қымбаттаса, '
          'алтын долларда арзандайды.',
          'DXY (the dollar index) is the gold trader\'s main barometer. It is the dollar\'s '
          'strength against a basket of 6 currencies (euro ~58%, yen, pound, Canadian dollar, '
          'krona, franc). A stable inverse correlation works for gold: gold is priced in dollars, '
          'so when the dollar rises, gold in dollars gets cheaper.'),
          title: _L('Индекс доллара DXY', 'Доллар индексі DXY', 'The dollar index DXY'),
        ),
        _example(_L(
          'Парадокс «тихой гавани»: в кризис 2008 года эпицентром был именно американский '
          'ипотечный рынок — но инвесторы со всего мира побежали... в доллар и гособлигации '
          'США. Почему? Потому что в момент паники все ищут самый ликвидный и «безопасный» '
          'актив, а это по-прежнему доллар. Кризис в США → доллар укрепляется. Абсурд, но факт.',
          '«Тыныш айлақ» парадоксы: 2008 дағдарысының эпицентрі дәл американдық ипотека нарығы '
          'болды — бірақ бүкіл әлем инвесторлары... долларға және АҚШ облигацияларына жүгірді. '
          'Неге? Өйткені дүрбелең сәтінде бәрі ең өтімді әрі «қауіпсіз» активті іздейді, ол әлі де '
          'доллар. АҚШ-тағы дағдарыс → доллар нығаяды. Абсурд, бірақ шындық.',
          'The "safe haven" paradox: in the 2008 crisis the epicentre was the American mortgage '
          'market itself — yet investors worldwide ran... into the dollar and US Treasuries. Why? '
          'Because in a panic everyone seeks the most liquid and "safe" asset, and that is still '
          'the dollar. A crisis in the US → the dollar strengthens. Absurd, but a fact.',
        )),
        _interactive('dxy', title: 'Интерактив: обратная корреляция DXY'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'DXY (индекс доллара) резко пошёл вверх. Что вероятнее всего с золотом?',
          'DXY (доллар индексі) күрт өсті. Алтынмен не болуы ықтимал?',
          'DXY (the dollar index) jumped sharply. What is most likely for gold?',
        ),
        options: [
          _L('Золото тоже растёт вместе с долларом', 'Алтын да доллармен бірге өседі', 'Gold rises together with the dollar'),
          _L('Золото обычно падает (обратная корреляция)', 'Алтын әдетте түседі (кері корреляция)', 'Gold usually falls (inverse correlation)'),
          _L('Золото не реагирует на DXY', 'Алтын DXY-ге реакция бермейді', 'Gold does not react to DXY'),
          _L('Золото всегда повторяет движение DXY', 'Алтын әрдайым DXY қозғалысын қайталайды', 'Gold always mirrors DXY'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Золото номинировано в долларах. Сильный доллар делает золото дороже для остального '
          'мира и снижает спрос → цена падает. DXY вверх → золото вниз, и наоборот.',
          'Алтын доллармен бағаланады. Күшті доллар алтынды басқа әлем үшін қымбаттатып, '
          'сұранысты азайтады → баға түседі. DXY жоғары → алтын төмен, керісінше де.',
          'Gold is priced in dollars. A strong dollar makes gold more expensive for the rest of '
          'the world and lowers demand → the price falls. DXY up → gold down, and vice versa.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l1_3',
      code: '1.3',
      title: 'Анатомия бирж и механика ликвидности: где крупный игрок оставляет следы?',
      blocks: [
        _essence(_L(
          'Цена двигается не «сама по себе» и не из-за линий на графике. Она двигается, когда '
          'кто-то агрессивно забирает ликвидность из стакана заявок (order book). Понять, как '
          'устроена эта «кухня», — значит перестать верить в магию и увидеть реальные потоки '
          'денег.',
          'Баға «өздігінен» немесе графиктегі сызықтардан қозғалмайды. Ол біреу өтінім '
          'кітабынан (order book) өтімділікті агрессивті алғанда қозғалады. Бұл «асхананың» '
          'қалай жұмыс істейтінін түсіну — сиқырға сенуді қойып, нақты ақша ағынын көру дегенді '
          'білдіреді.',
          'Price does not move "on its own" or because of lines on a chart. It moves when someone '
          'aggressively takes liquidity out of the order book. Understanding how this "kitchen" '
          'works means dropping belief in magic and seeing the real flows of money.',
        )),
        _h(_L('Где торгуется золото', 'Алтын қайда саудаланады', 'Where gold is traded')),
        _p(_L(
          'Спотовый рынок (LBMA в Лондоне) — поставка золота «здесь и сейчас». Фьючерсы '
          '(COMEX/CME в США) — контракты на поставку в будущем; именно фьючерсы во многом '
          'формируют ту цену XAU/USD, которую ты видишь в терминале.',
          'Спот нарық (Лондондағы LBMA) — алтынды «осында әрі қазір» жеткізу. Фьючерстер '
          '(АҚШ-тағы COMEX/CME) — болашақта жеткізу келісімдері; терминалда көретін XAU/USD '
          'бағасын көбіне дәл фьючерстер қалыптастырады.',
          'The spot market (LBMA in London) is delivery of gold "here and now". Futures '
          '(COMEX/CME in the US) are contracts for future delivery; it is largely futures that '
          'shape the XAU/USD price you see in the terminal.',
        )),
        _p(_L(
          'Розничный трейдер торгует через брокера CFD — контракт на разницу цен, без реальной '
          'поставки металла. Важно понимать: твой ордер сначала проходит через брокера и '
          'провайдера ликвидности, прежде чем повлиять на «настоящий» рынок.',
          'Жеке трейдер CFD брокері арқылы саудалайды — металды нақты жеткізусіз, баға '
          'айырмасына келісім. Маңыздысы: сенің ордерің «нағыз» нарыққа әсер етпес бұрын алдымен '
          'брокер мен өтімділік провайдері арқылы өтеді.',
          'A retail trader trades through a CFD broker — a contract for difference, with no real '
          'delivery of metal. Important: your order first passes through the broker and a '
          'liquidity provider before it touches the "real" market.',
        )),
        _rule(_L(
          'Маркетмейкеры выставляют заявки на покупку (bid) и продажу (ask) одновременно, '
          'обеспечивая ликвидность и зарабатывая на спреде. Когда стакан «толстый» (много '
          'заявок), цена двигается плавно. Когда стакан «тонкий» (заявок мало — например, '
          'ночью или перед новостью), даже средний ордер двигает цену резко. Отсюда импульсы '
          'и проскальзывание (slippage).',
          'Маркетмейкерлер сатып алу (bid) және сату (ask) өтінімдерін қатар қойып, өтімділік '
          'қамтамасыз етеді әрі спредтен табады. Стакан «қалың» болса (өтінім көп) — баға тегіс '
          'қозғалады. Стакан «жұқа» болса (өтінім аз — мысалы, түнде немесе жаңалық алдында) — '
          'орташа ордер де бағаны күрт жылжытады. Импульстер мен сырғу (slippage) осыдан.',
          'Market makers post buy (bid) and sell (ask) orders at the same time, providing '
          'liquidity and earning on the spread. When the book is "thick" (many orders) price moves '
          'smoothly. When the book is "thin" (few orders — e.g. at night or before news), even a '
          'medium order moves price sharply. Hence impulses and slippage.'),
          title: _L('Маркетмейкеры и стакан', 'Маркетмейкерлер мен стакан', 'Market makers and the order book'),
        ),
        _story(_L(
          '6 мая 2010 года, «Flash Crash». В 14:42 по Нью-Йорку индекс Dow Jones за считанные '
          'минуты рухнул почти на 1000 пунктов (~9%) — около триллиона долларов капитализации '
          'испарилось. Причина: крупный алгоритм начал агрессивно продавать фьючерсы на пустеющем '
          'стакане, высокочастотные роботы подхватили каскад. Акции Accenture на мгновение стоили '
          '1 цент, а Apple — \$100 000. Через ~20 минут рынок почти полностью отскочил. Урок: '
          'ликвидность исчезает мгновенно, и в этот момент цена делает что угодно.',
          '2010 жылы 6 мамыр, «Flash Crash». Нью-Йорк уақытымен 14:42-де Dow Jones индексі '
          'санаулы минутта 1000 пунктке (~9%) дерлік құлады — шамамен триллион доллар '
          'капитализация буланып кетті. Себебі: ірі алгоритм бостап бара жатқан стаканда '
          'фьючерстерді агрессивті сата бастады, жоғары жиілікті роботтар каскадты іліп әкетті. '
          'Accenture акциясы бір сәтте 1 цент, ал Apple — \$100 000 тұрды. ~20 минуттан кейін '
          'нарық толық дерлік қалпына келді. Сабақ: өтімділік лезде жоғалады, сол сәтте баға '
          'кез келген нәрсе жасайды.',
          'On 6 May 2010, the "Flash Crash". At 14:42 New York time the Dow Jones fell almost '
          '1000 points (~9%) in mere minutes — about a trillion dollars of market cap evaporated. '
          'The cause: a large algorithm began aggressively selling futures into an emptying book, '
          'and high-frequency robots picked up the cascade. Accenture shares momentarily cost 1 '
          'cent, and Apple — \$100,000. About 20 minutes later the market almost fully bounced '
          'back. The lesson: liquidity vanishes instantly, and at that moment price does anything.'),
          title: _L('Триллион долларов за 5 минут', 'Бес минутта триллион доллар', 'A trillion dollars in 5 minutes'),
        ),
        _fact(_L(
          'Более 70% объёма торгов на американских биржах генерируют не люди, а '
          'высокочастотные алгоритмы (HFT). Некоторые из них держат позицию микросекунды. '
          'Фирмы платят миллионы, чтобы поставить сервер физически ближе к бирже — выигрыш '
          'в наносекундах света по кабелю реально приносит деньги.',
          'Американдық биржалардағы сауда көлемінің 70%-дан астамын адамдар емес, жоғары '
          'жиілікті алгоритмдер (HFT) жасайды. Кейбірі позицияны микросекунд ұстайды. Фирмалар '
          'серверді биржаға физикалық жақын қою үшін миллиондар төлейді — кабельмен жарық '
          'наносекундындағы ұтыс шынымен ақша әкеледі.',
          'Over 70% of trading volume on US exchanges is generated not by people but by '
          'high-frequency algorithms (HFT). Some hold a position for microseconds. Firms pay '
          'millions to place a server physically closer to the exchange — the edge of nanoseconds '
          'of light down a cable really makes money.',
        )),
        _interactive('orderbook', title: 'Симулятор биржевого стакана (Order Book)'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Почему крупный ордер на «тонком» стакане вызывает резкий скачок цены?',
          'Неге «жұқа» стакандағы ірі ордер бағаны күрт секіртеді?',
          'Why does a large order on a "thin" book cause a sharp price jump?',
        ),
        options: [
          _L('Биржа специально наказывает крупных игроков', 'Биржа ірі ойыншыларды әдейі жазалайды', 'The exchange deliberately punishes big players'),
          _L('Не хватает встречной ликвидности, ордер «съедает» дальние уровни', 'Қарсы өтімділік жетпейді, ордер алыс деңгейлерді «жейді»', 'There is not enough opposing liquidity; the order "eats" far levels'),
          _L('Цена меняется случайно, без причины', 'Баға себепсіз, кездейсоқ өзгереді', 'Price changes randomly, without cause'),
          _L('Маркетмейкеры повышают комиссию', 'Маркетмейкерлер комиссияны көтереді', 'Market makers raise the commission'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Если в стакане мало встречных заявок, крупный рыночный ордер исполняется по всё '
          'более далёким ценам (проскальзывание), резко двигая котировку. Это и есть импульс.',
          'Стаканда қарсы өтінім аз болса, ірі нарықтық ордер барған сайын алыс бағалармен '
          'орындалады (сырғу), котировканы күрт жылжытады. Бұл — нақ импульс.',
          'If there are few opposing orders in the book, a large market order fills at ever more '
          'distant prices (slippage), sharply moving the quote. That is exactly an impulse.',
        ),
      ),
    ),
  ],
);

// ════════════════════════════════════════════════════════════════════
// МОДУЛЬ 2. Секретный код новостей
// ════════════════════════════════════════════════════════════════════
CourseModule _module2() => CourseModule(
  id: 'm2',
  index: 2,
  title: 'Секретный код новостей: как читать календарь и торговать отчёты',
  goal:
      'Перестать бояться красных новостей в календаре и понимать, какие цифры вызовут '
      'импульс и как на этом заработать.',
  lessons: [
    CourseLesson(
      id: 'l2_1',
      code: '2.1',
      title: 'CPI и PPI: главное оружие против инфляции',
      blocks: [
        _essence(_L(
          'CPI (индекс потребительских цен) — это инфляция глазами обычного покупателя: '
          'насколько подорожала корзина из еды, бензина, аренды и услуг. PPI (индекс цен '
          'производителей) — оптовая инфляция на уровне заводов; он опережает CPI, потому что '
          'рост цен сначала бьёт по производителям, а потом доходит до полок магазинов.',
          'CPI (тұтыну бағасы индексі) — қарапайым сатып алушының көзімен инфляция: тамақ, '
          'бензин, жалдау, қызмет себеті қаншаға қымбаттады. PPI (өндіруші бағасы индексі) — '
          'зауыт деңгейіндегі көтерме инфляция; ол CPI-ден озады, өйткені баға өсімі алдымен '
          'өндірушілерге тиіп, сосын дүкен сөресіне жетеді.',
          'CPI (the Consumer Price Index) is inflation through the eyes of an ordinary buyer: '
          'how much a basket of food, fuel, rent and services has risen. PPI (the Producer Price '
          'Index) is wholesale inflation at the factory level; it leads CPI, because price rises '
          'hit producers first and only later reach the shop shelves.',
        )),
        _h(_L('Почему рынок сходит с ума от двух цифр', 'Неге нарық екі саннан есінен танады', 'Why the market goes crazy over two numbers')),
        _p(_L(
          'У ФРС (центробанка США) есть мандат: держать инфляцию около 2%. Когда CPI выше — '
          'ФРС вынуждена «остужать» экономику высокой ставкой. Когда ниже — может смягчать '
          'политику. Поэтому каждый выход CPI — это, по сути, голосование о том, что сделает '
          'ФРС, а значит, куда пойдут доллар, золото и акции.',
          'ФРЖ-нің (АҚШ орталық банкі) мандаты бар: инфляцияны ~2% ұстау. CPI жоғары болса — '
          'ФРЖ экономиканы жоғары ставкамен «суытуға» мәжбүр. Төмен болса — саясатты жұмсарта '
          'алады. Сондықтан әрбір CPI шығуы — мәні бойынша ФРЖ не істейтіні туралы дауыс, демек '
          'доллар, алтын және акциялар қайда баратыны.',
          'The Fed (the US central bank) has a mandate: keep inflation near 2%. When CPI is '
          'higher, the Fed must "cool" the economy with a high rate. When lower, it can ease. So '
          'every CPI release is essentially a vote on what the Fed will do — and therefore where '
          'the dollar, gold and stocks will go.',
        )),
        _rule(_L(
          'Рынок торгует НЕ саму цифру, а её ОТКЛОНЕНИЕ от прогноза (Forecast/Consensus). '
          'Ожидания уже «вшиты» в цену заранее. Двигает рынок именно сюрприз: насколько факт '
          'разошёлся с тем, что все ждали.',
          'Нарық санның ӨЗІН емес, оның болжамнан (Forecast/Consensus) АУЫТҚУЫН саудалайды. '
          'Күтулер бағаға алдын ала «тігілген». Нарықты дәл сюрприз қозғайды: факт күткеннен '
          'қаншалық алшақтады.',
          'The market trades NOT the number itself, but its DEVIATION from the forecast '
          '(consensus). Expectations are already "priced in" beforehand. What moves the market is '
          'the surprise: how far the actual diverged from what everyone expected.'),
          title: _L('Главный принцип новостной торговли', 'Жаңалық саудасының басты қағидасы', 'The core principle of news trading'),
        ),
        _formula(_Lf(
          [
            'CPI/PPI ВЫШЕ прогноза (Actual > Forecast):',
            '  инфляция горячее ожиданий → ФРС жёстче →',
            '  доллар (DXY) ↑ → золото (XAUUSD) ↓',
            '',
            'CPI/PPI НИЖЕ прогноза (Actual < Forecast):',
            '  инфляция остывает → ФРС мягче →',
            '  доллар ↓ → золото ↑',
          ],
          [
            'CPI/PPI болжамнан ЖОҒАРЫ (Actual > Forecast):',
            '  инфляция күткеннен ыстық → ФРЖ қатаңырақ →',
            '  доллар (DXY) ↑ → алтын (XAUUSD) ↓',
            '',
            'CPI/PPI болжамнан ТӨМЕН (Actual < Forecast):',
            '  инфляция суынады → ФРЖ жұмсағырақ →',
            '  доллар ↓ → алтын ↑',
          ],
          [
            'CPI/PPI ABOVE forecast (Actual > Forecast):',
            '  inflation hotter than expected → Fed tighter →',
            '  dollar (DXY) ↑ → gold (XAUUSD) ↓',
            '',
            'CPI/PPI BELOW forecast (Actual < Forecast):',
            '  inflation cooling → Fed softer →',
            '  dollar ↓ → gold ↑',
          ],
        ), title: _L('Формула реакции', 'Реакция формуласы', 'Reaction formula')),
        _fact(_L(
          'Существует «Core CPI» (базовый) — без еды и энергии. Кажется странным выкидывать '
          'самое важное, но именно еда и бензин самые волатильные, и ФРС больше смотрит на '
          'базовый индекс, чтобы видеть устойчивый тренд инфляции. Профи следят за Core CPI '
          'даже внимательнее, чем за общим.',
          '«Core CPI» (базалық) бар — тамақ пен энергиясыз. Ең маңыздыны алып тастау оғаш '
          'көрінеді, бірақ дәл тамақ пен бензин ең құбылмалы, ал ФРЖ инфляцияның тұрақты '
          'трендін көру үшін базалық индекске көбірек қарайды. Кәсіпқойлар Core CPI-ді жалпыдан '
          'да мұқият бақылайды.',
          'There is "Core CPI" (the core index) — excluding food and energy. It seems odd to '
          'throw out the most important items, but food and fuel are the most volatile, and the '
          'Fed looks more at the core index to see the steady inflation trend. Pros watch Core CPI '
          'even more closely than the headline.',
        )),
        _story(_L(
          'Реальный день: выходит CPI, отклонение от прогноза всего на 0.2 процентного пункта. '
          'Казалось бы, мелочь. Но золото за 5 минут пролетело ~400 пунктов, выбив стопы у тех, '
          'кто стоял против. Эти 0.2% перевернули ожидания рынка по будущей ставке ФРС — и этого '
          'хватило для лавины.',
          'Нақты күн: CPI шығады, болжамнан ауытқу небәрі 0.2 пайыздық тармақ. Болмашы көрінеді. '
          'Бірақ алтын 5 минутта ~400 пункт ұшып, қарсы тұрғандардың стоптарын ұшырды. Осы 0.2% '
          'ФРЖ-нің болашақ ставкасы бойынша нарық күтулерін аударып тастады — лавинаға осы жетті.',
          'A real day: CPI comes out, the deviation from forecast is just 0.2 percentage points. '
          'Seems trivial. But gold flew ~400 points in 5 minutes, taking out the stops of those on '
          'the wrong side. Those 0.2% flipped the market\'s expectations for the Fed\'s future '
          'rate — and that was enough for an avalanche.',
        )),
        _interactive('cpi_trainer', title: 'Тренажёр календаря: CPI'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'CPI вышел ВЫШЕ прогноза. Какая реакция наиболее вероятна?',
          'CPI болжамнан ЖОҒАРЫ шықты. Қандай реакция ықтимал?',
          'CPI came out ABOVE forecast. What is the most likely reaction?',
        ),
        options: [
          _L('Доллар падает, золото растёт', 'Доллар түседі, алтын өседі', 'Dollar falls, gold rises'),
          _L('Доллар растёт, золото падает', 'Доллар өседі, алтын түседі', 'Dollar rises, gold falls'),
          _L('Реакции не будет', 'Реакция болмайды', 'There will be no reaction'),
          _L('Растут и доллар, и золото', 'Доллар да, алтын да өседі', 'Both dollar and gold rise'),
        ],
        correctIndex: 1,
        explanation: _L(
          'CPI выше прогноза = инфляция выше ожиданий → ФРС склонна держать/повышать ставку → '
          'доллар укрепляется → золото дешевеет.',
          'CPI болжамнан жоғары = инфляция күткеннен жоғары → ФРЖ ставканы ұстауға/көтеруге '
          'бейім → доллар нығаяды → алтын арзандайды.',
          'CPI above forecast = inflation above expectations → the Fed leans to hold/raise the '
          'rate → the dollar strengthens → gold gets cheaper.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l2_2',
      code: '2.2',
      title: 'Non-Farm Payrolls (NFP) и безработица: пульс рынка труда США',
      blocks: [
        _essence(_L(
          'NFP — количество новых рабочих мест вне сельского хозяйства за месяц. Вместе с '
          'уровнем безработицы это пульс американской экономики. Сильный рынок труда '
          '«развязывает руки» ФРС: можно держать ставку высокой, не боясь спровоцировать '
          'рецессию.',
          'NFP — айына ауыл шаруашылығынан тыс жаңа жұмыс орындарының саны. Жұмыссыздық '
          'деңгейімен бірге бұл американ экономикасының тамыры. Күшті еңбек нарығы ФРЖ-нің '
          '«қолын босатады»: рецессиядан қорықпай ставканы жоғары ұстауға болады.',
          'NFP is the number of new non-farm jobs per month. Together with the unemployment rate '
          'it is the pulse of the US economy. A strong labour market "unties the Fed\'s hands": it '
          'can keep the rate high without fearing a recession.',
        )),
        _h(_L('Почему именно первая пятница месяца', 'Неге дәл айдың бірінші жұмасы', 'Why the first Friday of the month')),
        _p(_L(
          'NFP выходит в первую пятницу каждого месяца в 15:30 по времени Астаны (8:30 EST). '
          'Это, пожалуй, самая ожидаемая регулярная новость на рынке. Перед ней объёмы часто '
          'замирают — крупные игроки ждут цифру, чтобы не попасть под случайный импульс.',
          'NFP әр айдың бірінші жұмасында Астана уақытымен 15:30-да (8:30 EST) шығады. Бұл, '
          'бәлкім, нарықтағы ең күтілетін тұрақты жаңалық. Оның алдында көлемдер жиі қатып '
          'қалады — ірі ойыншылар кездейсоқ импульске түспеу үшін санды күтеді.',
          'NFP comes out on the first Friday of each month at 15:30 Astana time (8:30 EST). It is '
          'arguably the most anticipated regular news on the market. Before it volumes often '
          'freeze — big players wait for the number so as not to be caught by a random impulse.',
        )),
        _formula(_Lf(
          [
            'Сильный NFP (Actual > Forecast) + низкая безработица:',
            '  экономика сильная → ФРС жёстче → доллар ↑ → золото ↓',
            '',
            'Слабый NFP (Actual < Forecast) + рост безработицы:',
            '  риск рецессии → ФРС мягче → доллар ↓ → золото ↑',
          ],
          [
            'Күшті NFP (Actual > Forecast) + төмен жұмыссыздық:',
            '  экономика күшті → ФРЖ қатаңырақ → доллар ↑ → алтын ↓',
            '',
            'Әлсіз NFP (Actual < Forecast) + жұмыссыздық өсімі:',
            '  рецессия қаупі → ФРЖ жұмсағырақ → доллар ↓ → алтын ↑',
          ],
          [
            'Strong NFP (Actual > Forecast) + low unemployment:',
            '  strong economy → Fed tighter → dollar ↑ → gold ↓',
            '',
            'Weak NFP (Actual < Forecast) + rising unemployment:',
            '  recession risk → Fed softer → dollar ↓ → gold ↑',
          ],
        ), title: _L('Формула реакции', 'Реакция формуласы', 'Reaction formula')),
        _warn(_L(
          'Первая пятница — это «вертолёты»: в первые секунды цена дёргается в обе стороны, '
          'спред расширяется, стопы выбивает в обоих направлениях. Новичкам входить в момент '
          'выхода NFP — почти гарантированный способ потерять деньги. Профи либо ждут, пока '
          'осядет пыль (15–30 минут), либо вообще не торгуют этот момент.',
          'Бірінші жұма — «тікұшақтар»: алғашқы секундтарда баға екі жаққа жұлқынады, спред '
          'кеңейеді, стоптар екі бағытта да ұшады. Жаңадан бастаушыға NFP шыққан сәтте кіру — '
          'ақша жоғалтудың кепілді жолы. Кәсіпқойлар не шаң басылғанша (15–30 мин) күтеді, не '
          'бұл сәтте мүлде саудаламайды.',
          'The first Friday means "helicopters": in the first seconds price jerks both ways, the '
          'spread widens, stops are hit in both directions. For beginners, entering at the NFP '
          'release is an almost guaranteed way to lose money. Pros either wait for the dust to '
          'settle (15–30 min) or simply do not trade that moment.',
        )),
        _fact(_L(
          'NFP — это оценка по опросу ~120 000 компаний, и её ПОСТОЯННО пересматривают в '
          'следующие месяцы, иногда на сотни тысяч рабочих мест. То есть рынок бурно реагирует '
          'на цифру, которая через месяц может оказаться совсем другой. Рынок торгует ожидания, '
          'а не истину.',
          'NFP — ~120 000 компанияны сұрау бойынша баға, оны келесі айларда ҮНЕМІ қайта '
          'қарайды, кейде жүздеген мың жұмыс орнына. Яғни нарық бір айдан кейін мүлде басқа '
          'болуы мүмкін санға қатты реакция береді. Нарық ақиқатты емес, күтулерді саудалайды.',
          'NFP is an estimate from a survey of ~120,000 companies, and it is CONSTANTLY revised '
          'in later months, sometimes by hundreds of thousands of jobs. So the market reacts '
          'violently to a number that may look completely different a month later. The market '
          'trades expectations, not the truth.',
        )),
        _example(_L(
          'Кейс «Двойной капкан»: NFP вышел сильным (+280k при прогнозе +180k), но уровень '
          'безработицы при этом ВЫРОС. Данные противоречат друг другу. Рынок сначала мечется, '
          'а затем выбирает ту цифру, на которой сейчас сфокусирована ФРС. Главный навык — '
          'не реагировать на один заголовок, а сопоставлять весь блок данных.',
          '«Қос қақпан» кейсі: NFP күшті шықты (+280k, болжам +180k), бірақ жұмыссыздық деңгейі '
          'сонымен қатар ӨСТІ. Деректер бір-біріне қайшы. Нарық алдымен сенделеді, сосын ФРЖ '
          'қазір назар аударған санды таңдайды. Басты дағды — бір тақырыпқа реакция беру емес, '
          'бүкіл дерек блогын салыстыру.',
          'The "double trap" case: NFP came out strong (+280k vs +180k expected), but the '
          'unemployment rate ALSO ROSE. The data contradict each other. The market first thrashes '
          'around, then picks the number the Fed is currently focused on. The key skill is not '
          'reacting to a single headline, but comparing the whole block of data.',
        )),
        _interactive('nfp_trap', title: 'Кейс «Двойной капкан»'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'NFP вышел слабым, безработица выросла. Что вероятнее с золотом?',
          'NFP әлсіз шықты, жұмыссыздық өсті. Алтынмен не ықтимал?',
          'NFP came out weak and unemployment rose. What is more likely for gold?',
        ),
        options: [
          _L('Золото падает', 'Алтын түседі', 'Gold falls'),
          _L('Золото растёт (риск рецессии → мягкая ФРС)', 'Алтын өседі (рецессия қаупі → жұмсақ ФРЖ)', 'Gold rises (recession risk → dovish Fed)'),
          _L('Золото не двигается', 'Алтын қозғалмайды', 'Gold does not move'),
          _L('Доллар укрепляется, золото растёт одновременно', 'Доллар нығаяды, алтын қатар өседі', 'The dollar strengthens and gold rises at the same time'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Слабый рынок труда = риск замедления экономики → ФРС склонна смягчать политику → '
          'доллар слабеет → золото растёт.',
          'Әлсіз еңбек нарығы = экономика баяулау қаупі → ФРЖ саясатты жұмсартуға бейім → '
          'доллар әлсірейді → алтын өседі.',
          'A weak labour market = risk of a slowing economy → the Fed leans to ease → the dollar '
          'weakens → gold rises.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l2_3',
      code: '2.3',
      title: 'Внутри головы Джерома Пауэлла: что делает ФРС при инфляции и дефляции?',
      blocks: [
        _essence(_L(
          'ФРС (Федеральная резервная система) — это центральный банк США и, по сути, '
          'дирижёр всех мировых рынков. У неё два главных рычага: процентная ставка и баланс '
          '(программы QE/QT). Понимать логику ФРС важнее, чем любой технический индикатор.',
          'ФРЖ (Федералды резервтік жүйе) — АҚШ орталық банкі әрі, мәні бойынша, бүкіл әлемдік '
          'нарықтардың дирижёры. Оның екі басты тұтқасы бар: пайыздық ставка және баланс '
          '(QE/QT бағдарламалары). ФРЖ логикасын түсіну кез келген техникалық индикатордан маңызды.',
          'The Fed (Federal Reserve System) is the US central bank and, in essence, the conductor '
          'of all world markets. It has two main levers: the interest rate and the balance sheet '
          '(QE/QT programs). Understanding the Fed\'s logic matters more than any technical indicator.',
        )),
        _h(_L('Два рычага власти', 'Биліктің екі тұтқасы', 'Two levers of power')),
        _p(_L(
          '1. Ставка (Fed Funds Rate) — цена денег. Повышают → кредиты дорожают → экономика '
          'остывает → инфляция падает. Снижают → деньги дешевеют → экономика разгоняется.',
          '1. Ставка (Fed Funds Rate) — ақшаның бағасы. Көтерсе → несие қымбаттайды → экономика '
          'суынады → инфляция түседі. Төмендетсе → ақша арзандайды → экономика жеделдейді.',
          '1. The rate (Fed Funds Rate) is the price of money. Raise it → credit gets dearer → the '
          'economy cools → inflation falls. Cut it → money gets cheaper → the economy accelerates.',
        )),
        _p(_L(
          '2. QE/QT — «печатный станок» против «пылесоса». QE (количественное смягчение): ФРС '
          'покупает облигации, вливая в систему свеженапечатанные деньги. QT (ужесточение): '
          'ФРС изымает ликвидность, сокращая баланс.',
          '2. QE/QT — «баспа станогы» мен «шаңсорғыш». QE (сандық жұмсарту): ФРЖ облигация '
          'сатып алып, жүйеге жаңа басылған ақша құяды. QT (қатаңдату): ФРЖ балансты қысқартып, '
          'өтімділікті алып тастайды.',
          '2. QE/QT — the "printing press" versus the "vacuum cleaner". QE (quantitative easing): '
          'the Fed buys bonds, pouring freshly printed money into the system. QT (tightening): the '
          'Fed drains liquidity by shrinking its balance sheet.',
        )),
        _rule(_L(
          '«Hawkish» (ястребиная) риторика = настрой на ужесточение (высокая ставка, QT) — '
          'плохо для золота. «Dovish» (голубиная) = настрой на смягчение (низкая ставка, QE) — '
          'хорошо для золота. Иногда сами СЛОВА Пауэлла на пресс-конференции двигают рынок '
          'сильнее, чем фактическое решение по ставке.',
          '«Hawkish» (қаршыға) риторикасы = қатаңдатуға бағыт (жоғары ставка, QT) — алтынға '
          'жаман. «Dovish» (көгершін) = жұмсартуға бағыт (төмен ставка, QE) — алтынға жақсы. '
          'Кейде Пауэллдің пресс-конференциядағы СӨЗДЕРІ нарықты нақты ставка шешімінен де '
          'қатты қозғайды.',
          '"Hawkish" rhetoric = a stance toward tightening (high rate, QT) — bad for gold. '
          '"Dovish" = a stance toward easing (low rate, QE) — good for gold. Sometimes Powell\'s '
          'WORDS at the press conference move the market more than the actual rate decision.'),
          title: _L('Ястребы и голуби', 'Қаршығалар мен көгершіндер', 'Hawks and doves'),
        ),
        _mechanic(_L(
          'Инфляция → ФРС включает «ястреба»: повышает ставку, изымает ликвидность (QT) → '
          'деньги дорожают → рынки падают, золото под давлением (т.к. растёт реальная доходность '
          'облигаций — конкурента золота).\n\n'
          'Дефляция/рецессия → ФРС включает «голубя»: снижает ставку к нулю, запускает '
          'печатный станок (QE) → система заливается дешёвыми деньгами → золото и акции взлетают.',
          'Инфляция → ФРЖ «қаршығаны» қосады: ставканы көтереді, өтімділікті алады (QT) → ақша '
          'қымбаттайды → нарықтар түседі, алтын қысымда (өйткені облигацияның — алтын бәсекелесінің '
          '— нақты табыстылығы өседі).\n\n'
          'Дефляция/рецессия → ФРЖ «көгершінді» қосады: ставканы нөлге түсіреді, баспа станогын '
          '(QE) іске қосады → жүйе арзан ақшаға толады → алтын мен акциялар ұшады.',
          'Inflation → the Fed turns on the "hawk": raises the rate, drains liquidity (QT) → money '
          'gets dearer → markets fall, gold is under pressure (because the real yield of bonds — '
          'gold\'s rival — rises).\n\n'
          'Deflation/recession → the Fed turns on the "dove": cuts the rate toward zero, fires up '
          'the printing press (QE) → the system floods with cheap money → gold and stocks soar.'),
          title: _L('Механика', 'Механика', 'The mechanics'),
        ),
        _story(_L(
          'Март 2020: пандемия, рынки в свободном падении. ФРС за считанные дни обрушила '
          'ставку до 0–0.25% и объявила QE «в неограниченном объёме» (unlimited QE). За '
          'несколько месяцев баланс ФРС вырос на триллионы. Итог: акции устроили мощнейшее '
          'ралли, а золото улетело к историческим максимумам выше \$2000 за унцию. Когда ФРС '
          'печатает — реальные активы дорожают.',
          '2020 наурыз: пандемия, нарықтар еркін құлдырауда. ФРЖ санаулы күнде ставканы '
          '0–0.25%-ке түсіріп, «шексіз» QE (unlimited QE) жариялады. Бірнеше айда ФРЖ балансы '
          'триллиондарға өсті. Нәтиже: акциялар қуатты ралли жасады, ал алтын унциясы \$2000-нан '
          'асып, тарихи шыңға ұшты. ФРЖ басып шығарғанда — нақты активтер қымбаттайды.',
          'March 2020: pandemic, markets in free fall. Within days the Fed slashed the rate to '
          '0–0.25% and announced "unlimited" QE. In a few months the Fed\'s balance sheet grew by '
          'trillions. The result: stocks staged a massive rally, and gold flew to record highs '
          'above \$2,000 per ounce. When the Fed prints, real assets get more expensive.'),
          title: _L('Базука 2020 года', '2020 жылғы базука', 'The 2020 bazooka'),
        ),
        _fact(_L(
          'Существует целая «индустрия» расшифровки слов ФРС. Аналитики считают, сколько раз '
          'Пауэлл сказал «инфляция» против «рост», и даже анализируют тон голоса. Есть термин '
          '«Fedspeak» — намеренно туманный язык, которым центробанкиры говорят так, чтобы '
          'ничего конкретно не пообещать и не обрушить рынки.',
          'ФРЖ сөздерін талдаудың тұтас «индустриясы» бар. Талдаушылар Пауэлл «инфляция» мен '
          '«өсу» сөздерін неше рет айтқанын санайды, тіпті дауыс ырғағын талдайды. «Fedspeak» '
          'деген термин бар — орталық банкирлер нақты ештеңе уәде етпей, нарықты құлатпай '
          'сөйлейтін әдейі бұлыңғыр тіл.',
          'There is a whole "industry" of decoding the Fed\'s words. Analysts count how many times '
          'Powell said "inflation" versus "growth" and even analyse his tone of voice. There is a '
          'term, "Fedspeak" — the deliberately vague language central bankers use to promise '
          'nothing specific and not crash the markets.',
        )),
        _interactive('fed_panel', title: 'Симуляция: ФРС, инфляция и золото'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Что означает «голубиная» (dovish) риторика ФРС?',
          'ФРЖ-нің «көгершін» (dovish) риторикасы нені білдіреді?',
          'What does "dovish" Fed rhetoric mean?',
        ),
        options: [
          _L('Повышение ставки и изъятие ликвидности', 'Ставканы көтеру және өтімділікті алу', 'Raising the rate and draining liquidity'),
          _L('Смягчение политики: низкая ставка, QE', 'Саясатты жұмсарту: төмен ставка, QE', 'Easing policy: low rate, QE'),
          _L('Отказ от любых действий', 'Кез келген әрекеттен бас тарту', 'Refusing to act at all'),
          _L('Запрет на торговлю золотом', 'Алтын саудасына тыйым', 'A ban on trading gold'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Dovish = мягкая политика: низкие ставки и вливание ликвидности (QE). Это обычно '
          'позитив для золота и рисковых активов. Hawkish — наоборот, ужесточение.',
          'Dovish = жұмсақ саясат: төмен ставка және өтімділік құю (QE). Бұл әдетте алтын мен '
          'тәуекелді активтерге оң. Hawkish — керісінше, қатаңдату.',
          'Dovish = soft policy: low rates and liquidity injection (QE). This is usually positive '
          'for gold and risk assets. Hawkish is the opposite — tightening.',
        ),
      ),
    ),
  ],
);

// ════════════════════════════════════════════════════════════════════
// МОДУЛЬ 3. Специфика XAUUSD
// ════════════════════════════════════════════════════════════════════
CourseModule _module3() => CourseModule(
  id: 'm3',
  index: 3,
  title: 'Специфика XAUUSD: золото как инструмент сохранения капитала',
  goal:
      'Понять внутреннюю кухню рынка золота: почему металл живёт по своим законам и как '
      'торговать его системно.',
  lessons: [
    CourseLesson(
      id: 'l3_1',
      code: '3.1',
      title: 'Почему золото — это «анти-доллар» и реальные деньги?',
      blocks: [
        _essence(_L(
          'Золото — это деньги, которые нельзя напечатать. За 5000 лет человечество добыло '
          'всего около 210 000 тонн золота — всё оно поместилось бы в куб со стороной ~22 метра '
          '(примерно три олимпийских бассейна). Эта физическая ограниченность делает золото '
          'вечной защитой от обесценивания бумажных валют.',
          'Алтын — басып шығаруға келмейтін ақша. 5000 жылда адамзат небәрі ~210 000 тонна '
          'алтын өндірді — оның бәрі қабырғасы ~22 метр текшеге сыяр еді (шамамен үш олимпиадалық '
          'бассейн). Осы физикалық шектеулілік алтынды қағаз валюта құнсыздануынан мәңгілік '
          'қорғанға айналдырады.',
          'Gold is money that cannot be printed. In 5,000 years humanity has mined only about '
          '210,000 tonnes of gold — all of it would fit in a cube ~22 metres on a side (about '
          'three Olympic pools). This physical scarcity makes gold an eternal hedge against the '
          'debasement of paper currencies.',
        )),
        _h(_L('Главный конкурент золота — облигации', 'Алтынның басты бәсекелесі — облигациялар', 'Gold\'s main rival — bonds')),
        _p(_L(
          'У золота есть «недостаток»: оно не платит процентов. Поэтому его главный соперник — '
          'гособлигации США (Treasuries), которые проценты платят. Выбор инвестора всегда '
          'между «бесполезным» золотом и облигацией с доходностью.',
          'Алтынның «кемшілігі» бар: ол пайыз төлемейді. Сондықтан оның басты қарсыласы — пайыз '
          'төлейтін АҚШ облигациялары (Treasuries). Инвестордың таңдауы әрдайым «пайдасыз» алтын '
          'мен табысы бар облигация арасында.',
          'Gold has a "flaw": it pays no interest. So its main rival is US government bonds '
          '(Treasuries), which do pay interest. An investor\'s choice is always between "useless" '
          'gold and a yielding bond.',
        )),
        _rule(_L(
          'Реальная доходность = доходность облигаций − инфляция.\n'
          'Когда реальная доходность РАСТЁТ → облигации привлекательнее (платят больше, чем '
          'съедает инфляция) → золото падает.\n'
          'Когда реальная доходность уходит в МИНУС (инфляция выше ставки) → держать облигации '
          'невыгодно → золото становится королём.',
          'Нақты табыстылық = облигация табыстылығы − инфляция.\n'
          'Нақты табыстылық ӨCКЕНДЕ → облигация тартымдырақ (инфляция жегеннен көп төлейді) → '
          'алтын түседі.\n'
          'Нақты табыстылық МИНУСҚА кеткенде (инфляция ставкадан жоғары) → облигация ұстау '
          'тиімсіз → алтын король болады.',
          'Real yield = bond yield − inflation.\n'
          'When real yield RISES → bonds are more attractive (they pay more than inflation eats) '
          '→ gold falls.\n'
          'When real yield goes NEGATIVE (inflation above the rate) → holding bonds is '
          'unprofitable → gold becomes king.'),
          title: _L('Железное правило золота', 'Алтынның темір ережесі', 'The iron rule of gold'),
        ),
        _fact(_L(
          'Золото настолько инертно и вечно, что почти всё когда-либо добытое золото '
          'существует до сих пор — в слитках, монетах, украшениях, зубах и электронике. '
          'Обручальное кольцо твоей бабушки может содержать атомы золота из Древнего Рима или '
          'из сокровищ инков. Золото не ржавеет и не разрушается.',
          'Алтын сонша инертті әрі мәңгілік — қашан да өндірілген алтынның бәрі дерлік әлі де '
          'бар: құймада, монетада, әшекейде, тісте, электроникада. Әжеңнің үйлену сақинасында '
          'Ежелгі Рим немесе инктер қазынасының алтын атомдары болуы мүмкін. Алтын тоттанбайды '
          'әрі бұзылмайды.',
          'Gold is so inert and eternal that almost all gold ever mined still exists — in bars, '
          'coins, jewellery, teeth and electronics. Your grandmother\'s wedding ring may contain '
          'gold atoms from Ancient Rome or from Inca treasures. Gold does not rust or decay.',
        )),
        _example(_L(
          'Геополитические шоки: при новостях о войнах, терактах, банковских кризисах золото '
          'взлетает за секунды, игнорируя любые технические уровни. В момент паники работает '
          'древний инстинкт: бежать в то, что было ценным тысячи лет. Ни один индикатор не '
          'предскажет геополитику — поэтому риск-менеджмент важнее прогноза.',
          'Геосаяси шоктар: соғыс, теракт, банк дағдарысы туралы жаңалықтарда алтын секундта '
          'ұшады, кез келген техникалық деңгейді елемей. Дүрбелең сәтінде ежелгі инстинкт жұмыс '
          'істейді: мыңжылдықтар бойы құнды болғанға қашу. Ешбір индикатор геосаясатты болжамайды '
          '— сондықтан тәуекел-менеджмент болжамнан маңызды.',
          'Geopolitical shocks: on news of wars, terror attacks or banking crises gold soars in '
          'seconds, ignoring any technical levels. In a panic an ancient instinct kicks in: run '
          'into what has been valuable for thousands of years. No indicator predicts geopolitics — '
          'which is why risk management matters more than forecasting.',
        )),
        _interactive('fear_greed', title: 'Индекс страха и жадности'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Реальная доходность гособлигаций США уходит глубоко в минус. Что с золотом?',
          'АҚШ облигацияларының нақты табыстылығы терең минусқа кетеді. Алтынмен не болады?',
          'The real yield of US Treasuries goes deeply negative. What happens to gold?',
        ),
        options: [
          _L('Золото падает — облигации привлекательнее', 'Алтын түседі — облигация тартымдырақ', 'Gold falls — bonds are more attractive'),
          _L('Золото растёт — у облигаций нет преимущества', 'Алтын өседі — облигацияның артықшылығы жоқ', 'Gold rises — bonds have no edge'),
          _L('Золото не реагирует', 'Алтын реакция бермейді', 'Gold does not react'),
          _L('Золото повторяет движение доходности', 'Алтын табыстылық қозғалысын қайталайды', 'Gold mirrors the yield'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Отрицательная реальная доходность означает, что облигации не защищают от инфляции. '
          'Тогда золото — лучший выбор для сохранения капитала, и оно растёт.',
          'Теріс нақты табыстылық облигация инфляциядан қорғамайтынын білдіреді. Сонда алтын — '
          'капиталды сақтаудың ең жақсы таңдауы әрі ол өседі.',
          'A negative real yield means bonds do not protect against inflation. Then gold is the '
          'best choice for preserving capital, and it rises.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l3_2',
      code: '3.2',
      title: 'Чёрное золото и жёлтое золото: как нефть влияет на рынки и золото?',
      blocks: [
        _essence(_L(
          'Нефть (WTI/Brent) — кровь мировой промышленности. Почти всё, что ты покупаешь, '
          'содержит в цене стоимость нефти: транспорт, пластик, удобрения, электричество. '
          'Поэтому цена нефти — это фундаментальный двигатель инфляции, а значит и золота.',
          'Мұнай (WTI/Brent) — әлемдік өнеркәсіптің қаны. Сатып алатын нәрсенің бәрі дерлік '
          'бағасында мұнай құнын ұстайды: көлік, пластик, тыңайтқыш, электр. Сондықтан мұнай '
          'бағасы — инфляцияның, демек алтынның да іргелі қозғаушысы.',
          'Oil (WTI/Brent) is the blood of global industry. Almost everything you buy carries the '
          'cost of oil in its price: transport, plastics, fertiliser, electricity. So the price of '
          'oil is a fundamental driver of inflation — and therefore of gold.',
        )),
        _h(_L('Межрыночный анализ', 'Нарықаралық талдау', 'Intermarket analysis')),
        _p(_L(
          'Профи смотрят не на один график, а на связи между рынками (intermarket analysis): '
          'нефть → инфляция → ставки → доллар → золото → акции. Всё переплетено, и сильное '
          'движение в одном активе расходится волнами по остальным.',
          'Кәсіпқойлар бір графикке емес, нарықтар арасындағы байланысқа қарайды (intermarket '
          'analysis): мұнай → инфляция → ставка → доллар → алтын → акция. Бәрі байланысты, бір '
          'активтегі күшті қозғалыс қалғандарына толқынмен тарайды.',
          'Pros do not look at one chart but at the links between markets (intermarket analysis): '
          'oil → inflation → rates → dollar → gold → stocks. Everything is intertwined, and a '
          'strong move in one asset ripples out to the others.',
        )),
        _formula(_Lf(
          [
            'Рост нефти →',
            '  рост себестоимости товаров и логистики →',
            '  рост инфляционных ожиданий (CPI) →',
            '  рост спроса на золото (хедж от инфляции) →',
            '  ответ ФРС (повышение ставки) для охлаждения',
          ],
          [
            'Мұнай өсімі →',
            '  тауар мен логистика өзіндік құнының өсуі →',
            '  инфляциялық күтулердің өсуі (CPI) →',
            '  алтынға сұраныстың өсуі (инфляциядан хедж) →',
            '  суыту үшін ФРЖ жауабы (ставка көтеру)',
          ],
          [
            'Oil rises →',
            '  cost of goods and logistics rises →',
            '  inflation expectations rise (CPI) →',
            '  demand for gold rises (inflation hedge) →',
            '  the Fed responds (raises the rate) to cool it',
          ],
        ), title: _L('Цепочка взаимосвязи', 'Байланыс тізбегі', 'The chain of links')),
        _fact(_L(
          'В апреле 2020 года цена фьючерса на нефть WTI впервые в истории ушла в '
          'ОТРИЦАТЕЛЬНУЮ зону — до −\$37 за баррель. Спрос рухнул из-за локдаунов, хранилища '
          'переполнились, и держателям фьючерсов пришлось ДОПЛАЧИВАТЬ, лишь бы кто-то забрал '
          'нефть, которую некуда было девать. Продавцу платили за покупку — сюрреализм рынка.',
          '2020 жылы сәуірде WTI мұнай фьючерсінің бағасы тарихта тұңғыш рет ТЕРІС аймаққа '
          'кетті — баррелі −\$37-ге дейін. Локдаундардан сұраныс құлады, қоймалар толды, '
          'фьючерс иелері баратын жері жоқ мұнайды біреу алсын деп ҮСТЕМЕ ТӨЛЕУГЕ мәжбүр болды. '
          'Сатушыға сатып алғаны үшін төледі — нарық сюрреализмі.',
          'In April 2020 the price of WTI oil futures went NEGATIVE for the first time in history '
          '— to −\$37 per barrel. Demand collapsed due to lockdowns, storage overflowed, and '
          'futures holders had to PAY EXTRA just for someone to take oil they had nowhere to put. '
          'The seller paid to be bought from — market surrealism.',
        )),
        _example(_L(
          'Энергетический шок 1970-х: арабское нефтяное эмбарго взвинтило цены на нефть в '
          '4 раза. Результат — «стагфляция» (инфляция + застой) в США и одно из величайших '
          'ралли золота в истории: с \$35 в 1971 до \$850 в 1980. Дорогая нефть → высокая '
          'инфляция → золото как спасение.',
          '1970-ші жылдардағы энергия шогы: араб мұнай эмбаргосы мұнай бағасын 4 есе көтерді. '
          'Нәтиже — АҚШ-тағы «стагфляция» (инфляция + тоқырау) және тарихтағы ең ұлы алтын '
          'раллиінің бірі: 1971 жылы \$35-тен 1980 жылы \$850-ге. Қымбат мұнай → жоғары инфляция '
          '→ алтын құтқарушы ретінде.',
          'The energy shock of the 1970s: the Arab oil embargo quadrupled oil prices. The result '
          '— "stagflation" (inflation + stagnation) in the US and one of the greatest gold rallies '
          'in history: from \$35 in 1971 to \$850 in 1980. Expensive oil → high inflation → gold '
          'as the rescue.',
        )),
        _interactive('intermarket', title: 'Карта межрыночных связей (домино)'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Как устойчивый рост цен на нефть в итоге влияет на золото?',
          'Мұнай бағасының тұрақты өсуі ақыр соңында алтынға қалай әсер етеді?',
          'How does a sustained rise in oil prices ultimately affect gold?',
        ),
        options: [
          _L('Золото падает — нефть забирает спрос', 'Алтын түседі — мұнай сұранысты алады', 'Gold falls — oil takes the demand'),
          _L('Золото растёт — нефть разгоняет инфляцию, золото как хедж', 'Алтын өседі — мұнай инфляцияны үдетеді, алтын хедж', 'Gold rises — oil drives inflation, gold is a hedge'),
          _L('Никак не влияет', 'Еш әсер етпейді', 'It has no effect'),
          _L('Золото всегда движется против нефти', 'Алтын әрдайым мұнайға қарсы қозғалады', 'Gold always moves opposite to oil'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Дорогая нефть → выше себестоимость → выше инфляция. Золото традиционно используют '
          'как защиту от инфляции, поэтому спрос на него растёт.',
          'Қымбат мұнай → жоғары өзіндік құн → жоғары инфляция. Алтынды дәстүрлі түрде '
          'инфляциядан қорғаныс ретінде қолданады, сондықтан оған сұраныс өседі.',
          'Expensive oil → higher costs → higher inflation. Gold is traditionally used as '
          'protection against inflation, so demand for it grows.',
        ),
      ),
    ),
  ],
);

// ════════════════════════════════════════════════════════════════════
// МОДУЛЬ 4. Магистры решений: мышление вероятностями
// ════════════════════════════════════════════════════════════════════
CourseModule _module4() => CourseModule(
  id: 'm4',
  index: 4,
  title: 'Магистры решений: мышление вероятностями (теория игр)',
  goal:
      'Превратить интуитивного игрока в хладнокровного математика. База управления рисками — '
      'в трейдинге и в жизни.',
  lessons: [
    CourseLesson(
      id: 'l4_1',
      code: '4.1',
      title: 'Математическое ожидание (+EV): как измерять выгоду в неизвестности',
      blocks: [
        _essence(_L(
          'Главная ошибка новичка: оценивать решение по результату. Выиграл — значит решение '
          'было хорошим? Нет. В мире вероятностей плохое решение может случайно принести деньги, '
          'а хорошее — временно убыток. Качество решения измеряется математическим ожиданием '
          '(EV) на длинной дистанции, а не итогом одной сделки.',
          'Жаңадан бастаушының басты қателігі: шешімді нәтиже бойынша бағалау. Ұттың — демек '
          'шешім жақсы ма? Жоқ. Ықтималдық әлемінде нашар шешім кездейсоқ ақша әкелуі мүмкін, ал '
          'жақсысы — уақытша зиян. Шешім сапасы бір мәмілемен емес, ұзақ дистанциядағы '
          'математикалық күтіммен (EV) өлшенеді.',
          'A beginner\'s main mistake: judging a decision by its result. You won — so the decision '
          'was good? No. In a world of probabilities a bad decision can win money by chance, and a '
          'good one can lose temporarily. The quality of a decision is measured by expected value '
          '(EV) over a long run, not by the outcome of a single trade.',
        )),
        _formula(_Lf(
          [
            'EV = (P_win × Profit) − (P_loss × Loss)',
            '',
            'Ставка: 50% шанс выиграть \$3,000:',
            'EV = 0.5 × 3000 − 0.5 × 0 = \$1,500',
            '',
            'Альтернатива — гарантированные \$1,000:',
            'EV = \$1,000',
          ],
          [
            'EV = (P_жеңіс × Пайда) − (P_жеңіліс × Зиян)',
            '',
            'Ставка: \$3,000 ұтудың 50% мүмкіндігі:',
            'EV = 0.5 × 3000 − 0.5 × 0 = \$1,500',
            '',
            'Балама — кепілді \$1,000:',
            'EV = \$1,000',
          ],
          [
            'EV = (P_win × Profit) − (P_loss × Loss)',
            '',
            'Bet: a 50% chance to win \$3,000:',
            'EV = 0.5 × 3000 − 0.5 × 0 = \$1,500',
            '',
            'Alternative — a guaranteed \$1,000:',
            'EV = \$1,000',
          ],
        ), title: _L('Формула', 'Формула', 'The formula')),
        _rule(_L(
          'Профессиональный покерист и трейдер мыслят одинаково: они отделяют качество РЕШЕНИЯ '
          'от качества РЕЗУЛЬТАТА. Это называется «resulting» — ошибка оценивать решение по '
          'исходу. Можно сыграть идеально и проиграть; можно сыграть глупо и выиграть.',
          'Кәсіби покершы мен трейдер бірдей ойлайды: олар ШЕШІМ сапасын НӘТИЖЕ сапасынан '
          'ажыратады. Бұл «resulting» деп аталады — шешімді нәтиже бойынша бағалау қателігі. '
          'Мінсіз ойнап ұтылуға болады; ақымақ ойнап ұтуға болады.',
          'A pro poker player and a trader think alike: they separate the quality of the DECISION '
          'from the quality of the RESULT. This is called "resulting" — the error of judging a '
          'decision by its outcome. You can play perfectly and lose; you can play stupidly and win.'),
          title: _L('Решение ≠ результат', 'Шешім ≠ нәтиже', 'Decision ≠ result'),
        ),
        _example(_L(
          'Большинство людей выберут «синицу в руках» — гарантированную \$1,000, потому что '
          'мозг панически боится потерять. Но математик выберет ставку с EV \$1,500. На дистанции '
          'в 1000 повторений выбор математика принесёт примерно в 1.5 раза больше. Эмоция '
          'выбирает комфорт, математика выбирает прибыль.',
          'Көпшілік «қолдағы торғайды» — кепілді \$1,000-ды таңдайды, өйткені ми жоғалтудан '
          'үрейленеді. Бірақ математик EV \$1,500 ставканы таңдайды. 1000 қайталау дистанциясында '
          'математиктің таңдауы шамамен 1.5 есе көп әкеледі. Эмоция жайлылықты, математика пайданы '
          'таңдайды.',
          'Most people choose "a bird in the hand" — a guaranteed \$1,000 — because the brain '
          'panics at losing. But the mathematician picks the bet with EV \$1,500. Over a run of '
          '1,000 repetitions the mathematician\'s choice yields about 1.5× more. Emotion chooses '
          'comfort; mathematics chooses profit.',
        )),
        _fact(_L(
          'Нобелевские лауреаты Канеман и Тверски доказали: боль от потери \$100 примерно в '
          '2–2.5 раза сильнее, чем радость от выигрыша тех же \$100. Это «неприятие потерь» '
          '(loss aversion). Именно из-за него трейдеры рано фиксируют прибыль и слишком долго '
          'держат убыток — действуя строго против математики.',
          'Нобель лауреаттары Канеман мен Тверски дәлелдеді: \$100 жоғалту ауыруы сол \$100-ды '
          'ұту қуанышынан шамамен 2–2.5 есе күшті. Бұл «жоғалтуды жек көру» (loss aversion). Дәл '
          'содан трейдерлер пайданы ерте бекітіп, зиянды тым ұзақ ұстайды — математикаға қарсы '
          'әрекет етеді.',
          'Nobel laureates Kahneman and Tversky proved: the pain of losing \$100 is about 2–2.5× '
          'stronger than the joy of winning the same \$100. This is "loss aversion". It is exactly '
          'why traders take profit too early and hold losses too long — acting strictly against the '
          'maths.',
        )),
        _interactive('ev_choice', title: 'Интерактив: выбор по EV'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Что важнее для оценки качества торгового решения?',
          'Сауда шешімінің сапасын бағалауда не маңызды?',
          'What matters most for judging the quality of a trading decision?',
        ),
        options: [
          _L('Результат одной конкретной сделки', 'Бір нақты мәміленің нәтижесі', 'The result of one specific trade'),
          _L('Положительное мат. ожидание (+EV) на длинной дистанции', 'Ұзақ дистанциядағы оң мат. күтім (+EV)', 'Positive expected value (+EV) over the long run'),
          _L('Сколько денег принесла сделка сегодня', 'Бүгін мәміле қанша ақша әкелді', 'How much money the trade made today'),
          _L('Мнение других трейдеров', 'Басқа трейдерлердің пікірі', 'The opinion of other traders'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Одна сделка может выиграть случайно. Качество стратегии определяется знаком '
          'математического ожидания на дистанции: +EV выживает, −EV разоряет.',
          'Бір мәміле кездейсоқ ұтуы мүмкін. Стратегия сапасы дистанциядағы математикалық '
          'күтім таңбасымен анықталады: +EV аман қалады, −EV банкротқа ұшыратады.',
          'A single trade can win by chance. A strategy\'s quality is set by the sign of its '
          'expected value over the run: +EV survives, −EV ruins you.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l4_2',
      code: '4.2',
      title: 'Винрейт против Risk-to-Reward: главный секрет выживания депозита',
      blocks: [
        _essence(_L(
          'Новички гоняются за высоким процентом прибыльных сделок (винрейтом), думая, что в '
          'этом секрет. Это ловушка. Можно иметь 90% прибыльных сделок и слить депозит, а можно '
          'иметь 35% и стабильно богатеть. Всё решает связка винрейта и Risk-to-Reward (RR) — '
          'отношения тейк-профита к стоп-лоссу.',
          'Жаңадан бастаушылар жоғары пайдалы мәміле пайызын (винрейт) қуады, құпия осында деп '
          'ойлап. Бұл тұзақ. 90% пайдалы мәмілемен депозитті құртуға болады, ал 35%-бен тұрақты '
          'байуға болады. Бәрін винрейт пен Risk-to-Reward (RR) — тейк-профиттің стоп-лосқа '
          'қатынасы шешеді.',
          'Beginners chase a high percentage of winning trades (win rate), thinking that is the '
          'secret. It is a trap. You can have 90% winning trades and blow the account, or have 35% '
          'and steadily get rich. Everything is decided by the pairing of win rate and '
          'Risk-to-Reward (RR) — the ratio of take-profit to stop-loss.',
        )),
        _formula(_Lf(
          [
            'EV сделки = WinRate × RR − (1 − WinRate) × 1',
            '',
            'Пример A: WinRate 40%, RR 1:3',
            'EV = 0.40 × 3 − 0.60 × 1 = +0.6R ✅ прибыльно',
            '',
            'Пример B: WinRate 90%, RR 1:0.1',
            'EV = 0.90 × 0.1 − 0.10 × 1 = −0.01R ❌ убыточно',
          ],
          [
            'Мәміле EV = WinRate × RR − (1 − WinRate) × 1',
            '',
            'Мысал A: WinRate 40%, RR 1:3',
            'EV = 0.40 × 3 − 0.60 × 1 = +0.6R ✅ пайдалы',
            '',
            'Мысал B: WinRate 90%, RR 1:0.1',
            'EV = 0.90 × 0.1 − 0.10 × 1 = −0.01R ❌ зиянды',
          ],
          [
            'Trade EV = WinRate × RR − (1 − WinRate) × 1',
            '',
            'Example A: WinRate 40%, RR 1:3',
            'EV = 0.40 × 3 − 0.60 × 1 = +0.6R ✅ profitable',
            '',
            'Example B: WinRate 90%, RR 1:0.1',
            'EV = 0.90 × 0.1 − 0.10 × 1 = −0.01R ❌ unprofitable',
          ],
        ), title: _L('Винрейт обманчив', 'Винрейт алдамшы', 'Win rate is deceptive')),
        _warn(_L(
          'Высокий винрейт — самая опасная иллюзия в трейдинге. Стратегия «беру маленькую '
          'прибыль, но не ставлю стоп» даёт 95% выигрышных сделок и ощущение гениальности... '
          'до тех пор, пока одна сделка без стопа не сожрёт все 95% побед разом. Так умирают '
          'депозиты «успешных» новичков.',
          'Жоғары винрейт — трейдингтегі ең қауіпті елес. «Кіші пайда аламын, бірақ стоп '
          'қоймаймын» стратегиясы 95% жеңісті мәміле мен данышпандық сезімін береді... бір '
          'стопсыз мәміле 95% жеңісті бір-ақ жұтқанша. «Табысты» жаңадан бастаушылардың '
          'депозиттері осылай өледі.',
          'A high win rate is the most dangerous illusion in trading. The "take a small profit but '
          'set no stop" strategy gives 95% winning trades and a feeling of genius... until one '
          'stop-less trade eats all 95% of the wins at once. That is how the accounts of '
          '"successful" beginners die.',
        )),
        _example(_L(
          'Знаменитые трейдеры-трендовики (turtle traders) имели винрейт всего ~35%. Они '
          'теряли деньги в 2 случаях из 3! Но их выигрышные сделки были в разы крупнее '
          'убыточных (RR 1:5 и выше), и на дистанции это сделало их миллионерами. Большой RR '
          'прощает низкий винрейт; маленький RR не спасёт даже высокий.',
          'Атақты тренд трейдерлерінің (turtle traders) винрейті небәрі ~35% болды. Олар 3-тің '
          '2-сінде ақша жоғалтты! Бірақ жеңісті мәмілелері зияндыдан бірнеше есе ірі еді (RR 1:5 '
          'және жоғары), бұл дистанцияда оларды миллионер етті. Үлкен RR төмен винрейтті кешіреді; '
          'кіші RR жоғарысын да құтқармайды.',
          'The famous trend-following "turtle traders" had a win rate of just ~35%. They lost '
          'money in 2 out of 3 cases! But their winning trades were many times larger than the '
          'losers (RR 1:5 and up), and over the run that made them millionaires. A big RR forgives '
          'a low win rate; a small RR will not save even a high one.',
        )),
        _interactive('winrate_rr', title: 'Симулятор: Win Rate × RR (500 сделок)'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Win Rate 40%, RR 1:3. Система прибыльна на дистанции?',
          'Win Rate 40%, RR 1:3. Жүйе дистанцияда пайдалы ма?',
          'Win Rate 40%, RR 1:3. Is the system profitable over the run?',
        ),
        options: [
          _L('Нет, ведь 60% сделок убыточны', 'Жоқ, өйткені 60% мәміле зиянды', 'No, because 60% of trades lose'),
          _L('Да: 0.4×3 − 0.6×1 = +0.6R на сделку', 'Иә: 0.4×3 − 0.6×1 = +0.6R әр мәмілеге', 'Yes: 0.4×3 − 0.6×1 = +0.6R per trade'),
          _L('Зависит только от удачи', 'Тек сәттілікке байланысты', 'It depends only on luck'),
          _L('Невозможно определить', 'Анықтау мүмкін емес', 'Impossible to determine'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Положительный RR компенсирует низкий винрейт. 0.4×3 − 0.6×1 = +0.6R — каждая сделка '
          'в среднем приносит 0.6 риска прибыли. Большой RR важнее высокого винрейта.',
          'Оң RR төмен винрейтті өтейді. 0.4×3 − 0.6×1 = +0.6R — әр мәміле орташа 0.6 тәуекел '
          'пайда әкеледі. Үлкен RR жоғары винрейттен маңызды.',
          'A positive RR compensates for a low win rate. 0.4×3 − 0.6×1 = +0.6R — each trade brings '
          'on average 0.6 of risk in profit. A big RR matters more than a high win rate.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l4_3',
      code: '4.3',
      title: 'Почему мастера решений — байесианцы? (Теорема Байеса на пальцах)',
      blocks: [
        _essence(_L(
          'Твоё мнение о рынке — это не флаг, который надо защищать, а вероятность, которую '
          'надо постоянно пересчитывать. Байесовское мышление: у тебя есть начальная оценка '
          '(prior), приходят новые данные — ты обновляешь оценку (posterior). Упрямство в '
          'трейдинге смертельно.',
          'Нарық туралы пікірің — қорғайтын ту емес, үнемі қайта есептейтін ықтималдық. Байес '
          'ойлауы: бастапқы бағаң (prior) бар, жаңа дерек келеді — бағаңды жаңартасың '
          '(posterior). Трейдингте қыңырлық өлімге апарады.',
          'Your opinion about the market is not a flag to defend, but a probability to constantly '
          'recompute. Bayesian thinking: you have an initial estimate (prior), new data arrives — '
          'you update the estimate (posterior). Stubbornness in trading is fatal.',
        )),
        _rule(_L(
          'Алгоритм байесианца:\n'
          '1. Сформулируй стартовую вероятность («думаю, золото вырастет — 60%»).\n'
          '2. Получи новые данные (вышел горячий CPI).\n'
          '3. Пересчитай: «теперь вероятность роста 30%».\n'
          '4. Действуй по новой вероятности, а не по старому плану.',
          'Байесшінің алгоритмі:\n'
          '1. Бастапқы ықтималдықты тұжырымда («алтын өседі деп ойлаймын — 60%»).\n'
          '2. Жаңа дерек ал (ыстық CPI шықты).\n'
          '3. Қайта есепте: «енді өсу ықтималдығы 30%».\n'
          '4. Ескі жоспармен емес, жаңа ықтималдықпен әрекет ет.',
          'The Bayesian\'s algorithm:\n'
          '1. State a starting probability ("I think gold will rise — 60%").\n'
          '2. Get new data (a hot CPI came out).\n'
          '3. Recompute: "now the probability of a rise is 30%".\n'
          '4. Act on the new probability, not the old plan.'),
          title: _L('Теорема Байеса в действии', 'Байес теоремасы іс жүзінде', 'Bayes\' theorem in action'),
        ),
        _fact(_L(
          'Теорему Байеса сформулировал в XVIII веке английский священник Томас Байес, и '
          'опубликована она была лишь после его смерти. Сегодня эта формула — фундамент '
          'спам-фильтров, медицинской диагностики, искусственного интеллекта и систем '
          'управления рисками крупнейших хедж-фондов.',
          'Байес теоремасын XVIII ғасырда ағылшын діни қызметкері Томас Байес тұжырымдады, ол '
          'тек өлімінен кейін жарияланды. Бүгінде бұл формула — спам-сүзгілердің, медициналық '
          'диагностиканың, жасанды интеллект пен ірі хедж-қорлардың тәуекел жүйелерінің іргетасы.',
          'Bayes\' theorem was formulated in the 18th century by the English clergyman Thomas '
          'Bayes, and published only after his death. Today this formula is the foundation of '
          'spam filters, medical diagnostics, artificial intelligence and the risk systems of the '
          'largest hedge funds.',
        )),
        _example(_L(
          'Профессионал, увидев, что условия изменились, мгновенно фиксирует микро-убыток и '
          'разворачивается — для него это не «поражение», а обновление вероятностей. Новичок '
          '«надеется», добавляет к убыточной позиции («усредняется») и держится за своё '
          'первоначальное мнение до маржин-колла. Рынку всё равно, что ты думал час назад.',
          'Кәсіпқой жағдай өзгергенін көріп, лезде микро-зиянды бекітіп, бұрылады — ол үшін бұл '
          '«жеңіліс» емес, ықтималдықты жаңарту. Жаңадан бастаушы «үміттенеді», зиянды позицияға '
          'қосады («орташалайды») және маржин-коллға дейін бастапқы пікірін ұстайды. Бір сағат '
          'бұрын не ойлағаның нарыққа бәрібір.',
          'A professional, seeing that conditions have changed, instantly takes a micro-loss and '
          'reverses — for them it is not "defeat" but an update of probabilities. A beginner '
          '"hopes", adds to a losing position ("averages down") and clings to their initial '
          'opinion until the margin call. The market does not care what you thought an hour ago.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Вышли новые данные, противоречащие вашему плану. Действие байесианца?',
          'Жоспарыңызға қайшы жаңа дерек шықты. Байесшінің әрекеті?',
          'New data came out contradicting your plan. The Bayesian\'s move?',
        ),
        options: [
          _L('Игнорировать данные, держаться плана', 'Деректі елемеу, жоспарды ұстау', 'Ignore the data, stick to the plan'),
          _L('Пересчитать вероятности и скорректировать решение', 'Ықтималдықты қайта есептеп, шешімді түзету', 'Recompute the probabilities and adjust the decision'),
          _L('Удвоить позицию против тренда', 'Трендке қарсы позицияны екі еселеу', 'Double the position against the trend'),
          _L('Закрыть терминал до завтра', 'Терминалды ертеңге дейін жабу', 'Close the terminal until tomorrow'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Байесовский подход требует обновлять оценку вероятностей при новой информации. '
          'Гибкость, а не упрямство — признак мастера решений.',
          'Байес тәсілі жаңа ақпаратта ықтималдық бағасын жаңартуды талап етеді. Қыңырлық емес, '
          'икемділік — шешім шеберінің белгісі.',
          'The Bayesian approach requires updating your probability estimate when new information '
          'arrives. Flexibility, not stubbornness, is the mark of a master of decisions.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l4_4',
      code: '4.4',
      title: 'Формула Келли: как рассчитать размер лота, чтобы не обнулиться',
      blocks: [
        _essence(_L(
          'Формула Келли отвечает на вопрос, который игнорируют 99% новичков: «какую долю '
          'капитала ставить?» Она находит оптимальный размер риска, при котором капитал растёт '
          'максимально быстро, но риск разорения остаётся под контролем.',
          'Келли формуласы жаңадан бастаушылардың 99%-ы елемейтін сұраққа жауап береді: '
          '«капиталдың қай үлесін қою керек?» Ол капитал ең жылдам өсетін, бірақ банкроттық '
          'қаупі бақылауда қалатын оңтайлы тәуекел мөлшерін табады.',
          'The Kelly formula answers the question 99% of beginners ignore: "what fraction of '
          'capital to bet?" It finds the optimal risk size at which capital grows as fast as '
          'possible while the risk of ruin stays under control.',
        )),
        _formula(_Lf(
          [
            'f* = W − (1 − W) / R',
            '',
            'W = винрейт (доля), R = risk-to-reward',
            '',
            'Пример: W=0.6, R=2',
            'f* = 0.6 − 0.4/2 = 0.4 (40% — чистый Келли)',
            '',
            'На практике берут ¼ Келли → ~10% — безопаснее',
          ],
          [
            'f* = W − (1 − W) / R',
            '',
            'W = винрейт (үлес), R = risk-to-reward',
            '',
            'Мысал: W=0.6, R=2',
            'f* = 0.6 − 0.4/2 = 0.4 (40% — таза Келли)',
            '',
            'Іс жүзінде ¼ Келли алады → ~10% — қауіпсіздеу',
          ],
          [
            'f* = W − (1 − W) / R',
            '',
            'W = win rate (fraction), R = risk-to-reward',
            '',
            'Example: W=0.6, R=2',
            'f* = 0.6 − 0.4/2 = 0.4 (40% — full Kelly)',
            '',
            'In practice use ¼ Kelly → ~10% — safer',
          ],
        ), title: _L('Формула Келли', 'Келли формуласы', 'The Kelly formula')),
        _warn(_L(
          'Полный Келли математически оптимален, но эмоционально невыносим: он допускает '
          'просадки 50%+. Поэтому профи используют «дробный Келли» (¼ или ½), жертвуя частью '
          'скорости роста ради спокойного сна и защиты от серии неудач.',
          'Толық Келли математикалық оңтайлы, бірақ эмоциялық тұрғыдан төзгісіз: ол 50%+ '
          'просадканы жібереді. Сондықтан кәсіпқойлар «бөлшек Келли» (¼ немесе ½) қолданады, '
          'тыныш ұйқы мен сәтсіздіктер тізбегінен қорғаныс үшін өсу жылдамдығының бір бөлігін '
          'құрбан етеді.',
          'Full Kelly is mathematically optimal but emotionally unbearable: it allows drawdowns of '
          '50%+. So pros use "fractional Kelly" (¼ or ½), sacrificing some growth speed for calm '
          'sleep and protection against a losing streak.',
        )),
        _fact(_L(
          'Формулу вывел Джон Келли в 1956 году, работая в Bell Labs — изначально для задач '
          'передачи сигнала, а не для денег. Её взял на вооружение математик Эд Торп, который '
          'сначала обыграл казино в блэкджек (его выгнали из Лас-Вегаса!), а затем применил '
          'тот же подход на Уолл-стрит, создав один из первых количественных хедж-фондов.',
          'Формуланы Джон Келли 1956 жылы Bell Labs-та жұмыс істеп жүргенде шығарды — бастапқыда '
          'ақша үшін емес, сигнал беру есептері үшін. Оны математик Эд Торп қаруға алды: алдымен '
          'казиноны блэкджекте ұтты (оны Лас-Вегастан қуды!), сосын дәл осы тәсілді Уолл-стритте '
          'қолданып, алғашқы сандық хедж-қорлардың бірін құрды.',
          'The formula was derived by John Kelly in 1956 while at Bell Labs — originally for '
          'signal-transmission problems, not money. It was adopted by mathematician Ed Thorp, who '
          'first beat the casino at blackjack (he was banned from Las Vegas!) and then applied the '
          'same approach on Wall Street, creating one of the first quantitative hedge funds.',
        )),
        _example(_L(
          'Даже с отличной стратегией (60% винрейт) риск 20% на сделку = гарантированное '
          'разорение. Серия из 5 убытков подряд при таком риске случается регулярно и почти '
          'обнуляет депозит. Не стратегия убивает трейдера, а завышенный размер позиции.',
          'Тіпті тамаша стратегиямен (60% винрейт) бір мәмілеге 20% тәуекел = кепілді банкроттық. '
          'Мұндай тәуекелде қатарынан 5 зиян тізбегі жиі болады әрі депозитті дерлік нөлдейді. '
          'Трейдерді стратегия емес, асырып жіберілген позиция мөлшері өлтіреді.',
          'Even with an excellent strategy (60% win rate) a 20% risk per trade = guaranteed ruin. '
          'A streak of 5 losses in a row at such risk happens regularly and almost zeroes the '
          'account. It is not the strategy that kills the trader, but an oversized position.',
        )),
        _interactive('drawdown', title: 'Математика просадки'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Зачем нужна формула Келли?',
          'Келли формуласы не үшін керек?',
          'What is the Kelly formula for?',
        ),
        options: [
          _L('Чтобы предсказать направление цены', 'Баға бағытын болжау үшін', 'To predict the direction of price'),
          _L('Чтобы определить оптимальный размер риска и избежать разорения', 'Оңтайлы тәуекел мөлшерін анықтап, банкроттықтан аулақ болу үшін', 'To set the optimal risk size and avoid ruin'),
          _L('Чтобы выбрать брокера', 'Брокер таңдау үшін', 'To choose a broker'),
          _L('Чтобы рассчитать спред', 'Спредті есептеу үшін', 'To calculate the spread'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Келли отвечает на вопрос «сколько ставить», а не «куда». Она балансирует рост '
          'капитала и риск разорения. На практике используют дробную долю Келли.',
          'Келли «қанша қою» сұрағына жауап береді, «қайда» емес. Ол капитал өсуі мен банкроттық '
          'қаупін теңгереді. Іс жүзінде Келлидің бөлшек үлесін қолданады.',
          'Kelly answers "how much to bet", not "where". It balances capital growth against the '
          'risk of ruin. In practice a fractional share of Kelly is used.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l4_5',
      code: '4.5',
      title: 'Восьмое чудо света: как правильно запустить сложный процент',
      blocks: [
        _essence(_L(
          'Сложный процент — это когда ты зарабатываешь процент не только на вложенное, но и '
          'на ранее заработанное. Капитал начинает расти по экспоненте — сначала незаметно, '
          'а потом взрывообразно. Эйнштейну приписывают слова: «Сложный процент — восьмое чудо '
          'света. Кто понимает его — зарабатывает, кто нет — платит».',
          'Күрделі пайыз — бұл пайызды тек салынғаннан емес, бұрын тапқаннан да табу. Капитал '
          'экспонентамен өсе бастайды — алдымен байқалмай, сосын жарылыс тәрізді. Эйнштейнге '
          'мынау сөз телінеді: «Күрделі пайыз — әлемнің сегізінші кереметі. Оны түсінген — '
          'табады, түсінбеген — төлейді».',
        )),
        _formula(_Lf(
          [
            'Капитал = Депозит × (1 + r)^n',
            '',
            '\$1,000 под 8% в месяц, 3 года (36 мес.):',
            '1000 × 1.08^36 ≈ \$15,968',
            '',
            'Те же 8%, но 5 лет (60 мес.):',
            '1000 × 1.08^60 ≈ \$101,257',
          ],
          [
            'Капитал = Депозит × (1 + r)^n',
            '',
            '\$1,000, айына 8%, 3 жыл (36 ай):',
            '1000 × 1.08^36 ≈ \$15,968',
            '',
            'Сол 8%, бірақ 5 жыл (60 ай):',
            '1000 × 1.08^60 ≈ \$101,257',
          ],
        ), title: _L('Сила экспоненты', 'Экспонента күші')),
        _fact(_L(
          'Притча о шахматной доске: мудрец попросил у султана награду — 1 зерно на первую '
          'клетку, 2 на вторую, 4 на третью, удваивая на каждой. Султан посмеялся над '
          '«скромностью»... пока не выяснил, что на 64 клетках нужно ~18 квинтиллионов зёрен — '
          'больше, чем человечество вырастило за всю историю. Вот что такое экспонента.',
          'Шахмат тақтасы туралы астарлы әңгіме: данышпан сұлтаннан сыйақы сұрады — бірінші '
          'шаршыға 1 дән, екіншіге 2, үшіншіге 4, әрқайсысында екі еселеп. Сұлтан '
          '«қарапайымдылыққа» күлді... 64 шаршыға ~18 квинтиллион дән керегін білгенше — оны '
          'адамзат бүкіл тарихта өсіргеннен көп. Экспонента деген осы.',
        )),
        _warn(_L(
          'Ловушка нетерпения: главный убийца сложного процента — жадность. Попытка разогнать '
          'депозит в 2–3 раза за месяц = огромный риск = неизбежная крупная просадка, которая '
          'обнуляет всё накопленное. Спокойные 5–10% в месяц на дистанции в годы превращают '
          'малый депозит в состояние. Скучно? Да. Работает? Да.',
          'Шыдамсыздық тұзағы: күрделі пайыздың басты өлтірушісі — ашкөздік. Депозитті айына '
          '2–3 есе қуу әрекеті = орасан тәуекел = бәрін нөлдейтін сөзсіз ірі просадка. Жылдар '
          'дистанциясындағы тыныш айына 5–10% кіші депозитті байлыққа айналдырады. Жалықтырады '
          'ма? Иә. Жұмыс істей ме? Иә.',
        )),
        _interactive('compound', title: 'Симулятор сложного процента'),
      ],
      quiz: QuizQuestion(
        question: _L(
          'В чём главная сила сложного процента?',
          'Күрделі пайыздың басты күші неде?',
        ),
        options: [
          _L('В быстром удвоении депозита за месяц', 'Депозитті айына жылдам екі еселеуде'),
          _L('В реинвестировании прибыли — экспоненциальный рост на дистанции', 'Пайданы қайта салуда — дистанциядағы экспоненциалды өсу'),
          _L('В использовании максимального плеча', 'Максималды иық қолдануда'),
          _L('В частых выводах прибыли', 'Пайданы жиі шығаруда'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Сложный процент работает за счёт реинвестирования: процент начисляется на растущую '
          'базу. Магия проявляется на длинной дистанции, а не за один месяц.',
          'Күрделі пайыз қайта салу есебінен жұмыс істейді: пайыз өсіп жатқан базаға есептеледі. '
          'Сиқыр бір айда емес, ұзақ дистанцияда көрінеді.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l4_6',
      code: '4.6',
      title: 'Ловушка казино: почему ты не победишь дилера на его поле?',
      blocks: [
        _essence(_L(
          'В казино всё построено на отрицательном математическом ожидании для игрока (House '
          'Edge) и законе больших чисел. Игрок может выиграть вечером, но на дистанции тысяч '
          'ставок математика неумолимо заберёт его деньги. Трейдер без преимущества — это '
          'игрок казино. Трейдер с системой +EV — это само казино.',
          'Казинода бәрі ойыншыға теріс математикалық күтімге (House Edge) және үлкен сандар '
          'заңына құрылған. Ойыншы кешке ұтуы мүмкін, бірақ мыңдаған ставка дистанциясында '
          'математика оның ақшасын аяусыз алады. Артықшылығы жоқ трейдер — казино ойыншысы. '
          '+EV жүйесі бар трейдер — казиноның өзі.',
        )),
        _rule(_L(
          'Чтобы оказаться «на стороне казино», нужно: (1) иметь реальное статистическое '
          'преимущество (+EV), (2) играть малым процентом капитала на ставку, (3) повторять '
          'это много раз с железной дисциплиной. Тогда закон больших чисел работает на тебя, '
          'а не против.',
          '«Казино жағында» болу үшін: (1) нақты статистикалық артықшылық (+EV) болуы керек, '
          '(2) ставкаға капиталдың кіші пайызын қою, (3) мұны темір тәртіппен көп рет қайталау. '
          'Сонда үлкен сандар заңы саған қарсы емес, сен үшін жұмыс істейді.'),
          title: _L('Стань казино', 'Казино бол'),
        ),
        _fact(_L(
          'Преимущество казино в европейской рулетке — всего ~2.7% (из-за зеро). Этого '
          'крошечного перевеса достаточно, чтобы строить миллиардные отели Лас-Вегаса. '
          'Вдумайся: перевес менее 3%, помноженный на миллионы ставок, = неисчерпаемая '
          'прибыль. Так и в трейдинге маленький, но стабильный +EV на дистанции = богатство.',
          'Еуропалық рулеткадағы казино артықшылығы — небәрі ~2.7% (зеро есебінен). Лас-Вегастың '
          'миллиардтаған қонақүйлерін салу үшін осы кішкентай басымдық жеткілікті. Ойлап көр: '
          '3%-дан кем басымдық миллиондаған ставкаға көбейтілсе = таусылмас пайда. Трейдингте де '
          'кіші, бірақ тұрақты +EV дистанцияда = байлық.',
        )),
        _example(_L(
          'Эд Торп научно вычислил, как считать карты в блэкджеке, и превратил House Edge в '
          'свою пользу. Казино так испугались, что начали тасовать колоды чаще и пожизненно '
          'банить «счётчиков». Вывод: даже на поле казино можно победить — но только с '
          'математическим преимуществом, а не с верой в удачу.',
          'Эд Торп блэкджекте картаны қалай санауды ғылыми есептеп, House Edge-ті өз пайдасына '
          'айналдырды. Казино сонша қорыққаны — колоданы жиірек араластырып, «санаушыларды» '
          'өмірлік бандай бастады. Қорытынды: казино алаңында да жеңуге болады — бірақ тек '
          'математикалық артықшылықпен, сәттілікке сеніммен емес.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Как трейдеру оказаться «на стороне казино», а не игрока?',
          'Трейдер «казино жағында» болу үшін не істеу керек, ойыншы емес?',
        ),
        options: [
          _L('Торговать на эмоциях и интуиции', 'Эмоция мен интуициямен саудалау'),
          _L('Иметь системное преимущество (+EV) и повторять его дисциплинированно', 'Жүйелік артықшылық (+EV) болып, оны тәртіппен қайталау'),
          _L('Делать крупные ставки редко', 'Ірі ставкаларды сирек жасау'),
          _L('Полагаться на удачу в серии сделок', 'Мәмілелер тізбегінде сәттілікке сену'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Казино выигрывает за счёт устойчивого +EV и закона больших чисел. Трейдер должен '
          'построить такое же статистическое преимущество и исполнять его системно.',
          'Казино тұрақты +EV мен үлкен сандар заңы есебінен ұтады. Трейдер дәл сондай '
          'статистикалық артықшылық құрып, оны жүйелі орындауы керек.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l4_7',
      code: '4.7',
      title: 'Антихрупкость: как использовать хаос, чтобы становиться сильнее',
      blocks: [
        _essence(_L(
          'Нассим Талеб ввёл понятие «антихрупкость» — свойство систем не просто выдерживать '
          'удары, а УСИЛИВАТЬСЯ от них. Хрупкое ломается от стресса (стакан). Устойчивое его '
          'игнорирует (камень). Антихрупкое — растёт от него (мышца от нагрузки). Лучшие '
          'торговые стратегии — антихрупкие.',
          'Нассим Талеб «антисынғыштық» ұғымын енгізді — жүйенің соққыға жай төтеп беруі емес, '
          'одан КҮШЕЮ қасиеті. Сынғыш стресстен сынады (стақан). Тұрақты оны елемейді (тас). '
          'Антисынғыш — одан өседі (бұлшықет жүктемеден). Ең жақсы сауда стратегиялары — '
          'антисынғыш.',
        )),
        _rule(_L(
          'Структура антихрупкости в трейдинге — асимметрия: много маленьких ограниченных '
          'убытков (стоп-лоссы как страховка) + редкие, но огромные прибыли (прибыль не '
          'ограничиваем). Ты ограничиваешь риск снизу и оставляешь потенциал открытым сверху.',
          'Трейдингтегі антисынғыштық құрылымы — асимметрия: көп кіші шектеулі зиян (стоп-лосс '
          'сақтандыру ретінде) + сирек, бірақ орасан пайда (пайданы шектемейміз). Сен тәуекелді '
          'төменнен шектеп, әлеуетті жоғарыдан ашық қалдырасың.'),
          title: _L('Принцип асимметрии', 'Асимметрия қағидасы'),
        ),
        _fact(_L(
          'Талеб не теоретик — он заработал состояние именно на этой философии. Его фонд '
          'покупал «дешёвую страховку» (опционы), которая почти всегда сгорала по мелочи, но '
          'в редкий день обвала (например, «Чёрный понедельник» 1987 или 2008) приносила '
          'тысячи процентов. Маленькие убытки — цена за билет на гигантскую прибыль.',
          'Талеб теоретик емес — ол дәл осы философиямен байлық тапты. Оның қоры «арзан '
          'сақтандыру» (опциондар) сатып алды, ол әрдайым дерлік болмашымен жанып кетті, бірақ '
          'сирек құлдырау күнінде (мысалы, 1987 «Қара дүйсенбі» немесе 2008) мыңдаған пайыз '
          'әкелді. Кіші зияндар — алып пайдаға билеттің бағасы.',
        )),
        _example(_L(
          '«Чёрный лебедь» — редкое, непредсказуемое событие с колоссальными последствиями '
          '(пандемия, обвал, война). Хрупкий трейдер с большим плечом и без стопов на нём '
          'разоряется. Антихрупкий — зарабатывает состояние, потому что заранее построил '
          'портфель так, чтобы катастрофа работала в его пользу.',
          '«Қара аққу» — орасан салдары бар сирек, болжанбайтын оқиға (пандемия, құлдырау, '
          'соғыс). Үлкен иығы бар, стопсыз сынғыш трейдер онда банкротқа ұшырайды. Антисынғыш — '
          'байлық табады, өйткені портфельді алдын ала апат өз пайдасына жұмыс істейтіндей құрды.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Что делает торговую стратегию антихрупкой?',
          'Сауда стратегиясын антисынғыш ететін не?',
        ),
        options: [
          _L('Большие убытки и маленькие прибыли', 'Үлкен зиян мен кіші пайда'),
          _L('Маленькие ограниченные убытки и редкие огромные прибыли', 'Кіші шектеулі зиян мен сирек орасан пайда'),
          _L('Полное отсутствие убытков', 'Зиянның мүлде болмауы'),
          _L('Максимальное плечо на каждой сделке', 'Әр мәмілеге максималды иық'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Антихрупкость = асимметрия: ограничь убытки (стопы), оставь прибыль открытой. '
          'Тогда редкие крупные движения рынка работают на тебя.',
          'Антисынғыштық = асимметрия: зиянды шекте (стоп), пайданы ашық қалдыр. Сонда нарықтың '
          'сирек ірі қозғалыстары сен үшін жұмыс істейді.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l4_8',
      code: '4.8',
      title: 'Островки определённости посреди хаоса: жёсткая система правил',
      blocks: [
        _essence(_L(
          'Будущее не знает никто — ни ты, ни гуру из телеграма, ни аналитики банков. Карта '
          'рынка — это карта вероятностей, а не пророчеств. Принять это страшно, но именно '
          'отсюда рождается сила: вместо поиска «грааля-предсказателя» ты строишь систему '
          'правил, которая работает в условиях неизвестности.',
          'Болашақты ешкім білмейді — сен де, телеграмдағы гуру да, банк аналитиктері де. Нарық '
          'картасы — пайғамбарлық емес, ықтималдық картасы. Мұны қабылдау қорқынышты, бірақ дәл '
          'осыдан күш туады: «болжаушы-грааль» іздеудің орнына белгісіздікте жұмыс істейтін '
          'ережелер жүйесін құрасың.',
        )),
        _rule(_L(
          'Три якоря определённости в хаосе:\n'
          '1. Чек-лист входа — сделка только при выполнении ВСЕХ условий, без исключений.\n'
          '2. Риск-менеджмент — фиксированный % риска на сделку (0.5–2%).\n'
          '3. Торговый план — заранее прописано, что делать при TP, при SL, при новости, '
          'при сомнении.',
          'Хаостағы үш айқындық зәкірі:\n'
          '1. Кіру чек-лист — мәміле тек БАРЛЫҚ шарт орындалғанда, ерекшеліксіз.\n'
          '2. Тәуекел-менеджмент — мәмілеге бекітілген тәуекел %-ы (0.5–2%).\n'
          '3. Сауда жоспары — TP, SL, жаңалық, күмән кезінде не істеу алдын ала жазылған.'),
          title: _L('Убираем хаос из дня', 'Күннен хаосты аламыз'),
        ),
        _fact(_L(
          'Хирурги с многолетним опытом совершают меньше ошибок, когда используют простой '
          'чек-лист перед операцией (исследование Атула Гаванде). Внедрение чек-листов в '
          'операционных снизило смертность на ~40%. Если чек-лист спасает жизни даже у '
          'гениальных хирургов — он точно спасёт твой депозит.',
          'Көпжылдық тәжірибесі бар хирургтар операция алдында қарапайым чек-лист қолданғанда '
          'аз қателеседі (Атул Гаванде зерттеуі). Операцияларда чек-лист енгізу өлімді ~40%-ға '
          'азайтты. Чек-лист данышпан хирургтардың да өмірін сақтаса — ол сенің депозитіңді де '
          'сақтайды.',
        )),
        _example(_L(
          'Трейдер без правил каждое утро принимает решения «с чистого листа», устаёт от '
          'постоянного выбора и выгорает за месяцы. Трейдер с системой исполняет чек-лист почти '
          'механически — мозг не тратит силы на муки выбора, и хаос рынка перестаёт пугать. '
          'Правила — это не клетка, а броня.',
          'Ережесіз трейдер әр таң сайын «таза парақтан» шешім қабылдайды, үздіксіз таңдаудан '
          'шаршап, айлар ішінде күйіп кетеді. Жүйесі бар трейдер чек-листі дерлік механикалық '
          'орындайды — ми таңдау азабына күш жұмсамайды, нарық хаосы қорқытуын қояды. Ережелер — '
          'тор емес, сауыт.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Зачем трейдеру чек-листы и жёсткий риск-менеджмент?',
          'Трейдерге чек-лист пен қатаң тәуекел-менеджмент не үшін керек?',
        ),
        options: [
          _L('Чтобы предсказывать будущее точно', 'Болашақты дәл болжау үшін'),
          _L('Чтобы убрать хаос и эмоции из принятия решений', 'Шешім қабылдаудан хаос пен эмоцияны алып тастау үшін'),
          _L('Чтобы торговать чаще', 'Жиірек саудалау үшін'),
          _L('Чтобы избежать любых убытков', 'Кез келген зияннан аулақ болу үшін'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Правила не предсказывают рынок — они структурируют твоё поведение. Это островки '
          'определённости, которые защищают от хаотичных эмоциональных решений.',
          'Ережелер нарықты болжамайды — олар сенің мінез-құлқыңды құрылымдайды. Бұл хаосты '
          'эмоциялық шешімдерден қорғайтын айқындық аралдары.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l4_9',
      code: '4.9',
      title: 'Как принимать решения, чтобы не сожалеть? (Фреймворк Безоса)',
      blocks: [
        _essence(_L(
          'Regret Minimization Framework Джеффа Безоса: при важном выборе спроецируй себя в '
          'возраст 80 лет и спроси — о чём я буду жалеть, оглядываясь назад? Этот приём '
          'отключает сиюминутный страх и показывает, что действительно важно в масштабе жизни.',
          'Джефф Безостың Regret Minimization Framework-і: маңызды таңдауда өзіңді 80 жасқа '
          'жобалап, сұра — артқа қарағанда неге өкінемін? Бұл тәсіл сәттік қорқынышты өшіріп, '
          'өмір ауқымында шынымен не маңызды екенін көрсетеді.',
        )),
        _rule(_L(
          'Применяй фреймворк к СТРАТЕГИЧЕСКИМ решениям (сменить профессию, начать обучение, '
          'войти в крупную долгосрочную инвестицию), а не к каждой мелкой сделке. Цель — '
          'минимизировать долгосрочное сожаление, а не краткосрочный дискомфорт.',
          'Фреймворкті СТРАТЕГИЯЛЫҚ шешімдерге қолдан (мамандық ауыстыру, оқуды бастау, ірі '
          'ұзақмерзімді инвестицияға кіру), әр ұсақ мәмілеге емес. Мақсат — қысқамерзімді '
          'жайсыздықты емес, ұзақмерзімді өкінішті азайту.'),
          title: _L('Как применять', 'Қалай қолдану'),
        ),
        _story(_L(
          'В 1994 году Безос работал на престижной высокооплачиваемой должности в хедж-фонде. '
          'Идея интернет-магазина была безумной авантюрой. Он спросил себя: «В 80 лет я буду '
          'жалеть, что ушёл с хорошей работы и попробовал? Или что НЕ попробовал?» Ответ был '
          'очевиден — он уволился и основал Amazon в гараже. Сожаление о непопытке тяжелее '
          'сожаления о неудаче.',
          '1994 жылы Безос хедж-қордағы беделді, жоғары жалақылы қызметте істеді. Интернет-дүкен '
          'идеясы есалаң авантюра еді. Ол өзіне сұрақ қойды: «80 жаста жақсы жұмыстан кетіп, '
          'байқап көргеніме өкінемін бе? Әлде БАЙҚАП КӨРМЕГЕНІМЕ ме?» Жауап анық еді — ол жұмыстан '
          'кетіп, гаражда Amazon-ды құрды. Байқап көрмегенге өкіну сәтсіздікке өкінуден ауыр.'),
          title: _L('Гараж, который стал триллионом', 'Триллионға айналған гараж'),
        ),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Суть Regret Minimization Framework Безоса?',
          'Безостың Regret Minimization Framework-інің мәні?',
        ),
        options: [
          _L('Принимать решения ради быстрой выгоды', 'Жылдам пайда үшін шешім қабылдау'),
          _L('Минимизировать будущее сожаление, глядя на выбор из возраста 80 лет', '80 жас тұрғысынан таңдауға қарап, болашақ өкінішті азайту'),
          _L('Всегда выбирать наименее рискованный путь', 'Әрдайым ең аз тәуекелді жолды таңдау'),
          _L('Спрашивать совета у большинства', 'Көпшіліктен кеңес сұрау'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Фреймворк проецирует тебя в старость и минимизирует сожаление, а не сиюминутный '
          'страх. Это инструмент для крупных стратегических решений.',
          'Фреймворк сені қартайған шаққа жобалап, сәттік қорқынышты емес, өкінішті азайтады. '
          'Бұл ірі стратегиялық шешімдерге арналған құрал.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l4_10',
      code: '4.10',
      title: 'Относительное преимущество против абсолютного: твоя специализация',
      blocks: [
        _essence(_L(
          'Закон сравнительного преимущества Давида Рикардо (1817) — одна из самых '
          'контринтуитивных идей экономики. Суть: выгоднее сфокусироваться на том, что ты '
          'делаешь ОТНОСИТЕЛЬНО лучше всего, и отсечь остальное — даже если в абсолюте кто-то '
          'делает это лучше тебя.',
          'Давид Рикардоның салыстырмалы артықшылық заңы (1817) — экономиканың ең '
          'контринтуитивті идеяларының бірі. Мәні: өзің САЛЫСТЫРМАЛЫ ең жақсы істейтінге '
          'шоғырланып, қалғанын кесіп тастаған тиімді — тіпті абсолютте біреу оны сенен жақсы '
          'істесе де.',
        )),
        _rule(_L(
          'В трейдинге: не пытайся торговать 40 инструментов и 10 стратегий одновременно. '
          'Выбери одну-две связки (например, золото на откатах в сессию США) и доведи до '
          'мастерства. Глубина бьёт ширину. Узкий специалист всегда обыграет «мастера на все '
          'руки».',
          'Трейдингте: 40 құрал мен 10 стратегияны қатар саудаламақ болма. Бір-екі байланысты '
          '(мысалы, АҚШ сессиясындағы откаттарда алтын) таңдап, шеберлікке жеткіз. Тереңдік '
          'енді жеңеді. Тар маман әрдайым «бәрін істейтін шеберді» ұтады.'),
          title: _L('Специализация', 'Мамандану'),
        ),
        _fact(_L(
          'Рикардо был не только экономистом, но и одним из самых успешных биржевых '
          'спекулянтов своего времени. Он сделал состояние на государственных облигациях во '
          'время битвы при Ватерлоо в 1815 году, поняв исход раньше рынка. Его правило: '
          '«Режь убытки, дай прибыли течь» — звучит из уст человека, который реально '
          'разбогател на бирже 200 лет назад.',
          'Рикардо тек экономист емес, өз заманының ең табысты биржа алыпсатарларының бірі '
          'болды. Ол 1815 жылы Ватерлоо шайқасы кезінде нәтижені нарықтан бұрын түсініп, '
          'мемлекеттік облигацияларда байлық тапты. Оның ережесі: «Зиянды кес, пайданы ағызып '
          'жібер» — 200 жыл бұрын биржада шынымен байыған адамның аузынан шыққан.',
        )),
        _example(_L(
          'Трейдер, который «понемногу знает всё» — про крипту, акции, форекс, опционы — '
          'проигрывает узкому специалисту по одному сетапу на одном инструменте. Распыление '
          'внимания = посредственность везде. Фокус = преимущество в одном месте.',
          '«Бәрін аздан білетін» трейдер — крипто, акция, форекс, опцион — бір құралдағы бір '
          'сетап бойынша тар маманнан ұтылады. Назарды шашырату = бәрінде орташалық. Фокус = '
          'бір жерде артықшылық.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Что советует закон сравнительного преимущества трейдеру?',
          'Салыстырмалы артықшылық заңы трейдерге нені кеңес береді?',
        ),
        options: [
          _L('Торговать максимум инструментов сразу', 'Бірден барынша көп құрал саудалау'),
          _L('Сфокусироваться на 1–2 стратегиях и довести их до мастерства', '1–2 стратегияға шоғырланып, оларды шеберлікке жеткізу'),
          _L('Копировать чужие сделки', 'Бөгде мәмілелерді көшіру'),
          _L('Менять стратегию каждую неделю', 'Әр апта сайын стратегияны ауыстыру'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Сравнительное преимущество = фокус на том, что получается лучше всего. Узкая '
          'специализация даёт глубину и устойчивое преимущество.',
          'Салыстырмалы артықшылық = ең жақсы шығатынға фокус. Тар мамандану тереңдік пен '
          'тұрақты артықшылық береді.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l4_11',
      code: '4.11',
      title: 'Серое восприятие, чёрно-белое решение',
      blocks: [
        _essence(_L(
          'Профессионала отличает умение переключать два режима мышления. Этап АНАЛИЗА должен '
          'быть «серым»: ты обязан видеть все риски, контраргументы и альтернативные сценарии. '
          'Но этап ИСПОЛНЕНИЯ — «чёрно-белый»: решение принято, нажал кнопку и следуй плану '
          'без сомнений.',
          'Кәсіпқойды екі ойлау режимін ауыстыра білу ерекшелейді. ТАЛДАУ кезеңі «сұр» болуы '
          'керек: барлық тәуекелді, қарсы дәлелді, балама сценарийді көруге міндеттісің. Бірақ '
          'ОРЫНДАУ кезеңі — «ақ-қара»: шешім қабылданды, батырманы бастың да, күмәнсіз жоспарға '
          'ер.',
        )),
        _rule(_L(
          'Две фазы — два разных мозга:\n'
          '• Анализ (серый): сомневайся, ищи, почему сделка может НЕ сработать, взвешивай '
          'вероятности. Здесь скепсис — твой друг.\n'
          '• Исполнение (чёрно-белое): план есть — действуй механически. Здесь сомнение — '
          'твой враг, оно ведёт к передвиганию стопов и панике.',
          'Екі фаза — екі түрлі ми:\n'
          '• Талдау (сұр): күмәндан, мәміле неге ІСТЕМЕЙ қалуы мүмкін екенін ізде, '
          'ықтималдықты өлше. Мұнда скепсис — досың.\n'
          '• Орындау (ақ-қара): жоспар бар — механикалық әрекет ет. Мұнда күмән — жауың, ол '
          'стоп жылжытуға және дүрбелеңге апарады.'),
          title: _L('Две фазы', 'Екі фаза'),
        ),
        _fact(_L(
          'Военные лётчики и спецназ тренируют ровно это разделение: на брифинге они часами '
          'разбирают все варианты провала (серая фаза), но в бою действуют по отработанному '
          'протоколу без раздумий (чёрно-белая фаза). Колебание в момент исполнения стоит '
          'жизни — в бою и денег — в трейдинге.',
          'Әскери ұшқыштар мен арнайы жасақ дәл осы бөлінуді жаттықтырады: брифингте сәтсіздіктің '
          'барлық нұсқасын сағаттап талдайды (сұр фаза), бірақ ұрыста ойланбай, пысықталған '
          'хаттамамен әрекет етеді (ақ-қара фаза). Орындау сәтіндегі тартыншақтық — ұрыста өмірге, '
          'трейдингте ақшаға түседі.',
        )),
        _example(_L(
          'Трейдер, который сомневается на этапе анализа и отказывается от слабой сделки — '
          'мудр. Трейдер, который вошёл по плану, а потом начал «передумывать», двигать стоп '
          'и закрывать руками из страха — теряет деньги на эмоциях, разрушая собственную '
          'статистику.',
          'Талдау кезеңінде күмәнданып, әлсіз мәміледен бас тартқан трейдер — дана. Жоспармен '
          'кіріп, сосын «ойын өзгерте» бастаған, стопты жылжытқан, қорқыныштан қолмен жапқан '
          'трейдер — эмоцияда ақша жоғалтып, өз статистикасын бұзады.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Когда уместны сомнения и поиск контраргументов?',
          'Күмән мен қарсы дәлел іздеу қашан орынды?',
        ),
        options: [
          _L('Во время исполнения уже открытой сделки', 'Ашылған мәмілені орындау кезінде'),
          _L('На этапе анализа, до входа («серая» фаза)', 'Талдау кезеңінде, кіргенге дейін («сұр» фаза)'),
          _L('Никогда — сомнения вредны', 'Ешқашан — күмән зиянды'),
          _L('Только после закрытия сделки', 'Тек мәмілені жапқаннан кейін'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Сомневайся на этапе анализа (видь все риски). Но как только вошёл — исполняй план '
          'чётко, без метаний. Анализ серый, исполнение чёрно-белое.',
          'Талдау кезеңінде күмәндан (барлық тәуекелді көр). Бірақ кіргеннен кейін — жоспарды '
          'анық, тартыншақсыз орында. Талдау — сұр, орындау — ақ-қара.',
        ),
      ),
    ),
  ],
);

// ════════════════════════════════════════════════════════════════════
// МОДУЛЬ 5. Анатомия экономических чудес
// ════════════════════════════════════════════════════════════════════
CourseModule _module5() => CourseModule(
  id: 'm5',
  index: 5,
  title: 'Анатомия экономических чудес: как взлетали и падали ТОП-5 экономик',
  goal:
      'На реальных примерах показать, как государственные решения и кризисы меняют баланс '
      'сил на планете. Уроки для долгосрочного инвестора.',
  lessons: [
    CourseLesson(
      id: 'l5_1',
      code: '5.1',
      title: 'США: капитализм на стероидах, экспорт долга и пузыри',
      blocks: [
        _essence(_L(
          'США — крупнейшая экономика мира (~25% мирового ВВП), построенная на потреблении, '
          'гигантском внутреннем рынке, инновациях и уникальном статусе доллара как мировой '
          'валюты. Это позволяет Америке жить в долг так, как не может ни одна другая страна.',
          'АҚШ — әлемнің ең ірі экономикасы (әлемдік ЖІӨ-нің ~25%), тұтынуға, алып ішкі '
          'нарыққа, инновацияға және доллардың әлемдік валюта мәртебесіне құрылған. Бұл Америкаға '
          'басқа ешбір ел жасай алмайтындай қарызбен өмір сүруге мүмкіндік береді.',
        )),
        _p(_L(
          'Взлёт: после двух мировых войн США оказались единственной крупной экономикой без '
          'разрушений на своей территории. Они создали Бреттон-Вудскую и нефтедолларовую '
          'системы, закрепив доллар в центре мира.',
          'Көтерілу: екі дүниежүзілік соғыстан кейін АҚШ өз аумағы қираудан аман жалғыз ірі '
          'экономика болды. Олар Бреттон-Вудс және мұнайдоллар жүйелерін құрып, долларды әлем '
          'орталығына бекітті.',
        )),
        _p(_L(
          'Особенность: культура потребления и предпринимательства, Кремниевая долина, '
          'венчурный капитал, статус USD как «всемирного кошелька».',
          'Ерекшелігі: тұтыну мен кәсіпкерлік мәдениеті, Кремний алқабы, венчурлік капитал, '
          'доллардың «бүкіләлемдік әмиян» мәртебесі.',
        )),
        CardsBlock(_L('4 секрета американского успеха', 'Америка табысының 4 құпиясы'), [
          CardItem('🔬', _L('Инновации', 'Инновация'), _L('Эдисон, Форд, Джобс, Маск. США — магнит для лучших умов мира.', 'Эдисон, Форд, Джобс, Маск. АҚШ — әлемнің ең үздік ақылдарының магниті.')),
          CardItem('🌍', _L('Иммиграция талантов', 'Таланттар иммиграциясы'), _L('Google основал россиянин Сергей Брин, Yahoo — тайванец Джерри Янг.', 'Google-ды ресейлік Сергей Брин, Yahoo-ны тайвандық Джерри Янг құрды.')),
          CardItem('⚖️', _L('Верховенство права', 'Заң үстемдігі'), _L('Защита собственности и контрактов. Бизнес доверяет системе.', 'Меншік пен келісімдерді қорғау. Бизнес жүйеге сенеді.')),
          CardItem('💵', _L('Сила доллара', 'Доллар күші'), _L('Мировая резервная валюта — Америка занимает у всего мира.', 'Әлемдік резервтік валюта — Америка бүкіл әлемнен қарыз алады.')),
        ]),
        _fact(_L(
          'Госдолг США превысил \$34 триллиона — это более \$100 000 на каждого американца, '
          'включая младенцев. Проценты по этому долгу уже сопоставимы с военным бюджетом. '
          'Но пока мир готов покупать американские облигации как «самый безопасный актив», '
          'машина продолжает работать.',
          'АҚШ мемлекеттік қарызы \$34 триллионнан асты — бұл әр американдыққа, нәрестелерді '
          'қоса, \$100 000-нан астам. Бұл қарыздың пайызы әскери бюджетпен салыстырмалы болды. '
          'Бірақ әлем американдық облигацияларды «ең қауіпсіз актив» ретінде сатып алуға дайын '
          'болғанша, машина жұмыс істей береді.',
        )),
        _warn(_L(
          'Уязвимости: хронический дефицит бюджета, экспоненциальный рост госдолга, '
          'политическая поляризация и риск, что однажды мир усомнится в долларе. Тот день '
          'станет величайшим финансовым событием века.',
          'Осалдықтар: созылмалы бюджет тапшылығы, мемлекеттік қарыздың экспоненциалды өсуі, '
          'саяси поляризация және бір күні әлем долларға күмәндану қаупі. Ол күн ғасырдың ең ұлы '
          'қаржы оқиғасы болады.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Главная структурная уязвимость экономики США?',
          'АҚШ экономикасының басты құрылымдық осалдығы?',
        ),
        options: [
          _L('Нехватка внутреннего рынка', 'Ішкі нарықтың жетіспеуі'),
          _L('Гигантский госдолг и риск потери доверия к доллару', 'Алып мемлекеттік қарыз және долларға сенімнен айырылу қаупі'),
          _L('Отсутствие технологий', 'Технологияның жоқтығы'),
          _L('Слабая валюта', 'Әлсіз валюта'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Сила США — мировой статус доллара. Но обратная сторона — растущий госдолг и '
          'хронический дефицит, что создаёт долгосрочный риск доверия к USD.',
          'АҚШ күші — доллардың әлемдік мәртебесі. Бірақ кері жағы — өсіп жатқан мемлекеттік '
          'қарыз бен созылмалы тапшылық, бұл USD-ге сенімнің ұзақмерзімді қаупін тудырады.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l5_2',
      code: '5.2',
      title: 'Япония: от пепла до роботов и ловушка «потерянных десятилетий»',
      blocks: [
        _essence(_L(
          'Послевоенное японское чудо — образец дисциплины и качества. Из руин 1945 года '
          'Япония за 40 лет стала второй экономикой мира, грозой американского автопрома и '
          'электроники. Но затем последовал самый поучительный для трейдера крах в истории.',
          'Соғыстан кейінгі жапон кереметі — тәртіп пен сапаның үлгісі. 1945 жылғы қираудан '
          'Жапония 40 жылда әлемнің екінші экономикасына, америка автопромы мен электроникасының '
          'үрейіне айналды. Бірақ сосын трейдер үшін тарихтағы ең тағылымды күйреу болды.',
        )),
        _p(_L(
          'Взлёт: восстановление с помощью США, корпорации-кейрецу, культ качества (Toyota, '
          'Sony), фокус на технологии и экспорт. В 1980-е казалось, что Япония скупит весь мир.',
          'Көтерілу: АҚШ көмегімен қалпына келу, кейрецу корпорациялары, сапа культі (Toyota, '
          'Sony), технология мен экспортқа фокус. 1980-ші жылдары Жапония бүкіл әлемді сатып '
          'алатындай көрінді.',
        )),
        _fact(_L(
          'На пике пузыря в 1989 году земля под императорским дворцом в Токио стоила, по '
          'оценкам, дороже ВСЕЙ недвижимости штата Калифорния. А территория Японии — дороже '
          'всех Соединённых Штатов. Это была самая грандиозная переоценка активов в истории.',
          '1989 жылы көпіршік шыңында Токиодағы император сарайының астындағы жер, бағалаулар '
          'бойынша, БҮКІЛ Калифорния штатының жылжымайтын мүлкінен қымбат тұрды. Ал Жапония '
          'аумағы — бүкіл Құрама Штаттардан қымбат. Бұл тарихтағы ең ұлы актив қайта бағалануы еді.',
        )),
        _story(_L(
          'Японский индекс Nikkei на пике 1989 года достиг почти 39 000 пунктов. Затем пузырь '
          'недвижимости и акций лопнул. Последовали «потерянные десятилетия» — стагнация и '
          'дефляция. Nikkei вернулся к тем уровням лишь спустя ~34 года, в 2024-м! Целое '
          'поколение инвесторов, купивших «на хаях», не видело прибыли всю жизнь.',
          'Жапон Nikkei индексі 1989 жыл шыңында 39 000 пунктке жуықтады. Сосын жылжымайтын '
          'мүлік пен акция көпіршігі жарылды. «Жоғалған ондаған жылдар» — тоқырау мен дефляция '
          'келді. Nikkei сол деңгейге тек ~34 жылдан кейін, 2024-те оралды! «Шыңда» сатып алған '
          'бүкіл бір буын инвестор бүкіл өмірінде пайда көрмеді.'),
          title: _L('34 года, чтобы вернуться в ноль', 'Нөлге оралуға 34 жыл'),
        ),
        _rule(_L(
          'Главный урок Японии для трейдера: миф «рынок всегда восстанавливается быстро» — '
          'ложь. Рынок может не расти ДЕСЯТИЛЕТИЯМИ. Поэтому слепое «купи и держи» без '
          'риск-менеджмента может стоить тебе целой жизни ожидания.',
          'Жапонияның трейдерге басты сабағы: «нарық әрдайым тез қалпына келеді» мифі — өтірік. '
          'Нарық ОНДАҒАН ЖЫЛ өспеуі мүмкін. Сондықтан тәуекел-менеджментсіз соқыр «сатып ал да '
          'ұста» саған бүкіл өмірлік күтуге түсуі мүмкін.'),
          title: _L('Урок из Японии', 'Жапониядан сабақ'),
        ),
        _warn(_L(
          'Уязвимости сегодня: рекордное старение населения, гигантский госдолг (>250% ВВП) и '
          'десятилетия около-нулевых ставок.',
          'Бүгінгі осалдықтар: халықтың рекордты қартаюы, алып мемлекеттік қарыз (ЖІӨ-нің >250%) '
          'және ондаған жылдық нөлге жуық ставкалар.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Какой главный урок для трейдера несёт история Японии после 1990?',
          '1990-нан кейінгі Жапония тарихы трейдерге қандай басты сабақ береді?',
        ),
        options: [
          _L('Рынки всегда растут в долгосроке', 'Нарықтар ұзақмерзімде әрдайым өседі'),
          _L('Рынки могут не расти десятилетиями (стагнация возможна)', 'Нарықтар ондаған жыл өспеуі мүмкін (тоқырау ықтимал)'),
          _L('Недвижимость не падает', 'Жылжымайтын мүлік түспейді'),
          _L('Технологии гарантируют рост рынка', 'Технология нарық өсуіне кепілдік береді'),
        ],
        correctIndex: 1,
        explanation: _L(
          'После краха пузыря 1990 года японский рынок стагнировал ~34 года. Это опровергает '
          'миф, что «рынок всегда восстанавливается быстро».',
          '1990 жылғы көпіршік күйреуінен кейін жапон нарығы ~34 жыл тоқырады. Бұл «нарық әрдайым '
          'тез қалпына келеді» мифін жоққа шығарады.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l5_3',
      code: '5.3',
      title: 'Сингапур: из третьего мира в первый за одно поколение',
      blocks: [
        _essence(_L(
          'Сингапур — главное доказательство того, что не ресурсы делают страну богатой, а '
          'институты и решения. Крошечный остров без природных богатств, без своей воды и даже '
          'без песка для строительства стал одним из богатейших государств планеты за ~30 лет.',
          'Сингапур — елді ресурс емес, институттар мен шешімдер бай ететінінің басты дәлелі. '
          'Табиғи байлығы жоқ, өз суы, тіпті құрылысқа құмы жоқ кішкентай арал ~30 жылда '
          'планетаның ең бай мемлекеттерінің біріне айналды.',
        )),
        _p(_L(
          'Взлёт: гений Ли Куан Ю, который превратил коррумпированный портовый город в '
          'финансовую столицу Азии. Ставка на образование, верховенство закона и '
          'привлечение мирового капитала.',
          'Көтерілу: жемқор порт қаласын Азияның қаржы астанасына айналдырған Ли Куан Юдың '
          'данышпандығы. Білімге, заң үстемдігіне және әлемдік капиталды тартуға бағыт.',
        )),
        _fact(_L(
          'Сингапуру приходится ИМПОРТИРОВАТЬ питьевую воду и даже песок для расширения '
          'территории. При этом по ВВП на душу населения он обогнал бывшую метрополию — '
          'Великобританию. Чистый интеллект и правильные институты победили отсутствие '
          'ресурсов.',
          'Сингапур ауыз суды, тіпті аумақты кеңейтуге құмды ИМПОРТТАУҒА мәжбүр. Сонда да жан '
          'басына шаққандағы ЖІӨ бойынша бұрынғы метрополия — Ұлыбританияны басып озды. Таза '
          'интеллект пен дұрыс институттар ресурс жоқтығын жеңді.',
        )),
        _warn(_L(
          'Уязвимости: полная зависимость от здоровья мировой торговли. Как только в мире '
          'кризис и торговые потоки сжимаются — Сингапур, живущий на транзите и финансах, '
          'штормит одним из первых.',
          'Осалдықтар: әлемдік сауданың денсаулығына толық тәуелділік. Әлемде дағдарыс болып, '
          'сауда ағындары қысқарған сәтте — транзит пен қаржыға тәуелді Сингапурды бірінші '
          'болып дауыл шайқайды.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Что стало фундаментом экономического чуда Сингапура?',
          'Сингапур экономикалық кереметінің іргетасы не болды?',
        ),
        options: [
          _L('Богатые природные ресурсы', 'Бай табиғи ресурстар'),
          _L('Верховенство закона, борьба с коррупцией, открытость для капитала', 'Заң үстемдігі, жемқорлықпен күрес, капиталға ашықтық'),
          _L('Большое население', 'Үлкен халық саны'),
          _L('Военная мощь', 'Әскери қуат'),
        ],
        correctIndex: 1,
        explanation: _L(
          'У Сингапура не было ресурсов. Успех построен на институтах: законность, нулевая '
          'коррупция и привлекательность для мирового капитала.',
          'Сингапурдың ресурсы болмады. Табыс институттарға құрылды: заңдылық, нөлдік жемқорлық '
          'және әлемдік капитал үшін тартымдылық.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l5_4',
      code: '5.4',
      title: 'Китай: фабрика планеты и госкапитализм',
      blocks: [
        _essence(_L(
          'Китай совершил самый быстрый и массовый экономический рывок в истории человечества: '
          'за 40 лет более 800 миллионов человек вышли из нищеты. Уникальная модель — '
          'коммунистический политический контроль в связке с диким рыночным капитализмом.',
          'Қытай адамзат тарихындағы ең жылдам әрі ауқымды экономикалық серпіліс жасады: '
          '40 жылда 800 миллионнан астам адам кедейліктен шықты. Бірегей модель — коммунистік '
          'саяси бақылау мен жабайы нарықтық капитализмнің тұтасуы.',
        )),
        _p(_L(
          'Взлёт: реформы Дэн Сяопина с 1978 года, свободные экономические зоны, дешёвая '
          'рабочая сила и государственная стратегия «стать фабрикой мира».',
          'Көтерілу: Дэн Сяопиннің 1978 жылдан реформалары, еркін экономикалық аймақтар, арзан '
          'жұмыс күші және «әлем фабрикасы болу» мемлекеттік стратегиясы.',
        )),
        _fact(_L(
          'За три года (2011–2013) Китай использовал больше цемента, чем США за весь XX век. '
          'Масштаб строительства и индустриализации был настолько колоссальным, что менял '
          'мировые цены на сырьё — железную руду, медь, уголь — и кормил экономики целых '
          'стран-экспортёров.',
          'Үш жылда (2011–2013) Қытай АҚШ-тың бүкіл XX ғасырда қолданғанынан көп цемент жұмсады. '
          'Құрылыс пен индустрияландыру ауқымы сонша зор болды — ол шикізатқа (темір кені, мыс, '
          'көмір) әлемдік бағаны өзгертіп, тұтас экспорттаушы елдердің экономикасын асырады.',
        )),
        _p(_L(
          'Особенность: долгие годы Китай искусственно удерживал курс юаня заниженным, чтобы '
          'его товары были дешёвыми на мировых рынках и захватывали долю за долей.',
          'Ерекшелігі: Қытай ұзақ жылдар юань бағамын жасанды түрде төмен ұстады — тауарлары '
          'әлемдік нарықта арзан болып, үлесті бірте-бірте жаулап алу үшін.',
        )),
        _warn(_L(
          'Уязвимости: кризис закредитованности сектора недвижимости (история Evergrande), '
          'стремительное старение населения как наследие политики «одна семья — один ребёнок», '
          'и нарастающие торговые войны с США.',
          'Осалдықтар: жылжымайтын мүлік секторының қарызға белшесінен батуы (Evergrande '
          'тарихы), «бір отбасы — бір бала» саясатының мұрасы ретіндегі халықтың жедел қартаюы '
          'және АҚШ-пен өршіп бара жатқан сауда соғыстары.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Как Китай долго стимулировал свой экспорт?',
          'Қытай экспортын ұзақ уақыт қалай ынталандырды?',
        ),
        options: [
          _L('Укреплял юань', 'Юаньды нығайтты'),
          _L('Искусственно удерживал курс юаня дешёвым', 'Юань бағамын жасанды түрде арзан ұстады'),
          _L('Повышал зарплаты рабочим', 'Жұмысшылардың жалақысын көтерді'),
          _L('Запрещал иностранные инвестиции', 'Шетел инвестицияларына тыйым салды'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Дешёвый юань делал китайские товары конкурентными на мировых рынках. Это ключевой '
          'инструмент экспортной модели Китая.',
          'Арзан юань қытай тауарларын әлемдік нарықта бәсекеге қабілетті етті. Бұл — Қытайдың '
          'экспорттық моделінің негізгі құралы.',
        ),
      ),
    ),
    CourseLesson(
      id: 'l5_5',
      code: '5.5',
      title: 'Германия: дисциплина, локомотив Европы и культ «Ordnung»',
      blocks: [
        _essence(_L(
          'Германия — экономический мотор Европы, построенный на инженерной точности, качестве '
          'и порядке («Ordnung»). После полного разрушения во Второй мировой она восстала за '
          'десятилетие — это назвали «немецким экономическим чудом» (Wirtschaftswunder).',
          'Германия — инженерлік дәлдікке, сапаға және тәртіпке («Ordnung») құрылған Еуропа '
          'экономикалық моторы. Екінші дүниежүзілік соғыстағы толық қираудан кейін ол он жылда '
          'қайта көтерілді — мұны «неміс экономикалық кереметі» (Wirtschaftswunder) деп атады.',
        )),
        _p(_L(
          'Взлёт: чудо 1950-х, план Маршалла, денежная реформа и культура труда. Германия '
          'стала главным экспортёром Евросоюза и одной из ведущих промышленных держав мира.',
          'Көтерілу: 1950-ші жылдар кереметі, Маршалл жоспары, ақша реформасы және еңбек '
          'мәдениеті. Германия Еуроодақтың басты экспорттаушысы әрі әлемнің жетекші өнеркәсіп '
          'державаларының біріне айналды.',
        )),
        _fact(_L(
          'Секретное оружие Германии — Mittelstand: тысячи семейных средних компаний, о '
          'которых никто не слышал, но которые являются мировыми монополистами в узких '
          'нишах. Их называют «скрытыми чемпионами» (hidden champions) — например, компания, '
          'делающая 70% мировых машин для производства упаковки или особых станков.',
          'Германияның құпия қаруы — Mittelstand: ешкім естімеген, бірақ тар салаларда әлемдік '
          'монополист болатын мыңдаған отбасылық орта компания. Оларды «жасырын чемпиондар» '
          '(hidden champions) дейді — мысалы, әлемдік қаптама машиналарының немесе арнайы '
          'станоктардың 70%-ын жасайтын компания.',
        )),
        _warn(_L(
          'Уязвимости: критическая зависимость от импорта дешёвой энергии (что больно ударило '
          'в энергокризис), тяжёлая бюрократия и роль «спонсора», который вынужден на своих '
          'плечах вытягивать экономически слабые страны Еврозоны.',
          'Осалдықтар: арзан энергия импортына сыни тәуелділік (энергодағдарыста қатты соққы '
          'болды), ауыр бюрократия және Еврозонаның экономикалық әлсіз елдерін өз иығымен '
          'тартуға мәжбүр «демеуші» рөлі.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'Что такое немецкий Mittelstand?',
          'Неміс Mittelstand дегеніміз не?',
        ),
        options: [
          _L('Государственные гиганты-монополисты', 'Мемлекеттік алып монополистер'),
          _L('Семейный высокотехнологичный средний бизнес — лидеры узких ниш', 'Отбасылық жоғары технологиялық орта бизнес — тар сала көшбасшылары'),
          _L('Сеть розничных магазинов', 'Бөлшек дүкендер желісі'),
          _L('Банковский картель', 'Банк картелі'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Mittelstand — костяк немецкой экономики: средние семейные компании, доминирующие '
          'в узких высокотехнологичных нишах мирового рынка («скрытые чемпионы»).',
          'Mittelstand — неміс экономикасының тірегі: әлемдік нарықтың тар жоғары технологиялық '
          'салаларында үстемдік ететін орта отбасылық компаниялар («жасырын чемпиондар»).',
        ),
      ),
    ),
    CourseLesson(
      id: 'l5_6',
      code: '5.6',
      title: 'Казахстан: наш путь и наш потенциал',
      blocks: [
        _essence(_L(
          'Казахстан — 9-я по территории страна мира с огромными природными богатствами и '
          'молодой нацией. Мы стоим на перекрёстке между Китаем, Россией и Европой. Понимать '
          'свою экономику — значит видеть и риски, и реальные возможности для роста капитала.',
          'Қазақстан — аумағы бойынша әлемде 9-шы, орасан табиғи байлығы мен жас ұлты бар ел. '
          'Біз Қытай, Ресей және Еуропа арасындағы тоғыспада тұрмыз. Өз экономикаңды түсіну — '
          'тәуекелдерді де, капитал өсуінің нақты мүмкіндіктерін де көру деген сөз.',
        )),
        CardsBlock(_L('4 опоры экономики Казахстана', 'Қазақстан экономикасының 4 тірегі'), [
          CardItem('🛢️', _L('Ресурсы', 'Ресурстар'), _L('Нефть, газ, уран (№1 в мире!), медь, золото. Сырьевой фундамент.', 'Мұнай, газ, уран (әлемде №1!), мыс, алтын. Шикізат іргетасы.')),
          CardItem('🚉', _L('Транзит', 'Транзит'), _L('Мост между Китаем и Европой — Новый Шёлковый путь идёт через нас.', 'Қытай мен Еуропа арасындағы көпір — Жаңа Жібек жолы біз арқылы өтеді.')),
          CardItem('🌾', _L('Агро', 'Агро'), _L('Один из крупнейших экспортёров пшеницы в мире.', 'Әлемдегі ең ірі бидай экспорттаушыларының бірі.')),
          CardItem('🧑‍💻', _L('Молодёжь', 'Жастар'), _L('Молодая нация, рост IT (Astana Hub) и финтеха (Kaspi).', 'Жас ұлт, IT (Astana Hub) және финтех (Kaspi) өсімі.')),
        ]),
        _fact(_L(
          'Казахстан — мировой лидер по добыче урана: около 40% всего урана планеты добывается '
          'у нас. Топливо для каждой пятой атомной электростанции в мире — родом из казахстанской степи.',
          'Қазақстан — уран өндіруде әлем көшбасшысы: планета ураны­ның шамамен 40%-ы бізде '
          'өндіріледі. Әлемдегі әр бесінші атом электр станциясының отыны — қазақ даласынан.',
        )),
        _rule(_L(
          'Главный вызов — «ресурсное проклятие»: когда экономика зависит от цен на нефть, она '
          'растёт в годы дорогого сырья и страдает в годы дешёвого. Путь вперёд — диверсификация: '
          'переработка, технологии, человеческий капитал, а не только продажа сырья.',
          'Басты сын-қатер — «ресурс қарғысы»: экономика мұнай бағасына тәуелді болғанда, ол '
          'шикізат қымбат жылдары өсіп, арзан жылдары зардап шегеді. Алға жол — әртараптандыру: '
          'қайта өңдеу, технология, адами капитал, тек шикізат сату емес.'),
          title: _L('Ресурсное проклятие', 'Ресурс қарғысы'),
        ),
        _warn(_L(
          'Уязвимости: зависимость от цен на нефть и от соседей (логистика экспорта), '
          'необходимость диверсифицировать экономику и развивать собственную переработку и '
          'технологии, а не только экспортировать сырьё.',
          'Осалдықтар: мұнай бағасына және көршілерге тәуелділік (экспорт логистикасы), '
          'экономиканы әртараптандыру және тек шикізат экспорттамай, өз қайта өңдеуі мен '
          'технологиясын дамыту қажеттігі.',
        )),
        _p(_L(
          'Возможность для тебя: финансовая грамотность и инвестиции — это и есть личная '
          'диверсификация. Понимая глобальные рынки и золото, ты защищаешь свой капитал от '
          'локальных рисков — независимо от цены на нефть.',
          'Сен үшін мүмкіндік: қаржылық сауаттылық пен инвестиция — бұл жеке әртараптандыру. '
          'Жаһандық нарықтар мен алтынды түсініп, сен капиталыңды жергілікті тәуекелдерден '
          'қорғайсың — мұнай бағасына тәуелсіз.',
        )),
      ],
      quiz: QuizQuestion(
        question: _L(
          'В чём суть «ресурсного проклятия» для экономики Казахстана?',
          'Қазақстан экономикасы үшін «ресурс қарғысының» мәні неде?',
        ),
        options: [
          _L('Слишком мало природных ресурсов', 'Табиғи ресурс тым аз'),
          _L('Зависимость от цен на сырьё делает экономику уязвимой; нужна диверсификация', 'Шикізат бағасына тәуелділік экономиканы осал етеді; әртараптандыру керек'),
          _L('Ресурсы быстро заканчиваются за год', 'Ресурстар бір жылда тез таусылады'),
          _L('Ресурсы запрещено экспортировать', 'Ресурстарды экспорттауға тыйым салынған'),
        ],
        correctIndex: 1,
        explanation: _L(
          'Когда экономика держится на экспорте сырья, она зависит от мировых цен на нефть. '
          'Защита — диверсификация: переработка, технологии и человеческий капитал.',
          'Экономика шикізат экспортына сүйенгенде, ол әлемдік мұнай бағасына тәуелді. Қорғаныс '
          '— әртараптандыру: қайта өңдеу, технология және адами капитал.',
        ),
      ),
    ),
  ],
);

// ════════════════════════════════════════════════════════════════════
// МОДУЛЬ 6. Психология трейдинга
// ════════════════════════════════════════════════════════════════════
CourseModule _module6() => CourseModule(
  id: 'm6',
  index: 6,
  title: 'Психология трейдинга: война с собственным мозгом',
  goal:
      'Понять, почему большинство трейдеров теряют деньги не из-за стратегии, а из-за психики, '
      'и как взять свой мозг под контроль.',
  lessons: [
    CourseLesson(
      id: 'l6_1',
      code: '6.1',
      title: 'Древний мозг против рынка: почему миндалина саботирует твои сделки',
      blocks: [
        _essence(
          'Твой мозг создавался миллионы лет для выживания в саванне, а не для торговли '
          'золотом. На любую угрозу деньгам он реагирует так же, как на тигра: выбросом '
          'кортизола, паникой и режимом «бей или беги». Проблема в том, что на рынке эти '
          'древние инстинкты ведут тебя прямиком к разорению.',
        ),
        _h('Три мозга в одной голове'),
        _p('Рептильный мозг — выживание, инстинкты. Лимбическая система (миндалина/амигдала) — '
            'эмоции, страх. Неокортекс — логика, планирование. В момент стресса миндалина '
            'буквально «перехватывает управление» (amygdala hijack), отключая логику.'),
        _mechanic(
          'Видишь убыток → миндалина видит «угрозу жизни» → выброс кортизола → логика '
          'отключается → ты закрываешь хорошую сделку из страха или, наоборот, замираешь и '
          'смотришь, как растёт убыток. Это не слабость характера — это древняя биология.',
          title: 'Механика захвата мозга',
        ),
        _fact(
          'Дофамин — гормон не удовольствия, а ПРЕДВКУШЕНИЯ. Он выбрасывается перед '
          'потенциальной наградой. Поэтому открытие сделки даёт дофаминовый «приход» — мозг '
          'подсаживается на сам процесс торговли, как на азартную игру. Именно так трейдинг '
          'превращается в зависимость, а не в работу.',
        ),
        _rule(
          'Ты не можешь отключить древний мозг, но можешь его обойти: заранее прописанный план '
          'и автоматические стоп-лоссы принимают решения ЗА тебя, пока миндалина в панике. '
          'Система — это твой неокортекс, записанный на бумаге.',
          title: 'Как победить биологию',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Почему логика «отключается» в момент крупного убытка?',
        options: [
          'Из-за недостатка опыта',
          'Миндалина (амигдала) перехватывает управление в режиме «бей или беги»',
          'Из-за плохого интернета',
          'Потому что рынок манипулирует мозгом напрямую',
        ],
        correctIndex: 1,
        explanation:
            'Стресс активирует миндалину (amygdala hijack), выбрасывается кортизол, и '
            'рациональный неокортекс временно теряет контроль. Защита — заранее заготовленный '
            'план и автоматические стопы.',
      ),
    ),
    CourseLesson(
      id: 'l6_2',
      code: '6.2',
      title: 'Страх и жадность: два всадника апокалипсиса депозита',
      blocks: [
        _essence(
          'Весь рынок, по сути, колеблется между двумя эмоциями толпы: страхом и жадностью. '
          'Жадность надувает пузыри на вершинах, страх обваливает рынки на дне. Трейдер, '
          'который понимает свои эмоции, может торговать ПРОТИВ толпы — а это и есть путь к '
          'прибыли.',
        ),
        _h('Как они убивают депозит'),
        _p('Жадность: не фиксируешь прибыль, надеясь на «ещё чуть-чуть», входишь без плана на '
            'FOMO (страх упустить движение), увеличиваешь плечо после серии побед.'),
        _p('Страх: рано закрываешь прибыльную сделку, боишься войти в идеальный сетап, '
            'передвигаешь стоп от страха потери и в итоге теряешь больше.'),
        _rule(
          'Знаменитое правило Уоррена Баффета: «Бойся, когда другие жадничают, и будь жадным, '
          'когда другие боятся». Лучшие покупки делаются в момент всеобщей паники, лучшие '
          'продажи — в момент всеобщей эйфории. Иди против эмоций толпы.',
          title: 'Правило Баффета',
        ),
        _fact(
          'Существует официальный «Индекс страха и жадности» (CNN Fear & Greed Index), который '
          'измеряет настроение рынка от 0 (крайний страх) до 100 (крайняя жадность). Истори­чески '
          'отметки «крайнего страха» часто совпадали с отличными моментами для покупки, а '
          '«крайней жадности» — с вершинами перед коррекцией.',
        ),
        _story(
          'Существует «индикатор чистильщика обуви». Перед крахом 1929 года Джозеф Кеннеди '
          '(отец будущего президента) продал все акции после того, как чистильщик обуви начал '
          'давать ему советы по бирже. Его логика: если даже чистильщики покупают акции — '
          'покупать больше некому, рынок на вершине. Когда «все» жадничают — пора бояться.',
          title: 'Индикатор чистильщика обуви',
        ),
        _interactive('fear_greed', title: 'Индекс страха и жадности'),
      ],
      quiz: const QuizQuestion(
        question: 'Как звучит правило Баффета об эмоциях рынка?',
        options: [
          'Покупай, когда все покупают, продавай, когда все продают',
          'Бойся, когда другие жадничают; будь жадным, когда другие боятся',
          'Никогда не торгуй против тренда',
          'Эмоции рынка не имеют значения',
        ],
        correctIndex: 1,
        explanation:
            'Лучшие возможности возникают в крайних эмоциях толпы: покупать в панике (дёшево), '
            'продавать в эйфории (дорого). Торгуй против эмоций большинства.',
      ),
    ),
    CourseLesson(
      id: 'l6_3',
      code: '6.3',
      title: 'Тильт: как одна сделка превращается в слив депозита',
      blocks: [
        _essence(
          '«Тильт» — термин из покера: состояние, когда после убытка эмоции берут верх и ты '
          'начинаешь играть безрассудно, пытаясь «отыграться». В трейдинге тильт уничтожает '
          'больше депозитов, чем любые ошибки в анализе. Один проигрыш → месть рынку → каскад '
          'импульсивных сделок → ноль.',
        ),
        _h('Анатомия тильта'),
        _p('1. Убыточная сделка (особенно несправедливая — выбило стопом и развернулось).'),
        _p('2. Злость и желание немедленно вернуть деньги («месть рынку», revenge trading).'),
        _p('3. Вход без сетапа, с увеличенным объёмом, чтобы «отыграться быстрее».'),
        _p('4. Новый убыток → ещё больше злости → ещё больше объём. Спираль смерти.'),
        _warn(
          'Revenge trading (торговля из мести) — самый дорогой эмоциональный сбой. Рынку всё '
          'равно, сколько ты потерял; он не «должен» тебе отдать. Попытка силой вернуть деньги '
          'превращает контролируемый убыток в катастрофу.',
        ),
        _rule(
          'Правило «стоп-дня»: установи дневной лимит убытка (например, −3% от депозита). '
          'Достиг его — выключаешь терминал до завтра, без исключений. Также правило «двух '
          'убытков подряд»: после двух минусов делаешь паузу 30+ минут. Это разрывает спираль '
          'тильта механически.',
          title: 'Как разорвать спираль',
        ),
        _fact(
          'Профессиональные трейдеры в проп-фирмах работают под жёсткими правилами: дневной '
          'лимит убытка автоматически закрывает их доступ к терминалу. Это не недоверие — это '
          'признание того, что даже у профи бывает тильт, и от него нужна защита на уровне '
          'системы, а не силы воли.',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Что такое «revenge trading» (торговля из мести)?',
        options: [
          'Стратегия торговли против тренда',
          'Импульсивные сделки после убытка с целью быстро отыграться',
          'Торговля по новостям',
          'Закрытие всех позиций перед выходными',
        ],
        correctIndex: 1,
        explanation:
            'Revenge trading — попытка эмоционально «вернуть» потерянное, входя без сетапа и с '
            'повышенным объёмом. Это спираль тильта. Защита — стоп-день и паузы после убытков.',
      ),
    ),
    CourseLesson(
      id: 'l6_4',
      code: '6.4',
      title: 'Когнитивные искажения трейдера: баги в прошивке мозга',
      blocks: [
        _essence(
          'Наш мозг использует «быстрые шаблоны» (эвристики) для экономии энергии. В обычной '
          'жизни они полезны, но на рынке превращаются в систематические ошибки — когнитивные '
          'искажения. Зная их в лицо, ты перестаёшь быть их жертвой.',
        ),
        const CardsBlock('5 ловушек мышления', [
          CardItem('🔍', 'Confirmation bias', 'Ищешь инфо, что подтверждает сделку, игнорируя противоречащую.'),
          CardItem('💔', 'Loss aversion', 'Боль потери в 2 раза сильнее радости. Держишь убытки, рано режешь прибыль.'),
          CardItem('⚓', 'Anchoring', 'Цепляешься за цену входа как «справедливую». Рынку на неё плевать.'),
          CardItem('🕳️', 'Sunk cost', '«Я уже столько потерял, нельзя выходить» — и теряешь ещё больше.'),
          CardItem('🆕', 'Recency bias', 'Три победы подряд → «я гений» → завышаешь риск.'),
        ]),
        _fact(
          'Эффект Даннинга-Крюгера: новички с минимальным опытом часто переоценивают свои '
          'навыки сильнее всего — «пик глупости». Именно поэтому многие сливают депозит на '
          'волне первой удачной серии, искренне веря, что разгадали рынок. Истинная экспертиза '
          'приходит вместе со здоровым сомнением.',
        ),
        _rule(
          'Лучшее лекарство от искажений — торговый журнал. Когда ты записываешь причину '
          'входа ДО сделки и сверяешь с результатом, мозгу становится негде спрятать свои '
          'самообманы. Журнал — это зеркало, которое не льстит.',
          title: 'Противоядие',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Трейдер держит убыточную сделку, думая «я уже столько потерял, нельзя выходить». Какое это искажение?',
        options: [
          'Confirmation bias (подтверждение)',
          'Sunk cost (невозвратные затраты)',
          'Recency bias (свежесть)',
          'Anchoring (якорение)',
        ],
        correctIndex: 1,
        explanation:
            'Это ошибка невозвратных затрат: прошлые потери не должны влиять на текущее решение. '
            'Рационально оценивать сделку «с нуля», а не цепляться за уже потерянное.',
      ),
    ),
    CourseLesson(
      id: 'l6_5',
      code: '6.5',
      title: 'Дисциплина как мышца: ритуалы профессионалов',
      blocks: [
        _essence(
          'Дисциплина — это не врождённый дар «железных людей», а навык, который тренируется '
          'как мышца. Профессиональные трейдеры не полагаются на силу воли (она кончается к '
          'вечеру) — они строят систему ритуалов и среды, которая делает правильное поведение '
          'автоматическим.',
        ),
        _h('Ритуалы профи'),
        _p('• Пре-маркет рутина: анализ перед сессией, отметка ключевых уровней и новостей. '
            'Решения принимаются на холодную голову, ДО открытия позиций.'),
        _p('• Чек-лист входа: сделка только при галочке по всем пунктам. Нет галочки — нет '
            'сделки, без «ну почти».'),
        _p('• Пост-маркет разбор: запись сделок в журнал, анализ ошибок, без эмоций.'),
        _p('• Физика: сон, спорт, отсутствие торговли в усталости или на эмоциях.'),
        _fact(
          'Исследования показывают, что сила воли — исчерпаемый ресурс («истощение эго»). '
          'Судьи по УДО выносили заметно более суровые решения перед обедом, когда были '
          'голодны и уставшими. Вывод для трейдера: не полагайся на «соберись» — полагайся на '
          'правила и режим, которые работают, даже когда силы воли нет.',
        ),
        _rule(
          'Золотое правило дисциплины: сделай правильное поведение лёгким, а неправильное — '
          'трудным. Автостопы (правильное легко), удаление торгового приложения с телефона на '
          'ночь (импульс труден), фиксированный риск в настройках. Дизайн среды побеждает '
          'силу воли.',
          title: 'Дизайн вместо силы воли',
        ),
        _story(
          'Легендарный трейдер Пол Тюдор Джонс держал на стене фразу «Losers average losers» '
          '(неудачники усредняют убытки) — как постоянное напоминание не добавлять к минусовым '
          'позициям. Простой визуальный ритуал, защищающий от главной ошибки даже в моменты '
          'слабости.',
          title: 'Напоминание на стене',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Почему профи строят систему ритуалов, а не полагаются на силу воли?',
        options: [
          'Ритуалы выглядят профессионально',
          'Сила воли — исчерпаемый ресурс; система делает правильное поведение автоматическим',
          'Так требуют брокеры',
          'Чтобы торговать чаще',
        ],
        correctIndex: 1,
        explanation:
            'Сила воли истощается за день. Ритуалы, чек-листы и дизайн среды делают дисциплину '
            'автоматической, не завися от сиюминутной мотивации.',
      ),
    ),
  ],
);

// ════════════════════════════════════════════════════════════════════
// МОДУЛЬ 7. Технический анализ и Smart Money
// ════════════════════════════════════════════════════════════════════
CourseModule _module7() => CourseModule(
  id: 'm7',
  index: 7,
  title: 'Технический анализ и Smart Money: следы крупного капитала',
  goal:
      'Научиться читать график как карту намерений крупного игрока, а не как набор '
      'магических линий.',
  lessons: [
    CourseLesson(
      id: 'l7_1',
      code: '7.1',
      title: 'Структура рынка: язык, на котором говорит цена',
      blocks: [
        _essence(
          'Прежде чем рисовать индикаторы, нужно понять структуру рынка — самый базовый и '
          'честный язык цены. Рынок всегда находится в одном из трёх состояний: восходящий '
          'тренд, нисходящий тренд или флэт (диапазон). Всё остальное — детали.',
        ),
        _h('Алфавит структуры'),
        _p('Восходящий тренд = последовательность повышающихся максимумов (HH) и повышающихся '
            'минимумов (HL). Нисходящий = понижающиеся максимумы (LH) и минимумы (LL).'),
        _p('BOS (Break of Structure) — пробой структуры в сторону тренда: тренд продолжается. '
            'CHoCH (Change of Character) — слом характера: первый признак, что тренд может '
            'развернуться.'),
        _rule(
          'Торгуй ПО структуре, а не против неё. В восходящем тренде ищи покупки на откатах к '
          'повышающимся минимумам. Не пытайся ловить вершину — «тренд твой друг, пока он не '
          'сломался» (пока нет CHoCH).',
          title: 'Главное правило структуры',
        ),
        _fact(
          'Концепция структуры рынка старше всех индикаторов. Ещё в начале XX века Чарльз Доу '
          '(основатель Wall Street Journal и индекса Dow Jones) сформулировал «теорию Доу», в '
          'основе которой — те же повышающиеся/понижающиеся максимумы и минимумы. Современный '
          'Smart Money — это переупакованная классика.',
        ),
        _interactive('liquidity_grab', title: 'Охота за ликвидностью'),
      ],
      quiz: const QuizQuestion(
        question: 'Что сигнализирует CHoCH (Change of Character)?',
        options: [
          'Продолжение текущего тренда',
          'Первый признак возможного разворота тренда',
          'Выход важной новости',
          'Расширение спреда',
        ],
        correctIndex: 1,
        explanation:
            'CHoCH — слом характера движения, первый намёк на смену тренда. BOS, наоборот, '
            'подтверждает продолжение тренда.',
      ),
    ),
    CourseLesson(
      id: 'l7_2',
      code: '7.2',
      title: 'Ликвидность: где лежат стопы и почему цена идёт за ними',
      blocks: [
        _essence(
          'Крупному игроку (банку, фонду) нужно исполнить ОГРОМНЫЙ ордер. Но если он просто '
          'купит по рынку, цена улетит вверх раньше, чем он наберёт позицию. Ему нужна '
          'встречная ликвидность — чужие ордера. И он точно знает, где их искать: там, где '
          'толпа поставила свои стоп-лоссы.',
        ),
        _h('Где лежит ликвидность'),
        _p('Под очевидными минимумами и над очевидными максимумами. За круглыми уровнями '
            '(\$2000, \$2050). За «двойными вершинами/днами», которые видят все. Чем очевиднее '
            'уровень для толпы — тем больше там стопов, тем вкуснее он для крупного игрока.'),
        _mechanic(
          'Liquidity grab (снятие ликвидности): цена резко прокалывает уровень, выбивает стопы '
          'толпы (это даёт крупному игроку нужные встречные ордера), а затем разворачивается. '
          'Новичков выбило «по стопу у самого дна», а умные деньги набрали позицию.',
          title: 'Stop hunt в действии',
        ),
        _rule(
          'Переверни мышление: стоп-лосс под очевидным минимумом — это не «защита», а мишень. '
          'Профи ставят стопы чуть ДАЛЬШE толпы или входят ПОСЛЕ снятия ликвидности, когда '
          'цена уже выбила слабые руки и развернулась.',
          title: 'Не будь ликвидностью',
        ),
        _fact(
          'Термин «stop hunt» долго считали теорией заговора, пока регуляторы не оштрафовали '
          'крупнейшие банки на миллиарды долларов за манипуляции на рынке золота и форекса '
          '(дело о манипуляциях с лондонским фиксингом золота). Оказалось, охота за стопами — '
          'реальная практика, а не паранойя трейдеров.',
        ),
        _interactive('liquidity_grab', title: 'Охота за ликвидностью (Stop Hunt)'),
      ],
      quiz: const QuizQuestion(
        question: 'Зачем крупный игрок «снимает ликвидность» под минимумом перед разворотом вверх?',
        options: [
          'Чтобы напугать новичков ради забавы',
          'Чтобы получить встречные ордера (стопы толпы) для набора крупной позиции',
          'Это случайное движение без причины',
          'Чтобы расширить спред',
        ],
        correctIndex: 1,
        explanation:
            'Крупному ордеру нужна встречная ликвидность. Выбивая стопы толпы под минимумом, '
            'игрок получает достаточно встречных ордеров, чтобы набрать позицию, после чего '
            'цена разворачивается.',
      ),
    ),
    CourseLesson(
      id: 'l7_3',
      code: '7.3',
      title: 'Order Blocks и Fair Value Gaps: отпечатки крупного капитала',
      blocks: [
        _essence(
          'Когда крупный игрок входит в рынок, он оставляет следы — зоны, откуда начался '
          'мощный импульс. Эти зоны (ордер-блоки) и разрывы в цене (имбалансы) часто '
          'выступают магнитами и уровнями, к которым цена возвращается.',
        ),
        _h('Два ключевых понятия'),
        _p('Order Block (ордер-блок) — последняя свеча перед сильным импульсным движением. '
            'Считается, что именно здесь крупный игрок набрал позицию. Когда цена возвращается '
            'в эту зону — часто следует реакция (отскок).'),
        _p('Fair Value Gap / Imbalance (FVG) — разрыв, образованный тремя свечами, когда цена '
            'двигалась так быстро, что оставила «пустоту» без полноценной торговли. Рынок '
            'часто возвращается, чтобы «закрыть» этот разрыв.'),
        _rule(
          'Имбаланс — это «незавершённое дело» рынка. Резкое движение без отката оставляет FVG, '
          'и цена с высокой вероятностью вернётся заполнить его, прежде чем продолжить путь. '
          'Это даёт точки входа с хорошим RR.',
          title: 'Рынок не любит пустоту',
        ),
        _warn(
          'Не превращай график в кашу из десятков ордер-блоков и FVG. Эти концепции работают '
          'в КОНТЕКСТЕ структуры и ликвидности, а не сами по себе. Один валидный ордер-блок на '
          'старшем таймфрейме ценнее двадцати на минутках.',
        ),
        _fact(
          'Большая часть терминологии Smart Money (SMC/ICT) — это переосмысление того, что '
          'институциональные трейдеры делали десятилетиями под другими названиями: ордер-блок '
          'это, по сути, зона спроса/предложения, а имбаланс — разновидность гэпа. Суть важнее '
          'модных терминов.',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Что такое Fair Value Gap (имбаланс)?',
        options: [
          'Комиссия брокера',
          'Ценовой разрыв от быстрого движения, который рынок часто возвращается «закрыть»',
          'Уровень поддержки на дневном графике',
          'Индикатор объёма',
        ],
        correctIndex: 1,
        explanation:
            'FVG — «пустота», оставленная резким движением цены. Рынок не любит дисбаланс и '
            'часто возвращается заполнить разрыв, что даёт точки входа.',
      ),
    ),
    CourseLesson(
      id: 'l7_4',
      code: '7.4',
      title: 'Торговые сессии и киллзоны: время — это всё',
      blocks: [
        _essence(
          'Рынок золота торгуется почти круглосуточно, но не все часы равны. Объёмы, '
          'волатильность и «честность» движения сильно зависят от того, какая сессия активна. '
          'Торговать в мёртвый час — всё равно что ловить рыбу в пустом пруду.',
        ),
        _h('Три сессии'),
        _p('Азиатская (Токио): обычно спокойная, узкие диапазоны, накопление ликвидности.'),
        _p('Лондонская: открытие в ~13:00 по Астане — взрыв волатильности, часто задаёт '
            'направление дня.'),
        _p('Нью-Йоркская: ~18:30 по Астане, перекрытие с Лондоном (London/NY overlap) — '
            'пик ликвидности и самые сильные движения, особенно на новостях США.'),
        _rule(
          '«Киллзоны» (ICT killzones) — это окна повышенной активности (открытие Лондона, '
          'открытие Нью-Йорка), когда крупный капитал наиболее активен. Большинство чистых '
          'движений и снятий ликвидности происходят именно в эти окна.',
          title: 'Киллзоны',
        ),
        _fact(
          'Существует статистически заметный «эффект перекрытия»: когда Лондон и Нью-Йорк '
          'работают одновременно (примерно 18:30–21:00 по Астане), на рынок приходится '
          'наибольший объём торгов за сутки. Для золота это самое «рабочее» время дня.',
        ),
        _warn(
          'Азиатская сессия и поздняя ночь — время узких диапазонов и ложных движений. '
          'Новичок, торгующий в 3 часа ночи на скуке, чаще всего просто кормит спред брокеру. '
          'Качество входов важнее количества часов у экрана.',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Когда обычно происходят самые сильные движения по золоту?',
        options: [
          'В азиатскую сессию ночью',
          'В перекрытие Лондона и Нью-Йорка (пик ликвидности)',
          'В выходные дни',
          'Время суток не имеет значения',
        ],
        correctIndex: 1,
        explanation:
            'Перекрытие London/NY — пик объёма и волатильности. Крупный капитал наиболее '
            'активен в эти «киллзоны», там и рождаются основные движения.',
      ),
    ),
    CourseLesson(
      id: 'l7_5',
      code: '7.5',
      title: 'Объём и подтверждение: почему свеча без объёма врёт',
      blocks: [
        _essence(
          'Цена показывает, ЧТО произошло, а объём — НАСКОЛЬКО это серьёзно. Движение на '
          'большом объёме означает участие крупного капитала и склонно к продолжению. '
          'Движение на низком объёме — часто ловушка, ложный пробой, за которым следует '
          'разворот.',
        ),
        _rule(
          'Пробой уровня на РАСТУЩЕМ объёме — вероятно настоящий (крупные деньги участвуют). '
          'Пробой на ПАДАЮЩЕМ объёме — подозрителен, часто это ложный пробой (fakeout), '
          'созданный, чтобы выбить стопы.',
          title: 'Объём подтверждает движение',
        ),
        _p('На спотовом форексе и CFD «настоящего» биржевого объёма нет — брокер показывает '
            'лишь тиковый объём (число изменений цены). Для золота более показателен объём '
            'фьючерсов COMEX. Но даже тиковый объём помогает отличить импульс от вялого '
            'движения.'),
        _fact(
          'Принцип «объём предшествует цене» лежит в основе метода Ричарда Вайкоффа, '
          'разработанного ещё в 1910-х годах. Вайкофф учил «читать ленту» — видеть в потоке '
          'сделок действия крупного оператора. Современный анализ объёмов (VSA) — прямой '
          'наследник его идей вековой давности.',
        ),
        _warn(
          'Ложный пробой (fakeout) на низком объёме — классическая ловушка. Толпа видит '
          '«пробой важного уровня», запрыгивает в сделку, и тут цена разворачивается, выбивая '
          'их стопы. Всегда спрашивай: есть ли за этим движением объём?',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Пробой важного уровня произошёл на ПАДАЮЩЕМ объёме. О чём это говорит?',
        options: [
          'Пробой надёжный, можно смело входить',
          'Пробой подозрителен — вероятен ложный пробой (fakeout)',
          'Объём не важен для пробоев',
          'Это сигнал на немедленную покупку',
        ],
        correctIndex: 1,
        explanation:
            'Настоящий пробой подтверждается ростом объёма (участие крупных денег). Пробой на '
            'низком объёме часто оказывается ложным и служит для выбивания стопов.',
      ),
    ),
  ],
);

// ════════════════════════════════════════════════════════════════════
// МОДУЛЬ 8. Риск-менеджмент и торговая система
// ════════════════════════════════════════════════════════════════════
CourseModule _module8() => CourseModule(
  id: 'm8',
  index: 8,
  title: 'Риск-менеджмент и торговая система: инженерия выживания',
  goal:
      'Превратить набор случайных сделок в управляемый бизнес с предсказуемым риском.',
  lessons: [
    CourseLesson(
      id: 'l8_1',
      code: '8.1',
      title: 'Дродаун и психология ямы: почему −50% требует +100%',
      blocks: [
        _essence(
          'Дродаун (drawdown) — это просадка капитала от пика. Главная контринтуитивная '
          'правда трейдинга: убытки и прибыль НЕ симметричны. Чем глубже яма, тем '
          'непропорционально труднее из неё выбраться.',
        ),
        _formula(
          [
            'Восстановление = Убыток / (100 − Убыток) × 100',
            '',
            '−10% → нужно +11%',
            '−25% → нужно +33%',
            '−50% → нужно +100% (удвоиться!)',
            '−90% → нужно +900%',
          ],
          title: 'Математика просадки',
        ),
        _rule(
          'Главная задача трейдера — не заработать побольше, а НЕ ПОТЕРЯТЬ много. Маленькие '
          'просадки восстанавливаются легко; глубокие — почти никогда. Защита капитала '
          'важнее погони за прибылью.',
          title: 'Защита прежде всего',
        ),
        _fact(
          'Помимо математики, есть психологическая яма: после просадки −50% большинство '
          'трейдеров уже не способны торговать спокойно. Страх и желание «отыграться» '
          'разрушают дисциплину, и реальное восстановление становится ещё менее вероятным, '
          'чем требует чистая арифметика.',
        ),
        _interactive('drawdown', title: 'Математика просадки'),
      ],
      quiz: const QuizQuestion(
        question: 'Депозит просел на 50%. Сколько нужно заработать, чтобы вернуться к началу?',
        options: [
          '+50%',
          '+100% (удвоиться)',
          '+25%',
          '+75%',
        ],
        correctIndex: 1,
        explanation:
            'Убыток и восстановление несимметричны: 50/(100−50)×100 = +100%. Потеряв половину, '
            'нужно удвоить остаток. Поэтому глубокие просадки так опасны.',
      ),
    ),
    CourseLesson(
      id: 'l8_2',
      code: '8.2',
      title: 'Размер позиции и корреляции: не клади все яйца в одну корзину',
      blocks: [
        _essence(
          'Размер позиции — это решение №1 в каждой сделке, важнее точки входа. Профессионал '
          'сначала определяет, сколько он готов потерять (риск), и только потом из этого '
          'вычисляет объём. Новичок делает наоборот: «хочу заработать побольше» → ставит '
          'большой объём → разоряется.',
        ),
        _rule(
          'Правило фиксированного риска: рискуй одним и тем же малым процентом депозита на '
          'каждую сделку (обычно 0.5–2%). Размер позиции = (Депозит × Риск%) / Размер стопа. '
          'Объём подстраивается под стоп, а не наоборот.',
          title: 'Фиксированный фракционный риск',
        ),
        _h('Скрытая ловушка корреляций'),
        _p('Если ты открыл лонг по золоту, шорт по доллару (DXY) и лонг по серебру — кажется, '
            'что у тебя три разные сделки. На деле это ОДНА ставка против доллара. Если доллар '
            'резко вырастет, все три позиции уйдут в минус одновременно. Твой реальный риск в '
            '3 раза больше, чем ты думаешь.'),
        _warn(
          'Коррелированные позиции маскируют истинный риск. Считай не количество сделок, а '
          'количество независимых «ставок». Несколько позиций по одному драйверу (доллар, '
          'ставки) — это одна большая позиция.',
        ),
        _fact(
          'Гарри Марковиц получил Нобелевскую премию за «современную портфельную теорию», '
          'математически доказав ценность диверсификации. Её часто называют «единственным '
          'бесплатным обедом в инвестициях»: правильно подобранные некоррелированные активы '
          'снижают риск, не снижая ожидаемую доходность.',
        ),
        _interactive('position_size', title: 'Калькулятор размера позиции'),
      ],
      quiz: const QuizQuestion(
        question: 'Лонг золота + шорт доллара + лонг серебра одновременно — это...',
        options: [
          'Три независимые диверсифицированные сделки',
          'По сути одна большая ставка против доллара (риск утроен)',
          'Безопасная нейтральная позиция',
          'Хедж, который убирает весь риск',
        ],
        correctIndex: 1,
        explanation:
            'Все три позиции коррелированы и зависят от одного драйвера — доллара. При его росте '
            'все уйдут в минус разом. Реальный риск кратно выше, чем кажется.',
      ),
    ),
    CourseLesson(
      id: 'l8_3',
      code: '8.3',
      title: 'Торговый журнал: твой личный детектор лжи',
      blocks: [
        _essence(
          'Без журнала ты не трейдер, а игрок, который помнит только удачи и забывает провалы. '
          'Торговый журнал — единственный инструмент, который показывает ПРАВДУ о твоей '
          'торговле, без прикрас и самообмана. Это разница между «мне кажется» и «я знаю».',
        ),
        _h('Что записывать'),
        _p('• Скриншот графика на входе и выходе.'),
        _p('• Причину входа (какой сетап, по чек-листу ли).'),
        _p('• Размер риска, стоп, тейк, RR.'),
        _p('• Эмоциональное состояние (спокоен / на тильте / FOMO).'),
        _p('• Результат и — главное — соблюдал ли ты план (независимо от результата).'),
        _rule(
          'Оценивай сделку по соблюдению ПЛАНА, а не по результату. Сделка по плану, '
          'закрывшаяся в минус, — хорошая сделка. Сделка против плана, случайно вышедшая в '
          'плюс, — плохая сделка (ты поощряешь вредную привычку). Журнал ловит именно это.',
          title: 'Что на самом деле оценивать',
        ),
        _fact(
          'Многие профессиональные фонды нанимают отдельных людей и психологов для анализа '
          'журналов трейдеров — они ищут паттерны: в какое время суток, в каком настроении и '
          'на каких инструментах трейдер теряет деньги. Часто оказывается, что 80% убытков '
          'приносят 1–2 повторяющихся ошибки, видимые только в журнале.',
        ),
        _example(
          'Трейдер был уверен, что его стратегия убыточна. Журнал показал обратное: сама '
          'стратегия прибыльна, но все потери приходят от импульсивных сделок «вне системы» '
          'по пятницам вечером. Решение оказалось простым — не торговать в это время. Без '
          'журнала он бы выбросил рабочую стратегию.',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Сделка была исполнена строго по плану, но закрылась в убыток. Как её оценить?',
        options: [
          'Плохая сделка — ведь убыток',
          'Хорошая сделка — план соблюдён, убыток здесь нормальная часть статистики',
          'Нейтральная, не имеет значения',
          'Нужно срочно менять стратегию',
        ],
        correctIndex: 1,
        explanation:
            'Качество оценивается по соблюдению плана, а не по результату одной сделки. Убытки '
            'по системе неизбежны и нормальны; важно, что ты следовал правилам.',
      ),
    ),
    CourseLesson(
      id: 'l8_4',
      code: '8.4',
      title: 'Бэктест и форвард-тест: как не обмануть самого себя',
      blocks: [
        _essence(
          'Прежде чем рисковать деньгами, стратегию нужно проверить. Бэктест — прогон '
          'стратегии на исторических данных. Форвард-тест — проверка на новых данных в '
          'реальном времени (демо или малый объём). Без проверки ты торгуешь на вере, а вера '
          'на рынке стоит дорого.',
        ),
        _warn(
          'Главная ловушка — переоптимизация (curve fitting). Можно так подогнать параметры '
          'под прошлое, что на истории система покажет 99% прибыльных сделок... и развалится '
          'на реальном рынке. Идеальный бэктест часто означает не гениальную систему, а '
          'подгонку под шум прошлого.',
        ),
        _rule(
          'Признаки честного теста: достаточная выборка (сотни сделок, не 10), проверка на '
          'РАЗНЫХ периодах рынка (тренд, флэт, кризис), и обязательный форвард-тест на данных, '
          'которых система «не видела». Если стратегия работает только на одном идеальном '
          'отрезке — это иллюзия.',
          title: 'Как тестировать честно',
        ),
        _fact(
          'Печально известный фонд LTCM, которым руководили два нобелевских лауреата, имел '
          'безупречные математические модели на исторических данных. В 1998 году реальность '
          '(дефолт России) преподнесла сценарий, которого «не было в истории», и фонд рухнул, '
          'едва не обрушив мировую финансовую систему. Прошлое не равно будущему.',
        ),
        _example(
          'Трейдер строит систему, идеально работающую на бычьем рынке 2020–2021. Он в '
          'восторге и заходит на всю котлету. Но рынок 2022 года был медвежьим — система, '
          'не проверенная на падающем рынке, сливает депозит. Урок: тестируй на всех типах '
          'рынка.',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Что такое переоптимизация (curve fitting)?',
        options: [
          'Правильная настройка стратегии под рынок',
          'Подгонка параметров под прошлое так, что система не работает на новых данных',
          'Метод увеличения плеча',
          'Способ ускорить бэктест',
        ],
        correctIndex: 1,
        explanation:
            'Curve fitting — чрезмерная подгонка под исторический шум. Такая система блестит на '
            'бэктесте, но проваливается в реальности. Защита — форвард-тест и проверка на разных '
            'периодах.',
      ),
    ),
    CourseLesson(
      id: 'l8_5',
      code: '8.5',
      title: 'Чек-лист и торговый план профессионала',
      blocks: [
        _essence(
          'Торговый план — это конституция твоего трейдинга. Он превращает хаотичные решения '
          'в повторяемый процесс. Без письменного плана каждое решение принимается заново, на '
          'эмоциях, и статистика становится невозможной.',
        ),
        _h('Из чего состоит план'),
        _p('1. Какие инструменты и таймфреймы я торгую.'),
        _p('2. Мой сетап: конкретные условия входа (чек-лист).'),
        _p('3. Риск на сделку и максимальный дневной убыток (стоп-день).'),
        _p('4. Куда ставлю стоп и тейк, правила переноса в безубыток.'),
        _p('5. Когда я НЕ торгую (новости, усталость, после серии убытков).'),
        _rule(
          'Чек-лист входа — сердце плана. Например: (1) есть тренд по структуре, (2) цена в '
          'зоне интереса (ордер-блок/уровень), (3) была снята ликвидность, (4) подтверждение '
          'на младшем ТФ, (5) RR минимум 1:2. Нет хотя бы одной галочки — нет сделки.',
          title: 'Чек-лист входа',
        ),
        _fact(
          'В авиации чек-листы появились после катастрофы 1935 года: новейший бомбардировщик '
          'Boeing разбился из-за того, что пилот забыл снять блокировку рулей. Самолёт был '
          '«слишком сложен, чтобы держать всё в голове». Решение — простой чек-лист. С тех пор '
          'чек-листы сделали авиацию безопаснейшим видом транспорта. Трейдинг тоже «слишком '
          'сложен для головы» в стрессе.',
        ),
        _rule(
          'План бесполезен, если он в голове. Запиши его, распечатай, держи перед глазами. '
          'План на бумаге — это договор с самим собой, который нельзя незаметно нарушить в '
          'момент слабости.',
          title: 'План должен быть написан',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Зачем трейдеру письменный чек-лист входа?',
        options: [
          'Для красоты и солидности',
          'Чтобы входить только при выполнении всех условий, убирая импульсивность',
          'Чтобы торговать чаще',
          'Этого требует брокер',
        ],
        correctIndex: 1,
        explanation:
            'Чек-лист гарантирует, что каждая сделка соответствует системе. Нет всех галочек — '
            'нет входа. Это защита от импульсивных решений под действием эмоций.',
      ),
    ),
  ],
);

// ════════════════════════════════════════════════════════════════════
// МОДУЛЬ 9. Большие циклы и геополитика золота
// ════════════════════════════════════════════════════════════════════
CourseModule _module9() => CourseModule(
  id: 'm9',
  index: 9,
  title: 'Большие циклы и геополитика золота',
  goal:
      'Увидеть рынок с высоты 100 лет: долговые суперциклы, валютные войны и роль золота в '
      'смене мирового порядка.',
  lessons: [
    CourseLesson(
      id: 'l9_1',
      code: '9.1',
      title: 'Долговой суперцикл Рэя Далио: как дышит кредитная машина',
      blocks: [
        _essence(
          'Рэй Далио, основатель крупнейшего хедж-фонда мира Bridgewater, объясняет экономику '
          'через долговые циклы. Есть короткий цикл (~5–8 лет, обычные рецессии) и большой '
          'долговой суперцикл (~75–100 лет), который заканчивается грандиозной перестройкой '
          'всей системы. Мы, по его мнению, сейчас в конце такого суперцикла.',
        ),
        _mechanic(
          'Кредит — это топливо роста. Когда ты берёшь в долг, ты тратишь больше, чем '
          'зарабатываешь, разгоняя экономику. Но долг нужно отдавать — тогда ты тратишь меньше. '
          'Так рождаются циклы: кредитная экспансия → пузырь → пик → делевередж (сокращение '
          'долгов) → кризис → перезапуск.',
          title: 'Как работает машина',
        ),
        _rule(
          'В конце большого цикла долги становятся неподъёмными. У государства есть выход: '
          'печатать деньги, чтобы обесценить долг (инфляция). Именно в этой фазе золото и '
          'реальные активы исторически показывают себя лучше всего, а держатели облигаций и '
          'наличных — теряют.',
          title: 'Где золото в цикле',
        ),
        _fact(
          'Далио начинал с торговли в 12 лет, работая кедди на гольф-поле и слушая советы '
          'инвесторов. Сегодня его принципы радикальной прозрачности и изучения «машины» '
          'экономики через циклы изложены в книгах, которые он раздаёт бесплатно. Его видео '
          '«How the Economic Machine Works» за 30 минут объясняет то, что вузы растягивают '
          'на годы.',
        ),
        _interactive('debt_cycle', title: 'Долговой суперцикл (фазы)'),
      ],
      quiz: const QuizQuestion(
        question: 'Как государство чаще всего «решает» проблему неподъёмного долга в конце цикла?',
        options: [
          'Полностью выплачивает его за счёт профицита',
          'Печатает деньги, обесценивая долг через инфляцию',
          'Просто игнорирует долг навсегда',
          'Запрещает гражданам иметь деньги',
        ],
        correctIndex: 1,
        explanation:
            'В конце суперцикла долги обесценивают печатанием денег (инфляцией). В этой фазе '
            'золото и реальные активы выигрывают, а наличные и облигации теряют покупательную '
            'способность.',
      ),
    ),
    CourseLesson(
      id: 'l9_2',
      code: '9.2',
      title: 'Валютные войны и закат резервных валют',
      blocks: [
        _essence(
          'История денег — это история сменяющих друг друга резервных валют. Ни одна не правила '
          'вечно. Голландский гульден, испанское песо, британский фунт — все были «мировыми '
          'деньгами» своей эпохи и все уступили трон. Доллар — текущий чемпион, но история '
          'учит: чемпионы меняются.',
        ),
        _h('Цикл гегемонии валюты'),
        _p('Страна-лидер выигрывает войну/торговлю → её валюта становится резервной → она '
            'получает «непомерную привилегию» жить в долг → накапливает долги и теряет '
            'конкурентоспособность → доверие к валюте падает → появляется новый претендент.'),
        _p('Валютная война — это когда страны намеренно ослабляют свои валюты, чтобы сделать '
            'экспорт дешевле и захватить рынки. Все девальвируют наперегонки — а реальной '
            'твёрдой ценностью на этом фоне остаётся золото.'),
        _fact(
          'Фунт стерлингов был мировой резервной валютой более 100 лет, на пике Британской '
          'империи. После двух мировых войн и потери колоний он уступил доллару. Переход '
          'занял десятилетия и сопровождался кризисами — смена гегемона никогда не бывает '
          'мгновенной и тихой.',
        ),
        _rule(
          'Для трейдера золота это ключевой долгосрочный контекст: чем больше сомнений в '
          'долларе и чем активнее валютные войны, тем сильнее структурный спрос на золото как '
          'на наднациональные «деньги без флага».',
          title: 'Почему это важно для золота',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Что история резервных валют говорит трейдеру золота?',
        options: [
          'Доллар будет резервной валютой вечно',
          'Резервные валюты сменяют друг друга; сомнения в долларе усиливают спрос на золото',
          'Золото не связано с валютами',
          'Валютные войны укрепляют все валюты сразу',
        ],
        correctIndex: 1,
        explanation:
            'Ни одна резервная валюта не правила вечно. В периоды валютных войн и сомнений в '
            'долларе золото — «деньги без флага» — получает структурный спрос.',
      ),
    ),
    CourseLesson(
      id: 'l9_3',
      code: '9.3',
      title: 'Золото центробанков и де-долларизация',
      blocks: [
        _essence(
          'Самые крупные покупатели золота сегодня — не частные инвесторы, а центральные банки '
          'государств. Они скупают физическое золото рекордными темпами, диверсифицируя '
          'резервы прочь от доллара. Это мощнейший фундаментальный фактор спроса на годы вперёд.',
        ),
        _h('Почему центробанки скупают золото'),
        _p('Золото — единственный резервный актив, который не является чьим-то обязательством '
            'и который нельзя заморозить санкциями или обесценить чужим печатным станком. '
            'После заморозки резервов России в 2022 году многие страны осознали: долларовые '
            'резервы можно отнять, а золото в собственном хранилище — нет.'),
        _fact(
          'В 2022–2023 годах центробанки мира покупали золото рекордными за полвека темпами — '
          'более 1000 тонн в год. Лидеры скупки — Китай, Индия, Турция и другие развивающиеся '
          'страны, активно снижающие долю доллара в резервах.',
        ),
        _p('Де-долларизация — постепенный процесс снижения роли доллара в мировой торговле и '
            'резервах. Страны БРИКС обсуждают расчёты в национальных валютах и идеи валюты, '
            'частично обеспеченной золотом. Даже если доллар не свергнут завтра, сам тренд '
            'поддерживает золото.'),
        _rule(
          'Покупки золота центробанками — это «пол» под ценой: крупный, нечувствительный к '
          'цене и долгосрочный покупатель. Это меняет фундаментальную картину рынка золота на '
          'годы, а не на дни.',
          title: 'Структурный спрос',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Почему центробанки наращивают золотые резервы вместо долларовых?',
        options: [
          'Золото приносит высокие проценты',
          'Золото нельзя заморозить санкциями или обесценить чужой эмиссией',
          'Золото проще хранить, чем доллары',
          'Доллар запрещён международными правилами',
        ],
        correctIndex: 1,
        explanation:
            'Золото — актив, не являющийся чьим-то обязательством. Его нельзя заморозить или '
            'напечатать. После заморозки резервов это стало ключевым аргументом для '
            'де-долларизации.',
      ),
    ),
    CourseLesson(
      id: 'l9_4',
      code: '9.4',
      title: 'Реальные активы против бумаги: товарный суперцикл',
      blocks: [
        _essence(
          'Капитал в мире циклически перетекает между «бумажными» активами (акции, облигации) '
          'и «реальными» (сырьё, металлы, энергия, золото). Эти большие приливы и отливы — '
          'товарные суперциклы — длятся по 10–20 лет и определяют, где делаются состояния '
          'целого поколения.',
        ),
        _h('Логика суперцикла'),
        _p('Долгие годы недоинвестирования в добычу → дефицит сырья → рост цен на годы → бум '
            'инвестиций в добычу → перепроизводство → падение цен → снова недоинвестирование. '
            'Цикл повторяется десятилетиями.'),
        _rule(
          'В эпоху высокой инфляции и обесценивания валют реальные активы (которые нельзя '
          'напечатать) исторически обгоняют бумажные. Золото — флагман этого класса: оно и '
          'реальный актив, и денежный, что делает его особенно сильным в такие периоды.',
          title: 'Когда реальное бьёт бумагу',
        ),
        _fact(
          'В 1980 году, на пике товарного суперцикла и инфляции, акции были настолько '
          'непопулярны, что журнал BusinessWeek вышел с обложкой «Смерть акций» (The Death of '
          'Equities). Это оказалось почти точным дном перед величайшим бычьим рынком акций в '
          'истории. Когда реальные активы на пике эйфории — маятник готов качнуться обратно.',
        ),
        _example(
          'Каждый суперцикл рождает свою «звезду»: нефть в 1970-х, японские акции в 1980-х, '
          'доткомы в 1990-х, сырьё и золото в 2000-х. Понимание, в какой фазе большого цикла '
          'мы находимся, важнее любого внутридневного сигнала.',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'В какие периоды реальные активы (сырьё, золото) обычно обгоняют бумажные?',
        options: [
          'В периоды низкой инфляции и крепких валют',
          'В периоды высокой инфляции и обесценивания валют',
          'Реальные активы всегда отстают от акций',
          'Это никак не связано с инфляцией',
        ],
        correctIndex: 1,
        explanation:
            'Когда валюты обесцениваются (высокая инфляция), реальные активы, которые нельзя '
            'напечатать, сохраняют ценность лучше бумажных. Золото — флагман этого класса.',
      ),
    ),
  ],
);

// ════════════════════════════════════════════════════════════════════
// МОДУЛЬ 10. Анатомия кризисов
// ════════════════════════════════════════════════════════════════════
CourseModule _module10() => CourseModule(
  id: 'm10',
  index: 10,
  title: 'Анатомия кризисов: как делались состояния на крови',
  goal:
      'На великих кризисах истории показать, как страх большинства превращается в '
      'возможность для подготовленного меньшинства.',
  lessons: [
    CourseLesson(
      id: 'l10_1',
      code: '10.1',
      title: 'Великая депрессия 1929: как лопнул крупнейший пузырь',
      blocks: [
        _essence(
          'Крах 1929 года — архетип всех биржевых катастроф. В 1920-е акции росли как на '
          'дрожжах, обычные люди влезали в долги, чтобы покупать акции с плечом 1:10. Когда '
          'пузырь лопнул, маржин-коллы превратили коррекцию в апокалипсис, а за ним пришла '
          'Великая депрессия.',
        ),
        _h('Анатомия пузыря'),
        _p('Эйфория и вера в «новую эру» → массовый вход неопытной толпы → покупки на огромное '
            'кредитное плечо → цены отрываются от реальности → первая трещина → маржин-коллы → '
            'принудительные распродажи → каскадный обвал.'),
        _story(
          'В «Чёрный вторник» 29 октября 1929 года рынок рухнул так, что лента тикера '
          'отставала на часы. Люди, купившие акции с плечом, получили маржин-коллы и потеряли '
          'всё за дни. Индекс Dow восстановился до уровня 1929 года только через 25 лет — в '
          '1954-м. Целое поколение запомнило акции как зло.',
          title: '25 лет до восстановления',
        ),
        _fact(
          'Перед крахом виднейший экономист Ирвинг Фишер публично заявил: «Цены акций достигли '
          'постоянного высокого плато». Через несколько дней рынок рухнул. Даже величайшие умы '
          'эпохи не видели пузыря изнутри — потому что были его частью. Когда «эксперты» '
          'отрицают риск, риск максимален.',
        ),
        _rule(
          'Уроки 1929 для трейдера: (1) кредитное плечо превращает коррекцию в катастрофу; '
          '(2) когда «все» уверены в вечном росте — пора осторожничать; (3) рынок может не '
          'восстанавливаться десятилетиями.',
          title: 'Вечные уроки',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Что превратило коррекцию 1929 года в катастрофический обвал?',
        options: [
          'Запрет на торговлю',
          'Массовое кредитное плечо и каскад маржин-коллов',
          'Слишком низкие цены акций',
          'Отсутствие интернета',
        ],
        correctIndex: 1,
        explanation:
            'Толпа покупала акции на большое плечо. Когда цены качнулись вниз, маржин-коллы '
            'заставили принудительно продавать, что обрушило рынок каскадом. Плечо — ускоритель '
            'катастроф.',
      ),
    ),
    CourseLesson(
      id: 'l10_2',
      code: '10.2',
      title: 'Сорос против Банка Англии: \$1 млрд за один день',
      blocks: [
        _essence(
          'Иногда один трейдер может победить целое государство — если он прав и действует '
          'решительно. «Чёрная среда» 16 сентября 1992 года: Джордж Сорос сделал ставку '
          'против британского фунта и заработал около миллиарда долларов за день, войдя в '
          'историю как «человек, который сломал Банк Англии».',
        ),
        _h('Суть сделки'),
        _p('Британия держала фунт в жёстком валютном механизме (ERM) по завышенному курсу. '
            'Сорос понял: экономика не вытягивает такой курс, фунт переоценён, и удерживать '
            'его искусственно невозможно бесконечно. Это была асимметричная ставка: риск '
            'ограничен, потенциал огромен.'),
        _story(
          'Сорос поставил против фунта более \$10 млрд. Банк Англии отчаянно скупал фунты и '
          'поднимал ставку дважды за день, пытаясь удержать курс, — но против фундаментальной '
          'реальности и огромного капитала это было бессильно. К вечеру Британия вышла из ERM, '
          'фунт рухнул, а Сорос зафиксировал ~\$1 млрд прибыли.',
          title: 'Как сломали Банк Англии',
        ),
        _rule(
          'Урок Сороса: лучшие сделки — асимметричные, где ты прав по фундаменту И рынок '
          'структурно уязвим. Когда у тебя сильная идея, по словам Сороса, «важно не то, прав '
          'ты или нет, а сколько ты зарабатываешь, когда прав, и сколько теряешь, когда не '
          'прав». Размер позиции под силу убеждённости.',
          title: 'Асимметрия убеждённости',
        ),
        _fact(
          'Сорос называет свою философию «теорией рефлексивности»: восприятие участников влияет '
          'на саму реальность рынка, создавая самоусиливающиеся циклы пузырей и крахов. Рынок '
          'не отражает реальность пассивно — он её формирует.',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'В чём была суть выигрышной ставки Сороса против фунта в 1992?',
        options: [
          'Он угадал случайно',
          'Фунт был искусственно переоценён, и удерживать курс было фундаментально невозможно',
          'Он подкупил Банк Англии',
          'Он купил фунты в надежде на рост',
        ],
        correctIndex: 1,
        explanation:
            'Сорос увидел, что завышенный курс фунта в ERM не соответствует экономике и '
            'неудержим. Это была асимметричная ставка против фундаментально уязвимой позиции '
            'государства.',
      ),
    ),
    CourseLesson(
      id: 'l10_3',
      code: '10.3',
      title: '2008 и The Big Short: ставка против целой системы',
      blocks: [
        _essence(
          'Кризис 2008 года показал, как жадность Уолл-стрит едва не обрушила мир — и как '
          'горстка трейдеров, увидевших правду раньше всех, заработала состояния, ставя против '
          'системы, в которую верили все. Это история о том, как идти против толпы, когда '
          'толпа состоит из самых уважаемых банков планеты.',
        ),
        _h('Что произошло'),
        _p('Банки выдавали ипотеку кому угодно, упаковывали эти токсичные кредиты в сложные '
            'бумаги (CDO), а рейтинговые агентства штамповали им рейтинг ААА (надёжнейший). '
            'Весь карточный домик держался на вере, что цены на жильё не падают. Когда они '
            'упали — рухнуло всё.'),
        _story(
          'Майкл Бьюрри, врач с одним глазом и синдромом Аспергера, ставший управляющим фонда, '
          'месяцами изучал тысячи ипотечных кредитов и понял: система обречена. Он буквально '
          'заставил банки создать инструмент (CDS), чтобы поставить против ипотеки. Его '
          'инвесторы крутили пальцем у виска и требовали вернуть деньги — пока в 2008-м его '
          'ставка не принесла сотни процентов прибыли.',
          title: 'Человек, который увидел пузырь',
        ),
        _fact(
          'Когда Бьюрри открыл свои «короткие» позиции, он терпел убытки больше года, и '
          'инвесторы яростно требовали закрыть «безумную» ставку. Быть правым слишком рано '
          'неотличимо от ошибки — пока рынок не догонит реальность. Выдержка под давлением '
          'оказалась важнее самой идеи.',
        ),
        _rule(
          'Уроки 2008: (1) сложность часто скрывает риск, а не убирает его; (2) рейтинги и '
          '«авторитеты» могут ошибаться все разом; (3) быть правым мало — нужно пережить '
          'период, пока рынок осознаёт правду.',
          title: 'Вечные уроки',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Какой ключевой психологический вызов стоял перед теми, кто ставил против ипотеки в 2008?',
        options: [
          'Нехватка капитала',
          'Они были правы «слишком рано» и терпели убытки и давление, пока рынок не догнал реальность',
          'Отсутствие торговых терминалов',
          'Запрет коротких позиций',
        ],
        correctIndex: 1,
        explanation:
            'Идея была верной, но рынок осознавал реальность медленно. Месяцами трейдеры терпели '
            'убытки и давление инвесторов. Выдержка, пока рынок догоняет правду, — отдельный навык.',
      ),
    ),
    CourseLesson(
      id: 'l10_4',
      code: '10.4',
      title: 'COVID-крах 2020: самое быстрое падение и V-восстановление',
      blocks: [
        _essence(
          'Март 2020 — уникальный кризис: рынки рухнули с рекордной скоростью на панике вокруг '
          'пандемии, а затем так же стремительно развернулись благодаря беспрецедентному '
          'вмешательству центробанков. Это живой учебник о том, что ликвидность от ФРС сильнее '
          'любой плохой новости.',
        ),
        _h('Хроника'),
        _p('Февраль–март: осознание масштаба пандемии → паническая распродажа всего → за ~33 '
            'дня индекс S&P 500 рухнул на ~34%, быстрее, чем в 1929 и 2008. Даже золото '
            'кратко падало — в панике продают всё, чтобы получить наличные доллары.'),
        _story(
          'В разгар обвала ФРС за считанные дни обнулила ставку и объявила «неограниченное QE». '
          'Правительство раздавало деньги напрямую гражданам. Рынок развернулся на дне и за '
          'несколько месяцев переписал максимумы — классическая V-образная форма. Те, кто '
          'паниковал и продавал на дне, остались за бортом ралли.',
          title: 'Деньги печатают — рынки растут',
        ),
        _fact(
          'Парадокс 2020: бушевала худшая пандемия за век, экономика стояла, безработица '
          'взлетела — а фондовый рынок ставил рекорды. Причина — океан напечатанной ликвидности. '
          'Это намертво вбило в головы трейдеров правило: «Don\'t fight the Fed» — не воюй '
          'против печатного станка ФРС.',
        ),
        _rule(
          'Уроки COVID-краха: (1) в острой панике продают даже золото — это создаёт '
          'возможность; (2) ликвидность центробанков двигает рынки сильнее новостей; (3) самые '
          'резкие развороты случаются в момент максимального страха.',
          title: 'Вечные уроки',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Что развернуло рынки вверх после обвала марта 2020?',
        options: [
          'Окончание пандемии',
          'Беспрецедентная ликвидность от ФРС (нулевая ставка + неограниченное QE)',
          'Запрет на продажи',
          'Рост безработицы',
        ],
        correctIndex: 1,
        explanation:
            'Несмотря на бушующую пандемию, океан ликвидности от ФРС развернул рынки вверх. '
            'Отсюда правило «Don\'t fight the Fed»: печатный станок сильнее плохих новостей.',
      ),
    ),
    CourseLesson(
      id: 'l10_5',
      code: '10.5',
      title: 'Анатомия пузыря: от тюльпанов до доткомов и крипты',
      blocks: [
        _essence(
          'Пузыри повторяются веками с пугающей точностью — меняются только объекты мании '
          '(тюльпаны, акции, доткомы, крипта), но психология толпы одинакова. Научившись '
          'распознавать стадии пузыря, ты сможешь не стать его последней жертвой.',
        ),
        _h('Пять стадий любого пузыря'),
        _p('1. Скрытая фаза: умные деньги тихо покупают новый актив.'),
        _p('2. Осознание: подключаются институционалы, цена уверенно растёт.'),
        _p('3. Мания: входит толпа, СМИ трубят о «новой эре», цена параболит, все вокруг '
            '«зарабатывают».'),
        _p('4. Срыв: умные деньги выходят, появляется первая трещина.'),
        _p('5. Паника и капитуляция: обвал, толпа продаёт на дне, проклиная актив.'),
        _story(
          '«Тюльпаномания» в Голландии 1637 года — первый задокументированный пузырь. На пике '
          'одна луковица редкого тюльпана стоила как роскошный дом в Амстердаме. Люди продавали '
          'имущество ради луковиц. А потом за несколько дней цены рухнули в сотни раз, оставив '
          'тысячи разорёнными. Цветок. Дороже дома.',
          title: 'Когда цветок стоил как дом',
        ),
        _fact(
          'Исаак Ньютон — гениальнейший ум человечества — потерял состояние на пузыре Компании '
          'Южных морей в 1720 году. Он вышел рано с прибылью, но потом, видя, как «все вокруг '
          'богатеют», вошёл снова на пике — и разорился. Его фраза: «Я могу рассчитать движение '
          'небесных тел, но не безумие людей».',
        ),
        _rule(
          'Признаки мании: актив растёт по параболе, о нём говорят таксисты и соседи, '
          '«в этот раз всё по-другому», люди берут кредиты ради покупки, скептиков высмеивают. '
          'Когда «зарабатывают все» — выходить почти некому, и вершина близко.',
          title: 'Как распознать пик',
        ),
      ],
      quiz: const QuizQuestion(
        question: 'Какой признак чаще всего указывает на финальную стадию (манию) пузыря?',
        options: [
          'Актив тихо растёт, о нём мало кто знает',
          'О нём говорят все вокруг, толпа берёт кредиты на покупку, скептиков высмеивают',
          'Институционалы только начинают покупать',
          'Цена медленно снижается',
        ],
        correctIndex: 1,
        explanation:
            'Мания — это всеобщее участие толпы, параболический рост, кредиты ради покупки и '
            'вера «в этот раз всё иначе». Когда покупают все, новых покупателей не остаётся — '
            'вершина рядом.',
      ),
    ),
  ],
);
