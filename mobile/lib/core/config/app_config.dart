/// Қосымшаның орта (environment) конфигурациясы.
///
/// Backend — ЖАЛҒЫЗ дереккөз (mock деректер жоқ). `useRemoteApi` әрқашан true;
/// барлық экран DB-ден API арқылы оқиды. `apiBaseUrl`-ды нақты серверге бағыттаңыз.
///
/// Android эмуляторында host-машинаның localhost-ы = 10.0.2.2.
/// iOS симуляторында = 127.0.0.1.
class AppConfig {
  AppConfig._();

  /// Backend жалғыз дереккөз — әрқашан remote. (`--dart-define=USE_REMOTE_API=false`
  /// арқылы өшіруге болады, бірақ mock fixtures жойылған — оқу жолдары API-ды талап етеді.)
  static const bool useRemoteApi =
      bool.fromEnvironment('USE_REMOTE_API', defaultValue: true);

  /// `--dart-define=API_BASE_URL=https://api.altyn.kz/api/v1` арқылы өзгертіледі.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
