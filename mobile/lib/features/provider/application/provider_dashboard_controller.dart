import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';

/// Фильтр периода дохода: day | week | month | year | all.
/// Смена авто-рефетчит [providerDashboardProvider].
final providerPeriodProvider = StateProvider<String>((ref) => 'month');

/// Дашборд трейдера (его кабинет) — зависит от выбранного периода.
final providerDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  final period = ref.watch(providerPeriodProvider);
  return ref.watch(apiServiceProvider).providerDashboard(period);
});
