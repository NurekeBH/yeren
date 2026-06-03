import 'package:equatable/equatable.dart';

import 'gallup.dart';

enum LessonSourceType { book, trader, film, podcast }

extension LessonSourceTypeX on LessonSourceType {
  /// UI-ға дереккөз белгісін көрсету (book/film/podcast/trader).
  String get emoji {
    switch (this) {
      case LessonSourceType.book:
        return '📖';
      case LessonSourceType.film:
        return '🎬';
      case LessonSourceType.podcast:
        return '🎧';
      case LessonSourceType.trader:
        return '🧑‍💼';
    }
  }
}

enum LessonTag { psychology, risk, strategy, discipline, mindset }

/// Тез сұраққа варианттар (қолмен жазбай, ой жинау керек):
class QuickCheck extends Equatable {
  const QuickCheck({required this.question, required this.options, required this.correctIndex});

  final String question;
  final List<String> options;
  final int correctIndex;

  @override
  List<Object?> get props => [question, options, correctIndex];
}

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.profile,
    required this.sourceType,
    required this.sourceName,
    required this.title,
    required this.quote,
    required this.explanation,
    required this.goldApplication,
    required this.quickCheck,
    required this.xp,
    required this.tag,
    this.externalUrl,
  });

  final String id;
  final GallupProfile profile;
  final LessonSourceType sourceType;
  final String sourceName;
  final String title;
  final String quote;
  final String explanation;
  final String goldApplication;
  final QuickCheck quickCheck;
  final int xp;
  final LessonTag tag;
  final String? externalUrl;

  @override
  List<Object?> get props => [id];
}
