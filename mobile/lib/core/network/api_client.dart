import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_controller.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';

/// JWT secure storage кілті (auth_controller-мен ортақ).
const kAuthTokenKey = 'auth_token';

/// Backend API-мен сөйлесетін Dio клиенті.
/// Әр сұранысқа secure storage-тағы JWT-ні `Authorization: Bearer` етіп қосады.
final apiClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      contentType: 'application/json',
      // 4xx-ті exception емес, қалыпты жауап ретінде өңдеу үшін:
      validateStatus: (code) => code != null && code < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: kAuthTokenKey);
        if (token != null && token.isNotEmpty && !token.startsWith('mock-')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      // 401 кез келген сұраудан келсе (токен жоқ/ескірген) — сессияны тазалап,
      // login ағынына шығарамыз. validateStatus<500 болғандықтан 401 — onResponse-та.
      onResponse: (response, handler) {
        if (response.statusCode == 401) {
          Future.microtask(() => ref.read(authControllerProvider.notifier).handleUnauthorized());
        }
        handler.next(response);
      },
    ),
  );

  return dio;
});

/// API қателерін біркелкі түрге келтіретін көмекші.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message, {this.isNetwork = false});
  final int? statusCode;
  final String message;

  /// Желі/таймаут қатесі (интернет жоқ/баяу) ма — сервер қайтарған қате емес.
  /// UI осыған қарап «Интернетті тексеріңіз» деп көрсетеді.
  final bool isNetwork;

  @override
  String toString() => 'ApiException($statusCode): $message';

  static ApiException from(Object error) {
    if (error is DioException) {
      // Желі деңгейіндегі қателер: таймаут, қосыла алмау, сертификат.
      const networkTypes = {
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
        DioExceptionType.badCertificate,
      };
      // type==unknown болғанда да жауап жоқ болса (SocketException т.б.) — желі.
      final isNet = networkTypes.contains(error.type) ||
          (error.type == DioExceptionType.unknown && error.response == null);
      final code = error.response?.statusCode;
      final data = error.response?.data;
      final msg = data is Map && data['error'] != null
          ? data['error'].toString()
          : (error.message ?? 'network_error');
      return ApiException(code, msg, isNetwork: isNet);
    }
    return ApiException(null, error.toString());
  }
}

/// Кез келген қатені желі қатесі ме деп тану (ApiException-ге айналмаған шикі
/// DioException/SocketException жағдайлары үшін де).
bool isNetworkError(Object? e) {
  if (e is ApiException) return e.isNetwork;
  if (e is DioException) return ApiException.from(e).isNetwork;
  final s = e.toString().toLowerCase();
  return s.contains('socketexception') ||
      s.contains('connection') ||
      s.contains('timeout') ||
      s.contains('failed host lookup') ||
      s.contains('network is unreachable');
}
