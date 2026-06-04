import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Баға ескертуі — пайдаланушы белгілеген бағаға/қашықтыққа жеткенде хабарлама.
/// Идеядан (50 пипс қалғанда) немесе қолмен (нақты баға) жасалуы мүмкін.
class PriceAlert extends Equatable {
  const PriceAlert({
    required this.id,
    required this.instrument,
    required this.targetPrice,
    required this.text,
    required this.createdAtIso,
    this.pips,
    this.ideaId,
  });

  final String id;
  final String instrument;
  final double targetPrice;
  final String text;
  final String createdAtIso;

  /// pips != null болса — «осынша пипс қалғанда» режимі.
  final double? pips;

  /// Қай идеядан жасалғаны (қолмен болса — null).
  final String? ideaId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'instrument': instrument,
        'targetPrice': targetPrice,
        'text': text,
        'createdAtIso': createdAtIso,
        'pips': pips,
        'ideaId': ideaId,
      };

  factory PriceAlert.fromJson(Map<String, dynamic> j) => PriceAlert(
        id: j['id'] as String,
        instrument: j['instrument'] as String,
        targetPrice: (j['targetPrice'] as num).toDouble(),
        text: j['text'] as String,
        createdAtIso: j['createdAtIso'] as String,
        pips: (j['pips'] as num?)?.toDouble(),
        ideaId: j['ideaId'] as String?,
      );

  /// Backend жолы (snake_case, pg numeric-тер string болуы мүмкін).
  factory PriceAlert.fromApi(Map<String, dynamic> j) {
    double d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    return PriceAlert(
      id: j['id'].toString(),
      instrument: (j['instrument'] ?? 'XAU/USD').toString(),
      targetPrice: d(j['target_price']),
      text: (j['text'] ?? '').toString(),
      createdAtIso: (j['created_at'] ?? '').toString(),
      pips: j['pips'] == null ? null : d(j['pips']),
      ideaId: j['idea_id']?.toString(),
    );
  }

  String encode() => jsonEncode(toJson());
  static PriceAlert decode(String s) => PriceAlert.fromJson(jsonDecode(s) as Map<String, dynamic>);

  @override
  List<Object?> get props => [id];
}
