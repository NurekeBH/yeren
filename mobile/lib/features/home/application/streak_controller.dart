import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../auth/application/auth_controller.dart';

/// Daily streak: чек-ин при открытии главной. Идемпотентно за день (сервер).
/// Возвращает {streak, longest, awarded}. awarded>0 → показать «+50 бонусов».
final streakProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.status != AuthStatus.authenticated) return const {};
  try {
    return await ref.read(apiServiceProvider).streakCheckin();
  } catch (_) {
    return const {}; // ретеншн не должен ломать главный экран
  }
});
