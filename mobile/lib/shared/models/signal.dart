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

  double get entryMid => (entryFrom + entryTo) / 2;

  @override
  List<Object?> get props => [id, pair, direction, status, publishedAt];
}
