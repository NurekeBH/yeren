import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../data/courses_repository.dart';
import '../data/exam.dart';

/// Финалдық емтихан — курстың барлық тесттерінен 30 сұрақ, соңында
/// нәтиже + модуль бойынша кеңес. Нәтиже жергілікті әрі backend-ке сақталады.
class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  // Курс async тартылады — викторина курс келгенде build-те бір рет құрылады.
  List<ExamQuestion> _q = const [];
  List<int?> _answers = const [];
  final _pc = PageController();
  int _page = 0;
  bool _finished = false;
  ExamResult? _result;

  static const _passMark = 0.7; // 70%

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _finish() {
    var score = 0;
    final perMod = <int, ({int correct, int total})>{};
    for (var i = 0; i < _q.length; i++) {
      final mi = _q[i].moduleIndex;
      final prev = perMod[mi] ?? (correct: 0, total: 0);
      final ok = _answers[i] == _q[i].quiz.correctIndex;
      if (ok) score++;
      perMod[mi] = (correct: prev.correct + (ok ? 1 : 0), total: prev.total + 1);
    }
    final result = ExamResult(
      courseId: widget.courseId,
      score: score,
      total: _q.length,
      passed: _q.isEmpty ? false : score / _q.length >= _passMark,
      perModule: perMod,
      dateIso: DateTime.now().toIso8601String(),
    );
    ref.read(examResultsProvider.notifier).save(result);
    ref.read(apiServiceProvider).submitExam(widget.courseId, result.toApiJson()).catchError((_) {});
    setState(() {
      _result = result;
      _finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final courseAsync = ref.watch(courseByIdProvider(widget.courseId));
    final course = courseAsync.valueOrNull;
    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: courseAsync.isLoading ? const CircularProgressIndicator() : Text(l.common_error),
        ),
      );
    }
    // Курс келді — викторинаны бір рет құрамыз (30 сұрақ).
    if (_q.isEmpty) {
      _q = buildExam(course, count: 30);
      _answers = List<int?>.filled(_q.length, null);
    }
    if (_q.isEmpty) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.common_error)));
    }
    if (_finished && _result != null) {
      return _ResultView(course: course, result: _result!, onRetake: () {
        setState(() {
          for (var i = 0; i < _answers.length; i++) {
            _answers[i] = null;
          }
          _page = 0;
          _finished = false;
          _result = null;
        });
        _pc.jumpToPage(0);
      });
    }

    final accent = Color(course.accent);
    final answered = _answers[_page] != null;
    final isLast = _page == _q.length - 1;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        elevation: 0,
        title: Text(l.exam_title, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Прогресс.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.exam_question_progress(_page + 1, _q.length),
                    style: AppTypography.label(color: accent).copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_page + 1) / _q.length,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceMuted,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _q.length,
              onPageChanged: (p) => setState(() => _page = p),
              itemBuilder: (_, i) {
                final q = _q[i].quiz;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_q[i].moduleTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label(color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Text(q.question, style: AppTypography.h2().copyWith(height: 1.25)),
                      const SizedBox(height: 16),
                      for (int o = 0; o < q.options.length; o++) ...[
                        _ExamOption(
                          text: q.options[o],
                          selected: _answers[i] == o,
                          accent: accent,
                          onTap: () => setState(() => _answers[i] = o),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Row(
                children: [
                  if (_page > 0) ...[
                    GestureDetector(
                      onTap: () => _pc.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: GestureDetector(
                      onTap: !answered
                          ? null
                          : isLast
                              ? _finish
                              : () => _pc.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                      child: Container(
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: answered ? accent : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(isLast ? l.exam_finish : l.course_next,
                            style: AppTypography.button(color: answered ? Colors.white : AppColors.textMuted).copyWith(fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamOption extends StatelessWidget {
  const _ExamOption({required this.text, required this.selected, required this.accent, required this.onTap});
  final String text;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? accent : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 18, color: selected ? accent : AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: AppTypography.bodyMedium().copyWith(height: 1.3))),
          ],
        ),
      ),
    );
  }
}

// ── Нәтиже + кеңес ──
class _ResultView extends ConsumerWidget {
  const _ResultView({required this.course, required this.result, required this.onRetake});
  final dynamic course;
  final ExamResult result;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final accent = Color(course.accent as int);
    final pct = (result.pct * 100).round();
    final passed = result.passed;
    final col = passed ? AppColors.profitGreen : AppColors.lossRed;

    // Модуль бойынша «нашар» (< 60%) тізімі — кеңес үшін.
    final weak = result.perModule.entries
        .where((e) => e.value.total > 0 && e.value.correct / e.value.total < 0.6)
        .toList()
      ..sort((a, b) => (a.value.correct / a.value.total).compareTo(b.value.correct / b.value.total));

    final modules = {for (final m in (course.modules as List)) m.index as int: m.title as String};

    return Scaffold(
      appBar: AppBar(title: Text(l.exam_title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const SizedBox(height: 8),
          Center(child: Text(passed ? '🏆' : '💪', style: const TextStyle(fontSize: 64))),
          const SizedBox(height: 12),
          Center(
            child: Text(passed ? l.exam_passed : l.exam_failed,
                style: AppTypography.h1(color: col)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: col.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: col.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(l.exam_your_score, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text('${result.score}/${result.total}  ·  $pct%',
                    style: AppTypography.display(color: col)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l.exam_advice_title, style: AppTypography.h2()),
          const SizedBox(height: 12),
          if (weak.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.profitGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.profitGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l.exam_advice_all_good,
                      style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600))),
                ],
              ),
            )
          else
            for (final e in weak)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lossRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.refresh, color: AppColors.lossRed, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('МОДУЛЬ ${e.key}: ${modules[e.key] ?? ''}',
                              style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700, height: 1.2)),
                          const SizedBox(height: 2),
                          Text('${e.value.correct}/${e.value.total} верно — стоит повторить',
                              style: AppTypography.label(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: accent),
              onPressed: onRetake,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l.exam_retake),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: Text(l.exam_back_to_course),
            ),
          ),
        ],
      ),
    );
  }
}
