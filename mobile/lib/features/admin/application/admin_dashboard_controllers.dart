import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';

/// Дата-фильтр дашборда. Значение — period для /admin/bi/revenue-compare:
/// 'week' (≈7 дней) | 'month' (≈30 дней) | 'day' (сегодня).
/// Смена этого StateProvider автоматически перезапускает зависимые FutureProvider —
/// это и есть «обновление при смене фильтра» без ручного setState.
final dashboardPeriodProvider = StateProvider<String>((ref) => 'week');

/// Заголовочные KPI (DAU/MAU/MRR/маржа/LTV-CAC/churn).
final biOverviewProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) => ref.watch(apiServiceProvider).biOverview(),
);

/// Сравнение моделей за выбранный период (зависит от фильтра → авто-рефетч).
final biRevenueProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  final period = ref.watch(dashboardPeriodProvider);
  return ref.watch(apiServiceProvider).biRevenueCompare(period);
});

/// Whales + топ-трейдеры + тиры 500/1000.
final biSignalsDeepProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) => ref.watch(apiServiceProvider).biSignalsDeep(),
);

/// Adoption будильника + DAU/MAU по разделам.
final biFeatureProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) => ref.watch(apiServiceProvider).biFeatureAdoption(),
);
