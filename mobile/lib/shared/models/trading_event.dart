import 'package:equatable/equatable.dart';

/// Іс-шара түрі: мастер-класс, лайв-трейд, вебинар.
enum EventType { masterclass, liveTrade, webinar }

extension EventTypeX on EventType {
  String get emoji {
    switch (this) {
      case EventType.masterclass:
        return '🎓';
      case EventType.liveTrade:
        return '📊';
      case EventType.webinar:
        return '💻';
    }
  }
}

/// Трейдерлерге арналған іс-шара (афиша, орны, бағасы, түсіндірмесі, видео).
class TradingEvent extends Equatable {
  const TradingEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.speaker,
    required this.city,
    required this.dateIso,
    required this.price,
    required this.isOnline,
    required this.description,
    this.youtubeId,
  });

  final String id;
  final EventType type;
  final String title;
  final String speaker;
  final String city;
  final String dateIso;
  final double price; // 0 = тегін
  final bool isOnline;
  final String description;
  final String? youtubeId; // видео-түсіндірме (қалауыңша)

  bool get isFree => price <= 0;

  @override
  List<Object?> get props => [id];
}
