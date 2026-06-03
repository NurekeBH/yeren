import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/gallup.dart';
import '../../../shared/models/lesson.dart';
import '../../profile/application/profile_controller.dart';
import '../data/lessons_repository.dart';
import 'widgets/weekly_progress.dart';

class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key, this.embedded = false});

  /// `true` болса: AppBar/Scaffold-сыз — Tab/parent ішінде ұқыпты тұру үшін.
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profile = ref.watch(profileControllerProvider);
    final lessonsAsync = ref.watch(allLessonsProvider);
    final completed = ref.watch(completedLessonsProvider);

    final body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (profile.gallup == null)
            _TestPromptCard(l: l, onTap: () => context.push('/academy/test'))
          else
            _ProfileCard(result: profile.gallup!, xp: profile.xp, streak: profile.streak, l: l),
          const SizedBox(height: 12),
          WeeklyProgress(completed: profile.weekProgress),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_library_outlined, color: AppColors.purple),
              title: Text(l.academy_library, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(l.academy_library_subtitle, style: AppTypography.bodySmall()),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: () => context.push('/academy/library'),
            ),
          ),
          const SizedBox(height: 20),
          lessonsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('${l.common_error}: $e'),
            data: (lessons) {
              final forProfile = profile.gallup == null
                  ? <Lesson>[]
                  : lessons.where((x) => x.profile == profile.gallup!.dominant).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (forProfile.isNotEmpty) ...[
                    Text(l.academy_lessons_for_you, style: AppTypography.h2()),
                    const SizedBox(height: 8),
                    for (final lesson in forProfile) _LessonTile(lesson: lesson, done: completed.contains(lesson.id), l: l),
                    const SizedBox(height: 16),
                  ],
                  Text(l.academy_all_lessons, style: AppTypography.h2()),
                  const SizedBox(height: 8),
                  for (final lesson in lessons) _LessonTile(lesson: lesson, done: completed.contains(lesson.id), l: l),
                ],
              );
            },
          ),
        ],
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: Text(l.academy_title)),
      body: body,
    );
  }
}

class _TestPromptCard extends StatelessWidget {
  const _TestPromptCard({required this.l, required this.onTap});

  final AppLocalizations l;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.purple.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.psychology, color: AppColors.purple),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.academy_take_test, style: AppTypography.h2()),
                    const SizedBox(height: 4),
                    Text(l.academy_take_test_subtitle, style: AppTypography.bodySmall()),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.result, required this.xp, required this.streak, required this.l});

  final GallupResult result;
  final int xp;
  final int streak;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final (name, _) = _profileLabel(result.dominant, l);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(result.dominant.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.academy_my_profile, style: AppTypography.label(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(name, style: AppTypography.h2()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Pill(text: l.academy_xp(xp), color: AppColors.purple),
                      const SizedBox(width: 8),
                      _Pill(text: l.academy_streak_days(streak), color: AppColors.gold),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: AppTypography.label(color: color)),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.done, required this.l});

  final Lesson lesson;
  final bool done;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => GoRouter.of(context).push('/academy/lesson/${lesson.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.school_outlined,
                  color: done ? AppColors.profitGreen : AppColors.gold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lesson.title, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(lesson.sourceName, style: AppTypography.bodySmall()),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_tagLabel(lesson.tag, l), style: AppTypography.label(color: AppColors.purple)),
                      ),
                    ],
                  ),
                ),
                Text('+${lesson.xp}', style: AppTypography.label(color: AppColors.purple)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

(String, String) _profileLabel(GallupProfile p, AppLocalizations l) {
  switch (p) {
    case GallupProfile.revenge:
      return (l.gallup_profile_revenge, l.gallup_profile_revenge_desc);
    case GallupProfile.uncontrolledRisk:
      return (l.gallup_profile_risk, l.gallup_profile_risk_desc);
    case GallupProfile.hope:
      return (l.gallup_profile_hope, l.gallup_profile_hope_desc);
    case GallupProfile.disciplined:
      return (l.gallup_profile_disciplined, l.gallup_profile_disciplined_desc);
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
