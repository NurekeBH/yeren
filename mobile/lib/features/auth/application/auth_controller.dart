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
  Future<void> register({required String phone, required String password, String? country}) async {
    final token = AppConfig.useRemoteApi
        ? (await _ref.read(apiServiceProvider).register(phone, password, country: country))['token'] as String
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
    // ВАЖНО: алдымен токенді сақтап, профильді ЖҮКТЕП аламыз, сосын ғана authenticated
    // деп белгілейміз. Әйтпесе isOnboarded әлі false болып, router қысқа сәтке
    // onboarding (edit-profile тәрізді) экранын жарқ еткізеді.
    await _writeToken(token, phone);
    if (AppConfig.useRemoteApi) {
      try {
        await _ref.read(profileControllerProvider.notifier).hydrateFromRemote();
      } catch (_) {/* профиль жүктелмесе де кіруге рұқсат */}
    } else {
      _ref.read(profileControllerProvider.notifier).markReturningUser();
    }
    state = AuthState(status: AuthStatus.authenticated, phone: phone);
  }

  /// 401 Unauthorized (токен жоқ/ескірген/жарамсыз) — кез келген сұраудан келсе,
  /// сессияны тазалап, login ағынына шығарамыз (api_client интерцепторы шақырады).
  Future<void> handleUnauthorized() async {
    if (state.status != AuthStatus.authenticated) return;
    await logout();
  }

  Future<String> _mockToken() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Токенді secure storage-қа жазу (күйді өзгертпейді — dio сұраныстарға қоса алады).
  Future<void> _writeToken(String token, String phone) async {
    final storage = _ref.read(secureStorageProvider);
    // Secure storage кейбір эмуляторларда баяу/қатеге ұшырауы мүмкін — бөгемейді.
    try {
      await storage.write(key: _tokenKey, value: token).timeout(const Duration(seconds: 4));
      await storage.write(key: _phoneKey, value: phone).timeout(const Duration(seconds: 4));
    } catch (_) {/* сақтау сәтсіз болса да авторизация жалғасады */}
  }

  Future<void> _persistAuth(String token, String phone) async {
    await _writeToken(token, phone);
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

  /// Аккаунтты толық жою (Apple талабы). Серверден өшіреміз, сосын шығамыз.
  Future<void> deleteAccount() async {
    if (AppConfig.useRemoteApi) {
      await _ref.read(apiServiceProvider).deleteAccount();
    }
    await logout();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
