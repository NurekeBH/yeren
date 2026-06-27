import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/signal_provider.dart';
import '../network/api_service.dart';

double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

/// Backend JSON → SignalProvider.
SignalProvider providerFromJson(Map<String, dynamic> j) => SignalProvider(
      id: j['id'].toString(),
      name: (j['name'] ?? '').toString(),
      avatar: (j['avatar'] ?? '📊').toString(),
      bio: (j['bio'] ?? '').toString(),
      winRate: _d(j['win_rate']),
      avgRr: _d(j['avg_rr']),
      rating: _d(j['rating']),
      subscribers: _i(j['subscribers']),
      tradesCount: _i(j['trades_count']),
      pricePerMonth: _i(j['price_per_month']),
      verified: j['verified'] == true,
    );

/// Сигнал провайдерлерінің каталогы — backend-тен (DB жалғыз дереккөз).
final signalProvidersProvider = FutureProvider<List<SignalProvider>>((ref) async {
  final list = await ref.watch(apiServiceProvider).providers();
  return list.map((e) => providerFromJson((e as Map).cast<String, dynamic>())).toList();
});
