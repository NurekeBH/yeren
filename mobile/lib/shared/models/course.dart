import 'package:equatable/equatable.dart';

/// Премиум-курс: бонус ұпайымен ашылады, модульдерден тұрады.
/// Әр модуль — сабақтар тізімі; әр сабақтың соңында бір тест (quiz) болады.
class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.priceBonus,
    required this.modules,
    this.accent = 0xFF2563EB,
    this.emoji = '🧠',
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;

  /// Курс мұқабасының эмодзиі.
  final String emoji;

  /// Курс бағасы (бонус ұпай). 0 болса — тегін.
  final int priceBonus;
  final List<CourseModule> modules;

  /// Курс түсіне арналған акцент (ARGB int).
  final int accent;

  bool get isFree => priceBonus <= 0;

  List<CourseLesson> get allLessons =>
      [for (final m in modules) ...m.lessons];

  int get lessonCount => allLessons.length;

  @override
  List<Object?> get props => [id];
}

class CourseModule extends Equatable {
  const CourseModule({
    required this.id,
    required this.index,
    required this.title,
    required this.goal,
    required this.lessons,
    this.emoji = '📦',
  });

  final String id;

  /// Модуль реттік нөмірі (1..N) — UI-да «МОДУЛЬ N» деп көрсетіледі.
  final int index;
  final String title;

  /// Модуль мұқабасының эмодзиі (hero-карточкада).
  final String emoji;

  /// Модуль мақсаты (қысқа сипаттама).
  final String goal;
  final List<CourseLesson> lessons;

  @override
  List<Object?> get props => [id];
}

class CourseLesson extends Equatable {
  const CourseLesson({
    required this.id,
    required this.code,
    required this.title,
    required this.blocks,
    required this.quiz,
    this.emoji = '📊',
    this.hook = '',
    this.minutes = 10,
  });

  final String id;

  /// Сабақ коды (мыс. «1.1», «4.3») — тақырып алдында көрсетіледі.
  final String code;
  final String title;

  /// Hero-карточкадағы үлкен эмодзи.
  final String emoji;

  /// Маркетингтік ілмек (қысқа қызықтыратын субтитр) — hero-да.
  final String hook;

  /// Сабақтың шамамен ұзақтығы (минут) — тізімде көрсетіледі.
  final int minutes;
  final List<LessonBlock> blocks;

  /// Сабақ соңындағы тест (бір сұрақ).
  final QuizQuestion quiz;

  @override
  List<Object?> get props => [id];
}

/// Сабақ мазмұнының блогы (мәтін, мысал, формула, интерактив, т.б.).
sealed class LessonBlock {
  const LessonBlock();
}

/// Қарапайым абзац.
class ParagraphBlock extends LessonBlock {
  const ParagraphBlock(this.text);
  final String text;
}

/// Бөлім тақырыпшасы.
class HeadingBlock extends LessonBlock {
  const HeadingBlock(this.text);
  final String text;
}

enum CalloutKind { essence, example, rule, mechanic, warning, fact, story }

/// Түсті «callout» карточка: Суть / Пример / Правило / Механика / Внимание.
class CalloutBlock extends LessonBlock {
  const CalloutBlock(this.kind, this.text, {this.title});
  final CalloutKind kind;
  final String text;
  final String? title;
}

/// Формула / тізбек қадамдары (моноширинамен, тілмен).
class FormulaBlock extends LessonBlock {
  const FormulaBlock(this.lines, {this.title});
  final List<String> lines;
  final String? title;
}

/// Интерактивті элемент — кілт бойынша виджет таңдалады
/// (course_interactives.dart ішінде).
class InteractiveBlock extends LessonBlock {
  const InteractiveBlock(this.key, {this.title});
  final String key;
  final String? title;
}

/// Мини-карточкалар тізбегі (мыс. «4 секрета успеха») — әрқайсысы
/// эмодзи + тақырып + мәтін. Көлденең тізіммен көрсетіледі.
class CardsBlock extends LessonBlock {
  const CardsBlock(this.title, this.items);
  final String title;
  final List<CardItem> items;
}

class CardItem {
  const CardItem(this.emoji, this.title, this.text);
  final String emoji;
  final String title;
  final String text;
}

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;

  /// Жауаптан кейінгі түсіндірме (неге дұрыс/бұрыс).
  final String explanation;
}
