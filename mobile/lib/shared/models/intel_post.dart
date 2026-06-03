import 'package:equatable/equatable.dart';

enum GoldImpact { bullish, bearish, neutral }

class IntelPost extends Equatable {
  const IntelPost({
    required this.id,
    required this.source,
    required this.text,
    required this.impact,
    required this.xauMove,
    required this.analysis,
    required this.support,
    required this.resistance,
    required this.suggestedSl,
    required this.sentiment,
    required this.publishedAt,
    this.isUrgent = false,
  });

  final String id;
  final String source;
  final String text;
  final GoldImpact impact;
  final double xauMove;
  final String analysis;
  final double support;
  final double resistance;
  final double suggestedSl;
  final int sentiment;
  final DateTime publishedAt;
  final bool isUrgent;

  @override
  List<Object?> get props => [id, source, publishedAt];
}
