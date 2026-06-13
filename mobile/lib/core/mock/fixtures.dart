import 'dart:math';

import '../../shared/models/calendar_event.dart';
import '../../shared/models/gallup.dart';
import '../../shared/models/intel_post.dart';
import '../../shared/models/kpi.dart';
import '../../shared/models/lesson.dart';
import '../../shared/models/market_session.dart';
import '../../shared/models/signal.dart';
import '../../shared/models/trade.dart';

/// MVP мок деректер. Барлық мәтіндер `loc` (kk/ru/en) бойынша таңдалады.
class MockFixtures {
  MockFixtures._();

  static DateTime get _now => DateTime.now();

  static String _pick(String loc, Map<String, String> m) =>
      m[loc] ?? m['kk'] ?? m.values.first;

  // ─────────────────────── Gold quote / KPI ───────────────────────

  static GoldQuote goldQuote() => const GoldQuote(
        price: 2374.20,
        deltaAbs: 9.80,
        deltaPct: 0.42,
        sparkline: [2362.1, 2364.8, 2363.5, 2367.2, 2370.4, 2369.8, 2371.6, 2373.0, 2372.4, 2374.2],
        dxy: 104.62,
        dxyDeltaPct: -0.18,
      );

  static KpiSnapshot kpi() => const KpiSnapshot(
        winRate: 0.68,
        netPnl: 4280.50,
        activeSignals: 3,
        streak: 5,
        equityCurve: [
          10000, 10120, 10080, 10210, 10180, 10340, 10410, 10380, 10520, 10610, 10580, 10720
        ],
      );

  // ─────────────────────── Signals ───────────────────────

  static List<Signal> signals(String loc) => [
        Signal(
          id: 'sig-001',
          providerId: 'pr-1',
          pair: 'XAU/USD',
          direction: SignalDirection.buy,
          entryFrom: 2371.00, entryTo: 2374.00,
          tp1: 2380.00, tp2: 2387.50, tp3: 2395.00, sl: 2365.00,
          rr: 2.4, confidence: 78, isFree: true,
          screenshotUrl: 'https://picsum.photos/seed/altyn-sig001/800/450',
          analysis: _pick(loc, {
            'kk': 'DXY кері кетті, Лондон сессиясы ашылуында retest setup. 2371 зонасынан bullish reaction күтілуде. SL — Asia low-дан төмен.',
            'ru': 'DXY развернулся вниз, на открытии Лондона ретест-сетап. От зоны 2371 ожидается bullish-реакция. SL ниже азиатского минимума.',
            'en': 'DXY rolled over; London open retest setup. Bullish reaction expected from 2371. SL below Asia low.',
          }),
          status: SignalStatus.active,
          publishedAt: _now.subtract(const Duration(minutes: 42)),
        ),
        Signal(
          id: 'sig-002',
          providerId: 'pr-3',
          pair: 'XAU/USD',
          direction: SignalDirection.sell,
          entryFrom: 2392.50, entryTo: 2394.00,
          tp1: 2385.00, tp2: 2378.00, tp3: 2371.00, sl: 2398.00,
          rr: 2.1, confidence: 65,
          screenshotUrl: 'https://picsum.photos/seed/altyn-sig002/800/450',
          analysis: _pick(loc, {
            'kk': 'NY ашылуында resistance breakout fakeout мүмкіндігі. Confidence орташа — DXY консолидацияда.',
            'ru': 'На открытии NY возможен fakeout пробоя сопротивления. Уверенность средняя — DXY в консолидации.',
            'en': 'NY open resistance fakeout possible. Confidence moderate — DXY consolidating.',
          }),
          status: SignalStatus.active,
          publishedAt: _now.subtract(const Duration(hours: 3)),
        ),
        Signal(
          id: 'sig-003',
          providerId: 'pr-2',
          pair: 'XAU/USD',
          direction: SignalDirection.buy,
          entryFrom: 2350.00, entryTo: 2352.00,
          tp1: 2360.00, tp2: 2368.00, tp3: 2375.00, sl: 2344.00,
          rr: 2.6, confidence: 82,
          screenshotUrl: 'https://picsum.photos/seed/altyn-sig003/800/450',
          analysis: _pick(loc, {
            'kk': 'SMC Order Block 2350 деңгейінде. Asia сессиясы низ retest, NY сессиясында reversal.',
            'ru': 'SMC Order Block на 2350. Ретест азиатского минимума, разворот в сессии NY.',
            'en': 'SMC Order Block at 2350. Asia low retest, NY session reversal.',
          }),
          status: SignalStatus.closedTp2,
          publishedAt: _now.subtract(const Duration(days: 1, hours: 4)),
          resultPips: 180,
        ),
        Signal(
          id: 'sig-004',
          providerId: 'pr-5',
          pair: 'XAU/USD',
          direction: SignalDirection.sell,
          entryFrom: 2402.00, entryTo: 2404.00,
          tp1: 2396.00, tp2: 2390.00, tp3: 2383.00, sl: 2408.00,
          rr: 1.8, confidence: 55,
          screenshotUrl: 'https://picsum.photos/seed/altyn-sig004/800/450',
          analysis: _pick(loc, {
            'kk': 'Resistance қайтарған, бірақ DXY өсуі сигналды әлсіретті. SL шықты.',
            'ru': 'Сопротивление отбило, но рост DXY ослабил сигнал. SL сработал.',
            'en': 'Resistance rejected, but DXY strength invalidated the setup. SL hit.',
          }),
          status: SignalStatus.closedSl,
          publishedAt: _now.subtract(const Duration(days: 2, hours: 8)),
          resultPips: -60,
        ),
      ];

  // ─────────────────────── Intel posts ───────────────────────

  static List<IntelPost> intelPosts(String loc) => [
        IntelPost(
          id: 'int-001',
          source: 'Bloomberg',
          text: 'Fed officials signal a pause in rate hikes as inflation cools faster than expected. Treasury yields drop sharply.',
          impact: GoldImpact.bullish,
          xauMove: 18.40,
          analysis: _pick(loc, {
            'kk': 'Dovish Fed → USD әлсірейді → Gold үшін bullish. Тарихи орташа: NFP-тен кейін +0.8%. Лондон ашылуында ретест күтіңіз; news-driven кірмеңіз — structure растағанша.',
            'ru': 'Голубиная риторика ФРС → ослабление USD → bullish для золота. Историческое среднее: после NFP +0.8%. Ждите ретест на открытии Лондона; не входите на новостях — пока структура не подтвердит.',
            'en': 'Dovish Fed → USD weakens → bullish for gold. Historical average: +0.8% post-NFP. Wait for London open retest; do not chase the news — wait for structure confirmation.',
          }),
          support: 0, resistance: 0, suggestedSl: 0,
          sentiment: 76,
          publishedAt: _now.subtract(const Duration(minutes: 22)),
          isUrgent: true,
        ),
        IntelPost(
          id: 'int-002',
          source: 'Reuters',
          text: 'Middle East tensions escalate as new sanctions are announced. Safe-haven demand spikes.',
          impact: GoldImpact.bullish,
          xauMove: 12.10,
          analysis: _pick(loc, {
            'kk': 'Геосаяси тәуекел → Gold safe haven. Sentiment экстремалды боп тұрған кезде "buy the rumor, sell the news" — Asia сессиясында жоғары волатильділік, кіруді H1 структурасынан кейін қарастырыңыз.',
            'ru': 'Геополитический риск → золото как safe haven. При экстремальном сентименте «buy the rumor, sell the news» — высокая волатильность в азиатскую сессию; вход после подтверждения структуры H1.',
            'en': 'Geopolitical risk → gold safe haven. With extreme sentiment, "buy the rumor, sell the news" applies — Asia session volatility high; only enter after H1 structure confirmation.',
          }),
          support: 0, resistance: 0, suggestedSl: 0,
          sentiment: 68,
          publishedAt: _now.subtract(const Duration(hours: 2)),
        ),
        IntelPost(
          id: 'int-003',
          source: 'FXStreet',
          text: 'DXY climbs to 6-week high on hawkish Powell remarks. Gold under pressure.',
          impact: GoldImpact.bearish,
          xauMove: -8.20,
          analysis: _pick(loc, {
            'kk': 'DXY күшеюі Gold-қа теріс әсер етеді. Тарихи корреляция: DXY +1% → Gold −0.6%. NY сессиясында retest жасап sell-side liquidity-ді қарастырыңыз.',
            'ru': 'Рост DXY негативен для золота. Историческая корреляция: DXY +1% → Gold −0.6%. В NY-сессию рассматривайте ретест и sell-side liquidity.',
            'en': 'DXY strength is negative for gold. Historical correlation: DXY +1% → Gold −0.6%. Consider NY-session retest and sell-side liquidity.',
          }),
          support: 0, resistance: 0, suggestedSl: 0,
          sentiment: 32,
          publishedAt: _now.subtract(const Duration(hours: 6)),
        ),
        IntelPost(
          id: 'int-004',
          source: 'Kitco',
          text: 'Central bank gold purchases reach record level in Q2. China and India lead the buying.',
          impact: GoldImpact.bullish,
          xauMove: 6.50,
          analysis: _pick(loc, {
            'kk': 'Орталық банктер сатып алуы long-term bullish сигнал. Қысқа мерзімде нарықтық реакция шектеулі — D1 swing setup-тарды қадағалаңыз.',
            'ru': 'Закупки центробанками — долгосрочный bullish сигнал. Кратко рыночная реакция ограничена — отслеживайте D1 swing-сетапы.',
            'en': 'Central bank buying is a long-term bullish signal. Short-term reaction limited — track D1 swing setups.',
          }),
          support: 0, resistance: 0, suggestedSl: 0,
          sentiment: 62,
          publishedAt: _now.subtract(const Duration(hours: 10)),
        ),
      ];

  // ─────────────────────── Calendar ───────────────────────

  static List<CalendarEvent> calendarEvents(String loc) {
    String t(String kk, String ru, String en) => _pick(loc, {'kk': kk, 'ru': ru, 'en': en});
    return [
      CalendarEvent(
        id: 'ev-001',
        name: 'US CPI (YoY)',
        currency: 'USD',
        impact: ImpactLevel.high,
        scheduledAt: _now.add(const Duration(hours: 2, minutes: 30)),
        forecast: '3.1%',
        previous: '3.2%',
        goldImpactNote: t(
          'Жоғары CPI → DXY өседі → Gold төмендейді',
          'Высокий CPI → рост DXY → давление на золото',
          'High CPI → DXY rises → gold under pressure',
        ),
      ),
      CalendarEvent(
        id: 'ev-001b',
        name: 'US Crude Oil Inventories',
        currency: 'USD',
        impact: ImpactLevel.medium,
        scheduledAt: _now.add(const Duration(hours: 4, minutes: 15)),
        forecast: '-1.2M',
        previous: '0.8M',
      ),
      CalendarEvent(
        id: 'ev-001c',
        name: 'BoC Interest Rate',
        currency: 'CAD',
        impact: ImpactLevel.high,
        scheduledAt: _now.add(const Duration(hours: 6)),
        forecast: '4.25%',
        previous: '4.50%',
      ),
      CalendarEvent(
        id: 'ev-002',
        name: 'FOMC Statement',
        currency: 'USD',
        impact: ImpactLevel.high,
        scheduledAt: _now.add(const Duration(days: 1, hours: 5)),
        forecast: '5.50%',
        previous: '5.50%',
        goldImpactNote: t(
          'Dovish FOMC → bullish Gold',
          'Голубиный FOMC → bullish для золота',
          'Dovish FOMC → bullish for gold',
        ),
      ),
      CalendarEvent(
        id: 'ev-002b',
        name: 'US Initial Jobless Claims',
        currency: 'USD',
        impact: ImpactLevel.medium,
        scheduledAt: _now.add(const Duration(days: 1, hours: 8)),
        forecast: '218K',
        previous: '221K',
      ),
      CalendarEvent(
        id: 'ev-002c',
        name: 'UK Retail Sales',
        currency: 'GBP',
        impact: ImpactLevel.low,
        scheduledAt: _now.add(const Duration(days: 1, hours: 2)),
        forecast: '0.3%',
        previous: '-0.1%',
      ),
      CalendarEvent(
        id: 'ev-003',
        name: 'ECB Press Conference',
        currency: 'EUR',
        impact: ImpactLevel.medium,
        scheduledAt: _now.add(const Duration(days: 2)),
        forecast: '4.00%',
        previous: '4.00%',
      ),
      CalendarEvent(
        id: 'ev-003b',
        name: 'NFP (Non-Farm Payrolls)',
        currency: 'USD',
        impact: ImpactLevel.high,
        scheduledAt: _now.add(const Duration(days: 2, hours: 8, minutes: 30)),
        forecast: '180K',
        previous: '254K',
        goldImpactNote: t(
          'Тарихи: NFP мисс → Gold +0.5–1.2%',
          'История: промах NFP → золото +0.5–1.2%',
          'History: NFP miss → gold +0.5–1.2%',
        ),
      ),
      CalendarEvent(
        id: 'ev-003c',
        name: 'Australia GDP (QoQ)',
        currency: 'AUD',
        impact: ImpactLevel.low,
        scheduledAt: _now.add(const Duration(days: 2, hours: 18)),
        forecast: '0.4%',
        previous: '0.2%',
      ),
    ];
  }

