import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/signal.dart';

abstract class SignalsRepository {
  Future<List<Signal>> fetchAll(String loc);
  Future<Signal?> fetchById(String loc, String id);
}

// ─── Backend JSON → Signal (pg numeric-тер string болуы мүмкін) ───
double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int? _i(dynamic v) => v == null ? null : (v is num ? v.toInt() : int.tryParse('$v'));

SignalDirection _dir(String s) => s == 'sell' ? SignalDirection.sell : SignalDirection.buy;
SignalStatus _statusOf(String s) {
  switch (s) {
    case 'closed_tp1':
      return SignalStatus.closedTp1;
    case 'closed_tp2':
      return SignalStatus.closedTp2;
    case 'closed_tp3':
      return SignalStatus.closedTp3;
    case 'closed_sl':
      return SignalStatus.closedSl;
    default:
      return SignalStatus.active;
  }
}

Signal signalFromJson(Map<String, dynamic> j) => Signal(
      id: j['id'].toString(),
      providerId: j['provider_id']?.toString(),
      pair: (j['pair'] ?? 'XAU/USD').toString(),
      direction: _dir((j['direction'] ?? 'buy').toString()),
      entryFrom: _d(j['entry_from']),
      entryTo: _d(j['entry_to']),
      tp1: _d(j['tp1']),
      tp2: _d(j['tp2']),
      tp3: _d(j['tp3']),
      sl: _d(j['sl']),
      rr: _d(j['rr']),
      confidence: _i(j['confidence']) ?? 0,
      screenshotUrl: (j['screenshot_url'] ?? '').toString(),
      analysis: (j['analysis'] ?? '').toString(),
      status: _statusOf((j['status'] ?? 'active').toString()),
      publishedAt: DateTime.tryParse('${j['published_at']}') ?? DateTime.now(),
      resultPips: _i(j['result_pips']),
      isFree: j['is_free'] == true || j['is_free']?.toString() == 'true',
      // Автор өз идеясын әрқашан ашық көреді (платный болса да).
      isMine: j['is_mine'] == true,
      buyers: _i(j['buyers']) ?? 0, // FOMO: сколько уже открыли
    );

class ApiSignalsRepository implements SignalsRepository {
  ApiSignalsRepository(this._api);
  final ApiService _api;

  @override
  Future<List<Signal>> fetchAll(String loc) async {
    final list = await _api.signals();
    return list.map((e) => signalFromJson((e as Map).cast<String, dynamic>())).toList();
  }

  @override
  Future<Signal?> fetchById(String loc, String id) async {
    try {
      return signalFromJson(await _api.signal(id));
    } catch (_) {
      return null;
    }
  }
}

final signalsRepositoryProvider = Provider<SignalsRepository>(
  (ref) => ApiSignalsRepository(ref.watch(apiServiceProvider)),
);

// Backend — жалғыз дереккөз. Автор өз идеясын `is_mine` арқылы ашық көреді,
// сондықтан жергілікті кэшті қоспаймыз (әйтпесе бір идея екі рет көрінер еді).
final signalsListProvider = FutureProvider<List<Signal>>((ref) async {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(signalsRepositoryProvider).fetchAll(loc);
});

final signalByIdProvider = FutureProvider.family<Signal?, String>((ref, id) async {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(signalsRepositoryProvider).fetchById(loc, id);
});
