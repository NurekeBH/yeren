import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/mock/fixtures.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/market_session.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/models/trade.dart';

const _tradesKey = 'user_trades_v1';

double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

// Dart enum ↔ backend snake_case тег.
String _setupTag(TradeSetup s) => s == TradeSetup.smcOb ? 'smc_ob' : s.name;
TradeSetup _setupFromTag(String t) => t == 'smc_ob'
    ? TradeSetup.smcOb
    : TradeSetup.values.firstWhere((e) => e.name == t, orElse: () => TradeSetup.retest);
String _sessionTag(MarketSession s) => s == MarketSession.newYork ? 'new_york' : s.name;
MarketSession _sessionFromTag(String t) => t == 'new_york'
    ? MarketSession.newYork
    : MarketSession.values.firstWhere((e) => e.name == t, orElse: () => MarketSession.asia);

/// Backend JSON → Trade.
Trade tradeFromApi(Map<String, dynamic> j) {
  final opened = DateTime.tryParse('${j['opened_at']}') ?? DateTime.now();
  return Trade(
    id: j['id'].toString(),
    instrument: (j['instrument'] ?? 'XAU/USD').toString(),
    direction: (j['direction'] == 'sell') ? SignalDirection.sell : SignalDirection.buy,
    openPrice: _d(j['open_price']),
    closePrice: j['close_price'] == null ? _d(j['open_price']) : _d(j['close_price']),
    lot: _d(j['lot']),
    pnl: _d(j['pnl']),
    setup: _setupFromTag((j['setup_tag'] ?? 'retest').toString()),
    session: _sessionFromTag((j['session_tag'] ?? 'asia').toString()),
    openedAt: opened,
    closedAt: DateTime.tryParse('${j['closed_at']}') ?? opened,
    broker: (j['source'] ?? 'API').toString(),
    rrPlanned: j['rr_planned'] == null ? null : _d(j['rr_planned']),
    rrActual: j['rr_actual'] == null ? null : _d(j['rr_actual']),
    emotion: j['emotion']?.toString(),
    notes: j['notes']?.toString(),
  );
}

Map<String, dynamic> tradeToApi(Trade t) => {
      'instrument': t.instrument,
      'direction': t.direction.name,
      'open_price': t.openPrice,
      'close_price': t.closePrice,
      'lot': t.lot,
      'pnl': t.pnl,
      if (t.rrPlanned != null) 'rr_planned': t.rrPlanned,
      if (t.rrActual != null) 'rr_actual': t.rrActual,
      'setup_tag': _setupTag(t.setup),
      'session_tag': _sessionTag(t.session),
      if (t.emotion != null && t.emotion!.isNotEmpty) 'emotion': t.emotion,
      if (t.notes != null && t.notes!.isNotEmpty) 'notes': t.notes,
      'source': 'manual',
      'opened_at': t.openedAt.toUtc().toIso8601String(),
      'closed_at': t.closedAt.toUtc().toIso8601String(),
    };

/// Mock режимде local SharedPreferences (fixture + пайдаланушы сделкалары);
/// remote режимде backend (`/trades`).
class JournalRepository {
  JournalRepository(this._prefs, this._api);

  final SharedPreferences _prefs;
  final ApiService _api;

  List<Trade> _userTrades() {
    final raw = _prefs.getString(_tradesKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(_fromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveUserTrades(List<Trade> trades) async {
    final list = trades.map(_toJson).toList();
    await _prefs.setString(_tradesKey, jsonEncode(list));
  }

  Future<List<Trade>> fetchAll(String loc) async {
    if (AppConfig.useRemoteApi) {
      final list = await _api.trades();
      final all = list.map((e) => tradeFromApi((e as Map).cast<String, dynamic>())).toList();
      all.sort((a, b) => b.openedAt.compareTo(a.openedAt));
      return all;
    }
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final stored = _userTrades();
    final all = [...stored, ...MockFixtures.trades(loc)];
    all.sort((a, b) => b.openedAt.compareTo(a.openedAt));
    return all;
  }

  Future<Trade> addTrade(Trade trade) async {
    if (AppConfig.useRemoteApi) {
      final res = await _api.createTrade(tradeToApi(trade));
      return res.isEmpty ? trade : tradeFromApi(res);
    }
    final stored = _userTrades();
    final next = [trade, ...stored];
    await _saveUserTrades(next);
    return trade;
  }

  Future<void> deleteTrade(String id) async {
    if (AppConfig.useRemoteApi) {
      await _api.deleteTrade(id);
      return;
    }
    final stored = _userTrades();
    final next = stored.where((t) => t.id != id).toList();
    await _saveUserTrades(next);
  }

  Map<String, dynamic> _toJson(Trade t) => {
        'id': t.id,
        'instrument': t.instrument,
        'direction': t.direction.name,
        'openPrice': t.openPrice,
        'closePrice': t.closePrice,
        'lot': t.lot,
        'pnl': t.pnl,
        'setup': t.setup.name,
        'session': t.session.name,
        'openedAt': t.openedAt.toIso8601String(),
        'closedAt': t.closedAt.toIso8601String(),
        'broker': t.broker,
        'rrPlanned': t.rrPlanned,
        'rrActual': t.rrActual,
        'emotion': t.emotion,
        'notes': t.notes,
      };

  Trade _fromJson(Map<String, dynamic> j) => Trade(
        id: j['id'] as String,
        instrument: j['instrument'] as String? ?? 'XAU/USD',
        direction: SignalDirection.values.firstWhere((d) => d.name == j['direction']),
        openPrice: (j['openPrice'] as num).toDouble(),
        closePrice: (j['closePrice'] as num).toDouble(),
        lot: (j['lot'] as num).toDouble(),
        pnl: (j['pnl'] as num).toDouble(),
        setup: TradeSetup.values.firstWhere((s) => s.name == j['setup']),
        session: MarketSession.values.firstWhere((s) => s.name == j['session']),
        openedAt: DateTime.parse(j['openedAt'] as String),
        closedAt: DateTime.parse(j['closedAt'] as String),
        broker: j['broker'] as String? ?? 'Manual',
        rrPlanned: (j['rrPlanned'] as num?)?.toDouble(),
        rrActual: (j['rrActual'] as num?)?.toDouble(),
        emotion: j['emotion'] as String?,
        notes: j['notes'] as String?,
      );
}

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => JournalRepository(ref.watch(sharedPreferencesProvider), ref.watch(apiServiceProvider)),
);

final tradesProvider = FutureProvider<List<Trade>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(journalRepositoryProvider).fetchAll(loc);
});
