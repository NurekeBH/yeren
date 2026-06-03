import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/mock/fixtures.dart';
import '../../../shared/models/calendar_event.dart';

class CalendarRepository {
  Future<List<CalendarEvent>> fetchAll(String loc) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final events = MockFixtures.calendarEvents(loc);
    return [...events]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }
}

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) => CalendarRepository());
final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(calendarRepositoryProvider).fetchAll(loc);
});
