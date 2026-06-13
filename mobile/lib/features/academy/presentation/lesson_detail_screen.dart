import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/lesson.dart';
import '../../profile/application/profile_controller.dart';
import '../data/lessons_repository.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  int? _selectedAnswer;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(allLessonsProvider);
    final completed = ref.watch(completedLessonsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.common_error}: $e')),
        data: (lessons) {
          final lesson = lessons.firstWhere((x) => x.id == widget.lessonId, orElse: () => lessons.first);
          final isDone = completed.contains(lesson.id);
          final correct = lesson.quickCheck.correctIndex;
          final canSubmit = !isDone && !_submitted && _selectedAnswer != null;
          final isCorrect = _submitted && _selectedAnswer == correct;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(_tagLabel(lesson.tag, l), style: AppTypography.label(color: AppColors.purple)),
                  ),
                  const SizedBox(width: 6),
                  Text(lesson.sourceType.emoji, style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              Text(lesson.title, style: AppTypography.display()),
              const SizedBox(height: 8),
              Text(lesson.sourceName, style: AppTypography.bodySmall(color: AppColors.purple)),
              const SizedBox(height: 20),
              _Section(label: l.lesson_quote, child: _Quote(text: lesson.quote)),
              _Section(label: l.lesson_explanation, child: Text(lesson.explanation, style: AppTypography.bodyMedium())),
              _Section(label: l.lesson_gold_application, child: Text(lesson.goldApplication, style: AppTypography.bodyMedium())),
              _Section(
                label: l.lesson_quick_check,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.quickCheck.question, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    for (var i = 0; i < lesson.quickCheck.options.length; i++)
                      _OptionTile(
                        index: i,
                        text: lesson.quickCheck.options[i],
                        selected: _selectedAnswer == i,
                        correctIndex: correct,
                        submitted: _submitted || isDone,
                        onTap: isDone || _submitted ? null : () => setState(() => _selectedAnswer = i),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isDone)
                _DoneBanner(text: l.lesson_completed(lesson.xp))
              else if (_submitted) ...[
                if (isCorrect)
                  _DoneBanner(text: l.lesson_completed(lesson.xp))
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lossRed.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.close, color: AppColors.lossRed),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.lesson_correct_answer(lesson.quickCheck.options[correct]),
                            style: AppTypography.bodySmall(color: AppColors.lossRed),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                if (isCorrect)
                  ElevatedButton(
                    onPressed: () {
                      ref.read(completedLessonsProvider.notifier).markCompleted(lesson.id);
                      ref.read(profileControllerProvider.notifier).addXp(lesson.xp);
                      context.pop();
                    },
                    child: Text(l.lesson_complete),
                  )
                else
                  OutlinedButton(
                    onPressed: () => setState(() {
                      _selectedAnswer = null;
                      _submitted = false;
                    }),
                    child: Text(l.common_retry),
                  ),
              ] else
                ElevatedButton(
                  onPressed: canSubmit ? () => setState(() => _submitted = true) : null,
                  child: Text(l.lesson_complete),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.text,
    required this.selected,
    required this.correctIndex,
    required this.submitted,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool selected;
  final int correctIndex;
  final bool submitted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.border;
    Color bg = AppColors.cardSurface;
    Widget? trailing;
    if (submitted) {
      if (index == correctIndex) {
        border = AppColors.profitGreen;
        bg = AppColors.profitGreen.withValues(alpha: 0.08);
        trailing = const Icon(Icons.check_circle, color: AppColors.profitGreen, size: 18);
      } else if (selected) {
        border = AppColors.lossRed;
        bg = AppColors.lossRed.withValues(alpha: 0.08);
        trailing = const Icon(Icons.cancel, color: AppColors.lossRed, size: 18);
      }
    } else if (selected) {
      border = AppColors.gold;
      bg = AppColors.gold.withValues(alpha: 0.10);
      trailing = const Icon(Icons.radio_button_checked, color: AppColors.gold, size: 18);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(child: Text(text, style: AppTypography.bodyMedium())),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _DoneBanner extends StatelessWidget {
  const _DoneBanner({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.profitGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.profitGreen),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTypography.bodyMedium(color: AppColors.profitGreen))),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.purple, width: 3)),
      ),
      child: Text('"$text"', style: AppTypography.bodyMedium().copyWith(fontStyle: FontStyle.italic)),
    );
  }
}

String _tagLabel(LessonTag t, AppLocalizations l) {
  switch (t) {
    case LessonTag.psychology:
      return l.tag_psychology;
    case LessonTag.risk:
      return l.tag_risk;
    case LessonTag.strategy:
      return l.tag_strategy;
    case LessonTag.discipline:
      return l.tag_discipline;
    case LessonTag.mindset:
      return l.tag_mindset;
  }
}
