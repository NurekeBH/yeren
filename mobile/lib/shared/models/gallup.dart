import 'package:equatable/equatable.dart';

/// TZ §11.2: 4 трейдер профилі.
enum GallupProfile {
  revenge,
  uncontrolledRisk,
  hope,
  disciplined;

  String get emoji {
    switch (this) {
      case GallupProfile.revenge:
        return '😤';
      case GallupProfile.uncontrolledRisk:
        return '⚠️';
      case GallupProfile.hope:
        return '🙏';
      case GallupProfile.disciplined:
        return '🏆';
    }
  }
}

/// Әр жауап параметрлер бойынша баллдар береді.
class GallupOption extends Equatable {
  const GallupOption({required this.label, required this.scores});

  final String label;
  final Map<GallupProfile, int> scores;

  @override
  List<Object?> get props => [label];
}

class GallupQuestion extends Equatable {
  const GallupQuestion({required this.id, required this.text, required this.options});

  final String id;
  final String text;
  final List<GallupOption> options;

  @override
  List<Object?> get props => [id];
}

class GallupResult extends Equatable {
  const GallupResult({required this.dominant, required this.scores});

  final GallupProfile dominant;
  final Map<GallupProfile, int> scores;

  static GallupResult fromAnswers(List<GallupOption> answers) {
    final scores = <GallupProfile, int>{
      for (final p in GallupProfile.values) p: 0,
    };
    for (final answer in answers) {
      answer.scores.forEach((k, v) => scores[k] = scores[k]! + v);
    }
    final dominant = scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return GallupResult(dominant: dominant, scores: scores);
  }

  @override
  List<Object?> get props => [dominant, scores];
}
