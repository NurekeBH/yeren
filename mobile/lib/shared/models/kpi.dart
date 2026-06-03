import 'package:equatable/equatable.dart';

class KpiSnapshot extends Equatable {
  const KpiSnapshot({
    required this.winRate,
    required this.netPnl,
    required this.activeSignals,
    required this.streak,
    required this.equityCurve,
  });

  final double winRate;
  final double netPnl;
  final int activeSignals;
  final int streak;
  final List<double> equityCurve;

  @override
  List<Object?> get props => [winRate, netPnl, activeSignals, streak, equityCurve];
}

class GoldQuote extends Equatable {
  const GoldQuote({
    required this.price,
    required this.deltaAbs,
    required this.deltaPct,
    required this.sparkline,
    required this.dxy,
    required this.dxyDeltaPct,
  });

  final double price;
  final double deltaAbs;
  final double deltaPct;
  final List<double> sparkline;
  final double dxy;
  final double dxyDeltaPct;

  bool get isUp => deltaAbs >= 0;

  @override
  List<Object?> get props => [price, deltaAbs, deltaPct, sparkline, dxy, dxyDeltaPct];
}
