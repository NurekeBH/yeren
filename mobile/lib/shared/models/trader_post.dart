import 'package:equatable/equatable.dart';

/// Трейдер посты («Published idea») — фото + мәтін + лайк + коммент.
/// Провайдер бетіндегі әлеуметтік лента.
class TraderPost extends Equatable {
  const TraderPost({
    required this.id,
    required this.providerId,
    required this.text,
    this.imageUrl,
    this.baseLikes = 0,
    this.seededComments = const [],
    this.agoLabel,
  });

  final String id;
  final String providerId;

  /// Локализацияланған пост мәтіні.
  final String text;

  /// Сурет (график скриншоты). Болмаса — тек мәтін.
  final String? imageUrl;

  /// Бастапқы лайк саны (фикстура).
  final int baseLikes;

  /// Бастапқы комментарийлер: (автор, мәтін).
  final List<PostComment> seededComments;

  /// «2 сағат бұрын» сияқты белгі (локализацияланған).
  final String? agoLabel;

  @override
  List<Object?> get props => [id];
}

/// Пост астындағы комментарий.
class PostComment extends Equatable {
  const PostComment({required this.author, required this.text, this.isMine = false});

  final String author;
  final String text;
  final bool isMine;

  @override
  List<Object?> get props => [author, text, isMine];
}
