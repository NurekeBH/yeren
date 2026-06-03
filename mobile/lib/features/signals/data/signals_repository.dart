import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/mock/fixtures.dart';
import '../../../shared/models/signal.dart';

abstract class SignalsRepository {
  Future<List<Signal>> fetchAll(String loc);
  Future<Signal?> fetchById(String loc, String id);
}

class MockSignalsRepository implements SignalsRepository {
  @override
  Future<List<Signal>> fetchAll(String loc) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockFixtures.signals(loc);
  }

  @override
  Future<Signal?> fetchById(String loc, String id) async {
    final all = await fetchAll(loc);
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

final signalsRepositoryProvider = Provider<SignalsRepository>(
  (ref) => MockSignalsRepository(),
);

final signalsListProvider = FutureProvider<List<Signal>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(signalsRepositoryProvider).fetchAll(loc);
});

final signalByIdProvider = FutureProvider.family<Signal?, String>((ref, id) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(signalsRepositoryProvider).fetchById(loc, id);
});
