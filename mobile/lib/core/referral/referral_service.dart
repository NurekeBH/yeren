import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../locale/locale_controller.dart' show sharedPreferencesProvider;
import '../network/api_service.dart';

/// Deferred deep link рефералы (вирусная петля без ручного ввода кода).
///
/// Поток:
///   1. Пользователь делится ссылкой inviteLink(promoCode) → altyn.social/invite?code=XYZ
///   2. Лендинг фиксирует клик на бэкенде (IP + code).
///   3. Приложение при ПЕРВОМ запуске (в т.ч. установка с нуля) вызывает
///      captureDeferredReferral() → бэкенд по IP-фингерпринту отдаёт код → кэшируем.
///   4. Экран регистрации авто-подставляет код (pendingReferral()).
///
/// Почему self-hosted fingerprint, а не Firebase Dynamic Links / Branch:
///   • Firebase Dynamic Links закрыт (2025) — использовать нельзя.
///   • Branch.io — платный сторонний SDK + внешняя зависимость.
///   • Наш метод работает уже сейчас (APK-раздача, без публикации в сторах),
///     без нативной конфигурации и сторонних сервисов.
class ReferralService {
  ReferralService(this._prefs, this._api);
  final SharedPreferences _prefs;
  final ApiService _api;

  static const String _base = 'https://altyn.social';
  static const String _kChecked = 'referral_checked';
  static const String _kPending = 'pending_referral';

  /// Реферальная ссылка пользователя (вшит промокод).
  String inviteLink(String promoCode) => '$_base/invite.html?code=$promoCode';

  /// Первый запуск: тихо резолвим отложенный код по IP-фингерпринту и кэшируем.
  /// Выполняется РОВНО один раз за установку (флаг [_kChecked]).
  Future<void> captureDeferredReferral() async {
    if (_prefs.getBool(_kChecked) == true) return;
    await _prefs.setBool(_kChecked, true);
    final code = await _api.resolveInvite();
    if (code != null && code.isNotEmpty) {
      await _prefs.setString(_kPending, code);
    }
  }

  /// Перехваченный промокод (для авто-подстановки в регистрацию), либо null.
  String? pendingReferral() => _prefs.getString(_kPending);

  /// Сброс после успешного использования (или если пользователь отменил).
  Future<void> clearPendingReferral() => _prefs.remove(_kPending);
}

final referralServiceProvider = Provider<ReferralService>(
  (ref) => ReferralService(ref.watch(sharedPreferencesProvider), ref.watch(apiServiceProvider)),
);
