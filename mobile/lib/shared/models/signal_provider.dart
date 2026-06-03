import 'package:equatable/equatable.dart';

/// Сигнал провайдері (трейдер). Әркімнің статистикасы бар, оған подписаться етуге болады.
/// Провайдер статусын админ береді (мокта — фикстурада берілген).
class SignalProvider extends Equatable {
  const SignalProvider({
    required this.id,
    required this.name,
    required this.avatar,
    required this.winRate,
    required this.avgRr,
    required this.rating,
    required this.subscribers,
    required this.pricePerMonth,
    required this.verified,
    required this.bio,
    required this.tradesCount,
  });

  final String id;
  final String name;
  final String avatar; // эмодзи аватар
  final double winRate; // 0..1
  final double avgRr;
  final double rating; // 0..5
  final int subscribers;
  final int pricePerMonth; // ₸; 0 = тегін
  final bool verified;
  final String bio;
  final int tradesCount;

  bool get isFree => pricePerMonth <= 0;

  @override
  List<Object?> get props => [id];
}
