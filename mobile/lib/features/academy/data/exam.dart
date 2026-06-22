import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../shared/models/course.dart';

/// Емтихан сұрағы — модуль контекстімен (нәтиже бойынша кеңес беру үшін).
class ExamQuestion {
  const ExamQuestion({required this.moduleIndex, required this.moduleTitle, required this.quiz});
  final int moduleIndex;
  final String moduleTitle;
  final QuizQuestion quiz;
}

/// Курстың барлық сабақ тесттерінен емтихан жинайды (араластырып, [count] сұрақ).
List<ExamQuestion> buildExam(Course course, {int count = 30, int? seed}) {
  final pool = <ExamQuestion>[
    for (final m in course.modules)
      for (final l in m.lessons)
        ExamQuestion(moduleIndex: m.index, moduleTitle: m.title, quiz: l.quiz),
  ];
  pool.shuffle(Random(seed));
  return pool.take(count.clamp(1, pool.length)).toList();
}

/// Емтихан нәтижесі (сақталады әрі дашбордқа жіберіледі).
class ExamResult {
  const ExamResult({
    required this.courseId,
    required this.score,
    required this.total,
    required this.passed,
    required this.perModule,
    required this.dateIso,
  });

  final String courseId;
  final int score;
  final int total;
  final bool passed;

  /// moduleIndex → (correct, total).
  final Map<int, ({int correct, int total})> perModule;
  final String dateIso;

  double get pct => total == 0 ? 0 : score / total;

  Map<String, dynamic> toApiJson() => {
        'score': score,
        'total': total,
        'passed': passed,
        'per_module': {
          for (final e in perModule.entries)
            e.key.toString(): {'correct': e.value.correct, 'total': e.value.total},
        },
      };

  Map<String, dynamic> toJson() => {
        'courseId': courseId,
        'score': score,
        'total': total,
        'passed': passed,
        'date': dateIso,
        'per': {for (final e in perModule.entries) e.key.toString(): [e.value.correct, e.value.total]},
      };

  static ExamResult fromJson(Map<String, dynamic> j) => ExamResult(
        courseId: j['courseId'].toString(),
        score: (j['score'] as num).toInt(),
        total: (j['total'] as num).toInt(),
        passed: j['passed'] == true,
        dateIso: (j['date'] ?? '').toString(),
        perModule: {
          for (final e in ((j['per'] as Map?) ?? {}).entries)
            int.parse(e.key.toString()): (
              correct: (e.value as List)[0] as int,
              total: (e.value as List)[1] as int,
            ),
        },
      );
}

// ── Соңғы емтихан нәтижесін жергілікті сақтау ──
const _examKey = 'exam_results_v1';

class ExamResultsController extends StateNotifier<Map<String, ExamResult>> {
  ExamResultsController(this._prefs) : super(_load(_prefs));
  final SharedPreferences _prefs;

  static Map<String, ExamResult> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_examKey);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return {for (final e in map.entries) e.key: ExamResult.fromJson(e.value as Map<String, dynamic>)};
    } catch (_) {
      return {};
    }
  }

  void save(ExamResult r) {
    state = {...state, r.courseId: r};
    _prefs.setString(_examKey, jsonEncode({for (final e in state.entries) e.key: e.value.toJson()}));
  }
}

final examResultsProvider =
    StateNotifierProvider<ExamResultsController, Map<String, ExamResult>>(
  (ref) => ExamResultsController(ref.watch(sharedPreferencesProvider)),
);