  // ─────────────────────── Trades ───────────────────────

  static List<Trade> trades(String loc) {
    String t(String kk, String ru, String en) => _pick(loc, {'kk': kk, 'ru': ru, 'en': en});
    return [
      Trade(
        id: 'tr-001',
        instrument: 'XAU/USD',
        direction: SignalDirection.buy,
        openPrice: 2360.50, closePrice: 2374.20,
        lot: 0.10, pnl: 137.0,
        setup: TradeSetup.retest, session: MarketSession.london,
        openedAt: _now.subtract(const Duration(hours: 6)),
        closedAt: _now.subtract(const Duration(hours: 2)),
        broker: 'Exness',
        rrPlanned: 2.0, rrActual: 2.3,
        emotion: '😌',
        notes: t('A+ setup, журналға толық жазылды.', 'A+ сетап, в журнал записано полностью.', 'A+ setup, journaled fully.'),
      ),
      Trade(
        id: 'tr-002',
        instrument: 'XAU/USD',
        direction: SignalDirection.sell,
        openPrice: 2398.00, closePrice: 2402.50,
        lot: 0.05, pnl: -22.5,
        setup: TradeSetup.breakout, session: MarketSession.newYork,
        openedAt: _now.subtract(const Duration(days: 1, hours: 4)),
        closedAt: _now.subtract(const Duration(days: 1, hours: 2)),
        broker: 'IC Markets',
        rrPlanned: 1.8, rrActual: -1.0,
        emotion: '😬',
        notes: t('NY break fakeout, SL қысқа.', 'NY-фейкаут пробоя, SL короткий.', 'NY break fakeout, SL was tight.'),
      ),
      Trade(
        id: 'tr-003',
        instrument: 'XAU/USD',
        direction: SignalDirection.buy,
        openPrice: 2350.00, closePrice: 2368.00,
        lot: 0.20, pnl: 360.0,
        setup: TradeSetup.smcOb, session: MarketSession.overlap,
        openedAt: _now.subtract(const Duration(days: 2)),
        closedAt: _now.subtract(const Duration(days: 1, hours: 20)),
        broker: 'Exness',
        rrPlanned: 2.5, rrActual: 2.7,
        emotion: '🙂',
      ),
    ];
  }

  // ─────────────────────── Gallup test (20 questions) ───────────────────────

