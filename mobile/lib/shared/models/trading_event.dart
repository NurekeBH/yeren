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
    this.isMine = false,
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

  /// Осы пайдаланушы (расталған трейдер) жариялаған іс-шара.
  final bool isMine;

  bool get isFree => price <= 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'speaker': speaker,
        'city': city,
        'dateIso': dateIso,
        'price': price,
        'isOnline': isOnline,
        'description': description,
        'youtubeId': youtubeId,
        'isMine': isMine,
      };

  factory TradingEvent.fromJsonLocal(Map<String, dynamic> j) => TradingEvent(
        id: j['id'].toString(),
        type: EventType.values.firstWhere((t) => t.name == j['type'], orElse: () => EventType.webinar),
        title: (j['title'] ?? '').toString(),
        speaker: (j['speaker'] ?? '').toString(),
        city: (j['city'] ?? '').toString(),
        dateIso: (j['dateIso'] ?? '').toString(),
        price: (j['price'] as num?)?.toDouble() ?? 0,
        isOnline: j['isOnline'] == true,
        description: (j['description'] ?? '').toString(),
        youtubeId: j['youtubeId'] as String?,
        isMine: j['isMine'] == true,
      );

  @override
  List<Object?> get props => [id];
}
