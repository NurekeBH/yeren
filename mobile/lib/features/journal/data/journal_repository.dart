import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/mock/fixtures.dart';
import '../../../shared/models/market_session.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/models/trade.dart';

const _tradesKey = 'user_trades_v1';

/// Local trades store: SharedPreferences-те JSON. Mock fixture trades +
/// пайдаланушы қосқан сделкаларды қосады.
class JournalRepository {
  JournalRepository(this._prefs);

  final SharedPreferences _prefs;

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
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final stored = _userTrades();
    final all = [...stored, ...MockFixtures.trades(loc)];
    all.sort((a, b) => b.openedAt.compareTo(a.openedAt));
    return all;
  }

  Future<Trade> addTrade(Trade trade) async {
    final stored = _userTrades();
    final next = [trade, ...stored];
    await _saveUserTrades(next);
    return trade;
  }

  Future<void> deleteTrade(String id) async {
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
  (ref) => JournalRepository(ref.watch(sharedPreferencesProvider)),
);

final tradesProvider = FutureProvider<List<Trade>>((ref) {
  final loc = ref.watch(localeControllerProvider).languageCode;
  return ref.watch(journalRepositoryProvider).fetchAll(loc);
});
