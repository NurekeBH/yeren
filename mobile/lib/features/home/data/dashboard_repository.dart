import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/mock/fixtures.dart';
import '../../../shared/models/calendar_event.dart';
import '../../../shared/models/intel_post.dart';
import '../../../shared/models/kpi.dart';
import '../../../shared/models/trade.dart';

class DashboardRepository {
  Future<GoldQuote> goldQuote() async => MockFixtures.goldQuote();
  Future<KpiSnapshot> kpi() async => MockFixtures.kpi();
  Future<List<Trade>> recentTrades(String loc, {int limit = 3}) async {
    final all = MockFixtures.trades(loc);
    return all.take(limit).toList();
  }

  Future<CalendarEvent?> nextHighImpact(String loc) async {
    final events = MockFixtures.calendarEvents(loc);
    final high = events.where((e) => e.impact == ImpactLevel.high).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return high.isEmpty ? null : high.first;
  }

  Future<List<IntelPost>> recentIntel(String loc, {int limit = 3}) async {
    return MockFixtures.intelPosts(loc).take(limit).toList();
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(),
);

final goldQuoteProvider = FutureProvider<GoldQuote>(
  (ref) => ref.watch(dashboardRepositoryProvider).goldQuote(),
);
final kpiProvider = FutureProvider<KpiSnapshot>(
  (ref) => ref.watch(dashboardRepositoryProvider).kpi(),
);
final recentTradesProvider = FutureProvider<List<Trade>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(dashboardRepositoryProvider).recentTrades(loc);
});
final nextHighEventProvider = FutureProvider<CalendarEvent?>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(dashboardRepositoryProvider).nextHighImpact(loc);
});
