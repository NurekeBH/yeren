import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/course.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/presentation/top_up_bonus_sheet.dart';
import '../data/courses_repository.dart';

/// Курс деталі — модульдер мен сабақтар тізімі + paywall.
class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final course = ref.watch(courseByIdProvider(courseId));
    if (course == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.common_error)));
    }
    final accent = Color(course.accent);
    final unlocked = ref.watch(purchasedCoursesProvider).contains(course.id);
    final progress = ref.watch(courseProgressProvider);
    final done = ref.watch(courseDoneCountProvider(course.id));
    final total = course.lessonCount;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(54, 0, 16, 14),
              title: Text(course.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium(color: Colors.white).copyWith(fontWeight: FontWeight.w700)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 52),
                alignment: Alignment.bottomLeft,
                child: Text(course.subtitle,
                    maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall(color: Colors.white.withValues(alpha: 0.92))),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.description, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Stat(value: '${course.modules.length}', label: l.course_modules_count(course.modules.length).split(' ').last),
                      const SizedBox(width: 12),
                      _Stat(value: '$total', label: l.course_lessons_count(total).split(' ').last),
                      const SizedBox(width: 12),
                      if (unlocked)
                        _Stat(value: '$done/$total', label: '✓', accent: AppColors.profitGreen),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (unlocked) ...[
                    LinearProgressIndicator(
                      value: total == 0 ? 0 : done / total,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceMuted,
                      color: accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      done >= total && total > 0 ? l.course_completed_all : l.course_progress(done, total),
                      style: AppTypography.label(color: AppColors.textSecondary),
                    ),
                  ] else
                    _UnlockBanner(course: course, accent: accent),
                  const SizedBox(height: 20),
                  Text(l.course_what_inside, style: AppTypography.h2()),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          // Модульдер мен сабақтар.
          SliverList.builder(
            itemCount: course.modules.length,
            itemBuilder: (context, mi) {
              final m = course.modules[mi];
              return _ModuleSection(
                course: course,
                module: m,
                accent: accent,
                unlocked: unlocked,
                progress: progress,
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.accent});
  final String value, label;
  final Color? accent;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.price(size: 17, color: accent ?? AppColors.textPrimary)),
          Text(label, style: AppTypography.label(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _UnlockBanner extends ConsumerStatefulWidget {
  const _UnlockBanner({required this.course, required this.accent});
  final Course course;
  final Color accent;

  @override
  ConsumerState<_UnlockBanner> createState() => _UnlockBannerState();
}

class _UnlockBannerState extends ConsumerState<_UnlockBanner> {
  bool _busy = false;

  Future<void> _unlock(AppLocalizations l, int cost) async {
    setState(() => _busy = true);
    ref.read(profileControllerProvider.notifier).spendBonus(cost);
    ref.read(purchasedCoursesProvider.notifier).unlock(widget.course.id);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.course_unlocked)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cost = widget.course.priceBonus;
    final balance = ref.watch(profileControllerProvider).bonusBalance;
    final canAfford = balance >= cost;
    final shortfall = (cost - balance).clamp(0, cost);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock, size: 18, color: widget.accent),
              const SizedBox(width: 8),
              Text(l.course_locked_hint,
                  style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.course_unlock_balance, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
              Text(l.promo_bonus_amount(balance),
                  style: AppTypography.bodyMedium(color: canAfford ? AppColors.profitGreen : AppColors.lossRed)
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          if (canAfford)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: widget.accent),
                onPressed: _busy ? null : () => _unlock(l, cost),
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.lock_open, size: 18),
                label: Text(l.course_unlock_for(cost)),
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: widget.accent),
                onPressed: _busy
                    ? null
                    : () async {
                        final ok = await showTopUpBonusSheet(context, suggested: shortfall);
                        if (ok && mounted && ref.read(profileControllerProvider).bonusBalance >= cost) {
                          await _unlock(l, cost);
                        }
                      },
                icon: const Icon(Icons.add_card, size: 18),
                label: Text(l.bonus_topup),
              ),
            ),
            const SizedBox(height: 6),
            Text(l.signals_not_enough(shortfall),
                style: AppTypography.label(color: AppColors.lossRed)),
          ],
        ],
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({
    required this.course,
    required this.module,
    required this.accent,
    required this.unlocked,
    required this.progress,
  });

  final Course course;
  final CourseModule module;
  final Color accent;
  final bool unlocked;
  final Set<String> progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.course_module_label(module.index),
              style: AppTypography.label(color: accent).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(module.title, style: AppTypography.bodyLarge().copyWith(fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 4),
          Text(module.goal, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          for (final lesson in module.lessons)
            _LessonTile(
              course: course,
              lesson: lesson,
              accent: accent,
              unlocked: unlocked,
              done: progress.contains(lesson.id),
            ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.course,
    required this.lesson,
    required this.accent,
    required this.unlocked,
    required this.done,
  });

  final Course course;
  final CourseLesson lesson;
  final Color accent;
  final bool unlocked;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unlocked
          ? () => context.push('/academy/course/${course.id}/lesson/${lesson.id}')
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: done ? AppColors.profitGreen.withValues(alpha: 0.4) : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? AppColors.profitGreen.withValues(alpha: 0.12) : accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: done
                  ? const Icon(Icons.check, color: AppColors.profitGreen, size: 22)
                  : Text(lesson.code, style: AppTypography.label(color: accent).copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(lesson.title,
                  style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600, height: 1.2)),
            ),
            const SizedBox(width: 8),
            Icon(
              unlocked ? Icons.chevron_right : Icons.lock_outline,
              color: unlocked ? AppColors.textMuted : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
