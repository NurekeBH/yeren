import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/locale/locale_controller.dart';
import 'core/notifications/push_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'l10n/gen/app_localizations.dart';

/// Фондық push хабары (жүйе хабарламаны өзі көрсетеді).
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase міндетті емес — қолжетімсіз болса, қосымша бәрібір жұмыс істейді.
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  } catch (_) {}
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TraderOSApp(),
    ),
  );
}

class TraderOSApp extends ConsumerStatefulWidget {
  const TraderOSApp({super.key});

  @override
  ConsumerState<TraderOSApp> createState() => _TraderOSAppState();
}

class _TraderOSAppState extends ConsumerState<TraderOSApp> {
  @override
  void initState() {
    super.initState();
    // FCM-ді бірінші кадрдан кейін іске қосамыз (рұқсат + токен + тіркеу).
    WidgetsBinding.instance.addPostFrameCallback((_) => PushService.init(ref));
  }

  @override
  Widget build(BuildContext context) {
    // Логинге өткенде push токенін backend-ке тіркейміз.
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated &&
          prev?.status != AuthStatus.authenticated) {
        PushService.registerAfterAuth(ref);
      }
    });

    final locale = ref.watch(localeControllerProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ALTYN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      locale: locale,
      supportedLocales: LocaleController.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
