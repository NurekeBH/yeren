// Бір реттік экспорт: академия сабақтары (28) + Gallup сұрақтары (20) MockFixtures-тен
// JSON-ға → backend seed DB-ге салады. Таза Dart. Іске қосу (mobile/ ішінен):
//   dart run tool/export_academy.dart
import 'dart:convert';
import 'dart:io';

import 'package:traderos/core/mock/fixtures.dart';

const _locales = ['ru', 'kk', 'en'];

void main() {
  final out = Directory('../apps/backend/src/db/seed_data');
  out.createSync(recursive: true);
  _exportLessons(out);
  _exportGallup(out);
  stdout.writeln('✅ academy экспорт бітті → ${out.path}');
}

void _exportLessons(Directory out) {
  final acc = <String, Map<String, dynamic>>{};
  var order = 0;
  for (final loc in _locales) {
    for (final l in MockFixtures.lessons(loc)) {
      final row = acc.putIfAbsent(l.id, () => {
            'id': l.id,
            'profile_type': l.profile.name,
            'source_type': l.sourceType.name,
            'source_name': l.sourceName,
            'tag': l.tag.name,
            'xp': l.xp,
            'external_url': l.externalUrl,
            'sort_order': order++,
            'title': <String, String>{},
            'quote': <String, String>{},
            'explanation': <String, String>{},
            'gold_application': <String, String>{},
            'quick_check': {
              'question': <String, String>{},
              'options': <String, List<String>>{},
              'correctIndex': l.quickCheck.correctIndex,
            },
          });
      (row['title'] as Map<String, String>)[loc] = l.title;
      (row['quote'] as Map<String, String>)[loc] = l.quote;
      (row['explanation'] as Map<String, String>)[loc] = l.explanation;
      (row['gold_application'] as Map<String, String>)[loc] = l.goldApplication;
      final qc = row['quick_check'] as Map<String, dynamic>;
      (qc['question'] as Map<String, String>)[loc] = l.quickCheck.question;
      (qc['options'] as Map<String, List<String>>)[loc] = l.quickCheck.options;
    }
  }
  final list = acc.values.toList();
  File('${out.path}/academy_lessons.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(list));
  stdout.writeln('  academy_lessons: ${list.length}');
}

void _exportGallup(Directory out) {
  final acc = <String, Map<String, dynamic>>{};
  var order = 0;
  for (final loc in _locales) {
    for (final q in MockFixtures.gallupQuestions(loc)) {
      final row = acc.putIfAbsent(q.id, () => {
            'id': q.id,
            'sort_order': order++,
            'text': <String, String>{},
            'options': List.generate(q.options.length, (_) => {
                  'label': <String, String>{},
                  'scores': <String, int>{},
                }),
          });
      (row['text'] as Map<String, String>)[loc] = q.text;
      final opts = row['options'] as List;
      for (var i = 0; i < q.options.length; i++) {
        final o = q.options[i];
        ((opts[i] as Map)['label'] as Map<String, String>)[loc] = o.label;
        final sc = (opts[i] as Map)['scores'] as Map<String, int>;
        o.scores.forEach((k, v) => sc[k.name] = v);
      }
    }
  }
  final list = acc.values.toList();
  File('${out.path}/gallup_questions.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(list));
  stdout.writeln('  gallup_questions: ${list.length}');
}
