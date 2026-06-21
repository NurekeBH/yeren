import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/course.dart';
import '../data/courses_repository.dart';
import 'widgets/course_interactives.dart';

/// Курс сабағы — мазмұн блоктары + интерактив + соңында тест.
class CourseLessonScreen extends ConsumerStatefulWidget {
  const CourseLessonScreen({super.key, required this.courseId, required this.lessonId});
  final String courseId;
  final String lessonId;

  @override
  ConsumerState<CourseLessonScreen> createState() => _CourseLessonScreenState();
}

class _CourseLessonScreenState extends ConsumerState<CourseLessonScreen> {
  int? _selected;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final course = ref.watch(courseByIdProvider(widget.courseId));
    if (course == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.common_error)));
    }
    final lessons = course.allLessons;
    final idx = lessons.indexWhere((x) => x.id == widget.lessonId);
    if (idx < 0) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.common_error)));
    }
    final lesson = lessons[idx];
    final accent = Color(course.accent);
    final done = ref.watch(courseProgressProvider).contains(lesson.id);
    final next = idx + 1 < lessons.length ? lessons[idx + 1] : null;

    final correct = lesson.quiz.correctIndex;
    final isCorrect = _submitted && _selected == correct;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.code, style: AppTypography.label(color: accent).copyWith(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Text(lesson.title, style: AppTypography.h1().copyWith(height: 1.2)),
          const SizedBox(height: 18),
          for (final block in lesson.blocks) ...[
            _BlockView(block: block),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 8),
          // ── Тест ──
          _QuizCard(
            quiz: lesson.quiz,
            accent: accent,
            selected: _selected,
            submitted: _submitted,
            onSelect: _submitted ? null : (i) => setState(() => _selected = i),
            onSubmit: _selected == null || _submitted
                ? null
                : () => setState(() => _submitted = true),
          ),
          const SizedBox(height: 20),
          // ── Аяқтау / келесі ──
          if (_submitted && isCorrect) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: accent),
                onPressed: () {
                  ref.read(courseProgressProvider.notifier).markDone(lesson.id);
                  if (next != null) {
                    context.pushReplacement('/academy/course/${course.id}/lesson/${next.id}');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.course_completed_all)),
                    );
                    context.pop();
                  }
                },
                icon: Icon(next != null ? Icons.arrow_forward : Icons.check_circle, size: 18),
                label: Text(next != null ? l.lesson_next : l.lesson_complete),
              ),
            ),
          ] else if (done) ...[
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.profitGreen, size: 18),
                  const SizedBox(width: 6),
                  Text(l.lesson_done_badge,
                      style: AppTypography.bodySmall(color: AppColors.profitGreen).copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Бір мазмұн блогын рендерлейді.
class _BlockView extends StatelessWidget {
  const _BlockView({required this.block});
  final LessonBlock block;

  @override
  Widget build(BuildContext context) {
    final b = block;
    if (b is ParagraphBlock) {
      return Text(b.text, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(height: 1.5));
    }
    if (b is HeadingBlock) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(b.text, style: AppTypography.h2()),
      );
    }
    if (b is CalloutBlock) {
      return _Callout(block: b);
    }
    if (b is FormulaBlock) {
      return _FormulaView(block: b);
    }
    if (b is InteractiveBlock) {
      return buildCourseInteractive(b.key);
    }
    return const SizedBox.shrink();
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.block});
  final CalloutBlock block;

  @override
  Widget build(BuildContext context) {
    final (color, icon, defTitle) = switch (block.kind) {
      CalloutKind.essence => (AppColors.gold, Icons.lightbulb_outline, 'Суть'),
      CalloutKind.example => (AppColors.dxyBlue, Icons.article_outlined, 'Пример'),
      CalloutKind.rule => (AppColors.profitGreen, Icons.gavel, 'Правило'),
      CalloutKind.mechanic => (AppColors.purple, Icons.settings_suggest, 'Механика'),
      CalloutKind.warning => (AppColors.lossRed, Icons.warning_amber, 'Внимание'),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(block.title ?? defTitle,
                  style: AppTypography.label(color: color).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(block.text, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class _FormulaView extends StatelessWidget {
  const _FormulaView({required this.block});
  final FormulaBlock block;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.midnight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.title != null) ...[
            Text(block.title!,
                style: AppTypography.label(color: Colors.white70).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 8),
          ],
          for (final line in block.lines)
            Text(
              line.isEmpty ? ' ' : line,
              style: AppTypography.price(size: 14, color: Colors.white)
                  .copyWith(height: 1.5, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.quiz,
    required this.accent,
    required this.selected,
    required this.submitted,
    required this.onSelect,
    required this.onSubmit,
  });

  final QuizQuestion quiz;
  final Color accent;
  final int? selected;
  final bool submitted;
  final ValueChanged<int>? onSelect;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isCorrect = submitted && selected == quiz.correctIndex;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz_outlined, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(l.lesson_quiz_title, style: AppTypography.h2()),
            ],
          ),
          const SizedBox(height: 12),
          Text(quiz.question, style: AppTypography.bodyLarge().copyWith(fontWeight: FontWeight.w600, height: 1.3)),
          const SizedBox(height: 14),
          for (int i = 0; i < quiz.options.length; i++) ...[
            _OptionRow(
              text: quiz.options[i],
              state: _optionState(i),
              onTap: onSelect == null ? null : () => onSelect!(i),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          if (!submitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accent),
                onPressed: onSubmit,
                child: Text(l.lesson_quiz_check),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isCorrect ? AppColors.profitGreen : AppColors.lossRed).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                          size: 16, color: isCorrect ? AppColors.profitGreen : AppColors.lossRed),
                      const SizedBox(width: 6),
                      Text(isCorrect ? l.lesson_quiz_correct : l.lesson_quiz_wrong,
                          style: AppTypography.bodyMedium(color: isCorrect ? AppColors.profitGreen : AppColors.lossRed)
                              .copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(quiz.explanation, style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(height: 1.4)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  _OptState _optionState(int i) {
    if (!submitted) return selected == i ? _OptState.selected : _OptState.idle;
    if (i == quiz.correctIndex) return _OptState.correct;
    if (i == selected) return _OptState.wrong;
    return _OptState.idle;
  }
}

enum _OptState { idle, selected, correct, wrong }

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.text, required this.state, required this.onTap});
  final String text;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg, icon) = switch (state) {
      _OptState.idle => (AppColors.surfaceMuted, AppColors.border, AppColors.textPrimary, null),
      _OptState.selected => (AppColors.gold.withValues(alpha: 0.1), AppColors.gold, AppColors.textPrimary, Icons.radio_button_checked),
      _OptState.correct => (AppColors.profitGreen.withValues(alpha: 0.12), AppColors.profitGreen, AppColors.textPrimary, Icons.check_circle),
      _OptState.wrong => (AppColors.lossRed.withValues(alpha: 0.1), AppColors.lossRed, AppColors.textPrimary, Icons.cancel),
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon ?? Icons.radio_button_unchecked, size: 18, color: border == AppColors.border ? AppColors.textMuted : border),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: AppTypography.bodyMedium(color: fg).copyWith(height: 1.3))),
          ],
        ),
      ),
    );
  }
}
