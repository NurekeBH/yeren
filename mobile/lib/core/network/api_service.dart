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
      if (e is ApiException) rethrow; // 4xx _ensureOk-тен — статус/хабарды сақтаймыз
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
      if (e is ApiException) rethrow; // 4xx _ensureOk-тен — статус/хабарды сақтаймыз
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

  /// Суретті backend арқылы Supabase Storage-қа жүктеп, public URL қайтарады.
  /// Сәтсіз болса (сторадж бапталмаған/офлайн) null — клиент жергілікті жолды қалдырады.
  Future<String?> uploadImage(String filePath) async {
    try {
      final form = FormData.fromMap({'file': await MultipartFile.fromFile(filePath)});
      final res = await _dio.post<dynamic>('/uploads', data: form);
      _ensureOk(res);
      final data = res.data;
      return data is Map ? data['url'] as String? : null;
    } catch (_) {
      return null;
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

  /// Ашылған (сатып алынған) идеялардың id-тізімі.
  Future<List<String>> purchasedSignals() async {
    final list = (await _get('/signals/purchased'))['signal_ids'] as List? ?? const [];
    return list.map((e) => e.toString()).toList();
  }

  /// Идеяны сатып алу (Kaspi төлемінен кейін backend-ке тіркеу).
  Future<void> purchaseSignal(String id) => _send('POST', '/signals/$id/purchase');

  /// Сигнал жариялау (расталған трейдер/админ).
  Future<Map<String, dynamic>> publishSignal(Map<String, dynamic> body) async =>
      (await _send('POST', '/signals', body: body))['signal'] as Map<String, dynamic>? ?? const {};

  /// Сигнал статусын өзгерту/жабу (TP1/TP2/TP3/SL).
  Future<void> closeSignal(String id, String status, int resultPips) =>
      _send('POST', '/signals/$id/close', body: {'status': status, 'result_pips': resultPips});

  /// Нәтижеге дауыс беру (төлеген қолданушылар): sl | tp1 | tp2 | tp3.
  Future<Map<String, dynamic>> voteSignal(String id, String outcome) =>
      _send('POST', '/signals/$id/vote', body: {'outcome': outcome});

  /// Сигнал бойынша дауыс қорытындысы.
  Future<Map<String, dynamic>> signalVotes(String id) => _get('/signals/$id/votes');

  /// Трейдердің follow-up апдейттері (timeline).
  Future<List<dynamic>> signalUpdates(String id) async =>
      (await _get('/signals/$id/updates'))['updates'] as List? ?? const [];
  Future<void> addSignalUpdate(String id, String text) =>
      _send('POST', '/signals/$id/updates', body: {'text': text});

  // ─────────────── Providers (aggregator) ───────────────
  Future<List<dynamic>> providers() async => (await _get('/providers'))['providers'] as List;
  Future<Map<String, dynamic>> provider(String id) => _get('/providers/$id');
  Future<List<dynamic>> mySubscriptions() async => (await _get('/me/subscriptions'))['providers'] as List;
  Future<void> subscribe(String providerId) => _send('POST', '/providers/$providerId/subscribe');
  Future<void> unsubscribe(String providerId) => _send('DELETE', '/providers/$providerId/subscribe');

  // ─────────────── Trader posts (Published Ideas) ───────────────
  Future<List<dynamic>> providerPosts(String providerId) async =>
      (await _get('/providers/$providerId/posts'))['posts'] as List? ?? const [];
  Future<Map<String, dynamic>> likePost(String postId) => _send('POST', '/posts/$postId/like');
  Future<Map<String, dynamic>> commentPost(String postId, String text) =>
      _send('POST', '/posts/$postId/comments', body: {'text': text});

  // ─────────────── Events ───────────────
  Future<List<dynamic>> events() async => (await _get('/events'))['events'] as List;
  Future<Map<String, dynamic>> event(String id) async =>
      (await _get('/events/$id'))['event'] as Map<String, dynamic>;
  Future<void> applyToEvent(String id, {required String name, required String phone, String? comment}) =>
      _send('POST', '/events/$id/apply', body: {'name': name, 'phone': phone, 'comment': comment ?? ''});

  /// Іс-шара жариялау (расталған трейдер/админ).
  Future<void> publishEvent(Map<String, dynamic> body) => _send('POST', '/events', body: body);

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

  // ─────────────── Push / Notifications ───────────────
  /// FCM токенін backend-ке тіркеу (notification_prefs.expo_push_token).
  Future<void> registerPushToken(String token) =>
      _send('PATCH', '/notifications/prefs', body: {'expo_push_token': token});

  // ─────────────── Agreement ───────────────
  Future<void> acceptAgreement({String version = 'v1'}) =>
      _send('POST', '/agreement/accept', body: {'version': version});
  Future<Map<String, dynamic>> agreementStatus() => _get('/agreement/me');

  // ─────────────── Intel / Calendar / Trades / Subscription ───────────────
  Future<List<dynamic>> intel() async => (await _get('/intel'))['posts'] as List? ?? const [];
  Future<List<dynamic>> calendar() async => (await _get('/calendar'))['events'] as List? ?? const [];
  Future<List<dynamic>> trades() async => (await _get('/trades'))['trades'] as List? ?? const [];
  Future<Map<String, dynamic>> createTrade(Map<String, dynamic> body) async =>
      (await _send('POST', '/trades', body: body))['trade'] as Map<String, dynamic>? ?? const {};
  Future<void> deleteTrade(String id) => _send('DELETE', '/trades/$id');

  // ─────────────── Брокер аккаунттары (synced) ───────────────
  Future<List<dynamic>> brokers() async =>
      (await _get('/brokers'))['accounts'] as List? ?? const [];
  Future<Map<String, dynamic>> linkBrokerMt(Map<String, dynamic> body) async =>
      (await _send('POST', '/brokers/mt', body: body))['account'] as Map<String, dynamic>? ?? const {};
  Future<void> syncBroker(String id) => _send('POST', '/brokers/$id/sync');
  Future<void> removeBroker(String id) => _send('DELETE', '/brokers/$id');

  // ─────────────── Support (қолдау хабары → админ-панель) ───────────────
  Future<void> sendSupportMessage(String text) =>
      _send('POST', '/support', body: {'text': text});

  // ─────────────── Promo / Bonus ───────────────
  /// Промокод қолдану (тіркелуден кейін) — backend бонус есептейді.
  Future<void> redeemPromo(String code) =>
      _send('POST', '/promo/redeem', body: {'code': code});

  /// Бонусты толтыру (Kaspi төлемінен кейін) — backend балансқа қосады.
  Future<void> topUpBonus(int amount) =>
      _send('POST', '/bonus/topup', body: {'amount': amount});

  // ─────────────── Академия курстары (backend синхрондау) ───────────────
  /// Курсты бонуспен ашу (backend балансты шегеріп, леджерге жазады).
  Future<void> purchaseCourse(String courseId, int bonusCost) =>
      _send('POST', '/courses/$courseId/purchase', body: {'bonus_cost': bonusCost});

  /// Сатып алынған курстардың id-лері.
  Future<List<String>> purchasedCourses() async {
    final list = (await _get('/courses/me'))['purchases'] as List? ?? const [];
    return list.map((e) => (e as Map)['course_id'].toString()).toList();
  }

  /// Сабақты «өтілді» деп белгілеу.
  Future<void> completeLesson(String courseId, String lessonId) =>
      _send('POST', '/courses/$courseId/lessons/$lessonId/complete');

  /// Финалдық емтихан нәтижесін сақтау.
  Future<void> submitExam(String courseId, Map<String, dynamic> result) =>
      _send('POST', '/courses/$courseId/exam', body: result);

  // ─────────────── Trader application (расталған трейдер өтінімі) ───────────────
  /// Расталған трейдер болуға өтінім жіберу (админ модерациясына түседі).
  Future<void> submitTraderApplication({required String about, String? years, String? proof}) =>
      _send('POST', '/trader-applications', body: {'about': about, 'years': years, 'proof': proof});
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService(ref.watch(apiClientProvider)));
