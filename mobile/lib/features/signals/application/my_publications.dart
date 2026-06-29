import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/models/trader_post.dart';
import '../data/signals_repository.dart';
import 'trader_posts_controller.dart';

/// Менің жарияланған идеяларым (белсенді + жабылған) — backend /me/signals.
final mySignalsProvider = FutureProvider<List<Signal>>((ref) async {
  final list = await ref.watch(apiServiceProvider).mySignals();
  return list.map((e) => signalFromJson((e as Map).cast<String, dynamic>())).toList();
});

/// Тек белсенді идеяларым.
final myActiveSignalsProvider = FutureProvider<List<Signal>>((ref) async {
  final all = await ref.watch(mySignalsProvider.future);
  return all.where((s) => s.status == SignalStatus.active).toList();
});

/// Тек жабылған идеяларым (TP/SL).
final myClosedSignalsProvider = FutureProvider<List<Signal>>((ref) async {
  final all = await ref.watch(mySignalsProvider.future);
  return all.where((s) => s.status != SignalStatus.active).toList();
});

/// Менің жарияланған посттарым — backend /me/posts.
final myPostsProvider = FutureProvider<List<TraderPost>>((ref) async {
  final list = await ref.watch(apiServiceProvider).myPosts();
  return list.map((e) => traderPostFromApi((e as Map).cast<String, dynamic>())).toList();
});
