import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_controller.dart';
import '../config/app_config.dart';
import '../network/api_service.dart';

/// FCM push басқаруы: рұқсат, токен алу, оны backend-ке тіркеу.
/// Нақты жіберу — backend жағында (notification_prefs.expo_push_token бойынша).
class PushService {
  PushService._();

  static String? _token;

  /// Firebase init-тен кейін бір рет шақырылады.
  static Future<void> init(WidgetRef ref) async {
    try {
      final m = FirebaseMessaging.instance;
      await m.requestPermission(alert: true, badge: true, sound: true);
      _token = await m.getToken();
      await _register(ref);
      m.onTokenRefresh.listen((t) {
        _token = t;
        _register(ref);
      });
    } catch (_) {
      // Firebase қолжетімсіз болса (мысалы, конфиг жоқ) — үнсіз өтеміз.
    }
  }

  /// Логиннен кейін токенді тіркеу (auth өзгергенде шақырылады).
  static Future<void> registerAfterAuth(WidgetRef ref) => _register(ref);

  static Future<void> _register(WidgetRef ref) async {
    final token = _token;
    if (token == null || !AppConfig.useRemoteApi) return;
    if (ref.read(authControllerProvider).status != AuthStatus.authenticated) return;
    try {
      await ref.read(apiServiceProvider).registerPushToken(token);
    } catch (_) {
      // желі қатесі — кейін token refresh / қайта логинде қайталанады
    }
  }
}
