import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';

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
  /// Backend дайын болғанша мок: кез келген phone+password 8+ символ → success.
  Future<void> register({required String phone, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final storage = _ref.read(secureStorageProvider);
    await storage.write(key: _tokenKey, value: 'mock-token-${DateTime.now().millisecondsSinceEpoch}');
    await storage.write(key: _phoneKey, value: phone);
    state = AuthState(status: AuthStatus.authenticated, phone: phone);
  }

  Future<void> login({required String phone, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final storage = _ref.read(secureStorageProvider);
    await storage.write(key: _tokenKey, value: 'mock-token-${DateTime.now().millisecondsSinceEpoch}');
    await storage.write(key: _phoneKey, value: phone);
    state = AuthState(status: AuthStatus.authenticated, phone: phone);
  }

  Future<void> logout() async {
    final storage = _ref.read(secureStorageProvider);
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _phoneKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
