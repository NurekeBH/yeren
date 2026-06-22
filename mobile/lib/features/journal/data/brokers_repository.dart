import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/broker_account.dart';

const _brokersKey = 'broker_accounts_v1';

/// Брокер аккаунттар store: жергілікті (SharedPreferences) + backend синхрон.
/// Online болса backend ақиқат көзі (/brokers); offline болса жергілікті кэш.
/// TZ §16.3: investor password backend-те AES-256 шифрленеді, client-те тек masked.
class BrokersController extends StateNotifier<List<BrokerAccount>> {
  BrokersController(this._prefs, this._ref) : super(_loadInitial(_prefs)) {
    _pullRemote();
  }

  final SharedPreferences _prefs;
  final Ref _ref;

  /// Backend-тен нақты аккаунттарды тартып аламыз (best-effort).
  Future<void> _pullRemote() async {
    try {
      final list = await _ref.read(apiServiceProvider).brokers();
      _set(list.map((e) => _fromApi(e as Map<String, dynamic>)).toList());
    } catch (_) {
      // Offline — жергілікті кэш қалады.
    }
  }

  static List<BrokerAccount> _loadInitial(SharedPreferences prefs) {
    final raw = prefs.getString(_brokersKey);
    if (raw == null || raw.isEmpty) return _seed();
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(_fromJson).toList();
    } catch (_) {
      return _seed();
    }
  }

  static List<BrokerAccount> _seed() => [
        BrokerAccount(
          id: 'br-001',
          broker: BrokerName.exness,
          platform: TradingPlatform.mt5,
          accountNumber: '85204517',
          server: 'Exness-MT5Real8',
          investorPasswordMasked: '••••••42',
          balance: 4280.50,
          linkedAt: DateTime.now().subtract(const Duration(days: 21)),
          syncedAt: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
        BrokerAccount(
          id: 'br-002',
          broker: BrokerName.icMarkets,
          platform: TradingPlatform.cTrader,
          accountNumber: 'ICM-3401822',
          balance: 1820.00,
          isOAuth: true,
          linkedAt: DateTime.now().subtract(const Duration(days: 6)),
          syncedAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ];

  Future<void> _persist() async {
    final list = state.map(_toJson).toList();
    await _prefs.setString(_brokersKey, jsonEncode(list));
  }

  void _set(List<BrokerAccount> next) {
    state = next;
    _persist();
  }

  Future<void> linkMt({
    required BrokerName broker,
    required TradingPlatform platform,
    required String accountNumber,
    required String server,
    required String investorPassword,
  }) async {
    // Backend-ке жалғаймыз (investor password сонда AES-256 шифрленеді).
    try {
      final acc = await _ref.read(apiServiceProvider).linkBrokerMt({
        'broker_name': _brokerToApi(broker),
        'platform': platform == TradingPlatform.mt4 ? 'mt4' : 'mt5',
        'account_number': accountNumber.trim(),
        'server': server.trim(),
        'investor_password': investorPassword,
      });
      if (acc.isNotEmpty) {
        _set([...state, _fromApi(acc)]);
        return;
      }
    } catch (_) {
      // Offline — оптимистік жергілікті қосу.
    }
    final masked = investorPassword.length <= 2
        ? '••'
        : '••••••${investorPassword.substring(investorPassword.length - 2)}';
    _set([
      ...state,
      BrokerAccount(
        id: 'br-${DateTime.now().millisecondsSinceEpoch}',
        broker: broker,
        platform: platform,
        accountNumber: accountNumber.trim(),
        server: server.trim(),
        investorPasswordMasked: masked,
        balance: 0,
        linkedAt: DateTime.now(),
        syncedAt: DateTime.now(),
      ),
    ]);
  }

  Future<void> linkCTrader({required BrokerName broker, required String accountNumber}) async {
    try {
      final acc = await _ref.read(apiServiceProvider).linkBrokerCtrader({
        'broker_name': _brokerToApi(broker),
        'account_number': accountNumber.trim(),
      });
      if (acc.isNotEmpty) {
        _set([...state, _fromApi(acc)]);
        return;
      }
    } catch (_) {
      // Offline fallback.
    }
    _set([
      ...state,
      BrokerAccount(
        id: 'br-${DateTime.now().millisecondsSinceEpoch}',
        broker: broker,
        platform: TradingPlatform.cTrader,
        accountNumber: accountNumber.trim(),
        balance: 0,
        isOAuth: true,
        linkedAt: DateTime.now(),
        syncedAt: DateTime.now(),
      ),
    ]);
  }

  void remove(String id) {
    _ref.read(apiServiceProvider).removeBroker(id).catchError((_) {});
    _set(state.where((a) => a.id != id).toList());
  }

  void sync(String id) {
    _ref.read(apiServiceProvider).syncBroker(id).catchError((_) {});
    _set(state
        .map((a) => a.id == id
            ? BrokerAccount(
                id: a.id,
                broker: a.broker,
                platform: a.platform,
                accountNumber: a.accountNumber,
                server: a.server,
                investorPasswordMasked: a.investorPasswordMasked,
                balance: a.balance,
                currency: a.currency,
                linkedAt: a.linkedAt,
                syncedAt: DateTime.now(),
                isOAuth: a.isOAuth,
              )
            : a)
        .toList());
  }

  void reset() {
    _prefs.remove(_brokersKey);
    state = _seed();
  }

  static Map<String, dynamic> _toJson(BrokerAccount a) => {
        'id': a.id,
        'broker': a.broker.name,
        'platform': a.platform.name,
        'accountNumber': a.accountNumber,
        'server': a.server,
        'investorPasswordMasked': a.investorPasswordMasked,
        'balance': a.balance,
        'currency': a.currency,
        'isOAuth': a.isOAuth,
        'linkedAt': a.linkedAt?.toIso8601String(),
        'syncedAt': a.syncedAt?.toIso8601String(),
      };

  static BrokerAccount _fromJson(Map<String, dynamic> j) => BrokerAccount(
        id: j['id'] as String,
        broker: BrokerName.values.firstWhere((b) => b.name == j['broker']),
        platform: TradingPlatform.values.firstWhere((p) => p.name == j['platform']),
        accountNumber: j['accountNumber'] as String,
        server: j['server'] as String?,
        investorPasswordMasked: j['investorPasswordMasked'] as String?,
        balance: (j['balance'] as num?)?.toDouble() ?? 0,
        currency: j['currency'] as String? ?? 'USD',
        isOAuth: j['isOAuth'] as bool? ?? false,
        linkedAt: j['linkedAt'] == null ? null : DateTime.parse(j['linkedAt'] as String),
        syncedAt: j['syncedAt'] == null ? null : DateTime.parse(j['syncedAt'] as String),
      );

  // ── Backend ↔ модель түрлендіру (enum snake_case-пен) ──
  static String _brokerToApi(BrokerName b) => switch (b) {
        BrokerName.exness => 'exness',
        BrokerName.icMarkets => 'ic_markets',
        BrokerName.xm => 'xm',
        BrokerName.pepperstone => 'pepperstone',
        BrokerName.oanda => 'oanda',
        BrokerName.fxPro => 'fxpro',
        BrokerName.other => 'other',
      };

  static BrokerName _brokerFromApi(String s) => switch (s) {
        'exness' => BrokerName.exness,
        'ic_markets' => BrokerName.icMarkets,
        'xm' => BrokerName.xm,
        'pepperstone' => BrokerName.pepperstone,
        'oanda' => BrokerName.oanda,
        'fxpro' => BrokerName.fxPro,
        _ => BrokerName.other,
      };

  static TradingPlatform _platformFromApi(String s) => switch (s) {
        'mt4' => TradingPlatform.mt4,
        'mt5' => TradingPlatform.mt5,
        _ => TradingPlatform.cTrader,
      };

  /// Backend жауабын (/brokers shape) модельге айналдырады.
  static BrokerAccount _fromApi(Map<String, dynamic> j) => BrokerAccount(
        id: j['id'].toString(),
        broker: _brokerFromApi((j['broker_name'] ?? 'other').toString()),
        platform: _platformFromApi((j['platform'] ?? 'mt5').toString()),
        accountNumber: (j['account_number'] ?? '').toString(),
        server: j['server'] as String?,
        investorPasswordMasked: j['investor_password_masked'] as String?,
        balance: (j['balance'] as num?)?.toDouble() ?? 0,
        currency: (j['currency'] ?? 'USD').toString(),
        isOAuth: j['is_oauth'] == true,
        linkedAt: j['linked_at'] == null ? null : DateTime.tryParse('${j['linked_at']}'),
        syncedAt: j['synced_at'] == null ? null : DateTime.tryParse('${j['synced_at']}'),
      );
}

final brokersControllerProvider =
    StateNotifierProvider<BrokersController, List<BrokerAccount>>(
  (ref) => BrokersController(ref.watch(sharedPreferencesProvider), ref),
);
