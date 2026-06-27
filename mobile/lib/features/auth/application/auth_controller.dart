import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../profile/application/profile_controller.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

@immutable
class AuthState {
  const AuthState({required this.status, this.phone});

  final AuthStatus status;
  final String? phone;

  AuthState copyWith({AuthStatus? status, String? phone}) =>
      AuthState(status: status ?? this.status, phone: phone ?? this.phone);

  static const unknown = AuthState(status: AuthStatus.unknown);
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(AuthState.unknown) {
    _restore();
  }

  final Ref _ref;
  static const _tokenKey = 'auth_token';
  static const _phoneKey = 'auth_phone';

  Future<void> _restore() async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.read(key: _tokenKey);
    final phone = await storage.read(key: _phoneKey);
    if (token != null && token.isNotEmpty) {
      state = AuthState(status: AuthStatus.authenticated, phone: phone);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Тіркелу: телефон + пароль. SMS жоқ (TZ.rtf override).
  /// useRemoteApi=true болса — backend; әйтпесе мок (offline режим).
  Future<void> register({required String phone, required String password}) async {
    final token = AppConfig.useRemoteApi
        ? (await _ref.read(apiServiceProvider).register(phone, password))['token'] as String
        : await _mockToken();
    await _persistAuth(token, phone);
    // Келісім checkbox тіркеу алдында расталады — серверге логқа жазамыз.
    if (AppConfig.useRemoteApi) {
      try {
        await _ref.read(apiServiceProvider).acceptAgreement();
      } catch (_) {/* best-effort */}
    }
  }

  Future<void> login({required String phone, required String password}) async {
    final token = AppConfig.useRemoteApi
        ? (await _ref.read(apiServiceProvider).login(phone, password))['token'] as String
        : await _mockToken();
    await _persistAuth(token, phone);
    // Қайта оралған пайдаланушы — профиль сұрақнамасын қайта сұрамаймыз.
    // Remote режимде backend профилін жүктейміз; mock режимде onboarded деп белгілейміз.
    if (AppConfig.useRemoteApi) {
      await _ref.read(profileControllerProvider.notifier).hydrateFromRemote();
    } else {
      _ref.read(profileControllerProvider.notifier).markReturningUser();
    }
  }

  Future<String> _mockToken() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _persistAuth(String token, String phone) async {
    final storage = _ref.read(secureStorageProvider);
    // Secure storage кейбір эмуляторларда баяу/қатеге ұшырауы мүмкін —
    // ол авторизацияны бөгемеуі тиіс (timeout + try/catch).
    try {
      await storage
          .write(key: _tokenKey, value: token)
          .timeout(const Duration(seconds: 4));
      await storage
          .write(key: _phoneKey, value: phone)
          .timeout(const Duration(seconds: 4));
    } catch (_) {/* сақтау сәтсіз болса да авторизация жалғасады */}
    state = AuthState(status: AuthStatus.authenticated, phone: phone);
  }

  Future<void> logout() async {
    final storage = _ref.read(secureStorageProvider);
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _phoneKey);
    // Кэштелген профиль деректерін де тазалаймыз (аты, стильдер, бонустар) —
    // келесі қолданушы ескі деректі көрмесін.
    await _ref.read(profileControllerProvider.notifier).clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
