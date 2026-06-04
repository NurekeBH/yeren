import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/mock/fixtures.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/intel_post.dart';

double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

GoldImpact _impact(String s) =>
    s == 'bearish' ? GoldImpact.bearish : (s == 'neutral' ? GoldImpact.neutral : GoldImpact.bullish);

/// Backend JSON → IntelPost.
IntelPost intelFromJson(Map<String, dynamic> j) => IntelPost(
      id: j['id'].toString(),
      source: (j['source'] ?? '').toString(),
      text: (j['text'] ?? '').toString(),
      impact: _impact((j['impact'] ?? 'neutral').toString()),
      xauMove: _d(j['xau_move']),
      analysis: (j['analysis'] ?? '').toString(),
      support: _d(j['support']),
      resistance: _d(j['resistance']),
      suggestedSl: _d(j['suggested_sl']),
      sentiment: _i(j['sentiment']),
      publishedAt: DateTime.tryParse('${j['published_at']}') ?? DateTime.now(),
      isUrgent: j['is_urgent'] == true,
    );

class IntelRepository {
  IntelRepository(this._api);
  final ApiService _api;

  Future<List<IntelPost>> fetchAll(String loc) async {
    if (AppConfig.useRemoteApi) {
      final list = await _api.intel();
      return list.map((e) => intelFromJson((e as Map).cast<String, dynamic>())).toList();
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockFixtures.intelPosts(loc);
  }
}

final intelRepositoryProvider =
    Provider<IntelRepository>((ref) => IntelRepository(ref.watch(apiServiceProvider)));
final intelListProvider = FutureProvider<List<IntelPost>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(intelRepositoryProvider).fetchAll(loc);
});
