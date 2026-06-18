import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/events/application/my_events_controller.dart';
import '../../shared/models/trading_event.dart';
import '../config/app_config.dart';
import '../locale/locale_controller.dart';
import '../network/api_service.dart';

double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

EventType _eventType(String s) {
  switch (s) {
    case 'live_trade':
      return EventType.liveTrade;
    case 'webinar':
      return EventType.webinar;
    default:
      return EventType.masterclass;
  }
}

/// Backend JSON → TradingEvent.
TradingEvent eventFromJson(Map<String, dynamic> j) {
  final yt = (j['youtube_id'] ?? '').toString();
  return TradingEvent(
    id: j['id'].toString(),
    type: _eventType((j['type'] ?? 'masterclass').toString()),
    title: (j['title'] ?? '').toString(),
    speaker: (j['speaker'] ?? '').toString(),
    city: (j['city'] ?? '').toString(),
    dateIso: (j['starts_at'] ?? '').toString(),
    price: _d(j['price']),
    isOnline: j['is_online'] == true,
    description: (j['description'] ?? '').toString(),
    youtubeId: yt.isEmpty ? null : yt,
  );
}

/// Іс-шаралар каталогы (мок). Мәтіндер `loc` бойынша таңдалады.
class EventsFixtures {
  EventsFixtures._();

  static String _pick(String loc, Map<String, String> m) =>
      m[loc] ?? m['ru'] ?? m['kk'] ?? m.values.first;

  static List<TradingEvent> all(String loc) {
    String t(String kk, String ru, String en) => _pick(loc, {'kk': kk, 'ru': ru, 'en': en});
    final now = DateTime.now();
    String inDays(int d) => now.add(Duration(days: d)).toIso8601String();

    return [
      TradingEvent(
        id: 'ev-101',
        type: EventType.masterclass,
        title: t('Психология трейдинга: дисциплина мен тәуекел',
            'Психология трейдинга: дисциплина и риск',
            'Trading psychology: discipline and risk'),
        speaker: 'Александр Герчик',
        city: t('Алматы', 'Алматы', 'Almaty'),
        dateIso: inDays(5),
        price: 15000,
        isOnline: false,
        youtubeId: 'DuImQVIE82I',
        description: t(
          'Тәжірибелі трейдермен толық мастер-класс: эмоцияны бақылау, шығыннан кейінгі тәртіп, A+ сетап критерийі мен күндік тәуекел лимиті. Тірі мысалдар мен сұрақ-жауап.',
          'Полный мастер-класс с опытным трейдером: контроль эмоций, дисциплина после убытка, критерий A+ сетапа и дневной лимит риска. Живые примеры и ответы на вопросы.',
          'A full masterclass with an experienced trader: emotional control, post-loss discipline, the A+ setup criterion and a daily risk limit. Live examples and Q&A.',
        ),
      ),
      TradingEvent(
        id: 'ev-102',
        type: EventType.liveTrade,
        title: t('Live-сессия: XAU/USD London open',
            'Live-сессия по XAU/USD: London open',
            'Live session: XAU/USD London open'),
        speaker: 'TraderOS',
        city: t('Онлайн', 'Онлайн', 'Online'),
        dateIso: inDays(2),
        price: 0,
        isOnline: true,
        description: t(
          'Лондон ашылуында XAU/USD-ты тікелей эфирде талдау: HTF bias, ликвидность, retest setup. Сигнал емес — нақты процесті көрсету.',
          'Прямой эфир-разбор XAU/USD на открытии Лондона: HTF bias, ликвидность, retest-сетап. Не сигнал, а демонстрация реального процесса.',
          'A live XAU/USD breakdown at the London open: HTF bias, liquidity, retest setup. Not a signal — a demonstration of the real process.',
        ),
      ),
      TradingEvent(
        id: 'ev-103',
        type: EventType.webinar,
        title: t('Капиталды басқару — нөлден',
            'Управление капиталом с нуля',
            'Capital management from scratch'),
        speaker: 'MaxCapital — Максим Петров',
        city: t('Онлайн', 'Онлайн', 'Online'),
        dateIso: inDays(7),
        price: 5000,
        isOnline: true,
        youtubeId: 'PZocEdQcst0',
        description: t(
          'Позиция мөлшерін есептеу, risk %, күндік лимит және депозитті сақтау. Калькулятормен практика.',
          'Расчёт размера позиции, risk %, дневной лимит и сохранение депозита. Практика с калькулятором.',
          'Position sizing, risk %, daily limit and capital preservation. Hands-on with a calculator.',
        ),
      ),
      TradingEvent(
        id: 'ev-104',
        type: EventType.masterclass,
        title: t('Smart Money: нарық құрылымы',
            'Smart Money: структура рынка',
            'Smart Money: market structure'),
        speaker: 'TraderOS Pro',
        city: t('Астана', 'Астана', 'Astana'),
        dateIso: inDays(12),
        price: 20000,
        isOnline: false,
        description: t(
          'Order block, liquidity sweep, BOS/CHoCH — нақты графиктерде. Топ-даун workflow мен кіру/шығу ережелері.',
          'Order block, liquidity sweep, BOS/CHoCH — на реальных графиках. Топ-даун workflow и правила входа/выхода.',
          'Order blocks, liquidity sweeps, BOS/CHoCH — on real charts. Top-down workflow and entry/exit rules.',
        ),
      ),
      TradingEvent(
        id: 'ev-105',
        type: EventType.liveTrade,
        title: t('Апта сделкаларын талдау',
            'Разбор сделок недели',
            'Weekly trade review'),
        speaker: 'Тимофей Мартынов',
        city: t('Онлайн', 'Онлайн', 'Online'),
        dateIso: inDays(9),
        price: 0,
        isOnline: true,
        youtubeId: 'HbsPPpeACvI',
        description: t(
          'Қатысушылардың сделкаларын тірі талдау: қателер, дұрыс шешімдер, журнал жүргізу.',
          'Живой разбор сделок участников: ошибки, верные решения, ведение журнала.',
          'A live review of participants\' trades: mistakes, good decisions, journaling.',
        ),
      ),
      TradingEvent(
        id: 'ev-106',
        type: EventType.webinar,
        title: t('Риск-менеджмент: лотты есептейміз',
            'Риск-менеджмент: считаем лот',
            'Risk management: sizing the lot'),
        speaker: 'ProMarket — Олег Полунин',
        city: t('Онлайн', 'Онлайн', 'Online'),
        dateIso: inDays(4),
        price: 0,
        isOnline: true,
        youtubeId: 'X3OMQriyHFg',
        description: t(
          'Тәуекелді сауатты есептеудің формулалары мен мысалдары. Жаңадан бастаушыларға тегін вебинар.',
          'Формулы и примеры грамотного расчёта риска. Бесплатный вебинар для начинающих.',
          'Formulas and examples for proper risk math. A free webinar for beginners.',
        ),
      ),
    ];
  }
}

final eventsProvider = FutureProvider<List<TradingEvent>>((ref) async {
  // Трейдер жариялаған іс-шаралар (жергілікті) тізімнің басына қосылады.
  final mine = ref.watch(myEventsProvider);
  final List<TradingEvent> base;
  if (AppConfig.useRemoteApi) {
    final list = await ref.watch(apiServiceProvider).events();
    base = list.map((e) => eventFromJson((e as Map).cast<String, dynamic>())).toList();
  } else {
    final loc = ref.watch(localeControllerProvider).languageCode;
    base = EventsFixtures.all(loc);
  }
  final mineIds = mine.map((e) => e.id).toSet();
  return [...mine, ...base.where((e) => !mineIds.contains(e.id))];
});
