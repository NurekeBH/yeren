import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/calendar_event.dart';

ImpactLevel _level(String s) =>
    s == 'high' ? ImpactLevel.high : (s == 'low' ? ImpactLevel.low : ImpactLevel.medium);

String? _s(dynamic v) {
  final s = v?.toString();
  return (s == null || s.isEmpty) ? null : s;
}

/// Backend JSON → CalendarEvent.
CalendarEvent calendarFromJson(Map<String, dynamic> j) => CalendarEvent(
      id: j['id'].toString(),
      name: (j['name'] ?? '').toString(),
      currency: (j['currency'] ?? '').toString(),
      impact: _level((j['impact'] ?? 'medium').toString()),
      scheduledAt: DateTime.tryParse('${j['scheduled_at']}') ?? DateTime.now(),
      forecast: _s(j['forecast']),
      previous: _s(j['previous']),
      actual: _s(j['actual']),
      goldImpactNote: _s(j['gold_impact_note']),
    );

class CalendarRepository {
  CalendarRepository(this._api);
  final ApiService _api;

  Future<List<CalendarEvent>> fetchAll(String loc) async {
    final list = await _api.calendar();
    final events = list.map((e) => calendarFromJson((e as Map).cast<String, dynamic>())).toList();
    return events..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }
}

final calendarRepositoryProvider =
    Provider<CalendarRepository>((ref) => CalendarRepository(ref.watch(apiServiceProvider)));
final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(calendarRepositoryProvider).fetchAll(loc);
});
