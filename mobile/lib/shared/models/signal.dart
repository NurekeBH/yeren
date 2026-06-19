import 'package:equatable/equatable.dart';

enum SignalDirection { buy, sell }

/// Тәуекел деңгейі — сенімділік пайызынан есептеледі (жоғары сенім = төмен тәуекел).
enum RiskLevel { low, medium, high }

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
    this.isMine = false,
    this.authorName,
    this.priceOverride,
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

  /// Осы пайдаланушы (расталған трейдер) жариялаған идея — оны басқара алады.
  final bool isMine;

  /// Авторы көрсетілетін аты (isMine идеялар үшін; provider жоқ болғанда).
  final String? authorName;

  /// Жылдам жарияланған идея бағасы (₸) — деңгейлер мәтінде, пипстен есептелмейді.
  final int? priceOverride;

  /// Сандық деңгейлер (entry/TP) енгізілген бе — жоқ болса фото+мәтін режимі.
  bool get hasLevels => entryFrom > 0 && tp1 > 0;

  double get entryMid => (entryFrom + entryTo) / 2;

  /// XAU/USD: 1 пипс = 0.10 баға қозғалысы (позиция калькуляторымен сәйкес).
  static const double pipSize = 0.10;

  /// Идеяның толық мақсатына дейінгі қашықтық (пипс) — кіру ортасынан ең алыс TP-ке.
  /// Buy/Sell бағытына тәуелсіз: үш TP ішінен ең үлкен модульдік қашықтық алынады.
  double get tpPips {
    // Тек қойылған TP-лерді (>0) ескереміз — қойылмаған tp2/tp3=0 нәтижені бұзбас үшін.
    final tps = [tp1, tp2, tp3].where((tp) => tp > 0);
    if (tps.isEmpty) return 0;
    final furthest = tps
        .map((tp) => (tp - entryMid).abs())
        .reduce((a, b) => a > b ? a : b);
    return furthest / pipSize;
  }

  /// Идея бағасы (₸): тегін болса 0; қолмен қойылса — priceOverride;
  /// әйтпесе TP 200 пипстен асса — 1000 ₸, басқаша 500 ₸.
  int get priceTg => isFree ? 0 : (priceOverride ?? (tpPips > 200 ? 1000 : 500));

  /// Ақылы идея ма (тегін емес).
  bool get isPaid => !isFree;

  /// Тәуекел деңгейі: сенімділік ≥75 → төмен, 55–74 → орташа, <55 → жоғары.
  RiskLevel get risk =>
      confidence >= 75 ? RiskLevel.low : (confidence >= 55 ? RiskLevel.medium : RiskLevel.high);

  /// Тәуекел деңгейіне сай сенімділік мәні (publish формасында қолданылады).
  static int confidenceForRisk(RiskLevel r) => switch (r) {
        RiskLevel.low => 85,
        RiskLevel.medium => 68,
        RiskLevel.high => 50,
      };

  Signal copyWith({SignalStatus? status, int? resultPips}) => Signal(
        id: id,
        pair: pair,
        direction: direction,
        entryFrom: entryFrom,
        entryTo: entryTo,
        tp1: tp1,
        tp2: tp2,
        tp3: tp3,
        sl: sl,
        rr: rr,
        confidence: confidence,
        screenshotUrl: screenshotUrl,
        analysis: analysis,
        status: status ?? this.status,
        publishedAt: publishedAt,
        resultPips: resultPips ?? this.resultPips,
        providerId: providerId,
        isFree: isFree,
        isMine: isMine,
        authorName: authorName,
        priceOverride: priceOverride,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'pair': pair,
        'direction': direction.name,
        'entryFrom': entryFrom,
        'entryTo': entryTo,
        'tp1': tp1,
        'tp2': tp2,
        'tp3': tp3,
        'sl': sl,
        'rr': rr,
        'confidence': confidence,
        'screenshotUrl': screenshotUrl,
        'analysis': analysis,
        'status': status.name,
        'publishedAt': publishedAt.toIso8601String(),
        'resultPips': resultPips,
        'isFree': isFree,
        'isMine': isMine,
        'authorName': authorName,
        'priceOverride': priceOverride,
      };

  factory Signal.fromJsonLocal(Map<String, dynamic> j) => Signal(
        id: j['id'].toString(),
        pair: (j['pair'] ?? 'XAU/USD').toString(),
        direction: SignalDirection.values.firstWhere((d) => d.name == j['direction'], orElse: () => SignalDirection.buy),
        entryFrom: (j['entryFrom'] as num).toDouble(),
        entryTo: (j['entryTo'] as num).toDouble(),
        tp1: (j['tp1'] as num).toDouble(),
        tp2: (j['tp2'] as num).toDouble(),
        tp3: (j['tp3'] as num).toDouble(),
        sl: (j['sl'] as num).toDouble(),
        rr: (j['rr'] as num).toDouble(),
        confidence: (j['confidence'] as num).toInt(),
        screenshotUrl: (j['screenshotUrl'] ?? '').toString(),
        analysis: (j['analysis'] ?? '').toString(),
        status: SignalStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => SignalStatus.active),
        publishedAt: DateTime.tryParse('${j['publishedAt']}') ?? DateTime.now(),
        resultPips: (j['resultPips'] as num?)?.toInt(),
        isFree: j['isFree'] == true,
        isMine: j['isMine'] == true,
        authorName: j['authorName'] as String?,
        priceOverride: (j['priceOverride'] as num?)?.toInt(),
      );

  @override
  List<Object?> get props => [id, pair, direction, status, publishedAt, resultPips];
}