  static List<GallupQuestion> gallupQuestions(String loc) {
    String t(String kk, String ru, String en) => _pick(loc, {'kk': kk, 'ru': ru, 'en': en});

    GallupOption op(String kk, String ru, String en, Map<GallupProfile, int> scores) =>
        GallupOption(label: t(kk, ru, en), scores: scores);

    return [
      GallupQuestion(id: 'q1', text: t(
        'Сделкаға кіру алдында сіздің бағыт (bias) қалай қалыптасады?',
        'Как формируется ваш bias перед входом в сделку?',
        'How is your bias formed before entering a trade?',
      ), options: [
        op('HTF (D1/H4) bias анықталады, тек LTF executor', 'Сначала HTF (D1/H4) bias, потом LTF исполнение', 'HTF (D1/H4) bias first, then LTF execution', {GallupProfile.disciplined: 3}),
        op('5-минуттық графикке қарап интуициямен', 'По интуиции на 5-минутке', '5m chart by intuition', {GallupProfile.uncontrolledRisk: 2, GallupProfile.hope: 1}),
        op('Соңғы шығыннан кейін қарсы бағытқа', 'После убытка — в противоположную сторону', 'Opposite direction after a loss', {GallupProfile.revenge: 3}),
        op('Соңында бұрылады деп күтемін', 'Жду разворота', 'I wait for reversal', {GallupProfile.hope: 3}),
      ]),
      GallupQuestion(id: 'q2', text: t(
        'Position sizing қалай шешіледі?',
        'Как выбираете объём позиции?',
        'How do you size positions?',
      ), options: [
        op('Account equity × 1–2% / SL pips калькуляторымен', 'Equity × 1–2% / SL pips через калькулятор', 'Equity × 1–2% / SL pips via calculator', {GallupProfile.disciplined: 3}),
        op('Лот сезімге сәйкес — кейде 5–10% risk', 'Лот по чувству — иногда 5–10%', 'Lot by feel — sometimes 5–10%', {GallupProfile.uncontrolledRisk: 3}),
        op('Шығынды қайтару үшін лотты үлкейтемін', 'Увеличиваю лот, чтобы отыграться', 'Increase lot to recover losses', {GallupProfile.revenge: 3}),
        op('"Бұл setup мықты" → лот ұлғаяды', '«Сетап сильный» → больше лот', '"Strong setup" → bigger lot', {GallupProfile.hope: 2, GallupProfile.uncontrolledRisk: 1}),
      ]),
      GallupQuestion(id: 'q3', text: t(
        'Stop-Loss деңгейі қайда қойылады?',
        'Где ставите Stop-Loss?',
        'Where do you place Stop-Loss?',
      ), options: [
        op('Structure invalidation point — қозғалмайды', 'Structure invalidation — не двигаю', 'Structure invalidation — never move it', {GallupProfile.disciplined: 3}),
        op('"Liquidity sweep тазалап шығарады" — алып тастаймын', '«Свип ликвидности» — снимаю SL', '"Liquidity sweep" — I remove the SL', {GallupProfile.hope: 3}),
        op('Шығынды қайтару үшін кеңейтемін', 'Расширяю, чтобы отыграться', 'Widen it to recover', {GallupProfile.revenge: 3}),
        op('Кейде қоямын, кейде SL жоқ', 'Иногда есть SL, иногда нет', 'Sometimes I use SL, sometimes not', {GallupProfile.uncontrolledRisk: 3}),
      ]),
      GallupQuestion(id: 'q4', text: t(
        'Күндік drawdown лимиті:',
        'Дневной лимит drawdown:',
        'Daily drawdown limit:',
      ), options: [
        op('−3%-ке жетсе автоматты "off day"', 'При −3% автоматический «off day»', 'At −3% automatic "off day"', {GallupProfile.disciplined: 3}),
        op('"Қайта қайтарам" деп жалғастырамын', '«Сейчас отыграю» — продолжаю', '"I will recover" — keep going', {GallupProfile.hope: 3}),
        op('Лотты ұлғайтамын — recovery үшін', 'Увеличиваю лот для recovery', 'Increase lot for recovery', {GallupProfile.revenge: 3}),
        op('Шектеу жоқ — әр сделка бөлек оқиға', 'Лимита нет — каждая сделка отдельно', 'No limit — every trade is separate', {GallupProfile.uncontrolledRisk: 3}),
      ]),
      GallupQuestion(id: 'q5', text: t(
        'HIGH-impact news event (NFP, FOMC):',
        'HIGH-impact новость (NFP, FOMC):',
        'HIGH-impact news event (NFP, FOMC):',
      ), options: [
        op('Pre-news жабам, post-news structure күтемін', 'Закрываю до новости, после жду structure', 'Close pre-news, wait for post-news structure', {GallupProfile.disciplined: 3}),
        op('Кеңейтілген SL-мен volatility-ге кіремін', 'Вхожу с расширенным SL в волатильность', 'Enter volatility with wider SL', {GallupProfile.uncontrolledRisk: 3}),
        op('Бағыт ауысуын алдын ала кіремін', 'Захожу на ожидании смены тренда', 'Enter pre-news on directional bet', {GallupProfile.hope: 2}),
        op('Шығынды pre-news pump-та қайтарам', 'Отыгрываю убыток на pre-news pump', 'Recover loss on pre-news pump', {GallupProfile.revenge: 3}),
      ]),
      GallupQuestion(id: 'q6', text: t(
        'Trading journal:',
        'Торговый журнал:',
        'Trading journal:',
      ), options: [
        op('Әр сделка: screenshot + теги + emotion + RR plan/actual', 'Каждая сделка: скриншот + теги + эмоция + RR plan/actual', 'Each trade: screenshot + tags + emotion + RR plan/actual', {GallupProfile.disciplined: 3}),
        op('Тек жеңістерді жазамын', 'Записываю только победы', 'I log only winners', {GallupProfile.hope: 2}),
        op('Шығынды көргім келмейді — өткізіп жіберемін', 'Не хочу видеть убытки — пропускаю', "I don't want to see losses — skip them", {GallupProfile.revenge: 2}),
        op('Артық — нарық оны өзгертпейді', 'Лишнее — рынок не изменится от этого', 'Pointless — market does not change', {GallupProfile.uncontrolledRisk: 3}),
      ]),
      GallupQuestion(id: 'q7', text: t(
        'SL шыққаннан кейін:',
        'После срабатывания SL:',
        'After SL hits:',
      ), options: [
        op('Минимум 30 мин пауза, талдау жасап журналға', 'Пауза минимум 30 мин, анализ в журнал', 'Minimum 30-min break, analyze in journal', {GallupProfile.disciplined: 3}),
        op('Лотты ұлғайтып қарсы бағытта кіремін', 'Захожу в противоположную сторону большим лотом', 'Bigger lot, opposite direction', {GallupProfile.revenge: 3}),
        op('"Соңында дұрыс шығады" — averaging down', '«В итоге выйдет в плюс» — averaging down', '"It will work in the end" — averaging down', {GallupProfile.hope: 3}),
        op('Бірнеше сделканы жылдам тізбектеп ашамын', 'Открываю несколько сделок подряд быстро', 'Open several trades back-to-back quickly', {GallupProfile.uncontrolledRisk: 3}),
      ]),
      GallupQuestion(id: 'q8', text: t(
        'Correlated positions (XAU/USD + XAG/USD + USDJPY):',
        'Коррелированные позиции (XAU/USD + XAG/USD + USDJPY):',
        'Correlated positions (XAU/USD + XAG/USD + USDJPY):',
      ), options: [
        op('Correlation matrix-те total exposure %-ке шектеймін', 'Лимитирую total exposure по матрице корреляций', 'Limit total exposure via correlation matrix', {GallupProfile.disciplined: 3}),
        op('Корреляцияны білмеймін — параллельді кіремін', 'Не знаю корреляций — захожу параллельно', "I don't know correlations — enter parallel", {GallupProfile.uncontrolledRisk: 3}),
        op('"Соның бірі дұрыс шығады" — экспозу үлкейтемін', '«Один из них сработает» — увеличиваю экспозицию', '"One will work" — bigger exposure', {GallupProfile.hope: 2}),
        op('Шығынды қайтару үшін көп pair ашамын', 'Открываю много пар, чтобы отыграться', 'Open many pairs to recover', {GallupProfile.revenge: 2}),
      ]),
      GallupQuestion(id: 'q9', text: t(
        'Жоспарда жоқ "FOMO" сделкасы:',
        'FOMO-сделка вне плана:',
        'Off-plan "FOMO" trade:',
      ), options: [
        op('Кірмеймін — A+ setup-та ғана пресс', 'Не вхожу — только A+ сетапы', 'Skip it — A+ setups only', {GallupProfile.disciplined: 3}),
        op('"Жіберсем өкінемін" — кіремін', '«Упущу — буду жалеть» — вхожу', '"I will regret missing it" — enter', {GallupProfile.uncontrolledRisk: 2, GallupProfile.hope: 1}),
        op('Соңғы шығыннан кейін кірдім', 'После убытка вошёл', 'Entered after a loss', {GallupProfile.revenge: 3}),
        op('"Қазір" сезімі — кіремін', 'Чувство «сейчас» — вхожу', '"Now" feeling — enter', {GallupProfile.hope: 3}),
      ]),
      GallupQuestion(id: 'q10', text: t(
        'TP1-ден кейін:',
        'После TP1:',
        'After TP1:',
      ), options: [
        op('50% жабам, SL → BE, trailing rule-мен', 'Закрываю 50%, SL → BE, trailing', 'Close 50%, SL → BE, trailing', {GallupProfile.disciplined: 3}),
        op('BE қозғамаймын — "жұтылады" сезім', 'Не двигаю BE — «съест»', "Don't move to BE — feels like it will eat me", {GallupProfile.hope: 3}),
        op('TP алып, тағы кіріп ұлғайтам', 'Беру TP, опять вхожу с большим лотом', 'Take TP, re-enter bigger', {GallupProfile.revenge: 2, GallupProfile.uncontrolledRisk: 1}),
        op('Trailing жоқ — кейде нәтиже жоғалады', 'Нет trailing — иногда теряю прибыль', 'No trailing — sometimes lose the move', {GallupProfile.uncontrolledRisk: 2}),
      ]),
      GallupQuestion(id: 'q11', text: t(
        'A+ setup критерийі:',
        'Критерий A+ setup:',
        'A+ setup criterion:',
      ), options: [
        op('Жазылған checklist — min 4 confluence', 'Чек-лист — минимум 4 confluence', 'Written checklist — min 4 confluence', {GallupProfile.disciplined: 3}),
        op('"Көрсем білемін" — нақты ереже жоқ', '«Увижу — пойму» — без правил', '"I will know it when I see it"', {GallupProfile.uncontrolledRisk: 2, GallupProfile.hope: 1}),
        op('"Болуы керек" интуицияға сенемін', 'Верю интуиции «должно сработать»', 'Trust the "should work" intuition', {GallupProfile.hope: 3}),
        op('Шығыннан кейін кез келген setup жарайды', 'После убытка любой сетап подойдёт', 'Any setup will do after a loss', {GallupProfile.revenge: 3}),
      ]),
      GallupQuestion(id: 'q12', text: t(
        'Multi-timeframe анализ:',
        'Мультитаймфреймовый анализ:',
        'Multi-timeframe analysis:',
      ), options: [
        op('D1 → H4 → H1 → 15M top-down workflow', 'D1 → H4 → H1 → 15M top-down', 'D1 → H4 → H1 → 15M top-down', {GallupProfile.disciplined: 3}),
        op('Тек 5M / 1M скальпинг', 'Только 5M / 1M скальп', 'Only 5M / 1M scalp', {GallupProfile.uncontrolledRisk: 2}),
        op('"Бұл момент дұрыс" — TF-сіз кіремін', '«Сейчас момент» — без TF', '"This moment is right" — no TF', {GallupProfile.hope: 3}),
        op('TF қарап тұрмаймын — кіремін', 'Не смотрю TF — захожу', "Don't check TFs — enter", {GallupProfile.revenge: 2}),
      ]),
      GallupQuestion(id: 'q13', text: t(
        'Стратегия туралы:',
        'О стратегии:',
        'About strategy:',
      ), options: [
        op('1 негізгі + 1 қосалқы, backtested 200+ trades', '1 основная + 1 вспомогательная, backtested 200+ сделок', '1 primary + 1 backup, backtested 200+ trades', {GallupProfile.disciplined: 3}),
        op('Әр аптада жаңасын сынап көремін', 'Каждую неделю тестирую новую', 'Try a new one each week', {GallupProfile.uncontrolledRisk: 3}),
        op('"Дұрыс шығады" интуициям — система', 'Моя интуиция — это система', 'My intuition is the system', {GallupProfile.hope: 3}),
        op('Шығыннан кейін стратегия ауыстырамын', 'Меняю стратегию после убытка', 'Change strategy after a loss', {GallupProfile.revenge: 3}),
      ]),
      GallupQuestion(id: 'q14', text: t(
        'TP-ға жеткеннен кейін:',
        'После TP:',
        'After hitting TP:',
      ), options: [
        op('Толық немесе scale out — RR жоспарға сай', 'Полностью или scale out — по плану RR', 'Full close or scale out per RR plan', {GallupProfile.disciplined: 3}),
        op('"Аз пайда" — жалғастырамын', '«Мало прибыли» — держу', '"Not enough profit" — hold', {GallupProfile.hope: 3}),
        op('Тағы кіріп лот ұлғайтамын', 'Перезахожу большим лотом', 'Re-enter bigger', {GallupProfile.revenge: 2, GallupProfile.uncontrolledRisk: 1}),
        op('Жоғары лотқа қайта кіргім келеді', 'Хочется снова войти большим лотом', 'Want to re-enter with bigger lot', {GallupProfile.uncontrolledRisk: 2}),
      ]),
      GallupQuestion(id: 'q15', text: t(
        'Максималды күндік сделка саны:',
        'Максимум сделок в день:',
        'Max trades per day:',
      ), options: [
        op('3–5 setup, көп болса "off day"', '3–5 сетапов, больше — «off day»', '3–5 setups, more = "off day"', {GallupProfile.disciplined: 3}),
        op('10+ — қаншасы келсе сонша', '10+ — сколько появится', '10+ — as many as appear', {GallupProfile.uncontrolledRisk: 3}),
        op('Шығынды қайтару керек болса 20+', 'Если надо отыграться — 20+', '20+ if I need to recover', {GallupProfile.revenge: 3}),
        op('"Қалайда бір setup туады" — қарап отырам', '«Какой-то setup появится» — жду', '"Some setup will appear" — wait', {GallupProfile.hope: 2}),
      ]),
      GallupQuestion(id: 'q16', text: t(
        'Стресс жағдайда:',
        'В стрессе:',
        'Under stress:',
      ), options: [
        op('Алыстаймын, breathing, журналға жазам', 'Отхожу, дыхание, запись в журнал', 'Step away, breathe, journal', {GallupProfile.disciplined: 3}),
        op('Pause жоқ — қайта кіремін', 'Без паузы — вхожу снова', 'No pause — re-enter', {GallupProfile.uncontrolledRisk: 2, GallupProfile.revenge: 1}),
        op('"Соңында дұрыс" — жалғастырамын', '«В итоге правильно» — продолжаю', '"Will be fine eventually" — keep going', {GallupProfile.hope: 3}),
        op('Лот ұлғайтып шығыннан шығам деп', 'Увеличиваю лот, чтобы выйти из убытка', 'Bigger lot to escape loss', {GallupProfile.revenge: 3}),
      ]),
      GallupQuestion(id: 'q17', text: t(
        'Backtesting & forward test:',
        'Бэктест и forward test:',
        'Backtesting & forward test:',
      ), options: [
        op('200+ сделка backtest + 1 ай forward демо', '200+ сделок backtest + 1 мес forward demo', '200+ trade backtest + 1-month forward demo', {GallupProfile.disciplined: 3}),
        op('Жайдан live-да тестілеу артық', 'Лучше тестировать сразу на live', "Better test on live directly", {GallupProfile.uncontrolledRisk: 3}),
        op('Бірнешеуін көрдім — жетеді', 'Несколько раз видел — хватит', "Saw a few — that's enough", {GallupProfile.hope: 1, GallupProfile.uncontrolledRisk: 1}),
        op('"Тарих қайталанады" — толық backtest жоқ', '«История повторится» — без полного бэктеста', '"History repeats" — no full backtest', {GallupProfile.hope: 3}),
      ]),
      GallupQuestion(id: 'q18', text: t(
        'Margin call / stop-out тарихы:',
        'История margin call / stop-out:',
        'Margin call / stop-out history:',
      ), options: [
        op('Болған емес — risk %-те қатаң тұрамын', 'Не было — строго держу риск %', "Never — strict on risk %", {GallupProfile.disciplined: 3}),
        op('Бірнеше рет, депозит қостым', 'Несколько раз, докладывал депозит', 'A few times, topped up deposit', {GallupProfile.uncontrolledRisk: 3}),
        op('Болмайды деп үміттеніп жалғастырам', 'Надеюсь, не случится — продолжаю', "I hope it won't happen — continue", {GallupProfile.hope: 3}),
        op('Болған, бірақ қайтарам деп жұмыс істедім', 'Было, но работал, чтобы отыграться', 'Happened, but worked to recover', {GallupProfile.revenge: 2}),
      ]),
      GallupQuestion(id: 'q19', text: t(
        'Edge (статистикалық преимущество) туралы:',
        'Об edge (статистическом преимуществе):',
        'About edge (statistical advantage):',
      ), options: [
        op('Win Rate × avg RR > 1.0 — нақты сандармен', 'Win Rate × avg RR > 1.0 — в цифрах', 'Win Rate × avg RR > 1.0 — numbers', {GallupProfile.disciplined: 3}),
        op('Бірнеше pip алу — менің edge', 'Несколько пипсов — мой edge', 'A few pips — my edge', {GallupProfile.uncontrolledRisk: 2}),
        op('Интуиция — менің edge', 'Интуиция — мой edge', 'Intuition is my edge', {GallupProfile.hope: 3}),
        op('Шығыннан кейін система ауыстырамын', 'Меняю систему после убытка', 'Switch system after a loss', {GallupProfile.revenge: 3}),
      ]),
      GallupQuestion(id: 'q20', text: t(
        'Жетістік деген не?',
        'Что такое успех?',
        'What is success?',
      ), options: [
        op('PF > 1.5, max DD < 10%, дисциплина 95%+', 'PF > 1.5, max DD < 10%, дисциплина 95%+', 'PF > 1.5, max DD < 10%, discipline 95%+', {GallupProfile.disciplined: 3}),
        op('Үлкен лот → үлкен пайыз', 'Большой лот → большой профит', 'Big lot → big profit', {GallupProfile.uncontrolledRisk: 3}),
        op('"Дұрыс ой" көп болса → пайыз', '«Правильных идей» больше → профит', 'More "good ideas" → profit', {GallupProfile.hope: 3}),
        op('Шығыннан шығып плюске келу', 'Выбраться из убытка в плюс', 'Climb out of loss into profit', {GallupProfile.revenge: 3}),
      ]),
    ];
  }

