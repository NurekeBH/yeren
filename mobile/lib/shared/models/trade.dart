import 'package:equatable/equatable.dart';

import 'market_session.dart';
import 'signal.dart';

enum TradeSetup { retest, breakout, smcOb, reversal, news, fvg }

class Trade extends Equatable {
  const Trade({
    required this.id,
    required this.instrument,
    required this.direction,
    required this.openPrice,
    required this.closePrice,
    required this.lot,
    required this.pnl,
    required this.setup,
    required this.session,
    required this.openedAt,
    required this.closedAt,
    this.broker = 'Mock',
    this.rrPlanned,
    this.rrActual,
    this.emotion,
    this.notes,
  });

  final String id;
  final String instrument;
  final SignalDirection direction;
  final double openPrice;
  final double closePrice;
  final double lot;
  final double pnl;
  final TradeSetup setup;
  final MarketSession session;
  final DateTime openedAt;
  final DateTime closedAt;
  final String broker;
  final double? rrPlanned;
  final double? rrActual;
  final String? emotion;
  final String? notes;

  bool get isWin => pnl >= 0;

  @override
  List<Object?> get props => [id, openedAt];
}
