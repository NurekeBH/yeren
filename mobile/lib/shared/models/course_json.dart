// Курс ағашының JSON сериализациясы (DB-ге экспорт ↔ API-ден оқу).
// Бір көзден: экспорт құралы (tool/export_catalog.dart) toJson қолданады,
// апп (courses API repository) fromJson қолданады. Блок иерархиясы `t` дискриминаторымен.
import 'course.dart';

// ─── Quiz ───
Map<String, dynamic> quizToJson(QuizQuestion q) => {
      'question': q.question,
      'options': q.options,
      'correctIndex': q.correctIndex,
      'explanation': q.explanation,
    };

QuizQuestion quizFromJson(Map j) => QuizQuestion(
      question: (j['question'] ?? '').toString(),
      options: ((j['options'] as List?) ?? const []).map((e) => e.toString()).toList(),
      correctIndex: (j['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: (j['explanation'] ?? '').toString(),
    );

// ─── LessonBlock (полиморфты, `t` кілті бойынша) ───
Map<String, dynamic> blockToJson(LessonBlock b) => switch (b) {
      ParagraphBlock(:final text) => {'t': 'p', 'text': text},
      HeadingBlock(:final text) => {'t': 'h', 'text': text},
      CalloutBlock(:final kind, :final text, :final title) => {
          't': 'callout',
          'kind': kind.name,
          'text': text,
          'title': ?title,
        },
      FormulaBlock(:final lines, :final title) => {
          't': 'formula',
          'lines': lines,
          'title': ?title,
        },
      InteractiveBlock(:final key, :final title) => {
          't': 'interactive',
          'key': key,
          'title': ?title,
        },
      CardsBlock(:final title, :final items) => {
          't': 'cards',
          'title': title,
          'items': [
            for (final c in items) {'emoji': c.emoji, 'title': c.title, 'text': c.text},
          ],
        },
      MediaRecBlock(:final kind, :final title, :final note, :final meta) => {
          't': 'media',
          'kind': kind.name,
          'title': title,
          'note': note,
          'meta': ?meta,
        },
    };

LessonBlock blockFromJson(Map j) {
  switch ((j['t'] ?? 'p').toString()) {
    case 'h':
      return HeadingBlock((j['text'] ?? '').toString());
    case 'callout':
      return CalloutBlock(
        CalloutKind.values.firstWhere((k) => k.name == j['kind'], orElse: () => CalloutKind.essence),
        (j['text'] ?? '').toString(),
        title: j['title'] as String?,
      );
    case 'formula':
      return FormulaBlock(
        ((j['lines'] as List?) ?? const []).map((e) => e.toString()).toList(),
        title: j['title'] as String?,
      );
    case 'interactive':
      return InteractiveBlock((j['key'] ?? '').toString(), title: j['title'] as String?);
    case 'cards':
      return CardsBlock(
        (j['title'] ?? '').toString(),
        [
          for (final c in (j['items'] as List? ?? const []))
            CardItem((c['emoji'] ?? '').toString(), (c['title'] ?? '').toString(), (c['text'] ?? '').toString()),
        ],
      );
    case 'media':
      return MediaRecBlock(
        kind: MediaKind.values.firstWhere((k) => k.name == j['kind'], orElse: () => MediaKind.film),
        title: (j['title'] ?? '').toString(),
        note: (j['note'] ?? '').toString(),
        meta: j['meta'] as String?,
      );
    case 'p':
    default:
      return ParagraphBlock((j['text'] ?? '').toString());
  }
}

// ─── Lesson ───
Map<String, dynamic> lessonToJson(CourseLesson l) => {
      'id': l.id,
      'code': l.code,
      'title': l.title,
      'emoji': l.emoji,
      'hook': l.hook,
      'minutes': l.minutes,
      'blocks': [for (final b in l.blocks) blockToJson(b)],
      'quiz': quizToJson(l.quiz),
    };

CourseLesson lessonFromJson(Map j) => CourseLesson(
      id: (j['id'] ?? '').toString(),
      code: (j['code'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      emoji: (j['emoji'] ?? '📊').toString(),
      hook: (j['hook'] ?? '').toString(),
      minutes: (j['minutes'] as num?)?.toInt() ?? 10,
      blocks: [for (final b in (j['blocks'] as List? ?? const [])) blockFromJson(b as Map)],
      quiz: quizFromJson((j['quiz'] as Map?) ?? const {}),
    );

// ─── Module ───
Map<String, dynamic> moduleToJson(CourseModule m) => {
      'id': m.id,
      'index': m.index,
      'title': m.title,
      'goal': m.goal,
      'emoji': m.emoji,
      'lessons': [for (final l in m.lessons) lessonToJson(l)],
    };

CourseModule moduleFromJson(Map j) => CourseModule(
      id: (j['id'] ?? '').toString(),
      index: (j['index'] as num?)?.toInt() ?? 0,
      title: (j['title'] ?? '').toString(),
      goal: (j['goal'] ?? '').toString(),
      emoji: (j['emoji'] ?? '📦').toString(),
      lessons: [for (final l in (j['lessons'] as List? ?? const [])) lessonFromJson(l as Map)],
    );

// ─── Course ───
Map<String, dynamic> courseToJson(Course c) => {
      'id': c.id,
      'title': c.title,
      'subtitle': c.subtitle,
      'description': c.description,
      'priceBonus': c.priceBonus,
      'emoji': c.emoji,
      'accent': c.accent,
      'modules': [for (final m in c.modules) moduleToJson(m)],
    };

Course courseFromJson(Map j) => Course(
      id: (j['id'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      subtitle: (j['subtitle'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      priceBonus: (j['priceBonus'] as num?)?.toInt() ?? 0,
      emoji: (j['emoji'] ?? '🧠').toString(),
      accent: (j['accent'] as num?)?.toInt() ?? 0xFF2563EB,
      modules: [for (final m in (j['modules'] as List? ?? const [])) moduleFromJson(m as Map)],
    );
