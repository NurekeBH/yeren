import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_controller.dart';
import '../config/app_config.dart';
import '../network/api_service.dart';
import '../router/app_router.dart';

/// FCM push басқаруы: рұқсат, токен алу, оны backend-ке тіркеу,
/// әрі келген хабарларды өңдеу (foreground SnackBar + басқанда навигация).
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

      // Foreground — қолданба ашық тұрғанда хабарды SnackBar-мен көрсетеміз.
      FirebaseMessaging.onMessage.listen((msg) => _showForeground(ref, msg));
      // Хабарды басқанда — тиісті экранға өтеміз (background).
      FirebaseMessaging.onMessageOpenedApp.listen((msg) => _navigate(ref, msg));
      // Қолданба жабық тұрып, хабардан ашылса.
      final initial = await m.getInitialMessage();
      if (initial != null) _navigate(ref, initial);
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

  /// data.type бойынша тиісті экранға өту.
  static void _navigate(WidgetRef ref, RemoteMessage msg) {
    final data = msg.data;
    final type = data['type']?.toString();
    final id = data['id']?.toString();
    final router = ref.read(routerProvider);
    switch (type) {
      case 'signal':
        if (id != null && id.isNotEmpty) router.push('/signals/$id');
        break;
      case 'intel':
        router.push('/intel');
        break;
      case 'price_alert':
        router.push('/alerts');
        break;
      case 'calendar':
        router.push('/calendar');
        break;
    }
  }

  static void _showForeground(WidgetRef ref, RemoteMessage msg) {
    final n = msg.notification;
    final text = n != null
        ? (n.title?.isNotEmpty == true ? '${n.title}: ${n.body ?? ''}' : (n.body ?? ''))
        : (msg.data['body']?.toString() ?? '');
    if (text.isEmpty) return;
    final ctx = ref.read(routerProvider).routerDelegate.navigatorKey.currentContext;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
        action: SnackBarAction(label: '→', onPressed: () => _navigate(ref, msg)),
      ),
    );
  }
}
