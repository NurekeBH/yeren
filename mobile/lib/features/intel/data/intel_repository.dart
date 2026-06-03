import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/mock/fixtures.dart';
import '../../../shared/models/intel_post.dart';

class IntelRepository {
  Future<List<IntelPost>> fetchAll(String loc) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockFixtures.intelPosts(loc);
  }
}

final intelRepositoryProvider = Provider<IntelRepository>((ref) => IntelRepository());
final intelListProvider = FutureProvider<List<IntelPost>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(intelRepositoryProvider).fetchAll(loc);
});
