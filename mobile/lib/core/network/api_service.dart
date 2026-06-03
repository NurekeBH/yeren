import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Backend REST API-дің типтелген қабаты.
/// Жауаптар JSON (Map/List) ретінде қайтады — repository-лер модельге айналдырады.
/// Backend deploy етіліп, AppConfig.useRemoteApi=true болғанда қолданылады.
class ApiService {
  ApiService(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> _get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get<dynamic>(path, queryParameters: query);
      _ensureOk(res);
      return (res.data as Map).cast<String, dynamic>();
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<Map<String, dynamic>> _send(String method, String path, {Object? body}) async {
    try {
      final res = await _dio.request<dynamic>(
        path,
        data: body,
        options: Options(method: method),
      );
      _ensureOk(res);
      return res.data is Map ? (res.data as Map).cast<String, dynamic>() : <String, dynamic>{};
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  void _ensureOk(Response<dynamic> res) {
    final code = res.statusCode ?? 0;
    if (code >= 400) {
      final data = res.data;
      final msg = data is Map && data['error'] != null ? data['error'].toString() : 'http_$code';
      throw ApiException(code, msg);
    }
  }

  // ─────────────── Auth ───────────────
  Future<Map<String, dynamic>> register(String phone, String password) =>
      _send('POST', '/auth/register', body: {'phone': phone, 'password': password});
  Future<Map<String, dynamic>> login(String phone, String password) =>
      _send('POST', '/auth/login', body: {'phone': phone, 'password': password});
  Future<Map<String, dynamic>> me() => _get('/auth/me');
  Future<void> updateMe(Map<String, dynamic> patch) => _send('PATCH', '/auth/me', body: patch);

  // ─────────────── Signals / Ideas ───────────────
  Future<List<dynamic>> signals() async => (await _get('/signals'))['signals'] as List;
  Future<Map<String, dynamic>> signal(String id) async =>
      (await _get('/signals/$id'))['signal'] as Map<String, dynamic>;
  Future<Map<String, dynamic>> signalStats() => _get('/signals/stats');

  // ─────────────── Providers (aggregator) ───────────────
  Future<List<dynamic>> providers() async => (await _get('/providers'))['providers'] as List;
  Future<Map<String, dynamic>> provider(String id) => _get('/providers/$id');
  Future<List<dynamic>> mySubscriptions() async => (await _get('/me/subscriptions'))['providers'] as List;
  Future<void> subscribe(String providerId) => _send('POST', '/providers/$providerId/subscribe');
  Future<void> unsubscribe(String providerId) => _send('DELETE', '/providers/$providerId/subscribe');

  // ─────────────── Events ───────────────
  Future<List<dynamic>> events() async => (await _get('/events'))['events'] as List;
  Future<Map<String, dynamic>> event(String id) async =>
      (await _get('/events/$id'))['event'] as Map<String, dynamic>;
  Future<void> applyToEvent(String id, {required String name, required String phone, String? comment}) =>
      _send('POST', '/events/$id/apply', body: {'name': name, 'phone': phone, 'comment': comment ?? ''});

  // ─────────────── Price alerts ───────────────
  Future<List<dynamic>> alerts() async => (await _get('/alerts'))['alerts'] as List;
  Future<Map<String, dynamic>> createAlert(Map<String, dynamic> body) =>
      _send('POST', '/alerts', body: body);
  Future<void> deleteAlert(String id) => _send('DELETE', '/alerts/$id');

  // ─────────────── Library (save / rating / review) ───────────────
  Future<List<dynamic>> myLibrary() async => (await _get('/library/me'))['items'] as List;
  Future<void> upsertLibrary(String itemId, Map<String, dynamic> body) =>
      _send('PUT', '/library/$itemId', body: body);
  Future<List<dynamic>> itemReviews(String itemId) async =>
      (await _get('/library/$itemId/reviews'))['reviews'] as List;

  // ─────────────── Agreement ───────────────
  Future<void> acceptAgreement({String version = 'v1'}) =>
      _send('POST', '/agreement/accept', body: {'version': version});
  Future<Map<String, dynamic>> agreementStatus() => _get('/agreement/me');

  // ─────────────── Intel / Calendar / Trades / Subscription ───────────────
  Future<List<dynamic>> intel() async => (await _get('/intel'))['posts'] as List? ?? const [];
  Future<List<dynamic>> calendar() async => (await _get('/calendar'))['events'] as List? ?? const [];
  Future<List<dynamic>> trades() async => (await _get('/trades'))['trades'] as List? ?? const [];
  Future<Map<String, dynamic>> subscription() => _get('/subscription');
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService(ref.watch(apiClientProvider)));