  // ─────────────────────── Lessons / Library ───────────────────────

  static List<Lesson> lessons(String loc) {
    Lesson build({
      required String id,
      required GallupProfile profile,
      required LessonSourceType sourceType,
      required String sourceName,
      String? externalUrl,
      required int xp,
      required LessonTag tag,
      required int correctIndex,
      required Map<String, String> title,
      required String quote,
      required Map<String, String> explanation,
      required Map<String, String> goldApp,
      required Map<String, String> qcQuestion,
      required List<Map<String, String>> qcOptions,
    }) {
      String p(Map<String, String> m) => _pick(loc, m);
      return Lesson(
        id: id,
        profile: profile,
        sourceType: sourceType,
        sourceName: sourceName,
        externalUrl: externalUrl,
        xp: xp,
        tag: tag,
        title: p(title),
        quote: quote,
        explanation: p(explanation),
        goldApplication: p(goldApp),
        quickCheck: QuickCheck(
          question: p(qcQuestion),
          options: qcOptions.map(p).toList(),
          correctIndex: correctIndex,
        ),
      );
    }

    return [
      // ────── REVENGE TRADING ──────
      build(
        id: 'l-001', profile: GallupProfile.revenge,
        sourceType: LessonSourceType.book,
        sourceName: 'Mark Douglas — Trading in the Zone',
        externalUrl: 'https://www.amazon.com/Trading-Zone-Confidence-Discipline-Attitude/dp/0735201447',
        xp: 25, tag: LessonTag.psychology, correctIndex: 1,
        title: {
          'kk': 'Шығыннан кейінгі ереже',
          'ru': 'Правило после убытка',
          'en': 'The post-loss rule',
        },
        quote: "Anything can happen. You don't need to know what is going to happen next to make money.",
        explanation: {
          'kk': 'Шығын — жүйенің бір бөлшегі. "Қайтару керек" эмоциясы — нейробиологиялық рефлекс, нарықпен байланысы жоқ. Әр сделкаға тәуелсіз оқиға ретінде қарау керек.',
          'ru': 'Убыток — часть системы. «Надо отыграться» — нейробиологический рефлекс, не связан с рынком. Каждую сделку рассматривайте как независимое событие.',
          'en': 'Loss is part of the system. "I must recover" is a neurobiological reflex, not a market signal. Treat each trade as an independent event.',
        },
        goldApp: {
          'kk': 'XAU/USD SL шықса — кем дегенде 1 сағат пауза. Бір сессияға max 3 сделка.',
          'ru': 'Если на XAU/USD сработал SL — пауза минимум 1 час. Максимум 3 сделки в сессию.',
          'en': 'If SL hits on XAU/USD — at least 1-hour pause. Max 3 trades per session.',
        },
        qcQuestion: {
          'kk': 'Үлкен шығыннан кейінгі ең сау әрекет:',
          'ru': 'Самое здоровое действие после большого убытка:',
          'en': 'The healthiest action after a large loss:',
        },
        qcOptions: [
          {'kk': 'Лотты ұлғайтып қарсы кіру', 'ru': 'Войти противоположно с большим лотом', 'en': 'Re-enter opposite with bigger lot'},
          {'kk': 'Кем дегенде 1 сағат пауза + журналға жазу', 'ru': 'Минимум час паузы и запись в журнал', 'en': 'At least 1-hour break + journal it'},
          {'kk': 'Бірден тағы 3–4 сделка ашу', 'ru': 'Сразу открыть ещё 3–4 сделки', 'en': 'Open 3–4 more trades immediately'},
          {'kk': 'SL-ді кеңейтіп күту', 'ru': 'Расширить SL и ждать', 'en': 'Widen the SL and wait'},
        ],
      ),
      build(
        id: 'l-002', profile: GallupProfile.revenge,
        sourceType: LessonSourceType.film,
        sourceName: 'Margin Call (2011)',
        externalUrl: 'https://www.imdb.com/title/tt1615147/',
        xp: 20, tag: LessonTag.mindset, correctIndex: 1,
        title: {'kk': 'Шектен шығу нүктесі', 'ru': 'Точка остановки', 'en': 'The cut-off point'},
        quote: 'Be first, be smarter, or cheat.',
        explanation: {
          'kk': 'Эмоциялық сделкаларда edge жоқ. Нарық сізді емес, статистиканы көреді. Шектен шыққанда — тоқтау.',
          'ru': 'У эмоциональных сделок нет edge. Рынок не видит вас — он видит статистику. Достиг лимита — стоп.',
          'en': 'Emotional trades have no edge. The market does not see you — it sees statistics. Hit the limit — stop.',
        },
        goldApp: {
          'kk': '3 шығын қатарынан → терминалды жап. Ертеңге қалдыр.',
          'ru': '3 убытка подряд → закрой терминал. Оставь на завтра.',
          'en': '3 losses in a row → close the terminal. Leave it for tomorrow.',
        },
        qcQuestion: {
          'kk': 'Күн ішінде "stop"-ты не белгілейді?',
          'ru': 'Что определяет «стоп» внутри дня?',
          'en': 'What defines the daily "stop"?',
        },
        qcOptions: [
          {'kk': 'Тек уақыт (24:00)', 'ru': 'Только время (24:00)', 'en': 'Only the clock (24:00)'},
          {'kk': '−3% drawdown немесе 3 қатарынан шығын', 'ru': '−3% drawdown или 3 убытка подряд', 'en': '−3% drawdown or 3 losses in a row'},
          {'kk': 'Депозит толық жоғалғанда', 'ru': 'Когда депозит полностью потерян', 'en': 'When the deposit is fully lost'},
          {'kk': 'Көңіл-күй жабылғанда', 'ru': 'Когда испортилось настроение', 'en': 'When the mood drops'},
        ],
      ),
      build(
        id: 'l-003', profile: GallupProfile.revenge,
        sourceType: LessonSourceType.podcast,
        sourceName: 'Chat With Traders — Brett Steenbarger',
        externalUrl: 'https://chatwithtraders.com/',
        xp: 25, tag: LessonTag.psychology, correctIndex: 1,
        title: {'kk': 'Эмоция ↔ есеп', 'ru': 'Эмоция ↔ метрика', 'en': 'Emotion ↔ metric'},
        quote: 'Successful traders are not those without emotions, but those who recognize them in real time.',
        explanation: {
          'kk': 'Эмоцияларды жасырмау. Олар сигнал — нені дұрыс емес жасап жатқанының белгісі. Журналда эмоция бағанын қосу — өзгерістің 1-ші қадамы.',
          'ru': 'Не прячьте эмоции. Они сигнал — что вы делаете не так. Колонка эмоций в журнале — первый шаг к изменению.',
          'en': "Don't hide emotions. They are signals showing what you do wrong. An emotion column in the journal is step one.",
        },
        goldApp: {
          'kk': 'Әр сделкаға эмодзи (😤😬😐🙂😌). Соңында pattern шығады.',
          'ru': 'К каждой сделке — эмодзи (😤😬😐🙂😌). Со временем виден паттерн.',
          'en': 'Tag each trade with an emoji (😤😬😐🙂😌). Patterns emerge over time.',
        },
        qcQuestion: {
          'kk': 'Эмоцияны журналда тіркеудің мақсаты:',
          'ru': 'Зачем фиксировать эмоции в журнале:',
          'en': 'Why log emotions in the journal:',
        },
        qcOptions: [
          {'kk': 'Сатып алушыларды қызықтыру', 'ru': 'Привлечь подписчиков', 'en': 'Attract followers'},
          {'kk': 'Pattern табу — қандай күйде дұрыс емес сделка ашылады', 'ru': 'Найти паттерн — в каком состоянии открываются плохие сделки', 'en': 'Find the pattern of which mood triggers bad trades'},
          {'kk': 'Уақыт өткізу', 'ru': 'Просто провести время', 'en': 'Pass the time'},
          {'kk': 'Психологқа көрсету', 'ru': 'Показать психологу', 'en': 'Show to a psychologist'},
        ],
      ),
      build(
        id: 'l-004', profile: GallupProfile.revenge,
        sourceType: LessonSourceType.book,
        sourceName: 'Brett Steenbarger — The Psychology of Trading',
        externalUrl: 'https://www.amazon.com/Psychology-Trading-Tools-Techniques-Minded/dp/0471267619',
        xp: 30, tag: LessonTag.psychology, correctIndex: 2,
        title: {'kk': 'Стрессті процеске айналдыру', 'ru': 'Превратить стресс в процесс', 'en': 'Turn stress into process'},
        quote: 'The market does not care about your feelings; build a process that does.',
        explanation: {
          'kk': 'Эмоциялы күйде ереже орындалмайды. Шешім — процесс: pre-trade checklist, post-trade review.',
          'ru': 'В эмоциях правила не работают. Решение — процесс: pre-trade чек-лист, post-trade ревью.',
          'en': 'Rules fail under emotion. Solution: a process — pre-trade checklist, post-trade review.',
        },
        goldApp: {
          'kk': 'XAU/USD setup жоспарын жазып алмай — кірмеу.',
          'ru': 'Не входим в XAU/USD без записанного плана сетапа.',
          'en': "Don't enter XAU/USD without a written setup plan.",
        },
        qcQuestion: {
          'kk': 'Стресс кезінде ережелер жұмыс істемейді. Дұрыс шешім:',
          'ru': 'В стрессе правила не работают. Что делать:',
          'en': "Rules fail under stress. What works:",
        },
        qcOptions: [
          {'kk': 'Күштірек тырысу', 'ru': 'Сильнее стараться', 'en': 'Try harder'},
          {'kk': 'Мотивациялық видео көру', 'ru': 'Смотреть мотивационные видео', 'en': 'Watch motivational videos'},
          {'kk': 'Pre-trade және post-trade процесс орнату', 'ru': 'Внедрить pre-trade и post-trade процесс', 'en': 'Install pre-trade and post-trade process'},
          {'kk': 'Терминалды босату', 'ru': 'Снести терминал', 'en': 'Delete the terminal'},
        ],
      ),
      build(
        id: 'l-005', profile: GallupProfile.revenge,
        sourceType: LessonSourceType.trader,
        sourceName: 'Ed Seykota',
        externalUrl: 'https://en.wikipedia.org/wiki/Ed_Seykota',
        xp: 30, tag: LessonTag.mindset, correctIndex: 0,
        title: {'kk': 'Әркім қалаған нәтижесін алады', 'ru': 'Каждый получает желаемый результат', 'en': 'Everyone gets what they want'},
        quote: 'Win or lose, everybody gets what they want out of the market.',
        explanation: {
          'kk': 'Шығыннан рахаттанатын адам шығынға келеді. "Қайтару" — өзін-өзі жазалаудың формасы. Іс-әрекетті өзгерту үшін — себебін табыңыз.',
          'ru': 'Кто получает удовольствие от убытков, тот их получает. «Отыграться» — форма самонаказания. Чтобы поменять поведение — найдите причину.',
          'en': 'Those who enjoy losses get them. "Revenge" is self-punishment. To change behaviour, find the underlying motive.',
        },
        goldApp: {
          'kk': 'Шығыннан кейін: "Мен не алдым?" сұрағы — pause + журнал.',
          'ru': 'После убытка: вопрос «что я получил?» — пауза + журнал.',
          'en': "After a loss ask 'what did I get?' — pause + journal.",
        },
        qcQuestion: {
          'kk': 'Сейкотаның тезисі бойынша, қайталанатын шығынның түпкі себебі:',
          'ru': 'По Сейкоте, корневая причина повторяющихся убытков:',
          'en': "Per Seykota, the root cause of recurring losses:",
        },
        qcOptions: [
          {'kk': 'Жасырын мотив — өзін жазалау', 'ru': 'Скрытый мотив — самонаказание', 'en': 'Hidden motive — self-punishment'},
          {'kk': 'Брокер манипуляциясы', 'ru': 'Манипуляции брокера', 'en': 'Broker manipulation'},
          {'kk': 'Нашар интернет', 'ru': 'Плохой интернет', 'en': 'Bad internet'},
          {'kk': 'Айдың фазасы', 'ru': 'Фаза луны', 'en': 'Phase of the moon'},
        ],
      ),

      // ────── UNCONTROLLED RISK ──────
      build(
        id: 'l-006', profile: GallupProfile.uncontrolledRisk,
        sourceType: LessonSourceType.book,
        sourceName: 'Alexander Elder — Trading for a Living',
        externalUrl: 'https://www.amazon.com/Trading-Living-Psychology-Tactics-Management/dp/0471592242',
        xp: 30, tag: LessonTag.risk, correctIndex: 0,
        title: {'kk': '2% ережесі', 'ru': 'Правило 2%', 'en': 'The 2% rule'},
        quote: 'Risk no more than 2% of your equity on any single trade.',
        explanation: {
          'kk': 'Кез келген сделкаға 2%-дан көп қою — оқыс өлім. 10 қатарынан шығын болса да, депозит −20%-дан төмендемейді.',
          'ru': 'Больше 2% на сделку — внезапная смерть. Даже при 10 убытках подряд депозит не упадёт ниже −20%.',
          'en': 'Risking more than 2% per trade is sudden death. Even 10 losses in a row keep the account above −20%.',
        },
        goldApp: {
          'kk': '\$1000 депозит → max \$20 risk → 0.05 lot 40 pip SL-мен.',
          'ru': 'Депозит \$1000 → макс. \$20 риска → 0.05 лот при SL 40 пипсов.',
          'en': '\$1000 deposit → max \$20 risk → 0.05 lot with 40-pip SL.',
        },
        qcQuestion: {
          'kk': '\$5000 депозит, 1% риск, SL 50 пип. Лот:',
          'ru': 'Депозит \$5000, риск 1%, SL 50 пипсов. Лот:',
          'en': '\$5000 deposit, 1% risk, 50-pip SL. Lot size:',
        },
        qcOptions: [
          {'kk': '0.1 lot', 'ru': '0.1 lot', 'en': '0.1 lot'},
          {'kk': '1.0 lot', 'ru': '1.0 lot', 'en': '1.0 lot'},
          {'kk': '0.5 lot', 'ru': '0.5 lot', 'en': '0.5 lot'},
          {'kk': '5.0 lot', 'ru': '5.0 lot', 'en': '5.0 lot'},
        ],
      ),
      build(
        id: 'l-007', profile: GallupProfile.uncontrolledRisk,
        sourceType: LessonSourceType.book,
        sourceName: 'Nassim Taleb — Fooled by Randomness',
        externalUrl: 'https://www.amazon.com/Fooled-Randomness-Hidden-Markets-Incerto/dp/0812975219',
        xp: 30, tag: LessonTag.risk, correctIndex: 1,
        title: {'kk': 'Жеңіс ≠ ақылдылық', 'ru': 'Победа ≠ ум', 'en': 'Winning ≠ skill'},
        quote: 'Mild success can be explained by skills and labor. Wild success is attributable to variance.',
        explanation: {
          'kk': 'Үлкен ұтыс — көбіне randomness. Жоғары лотпен бір рет ұту → "ережені тапқам" сезім → келесіде талқандалу.',
          'ru': 'Большая выигрышная серия — это часто случайность. После «угадал» большим лотом следует разнос.',
          'en': 'Big wins often come from randomness. One outsized win seeds overconfidence and the next blow-up.',
        },
        goldApp: {
          'kk': 'Жеңістен кейін лотты үлкейтпеңіз. Plan-Do-Review циклы.',
          'ru': 'После победы не увеличивайте лот. Цикл Plan-Do-Review.',
          'en': 'Do not increase lot after a win. Plan-Do-Review cycle.',
        },
        qcQuestion: {
          'kk': '5 жеңіс қатарынан кейінгі сау әрекет:',
          'ru': 'Здоровое действие после 5 побед подряд:',
          'en': 'Healthy action after 5 wins in a row:',
        },
        qcOptions: [
          {'kk': 'Лотты 2× үлкейту', 'ru': 'Увеличить лот в 2 раза', 'en': 'Double the lot'},
          {'kk': 'Сол ережемен жалғастыру', 'ru': 'Продолжать по тем же правилам', 'en': 'Stick to the same rules'},
          {'kk': 'Барлық депозитті бір сделкаға салу', 'ru': 'Поставить весь депозит на одну сделку', 'en': 'All-in on one trade'},
          {'kk': 'Жұмысты тастап тек трейдинг', 'ru': 'Уволиться и только трейдить', 'en': 'Quit job and trade full-time'},
        ],
      ),
      build(
        id: 'l-008', profile: GallupProfile.uncontrolledRisk,
        sourceType: LessonSourceType.book,
        sourceName: 'Nassim Taleb — The Black Swan',
        externalUrl: 'https://www.amazon.com/Black-Swan-Improbable-Robustness-Fragility/dp/081297381X',
        xp: 30, tag: LessonTag.risk, correctIndex: 2,
        title: {'kk': 'Қара аққу — әрқашан тағатын', 'ru': 'Чёрный лебедь — всегда возможен', 'en': 'Black Swan — always possible'},
        quote: 'History does not crawl, it jumps.',
        explanation: {
          'kk': 'Тарихтың үлкен өзгерістері — қара аққулар. Risk management — олардан өтуге арналған.',
          'ru': 'Главные изменения истории — чёрные лебеди. Риск-менеджмент нужен, чтобы их пережить.',
          'en': "History's biggest moves are black swans. Risk management exists to survive them.",
        },
        goldApp: {
          'kk': 'Stop loss-сыз сделка — бомба. Әрқашан SL.',
          'ru': 'Сделка без SL — бомба. Всегда SL.',
          'en': 'Trade without SL = a bomb. Always SL.',
        },
        qcQuestion: {
          'kk': 'Қара аққу оқиғасынан қорғану жолы:',
          'ru': 'Защита от события «чёрного лебедя»:',
          'en': 'Protection from a Black Swan event:',
        },
        qcOptions: [
          {'kk': 'Жоғары leverage', 'ru': 'Высокое плечо', 'en': 'High leverage'},
          {'kk': 'Болжам нақты болса — SL жоқ', 'ru': 'Если прогноз чёткий — без SL', 'en': 'No SL if forecast is clear'},
          {'kk': 'Барлық сделкада SL + max risk %', 'ru': 'SL и максимум % риска на каждой сделке', 'en': 'SL + max % risk on every trade'},
          {'kk': 'Бір ғана активке шоғырлану', 'ru': 'Концентрация на одном активе', 'en': 'Concentrate in one asset'},
        ],
      ),
      build(
        id: 'l-009', profile: GallupProfile.uncontrolledRisk,
        sourceType: LessonSourceType.film,
        sourceName: 'Rogue Trader (1999)',
        externalUrl: 'https://www.imdb.com/title/tt0131566/',
        xp: 25, tag: LessonTag.risk, correctIndex: 1,
        title: {'kk': 'Барингс банкі: бір трейдердің құлауы', 'ru': 'Barings: падение из-за одного трейдера', 'en': 'Barings: one trader, full collapse'},
        quote: 'I bet the bank — and lost it.',
        explanation: {
          'kk': 'Ник Лисон averaging-down арқылы \$1.3B жоғалтып, 233 жасар банкті құлатты. Дисциплинасыз risk — апат.',
          'ru': 'Ник Лисон averaging-down потерял \$1.3B и обанкротил 233-летний банк. Риск без дисциплины — катастрофа.',
          'en': 'Nick Leeson averaged-down to \$1.3B in losses, sinking a 233-year-old bank. Risk without discipline = disaster.',
        },
        goldApp: {
          'kk': 'Averaging-down ешқашан. Тек жоспарланған позиция масштабтау.',
          'ru': 'Averaging-down — никогда. Только запланированный набор позиции.',
          'en': 'Averaging-down — never. Only planned position scaling.',
        },
        qcQuestion: {
          'kk': 'Averaging-down дегеніміз не үшін қауіпті?',
          'ru': 'Почему averaging-down опасен?',
          'en': 'Why is averaging-down dangerous?',
        },
        qcOptions: [
          {'kk': 'Орташа бағаны жақсартады', 'ru': 'Улучшает среднюю цену', 'en': 'It improves the average'},
          {'kk': 'Шығынды экспоненциалды үлкейтеді', 'ru': 'Экспоненциально увеличивает убыток', 'en': 'It grows losses exponentially'},
          {'kk': 'Брокерге пайдалы', 'ru': 'Выгодно брокеру', 'en': 'Good for the broker'},
          {'kk': 'Эмоция жағынан жеңіл', 'ru': 'Эмоционально легче', 'en': 'Easier emotionally'},
        ],
      ),
      build(
        id: 'l-010', profile: GallupProfile.uncontrolledRisk,
        sourceType: LessonSourceType.podcast,
        sourceName: 'The Trading Game Podcast — Gary Stevenson',
        externalUrl: 'https://garyseconomics.com/podcast',
        xp: 25, tag: LessonTag.risk, correctIndex: 0,
        title: {'kk': 'Тәуекелді жеуге үйрену', 'ru': 'Учиться переваривать риск', 'en': 'Learning to digest risk'},
        quote: 'You don\'t learn to win — you learn to size losses.',
        explanation: {
          'kk': 'Citi-дегі ең жас трейдер: позиция мөлшерін емес, шығын мөлшерін бақылау керек.',
          'ru': 'Самый молодой трейдер Citi: контролируйте не размер позиции, а размер убытка.',
          'en': "Citi's youngest trader: control loss size, not position size.",
        },
        goldApp: {
          'kk': 'XAU/USD-те SL әрқашан жоспарлы. Лот — SL-ден туады.',
          'ru': 'SL на XAU/USD всегда заранее. Лот — следствие SL.',
          'en': "SL on XAU/USD is always pre-planned. Lot follows from SL.",
        },
        qcQuestion: {
          'kk': 'Профи трейдер бірінші не есептейді?',
          'ru': 'Что профи считает в первую очередь?',
          'en': 'What does a pro calculate first?',
        },
        qcOptions: [
          {'kk': 'Ықтимал шығын', 'ru': 'Потенциальный убыток', 'en': 'Potential loss'},
          {'kk': 'Ықтимал пайда', 'ru': 'Потенциальная прибыль', 'en': 'Potential profit'},
          {'kk': 'Брокер комиссиясы', 'ru': 'Комиссию брокера', 'en': 'Broker commission'},
          {'kk': 'Spread', 'ru': 'Spread', 'en': 'Spread'},
        ],
      ),

      // ────── HOPE TRADING ──────
      build(
        id: 'l-011', profile: GallupProfile.hope,
        sourceType: LessonSourceType.book,
        sourceName: 'Edwin Lefèvre — Reminiscences of a Stock Operator',
        externalUrl: 'https://www.amazon.com/Reminiscences-Stock-Operator-Edwin-Lef%C3%A8vre/dp/0471770884',
        xp: 25, tag: LessonTag.discipline, correctIndex: 1,
        title: {'kk': 'Үміт пен Жоспар', 'ru': 'Надежда и план', 'en': 'Hope and plan'},
        quote: 'The market is never wrong; opinions often are.',
        explanation: {
          'kk': '"Соңында бұрылады" сезімі — интуиция емес, шығыннан қашу. SL — қорғаныс, оны қозғау зиян.',
          'ru': '«В итоге развернётся» — не интуиция, а бегство от убытка. SL — защита, его нельзя двигать.',
          'en': '"It will turn around" is not intuition — it is escape from loss. SL is a shield; do not move it.',
        },
        goldApp: {
          'kk': 'SL қойдың — кеңейтпе. TP жетпесе breakeven-ге жылжыт, артқа емес.',
          'ru': 'Поставил SL — не расширяй. Не достал TP → двигай в breakeven, не назад.',
          'en': 'SL set — do not widen it. If TP not reached → move to breakeven, never back.',
        },
        qcQuestion: {'kk': 'SL дегеніміз:', 'ru': 'Что такое SL:', 'en': 'What is SL:'},
        qcOptions: [
          {'kk': 'Шығу — ұят, оны кеңейту керек', 'ru': 'Уйти стыдно — лучше расширить', 'en': 'Exiting is shameful, widen it'},
          {'kk': 'Setup invalidation point — қозғалмайды', 'ru': 'Точка инвалидации сетапа — не двигается', 'en': 'Setup invalidation point — never moves'},
          {'kk': 'Брокер ұсынысы ғана', 'ru': 'Просто рекомендация брокера', 'en': "Just a broker's suggestion"},
          {'kk': 'Қажет емес деталь', 'ru': 'Ненужная деталь', 'en': 'Unnecessary detail'},
        ],
      ),
      build(
        id: 'l-012', profile: GallupProfile.hope,
        sourceType: LessonSourceType.podcast,
        sourceName: 'Two Quants and a Financial Planner',
        externalUrl: 'https://twoquantsandafinancialplanner.com/',
        xp: 25, tag: LessonTag.psychology, correctIndex: 1,
        title: {'kk': 'Probabilistic thinking', 'ru': 'Вероятностное мышление', 'en': 'Probabilistic thinking'},
        quote: 'Stop predicting. Start measuring probabilities.',
        explanation: {
          'kk': 'Үміт — бір нәтижеге сену. Trader — әр сценарийге ықтималдық беру. Бұл — кәсіби көзқарас.',
          'ru': 'Надежда — это вера в один исход. Трейдер же присваивает вероятность каждому сценарию.',
          'en': 'Hope is belief in one outcome. A trader assigns probability to every scenario.',
        },
        goldApp: {
          'kk': 'Сделка алдында: bullish 60% / bearish 30% / neutral 10%. Соған сай size.',
          'ru': 'Перед сделкой: bullish 60% / bearish 30% / neutral 10%. Под это и размер позиции.',
          'en': 'Pre-trade: bullish 60% / bearish 30% / neutral 10%. Size accordingly.',
        },
        qcQuestion: {'kk': 'Үміттің трейдингтегі рөлі:', 'ru': 'Роль надежды в трейдинге:', 'en': "Hope's role in trading:"},
        qcOptions: [
          {'kk': 'Күшті актив — үміт жоғары → жеңіс жоғары', 'ru': 'Сильный актив — больше надежды → больше побед', 'en': 'Strong asset, more hope → more wins'},
          {'kk': 'Жоспарға қарсы — статистикалық edge жоқ', 'ru': 'Против плана — нет статистического edge', 'en': 'Against the plan — no statistical edge'},
          {'kk': 'Тек day trading-те қолданылады', 'ru': 'Только в дей-трейдинге', 'en': 'Used only in day trading'},
          {'kk': 'Инвестбанкте керек', 'ru': 'Нужна в инвестбанке', 'en': 'Needed at an investment bank'},
        ],
      ),
      build(
        id: 'l-013', profile: GallupProfile.hope,
        sourceType: LessonSourceType.book,
        sourceName: 'Annie Duke — Thinking in Bets',
        externalUrl: 'https://www.amazon.com/Thinking-Bets-Making-Smarter-Decisions/dp/0735216355',
        xp: 30, tag: LessonTag.mindset, correctIndex: 1,
        title: {'kk': 'Шешімді нәтижеден ажырату', 'ru': 'Отделить решение от результата', 'en': 'Decision vs outcome'},
        quote: 'Resulting is judging a decision based on its outcome rather than on the quality of the decision.',
        explanation: {
          'kk': 'Жақсы шешім қате нәтиже бере алады — және керісінше. Шешімнің сапасын бөлек бағалаңыз.',
          'ru': 'Хорошее решение может дать плохой исход — и наоборот. Оценивайте качество решения отдельно от результата.',
          'en': 'A good decision can yield a bad outcome and vice versa. Judge decision quality independently of result.',
        },
        goldApp: {
          'kk': 'SL шықса да, A+ setup болса — журналда "сапалы шешім" деп белгілеу.',
          'ru': 'Даже если SL — но это был A+ сетап, в журнале отметить «качественное решение».',
          'en': "Even if SL hit, if it was an A+ setup, log it as 'good decision'.",
        },
        qcQuestion: {'kk': '"Resulting" қатесі:', 'ru': 'Ошибка «resulting»:', 'en': 'The "resulting" mistake:'},
        qcOptions: [
          {'kk': 'Нәтижені тым көп тексеру', 'ru': 'Слишком часто проверять результат', 'en': 'Checking outcomes too often'},
          {'kk': 'Шешімді тек нәтиже бойынша бағалау', 'ru': 'Оценивать решение только по результату', 'en': 'Judging decisions purely by outcome'},
          {'kk': 'Шығынды теріске шығару', 'ru': 'Отрицать убыток', 'en': 'Denying losses'},
          {'kk': 'Pause жасау', 'ru': 'Делать паузу', 'en': 'Taking a break'},
        ],
      ),
      build(
        id: 'l-014', profile: GallupProfile.hope,
        sourceType: LessonSourceType.film,
        sourceName: 'The Wolf of Wall Street (2013)',
        externalUrl: 'https://www.imdb.com/title/tt0993846/',
        xp: 20, tag: LessonTag.mindset, correctIndex: 2,
        title: {'kk': 'Гипер-үміттің бағасы', 'ru': 'Цена гипер-надежды', 'en': 'Cost of hyper-hope'},
        quote: 'The only thing standing between you and your goal is the bullsh*t story you keep telling yourself.',
        explanation: {
          'kk': 'Үлкен үміт — кейде үлкен сатылым ғана. Жоспардан тыс "ұту" уәдесі — жоқ. Жоспар бар.',
          'ru': 'Большая надежда часто это просто продажа. Никакого «выигрыша вне плана» — есть только план.',
          'en': 'Big hope is often just a sales pitch. There is no "win outside the plan" — there is only the plan.',
        },
        goldApp: {
          'kk': '"Ұтуға болады" сезімі болса — соны жоспарға айналдыр (entry/SL/TP/RR).',
          'ru': 'Появилось чувство «можно заработать» — превратите его в план (entry/SL/TP/RR).',
          'en': 'When "I could win this" arises — turn it into a plan (entry/SL/TP/RR).',
        },
        qcQuestion: {
          'kk': '"Соны қашыруға болмайды" сезімі — қалай әрекет ету керек?',
          'ru': '«Нельзя пропустить» — как реагировать?',
          'en': 'The "I cannot miss this" feeling — how to react?',
        },
        qcOptions: [
          {'kk': 'Сезімге кіру', 'ru': 'Войти по чувству', 'en': 'Enter by feeling'},
          {'kk': 'Лот ұлғайту', 'ru': 'Увеличить лот', 'en': 'Increase the lot'},
          {'kk': 'Жоспарды талап ету (entry/SL/TP) немесе өткізу', 'ru': 'Потребовать план (entry/SL/TP) или пропустить', 'en': 'Demand a plan (entry/SL/TP) or skip'},
          {'kk': 'Жоғары leverage', 'ru': 'Включить максимальное плечо', 'en': 'Max leverage'},
        ],
      ),
      build(
        id: 'l-015', profile: GallupProfile.hope,
        sourceType: LessonSourceType.podcast,
        sourceName: 'Better System Trader',
        externalUrl: 'https://bettersystemtrader.com/',
        xp: 25, tag: LessonTag.strategy, correctIndex: 1,
        title: {'kk': 'Жүйесіз сауда — кездейсоқ нәтиже', 'ru': 'Без системы — случайный результат', 'en': 'No system, random result'},
        quote: 'If you can\'t describe what you\'re doing as a system, you don\'t have an edge.',
        explanation: {
          'kk': 'Жүйе — қайталанатын. Жүйесіз "үміт" нәтижені кездейсоқ етеді. Жүйе backtest-пен расталады.',
          'ru': 'Система воспроизводима. Без системы «надежда» делает результат случайным. Система проверяется бэктестом.',
          'en': "A system is reproducible. Without it, 'hope' makes results random. A system is validated via backtest.",
        },
        goldApp: {
          'kk': 'XAU/USD стратегиясын 50 retest + 50 breakout бойынша backtest жасап шығар.',
          'ru': 'Прогоните стратегию XAU/USD по 50 ретестам + 50 пробоям в бэктесте.',
          'en': 'Backtest your XAU/USD strategy across 50 retests + 50 breakouts.',
        },
        qcQuestion: {
          'kk': 'Жүйенің ең қарапайым тексерісі:',
          'ru': 'Простейшая проверка системы:',
          'en': 'Simplest system check:',
        },
        qcOptions: [
          {'kk': 'Брокердің мақұлдауы', 'ru': 'Одобрение брокера', 'en': "Broker's approval"},
          {'kk': 'Backtest + forward demo', 'ru': 'Backtest + forward demo', 'en': 'Backtest + forward demo'},
          {'kk': 'Telegram чатының саны', 'ru': 'Количество телеграм-чатов', 'en': 'Number of Telegram chats'},
          {'kk': 'Әлеуметтік желілердегі лайктар', 'ru': 'Лайки в соцсетях', 'en': 'Social media likes'},
        ],
      ),
      build(
        id: 'l-016', profile: GallupProfile.hope,
        sourceType: LessonSourceType.book,
        sourceName: 'Mark Douglas — The Disciplined Trader',
        externalUrl: 'https://www.amazon.com/Disciplined-Trader-Developing-Winning-Attitudes/dp/0132157578',
        xp: 25, tag: LessonTag.discipline, correctIndex: 0,
        title: {'kk': 'Сенімділік шарты', 'ru': 'Условие уверенности', 'en': 'Confidence condition'},
        quote: 'Confidence and fear are mutually exclusive.',
        explanation: {
          'kk': 'Сенімділік — жүйеге сенімнен туады. Үміт — қорқыныштан туады.',
          'ru': 'Уверенность рождается из доверия к системе. Надежда — из страха.',
          'en': 'Confidence comes from trust in a system. Hope comes from fear.',
        },
        goldApp: {
          'kk': 'A+ checklist құр; әр сделкаға дейін соны қайталап оқы.',
          'ru': 'Соберите A+ чек-лист и читайте его перед каждой сделкой.',
          'en': 'Build an A+ checklist and read it before each trade.',
        },
        qcQuestion: {
          'kk': 'Сенімділіктің көзі:',
          'ru': 'Источник уверенности:',
          'en': 'Source of confidence:',
        },
        qcOptions: [
          {'kk': 'Жүйеге сенім', 'ru': 'Доверие к системе', 'en': 'Trust in the system'},
          {'kk': 'Үлкен депозит', 'ru': 'Большой депозит', 'en': 'Large deposit'},
          {'kk': 'Мотивациялық цитаталар', 'ru': 'Мотивационные цитаты', 'en': 'Motivational quotes'},
          {'kk': 'Брокер логотипі', 'ru': 'Логотип брокера', 'en': "Broker's logo"},
        ],
      ),

      // ────── DISCIPLINED ──────
      build(
        id: 'l-017', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.trader,
        sourceName: 'Paul Tudor Jones',
        externalUrl: 'https://en.wikipedia.org/wiki/Paul_Tudor_Jones',
        xp: 35, tag: LessonTag.strategy, correctIndex: 1,
        title: {'kk': 'Тәуекел әуелі, пайда содан кейін', 'ru': 'Сначала риск, потом прибыль', 'en': 'Risk first, profit second'},
        quote: 'The most important rule of trading is to play great defense, not great offense.',
        explanation: {
          'kk': 'Defense — әр сделкадан кейін журнал, statistical edge есептеу, A+ setup-тарды ғана таңдау.',
          'ru': 'Defense — журнал после каждой сделки, оценка edge, только A+ сетапы.',
          'en': 'Defense — journal every trade, measure the edge, take only A+ setups.',
        },
        goldApp: {
          'kk': 'XAU/USD үшін аптада max 5 A+ setup. London/NY overlap-қа шоғырлан.',
          'ru': 'На XAU/USD — максимум 5 A+ сетапов в неделю. Фокус на overlap London/NY.',
          'en': 'On XAU/USD: max 5 A+ setups per week. Focus on London/NY overlap.',
        },
        qcQuestion: {'kk': 'A+ setup критерийі:', 'ru': 'Критерий A+ сетапа:', 'en': 'A+ setup criterion:'},
        qcOptions: [
          {'kk': '"Көзімде дұрыс" сезім', 'ru': 'Чувство «выглядит правильно»', 'en': '"Feels right" intuition'},
          {'kk': 'Жазылған checklist — min 4 confluence', 'ru': 'Письменный чек-лист — минимум 4 confluence', 'en': 'Written checklist — min 4 confluence'},
          {'kk': 'Тек жоғары волатильділік', 'ru': 'Только высокая волатильность', 'en': 'Only high volatility'},
          {'kk': 'Кез келген retest', 'ru': 'Любой ретест', 'en': 'Any retest'},
        ],
      ),
      build(
        id: 'l-018', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.book,
        sourceName: 'Jack Schwager — Market Wizards',
        externalUrl: 'https://www.amazon.com/Market-Wizards-Updated-Interviews-Traders/dp/1118273052',
        xp: 35, tag: LessonTag.strategy, correctIndex: 2,
        title: {'kk': 'Edge табу', 'ru': 'Поиск edge', 'en': 'Finding the edge'},
        quote: 'The hard work in trading comes in the preparation. The actual process of trading should be effortless.',
        explanation: {
          'kk': 'Edge — статистикалық преимущество. Backtesting + forward demo + журналдан кейін ғана live.',
          'ru': 'Edge — это статистическое преимущество. Live только после backtest + forward demo + журнала.',
          'en': 'Edge = statistical advantage. Live only after backtest + forward demo + journal.',
        },
        goldApp: {
          'kk': '200+ сделка backtest + 1 ай forward демо → live.',
          'ru': '200+ сделок backtest + месяц forward demo → live.',
          'en': '200+ trade backtest + 1-month forward demo → live.',
        },
        qcQuestion: {
          'kk': 'Стратегияны live-қа қашан шығару керек?',
          'ru': 'Когда выводить стратегию на live?',
          'en': 'When to take a strategy live?',
        },
        qcOptions: [
          {'kk': 'Бірден, идея бар болса', 'ru': 'Сразу, как появилась идея', 'en': 'Right after the idea forms'},
          {'kk': '5 сделкадан кейін', 'ru': 'После 5 сделок', 'en': 'After 5 trades'},
          {'kk': '200+ backtest + 1 ай forward демо растағаннан кейін', 'ru': 'После 200+ бэктеста + месяц forward demo', 'en': 'After 200+ backtest + 1-month forward demo'},
          {'kk': '10 жеңіс қатарынан болғанда', 'ru': 'После 10 побед подряд', 'en': 'After 10 wins in a row'},
        ],
      ),
      build(
        id: 'l-019', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.film,
        sourceName: 'The Big Short (2015)',
        externalUrl: 'https://www.imdb.com/title/tt1596363/',
        xp: 30, tag: LessonTag.mindset, correctIndex: 1,
        title: {'kk': 'Контр-консенсус', 'ru': 'Против консенсуса', 'en': 'Counter-consensus'},
        quote: 'The market does what it wants to do, when it wants to do it.',
        explanation: {
          'kk': 'Дисциплиналы трейдер консенсуспен бірге емес — өз edge-ін ұстайды. Бірақ ол тиімді болуы үшін жоспар + журнал + research керек.',
          'ru': 'Дисциплинированный трейдер идёт не с толпой, а со своим edge. Но это работает только при плане + журнале + research.',
          'en': 'The disciplined trader does not follow the crowd — they hold their edge. But only with a plan + journal + research.',
        },
        goldApp: {
          'kk': 'Crowd "bullish" → DXY-ді тексеру. Sentiment + structure divergence — A+ setup.',
          'ru': 'Толпа bullish → проверяй DXY. Дивергенция sentiment + структура — A+ сетап.',
          'en': 'Crowd bullish → check DXY. Sentiment + structure divergence — A+ setup.',
        },
        qcQuestion: {
          'kk': 'Контр-консенсус сделканы қашан ашуға болады?',
          'ru': 'Когда можно открывать сделку против консенсуса?',
          'en': 'When can you take a counter-consensus trade?',
        },
        qcOptions: [
          {'kk': 'Барлығы bullish дегенде керісінше', 'ru': 'Когда все bullish — сразу против', 'en': 'When all are bullish — go opposite'},
          {'kk': 'Тек жоспар + research + structure растағанда', 'ru': 'Только когда план + research + structure подтверждают', 'en': 'Only with plan + research + structure confirmation'},
          {'kk': 'Алдыңғы шығынды қайтару үшін', 'ru': 'Чтобы отыграться', 'en': 'To recover a loss'},
          {'kk': 'Әрқашан', 'ru': 'Всегда', 'en': 'Always'},
        ],
      ),
      build(
        id: 'l-020', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.trader,
        sourceName: 'Stanley Druckenmiller',
        externalUrl: 'https://en.wikipedia.org/wiki/Stanley_Druckenmiller',
        xp: 30, tag: LessonTag.strategy, correctIndex: 2,
        title: {'kk': 'Концентрация мен сабырлылық', 'ru': 'Концентрация и терпение', 'en': 'Concentration and patience'},
        quote: 'The way to build long-term returns is preservation of capital and home runs.',
        explanation: {
          'kk': 'Көп майда сделка емес — бірақ дайын тұрып, бір үлкен setup-та "all-in" (риск %-ке сай). Сабырлылық — алдыңғы дағды.',
          'ru': 'Не много мелких сделок — а готовность ждать и взять один большой сетап (в рамках риска %). Терпение — главный навык.',
          'en': 'Not many small trades — wait and strike one big setup within risk %. Patience is the skill.',
        },
        goldApp: {
          'kk': 'XAU/USD-та аптасына 1–2 H4 сетапқа дайын болу. Қалғанын өткіз.',
          'ru': 'На XAU/USD будь готов к 1–2 сетапам H4 в неделю. Остальное — пропускай.',
          'en': 'On XAU/USD: ready for 1–2 H4 setups per week. Skip the rest.',
        },
        qcQuestion: {
          'kk': 'Druckenmiller бойынша негізгі сапа:',
          'ru': 'Главное качество по Друкенмиллеру:',
          'en': 'Druckenmiller\'s key trait:',
        },
        qcOptions: [
          {'kk': 'Жылдамдық', 'ru': 'Скорость', 'en': 'Speed'},
          {'kk': 'Көп сделка', 'ru': 'Много сделок', 'en': 'Many trades'},
          {'kk': 'Капиталды сақтап, сабырмен күту', 'ru': 'Сохранение капитала и терпение', 'en': 'Capital preservation + patience'},
          {'kk': 'Жоғары leverage', 'ru': 'Большое плечо', 'en': 'High leverage'},
        ],
      ),
      build(
        id: 'l-021', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.film,
        sourceName: 'Trader: The Documentary (1987, Paul Tudor Jones)',
        externalUrl: 'https://en.wikipedia.org/wiki/Trader_(film)',
        xp: 25, tag: LessonTag.discipline, correctIndex: 1,
        title: {'kk': 'Күн тәртібі — бәрі', 'ru': 'Распорядок — это всё', 'en': 'Routine is everything'},
        quote: 'I have a daily routine. That\'s it.',
        explanation: {
          'kk': 'PTJ-дың пре-маркет, ішкі маркет, пост-маркет ритуалы — performance-тің негізі.',
          'ru': 'Пре-маркет, рынок, пост-маркет — ритуал PTJ, фундамент его эффективности.',
          'en': "PTJ's pre-, in-, post-market routine is the bedrock of his performance.",
        },
        goldApp: {
          'kk': 'Әр күнгі ритуал: 8:30 HTF талдау, 10:00 setup тізімі, 18:00 журнал.',
          'ru': 'Ежедневный ритуал: 8:30 HTF-анализ, 10:00 список сетапов, 18:00 журнал.',
          'en': 'Daily routine: 8:30 HTF analysis, 10:00 setup list, 18:00 journal.',
        },
        qcQuestion: {
          'kk': 'Күн тәртібінің рөлі:',
          'ru': 'Роль распорядка:',
          'en': 'Role of the routine:',
        },
        qcOptions: [
          {'kk': 'Мағынасыз салт', 'ru': 'Бессмысленный ритуал', 'en': 'Meaningless ritual'},
          {'kk': 'Шешімдер сапасы мен тұрақтылықтың базасы', 'ru': 'База качества решений и стабильности', 'en': 'Foundation of decision quality + consistency'},
          {'kk': 'Тек newbie-лерге', 'ru': 'Только для новичков', 'en': 'Only for newbies'},
          {'kk': 'Уақытты жоғалту', 'ru': 'Потеря времени', 'en': 'Waste of time'},
        ],
      ),
      build(
        id: 'l-022', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.film,
        sourceName: 'Floored (2009)',
        externalUrl: 'https://www.imdb.com/title/tt1372701/',
        xp: 20, tag: LessonTag.mindset, correctIndex: 2,
        title: {'kk': 'Pit-тегі күн', 'ru': 'День в пите', 'en': 'A day in the pit'},
        quote: 'Discipline and self-control will be your only friend on the trading floor.',
        explanation: {
          'kk': 'Чикаго pit-инің ыстық эмоциясы — қазіргі экранмен бірдей. Ережелер — өзіңмен соғыстағы қаруың.',
          'ru': 'Эмоция чикагского пита — та же, что и за экраном. Правила — оружие против самого себя.',
          'en': "Chicago pit emotion = the same as the modern screen. Rules are your weapon against yourself.",
        },
        goldApp: {
          'kk': 'Tilt сезімде — pause + 4 саттық дем алу.',
          'ru': 'Чувствуете tilt — пауза + 4-секундное дыхание.',
          'en': 'Feeling tilt — pause + 4-second breathing.',
        },
        qcQuestion: {'kk': 'Tilt-тен шығу әдісі:', 'ru': 'Способ выйти из tilt:', 'en': 'Way out of tilt:'},
        qcOptions: [
          {'kk': 'Лот ұлғайту', 'ru': 'Увеличить лот', 'en': 'Increase the lot'},
          {'kk': 'Кофе ішу', 'ru': 'Кофе', 'en': 'Coffee'},
          {'kk': 'Pause + дем алу + журналға жазу', 'ru': 'Пауза + дыхание + запись в журнал', 'en': 'Pause + breathing + journaling'},
          {'kk': 'Жаңалықтарды ашу', 'ru': 'Открыть новости', 'en': 'Open the news'},
        ],
      ),
      build(
        id: 'l-023', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.podcast,
        sourceName: 'Top Traders Unplugged',
        externalUrl: 'https://toptradersunplugged.com/',
        xp: 25, tag: LessonTag.strategy, correctIndex: 0,
        title: {'kk': 'Systematic ↔ Discretionary', 'ru': 'Systematic ↔ Discretionary', 'en': 'Systematic ↔ Discretionary'},
        quote: 'You don\'t need to predict — you need to react with rules.',
        explanation: {
          'kk': 'Дисциплина — systematic-те. Discretionary болсаңыз да, шешімдеріңізді жазылған ережелерге айналдыр.',
          'ru': 'Дисциплина в системности. Даже если discretionary — превратите решения в письменные правила.',
          'en': 'Discipline is systematic. Even if discretionary, convert decisions into written rules.',
        },
        goldApp: {
          'kk': 'Әр setup-тың кіру/SL/TP/exit ережесі жазылған.',
          'ru': 'У каждого сетапа прописаны правила входа/SL/TP/выхода.',
          'en': 'Every setup has written entry/SL/TP/exit rules.',
        },
        qcQuestion: {
          'kk': 'Discretionary трейдердің дисциплинасы:',
          'ru': 'Дисциплина discretionary-трейдера:',
          'en': "A discretionary trader's discipline:",
        },
        qcOptions: [
          {'kk': 'Шешімдерді жазылған ережелерге айналдыру', 'ru': 'Превратить решения в письменные правила', 'en': 'Convert decisions into written rules'},
          {'kk': 'Тек интуиция', 'ru': 'Только интуиция', 'en': 'Intuition only'},
          {'kk': 'Брокерге сену', 'ru': 'Доверие брокеру', 'en': 'Trust the broker'},
          {'kk': 'Жаңалықтарға тәуелді болу', 'ru': 'Зависимость от новостей', 'en': 'Depending on news'},
        ],
      ),
      build(
        id: 'l-024', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.podcast,
        sourceName: 'Chat With Traders — Aaron Fifield',
        externalUrl: 'https://chatwithtraders.com/',
        xp: 25, tag: LessonTag.discipline, correctIndex: 1,
        title: {'kk': 'Сабырлылықтың құны', 'ru': 'Цена терпения', 'en': 'The price of patience'},
        quote: 'The market pays the patient — and tuition for the impatient.',
        explanation: {
          'kk': 'Күтуді практика — pre-trade checklist, минут пауза, тек A+ setup.',
          'ru': 'Терпение — практика: pre-trade чек-лист, минутная пауза, только A+ сетапы.',
          'en': 'Patience is a practice — pre-trade checklist, 60-sec pause, A+ setups only.',
        },
        goldApp: {
          'kk': 'Әр сделкаға дейін 60 секунд тоқта — checklist арқылы өт.',
          'ru': 'Перед каждой сделкой — 60-секундная пауза по чек-листу.',
          'en': 'Before each trade — 60-second pause via checklist.',
        },
        qcQuestion: {'kk': 'Сабырлылық — бұл:', 'ru': 'Терпение — это:', 'en': 'Patience is:'},
        qcOptions: [
          {'kk': 'Қозғалыссыздық', 'ru': 'Бездействие', 'en': 'Inaction'},
          {'kk': 'Жоспарға дейін күту мен ережеге сай орындау', 'ru': 'Ожидание плана и точное исполнение', 'en': 'Waiting for the plan and executing it'},
          {'kk': 'Қорқыныш', 'ru': 'Страх', 'en': 'Fear'},
          {'kk': 'Сенімсіздік', 'ru': 'Неуверенность', 'en': 'Uncertainty'},
        ],
      ),
      build(
        id: 'l-025', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.book,
        sourceName: 'Van K. Tharp — Trade Your Way to Financial Freedom',
        externalUrl: 'https://www.amazon.com/Trade-Your-Way-Financial-Freedom/dp/0071478710',
        xp: 30, tag: LessonTag.risk, correctIndex: 1,
        title: {'kk': 'Position sizing — басты сапа', 'ru': 'Position sizing — главный навык', 'en': 'Position sizing — the key skill'},
        quote: 'Most people focus on entries. Wizards focus on position sizing.',
        explanation: {
          'kk': 'Лот — пайданың 90%-ы. Entry-ге емес, sizing-ке шоғырлан. Risk-of-ruin есепте.',
          'ru': 'Лот определяет 90% результата. Фокус не на входе, а на sizing. Считай risk-of-ruin.',
          'en': 'Lot drives 90% of returns. Focus on sizing, not entries. Calculate risk-of-ruin.',
        },
        goldApp: {
          'kk': 'XAU/USD-те sizing-ке Position Calculator-ды қолдан (TraderOS-та бар).',
          'ru': 'Для XAU/USD используйте Position Calculator в TraderOS.',
          'en': 'Use the Position Calculator inside TraderOS for XAU/USD sizing.',
        },
        qcQuestion: {
          'kk': 'Tharp бойынша пайданың үлкен бөлігі неден туады?',
          'ru': 'По Тарпу, большая часть результата от чего?',
          'en': "Per Tharp, what drives most of the return?",
        },
        qcOptions: [
          {'kk': 'Entry timing', 'ru': 'Время входа', 'en': 'Entry timing'},
          {'kk': 'Position sizing', 'ru': 'Position sizing', 'en': 'Position sizing'},
          {'kk': 'Брокер таңдау', 'ru': 'Выбор брокера', 'en': 'Broker choice'},
          {'kk': 'Тіл алмастыру', 'ru': 'Смена языка', 'en': 'Switching language'},
        ],
      ),
      build(
        id: 'l-026', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.book,
        sourceName: 'Andrew Aziz — How to Day Trade for a Living',
        externalUrl: 'https://www.amazon.com/How-Day-Trade-Living-Management/dp/1535585951',
        xp: 25, tag: LessonTag.strategy, correctIndex: 1,
        title: {'kk': 'Routine + setup + risk', 'ru': 'Routine + setup + риск', 'en': 'Routine + setup + risk'},
        quote: 'Trading is not a sprint. It\'s a process you repeat every day.',
        explanation: {
          'kk': 'Күнделікті: HTF bias, watchlist, setup criteria, sizing, журнал.',
          'ru': 'Ежедневно: HTF bias, watchlist, критерии сетапа, sizing, журнал.',
          'en': 'Daily: HTF bias, watchlist, setup criteria, sizing, journal.',
        },
        goldApp: {
          'kk': 'TraderOS-те Edge Academy + Position Calculator + Journal — толық цикл.',
          'ru': 'В TraderOS Edge Academy + Position Calculator + Journal — полный цикл.',
          'en': 'In TraderOS: Edge Academy + Position Calculator + Journal — the complete loop.',
        },
        qcQuestion: {
          'kk': 'Күнделікті процестің ең қажетті элементі:',
          'ru': 'Самый важный элемент ежедневного процесса:',
          'en': 'The most essential element of the daily process:',
        },
        qcOptions: [
          {'kk': 'Жаңалық', 'ru': 'Новости', 'en': 'News'},
          {'kk': 'Сату-сатып алу журналы (review)', 'ru': 'Журнал сделок (review)', 'en': 'Trade journal (review)'},
          {'kk': 'Брокер чаттары', 'ru': 'Чаты брокера', 'en': 'Broker chats'},
          {'kk': 'YouTube ағыны', 'ru': 'YouTube-стрим', 'en': 'YouTube stream'},
        ],
      ),
      build(
        id: 'l-027', profile: GallupProfile.disciplined,
        sourceType: LessonSourceType.book,
        sourceName: 'Michael Covel — Trend Following',
        externalUrl: 'https://www.amazon.com/Trend-Following-Updated-Edition-Learn/dp/0136137180',
        xp: 25, tag: LessonTag.strategy, correctIndex: 0,
        title: {'kk': 'Трендке еру жүйесі', 'ru': 'Система следования за трендом', 'en': 'Trend-following as a system'},
        quote: 'You don\'t predict — you respond.',
        explanation: {
          'kk': 'Тренд бойынша жүйе: HTF bias, breakout entry, trailing stop. Кездейсоқтыққа қарсы — қайталанатын процесс.',
          'ru': 'Система по тренду: HTF bias, вход на пробой, trailing stop. Воспроизводимый процесс.',
          'en': 'Trend-based system: HTF bias, breakout entry, trailing stop. A repeatable process.',
        },
        goldApp: {
          'kk': 'XAU/USD H4 trend → 15M структурада entry → trailing.',
          'ru': 'Тренд H4 на XAU/USD → вход по структуре 15M → trailing.',
          'en': 'XAU/USD H4 trend → 15M structural entry → trailing.',
        },
        qcQuestion: {
          'kk': 'Trend-following жүйесінің базасы:',
          'ru': 'Основа trend-following:',
          'en': 'Core of trend-following:',
        },
        qcOptions: [
          {'kk': 'Жоғары TF bias + LTF entry + trailing', 'ru': 'HTF bias + LTF вход + trailing', 'en': 'HTF bias + LTF entry + trailing'},
          {'kk': 'Барлық signal-ды сүзу', 'ru': 'Фильтр всех сигналов', 'en': 'Filter all signals'},
          {'kk': 'Тек жаңалық бойынша', 'ru': 'Только по новостям', 'en': 'News-only'},
          {'kk': 'Жоғары leverage', 'ru': 'Большое плечо', 'en': 'High leverage'},
        ],
      ),
    ];
  }

