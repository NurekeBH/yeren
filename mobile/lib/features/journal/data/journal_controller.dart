import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import 'journal_models.dart';

/// Таңдалған аккаунт (null = барлық аккаунттар).
final selectedAccountProvider = StateProvider<String?>((ref) => null);

final journalAccountsProvider = FutureProvider<List<JournalAccount>>((ref) async {
  final raw = await ref.watch(apiServiceProvider).journalAccounts();
  return raw.map((e) => JournalAccount.fromJson((e as Map).cast<String, dynamic>())).toList();
});

final journalTradesProvider = FutureProvider<List<JournalTrade>>((ref) async {
  final acc = ref.watch(selectedAccountProvider);
  final raw = await ref.watch(apiServiceProvider).journalTrades(acc);
  return raw.map((e) => JournalTrade.fromJson((e as Map).cast<String, dynamic>())).toList();
});

final journalAnalyticsProvider = FutureProvider<JournalAnalytics>((ref) async {
  final acc = ref.watch(selectedAccountProvider);
  final raw = await ref.watch(apiServiceProvider).journalAnalytics(acc);
  return JournalAnalytics.fromJson(raw);
});

/// Журнал әрекеттері — barlығы аяқталған соң тиісті провайдерлерді жаңартады.
class JournalController {
  JournalController(this._ref);
  final Ref _ref;

  ApiService get _api => _ref.read(apiServiceProvider);

  void _refreshAll() {
    _ref.invalidate(journalAccountsProvider);
    _ref.invalidate(journalTradesProvider);
    _ref.invalidate(journalAnalyticsProvider);
  }

  Future<JournalAccount> linkAccount(Map<String, dynamic> body) async {
    final json = await _api.linkJournalAccount(body);
    _ref.invalidate(journalAccountsProvider);
    return JournalAccount.fromJson(json);
  }

  Future<void> removeAccount(String id) async {
    await _api.removeJournalAccount(id);
    _refreshAll();
  }

  /// Аккаунтты синхрондау. SyncResult қайтарады (ok/state/inserted/updated/error).
  Future<Map<String, dynamic>> sync(String id) async {
    final res = await _api.syncJournalAccount(id);
    _refreshAll();
    return res;
  }

  /// Statement импорттау (.html/.csv). Backend парсеп upsert жасайды.
  Future<Map<String, dynamic>> importStatement(String path, {String? accountId}) async {
    final res = await _api.importStatement(path, accountId: accountId);
    _refreshAll();
    return res;
  }

  Future<void> addManual(Map<String, dynamic> body) async {
    await _api.addJournalTrade(body);
    _ref.invalidate(journalTradesProvider);
    _ref.invalidate(journalAnalyticsProvider);
  }

  Future<void> deleteTrade(String id) async {
    await _api.deleteJournalTrade(id);
    _ref.invalidate(journalTradesProvider);
    _ref.invalidate(journalAnalyticsProvider);
  }

  Future<void> setMetadata(String tradeId, Map<String, dynamic> body) async {
    await _api.setTradeMetadata(tradeId, body);
    _ref.invalidate(journalTradesProvider);
    _ref.invalidate(journalAnalyticsProvider);
  }
}

final journalControllerProvider = Provider<JournalController>((ref) => JournalController(ref));
