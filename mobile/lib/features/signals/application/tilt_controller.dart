import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../auth/application/auth_controller.dart';

/// Анти-тильт: 2 закрытые сделки подряд в минус → пауза 2ч (сервер считает по
/// journal_trades). Возвращает {tilt, until, losing_streak}.
final tiltStatusProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth.status != AuthStatus.authenticated) return const {};
  try {
    return await ref.read(apiServiceProvider).tiltStatus();
  } catch (_) {
    return const {}; // защита не должна ломать экран
  }
});