  // ─────────────────────── AI insight ───────────────────────

  static String aiInsightOfTheDay(String loc, Random? rng) {
    final variants = _pickList(loc, kk: [
      'Сіздің ең мықты сетапыңыз — London ашылуында retest. Соңғы 30 сделкадан 12-сі осы сетап (Win Rate 75%).',
      'NY сессиясында breakout сделкалар Win Rate тек 42%. Risk-ті азайтып, retest-терге шоғырлан.',
      'Asia сессиясында 6 сделкадан 1 ғана плюс. Бұл сессияны мүлдем алып тастауға болады.',
      'Соңғы 7 күн streak: 5 күн. Бүгінгі сделка жоспарын ертеңге дейін жаз — стрик сақтал.',
    ], ru: [
      'Ваш сильнейший сетап — ретест на открытии Лондона. 12 из последних 30 сделок именно он (Win Rate 75%).',
      'В сессию NY сделки на пробой дают Win Rate всего 42%. Снижайте риск и фокусируйтесь на ретестах.',
      'В азиатскую сессию плюс лишь 1 из 6 сделок. Сессию можно исключить полностью.',
      'Streak последних 7 дней: 5. Запишите план на сегодня, чтобы сохранить серию.',
    ], en: [
      'Your strongest setup is London-open retest. 12 of the last 30 trades were this setup (Win Rate 75%).',
      'NY-session breakout trades have only 42% Win Rate. Reduce risk and focus on retests.',
      'Asia session has only 1 winning trade out of 6. This session can be skipped entirely.',
      'Streak of last 7 days: 5. Write today\'s plan to keep it alive.',
    ]);
    final r = rng ?? Random();
    return variants[r.nextInt(variants.length)];
  }

  static List<String> _pickList(String loc, {required List<String> kk, required List<String> ru, required List<String> en}) {
    switch (loc) {
      case 'ru':
        return ru;
      case 'en':
        return en;
      default:
        return kk;
    }
  }
}
