/// Қосымшаның орта (environment) конфигурациясы.
///
/// `useRemoteApi = false` болса — app мок деректермен (fixtures + локалды сақтау)
/// жұмыс істейді. Backend deploy етілген соң, `useRemoteApi = true` қойып,
/// `apiBaseUrl`-ды нақты серверге бағыттаңыз.
///
/// Android эмуляторында host-машинаның localhost-ы = 10.0.2.2.
/// iOS симуляторында = 127.0.0.1.
class AppConfig {
  AppConfig._();

  /// `--dart-define=USE_REMOTE_API=true` арқылы build кезінде қосуға болады.
  static const bool useRemoteApi =
      bool.fromEnvironment('USE_REMOTE_API', defaultValue: false);

  /// `--dart-define=API_BASE_URL=https://api.altyn.kz/api/v1` арқылы өзгертіледі.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
