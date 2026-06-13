import 'package:equatable/equatable.dart';

enum SignalDirection { buy, sell }

enum SignalStatus { active, closedTp1, closedTp2, closedTp3, closedSl }

extension SignalStatusX on SignalStatus {
  bool get isClosed => this != SignalStatus.active;
  bool get isWin =>
      this == SignalStatus.closedTp1 ||
      this == SignalStatus.closedTp2 ||
      this == SignalStatus.closedTp3;
}

class Signal extends Equatable {
  const Signal({
    required this.id,
    required this.pair,
    required this.direction,
    required this.entryFrom,
    required this.entryTo,
    required this.tp1,
    required this.tp2,
    required this.tp3,
    required this.sl,
    required this.rr,
    required this.confidence,
    required this.screenshotUrl,
    required this.analysis,
    required this.status,
    required this.publishedAt,
    this.resultPips,
    this.providerId,
    this.isFree = false,
  });

  final String id;
  final String pair;
  final SignalDirection direction;
  final double entryFrom;
  final double entryTo;
  final double tp1;
  final double tp2;
  final double tp3;
  final double sl;
  final double rr;
  final int confidence;
  final String screenshotUrl;
  final String analysis;
  final SignalStatus status;
  final DateTime publishedAt;
  final int? resultPips;
  final String? providerId;

  /// Тегін идея — paywall жоқ, толық көрінеді (баға 0).
  final bool isFree;

  double get entryMid => (entryFrom + entryTo) / 2;

  /// XAU/USD: 1 пипс = 0.10 баға қозғалысы (позиция калькуляторымен сәйкес).
  static const double pipSize = 0.10;

  /// Идеяның толық мақсатына дейінгі қашықтық (пипс) — кіру ортасынан ең алыс TP-ке.
  /// Buy/Sell бағытына тәуелсіз: үш TP ішінен ең үлкен модульдік қашықтық алынады.
  double get tpPips {
    final furthest = [tp1, tp2, tp3]
        .map((tp) => (tp - entryMid).abs())
        .reduce((a, b) => a > b ? a : b);
    return furthest / pipSize;
  }

  /// Идея бағасы (₸): тегін болса 0; әйтпесе TP 200 пипстен асса — 1000 ₸, басқаша 500 ₸.
  int get priceTg => isFree ? 0 : (tpPips > 200 ? 1000 : 500);

  /// Ақылы идея ма (тегін емес).
  bool get isPaid => !isFree;

  @override
  List<Object?> get props => [id, pair, direction, status, publishedAt];
}
