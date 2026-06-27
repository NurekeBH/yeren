import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/events/application/my_events_controller.dart';
import '../../shared/models/trading_event.dart';
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

/// Іс-шаралар каталогы — backend-тен (DB). Трейдер жариялаған (жергілікті) іс-шаралар
/// тізімнің басына қосылады.
final eventsProvider = FutureProvider<List<TradingEvent>>((ref) async {
  final mine = ref.watch(myEventsProvider);
  final list = await ref.watch(apiServiceProvider).events();
  final base = list.map((e) => eventFromJson((e as Map).cast<String, dynamic>())).toList();
  final mineIds = mine.map((e) => e.id).toSet();
  return [...mine, ...base.where((e) => !mineIds.contains(e.id))];
});
