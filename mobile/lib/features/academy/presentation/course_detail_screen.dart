import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/course.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/presentation/top_up_bonus_sheet.dart';
import '../data/courses_repository.dart';
import '../data/exam.dart';
import 'course_unlock_sheet.dart';

/// Курс деталі — модульдер мен сабақтар тізімі + paywall.
class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final courseAsync = ref.watch(courseByIdProvider(courseId));
    final course = courseAsync.valueOrNull;
    if (course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: courseAsync.isLoading ? const CircularProgressIndicator() : Text(l.common_error),
        ),
      );
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
                    _GamifiedProgress(done: done, total: total, l: l),
                    const SizedBox(height: 12),
                    _ExamCard(course: course, accent: accent),
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

/// Геймификацияланған прогресс — «🕵️ Раскрыто X/Y» қара карточка.
class _GamifiedProgress extends StatelessWidget {
  const _GamifiedProgress({required this.done, required this.total, required this.l});
  final int done;
  final int total;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.midnight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🕵️ ${l.course_solved(done, total)}',
                  style: AppTypography.bodyMedium(color: Colors.white).copyWith(fontWeight: FontWeight.w700)),
              Text('${(pct * 100).round()}%',
                  style: AppTypography.bodyMedium(color: AppColors.gold).copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              color: AppColors.gold,
            ),
          ),
          if (done >= total && total > 0) ...[
            const SizedBox(height: 8),
            Text(l.course_completed_all, style: AppTypography.label(color: AppColors.profitGreen).copyWith(fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}

/// Сатушы құнды-ұсыныс жолы (✓ ...).
class _SellBullet extends StatelessWidget {
  const _SellBullet({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 17, color: AppColors.profitGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(height: 1.35)),
          ),
        ],
      ),
    );
  }
}

/// Финалдық емтиханға кіру карточкасы (курс ашылғанда).
class _ExamCard extends ConsumerWidget {
  const _ExamCard({required this.course, required this.accent});
  final Course course;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final last = ref.watch(examResultsProvider)[course.id];
    return GestureDetector(
      onTap: () => context.push('/academy/course/${course.id}/exam'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, accent.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.exam_title,
                      style: AppTypography.bodyLarge(color: Colors.white).copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    last != null
                        ? l.exam_last_result(last.score, last.total)
                        : '${l.exam_intro_sub} · ${l.exam_questions_count(30)}',
                    style: AppTypography.label(color: Colors.white).copyWith(height: 1.25),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
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
    ref.read(apiServiceProvider).purchaseCourse(widget.course.id, cost).catchError((_) {});
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
          Text(l.course_sell_headline,
              style: AppTypography.bodyLarge().copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _SellBullet(text: l.course_sell_b1),
          _SellBullet(text: l.course_sell_b2),
          _SellBullet(text: l.course_sell_b3),
          _SellBullet(text: l.course_sell_b4),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('💡 ${l.course_sell_footer}',
                style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 14),
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
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(module.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.course_module_label(module.index),
                        style: AppTypography.label(color: accent).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1)),
                    const SizedBox(height: 2),
                    Text(module.title, style: AppTypography.bodyLarge().copyWith(fontWeight: FontWeight.w800, height: 1.15)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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

class _LessonTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: unlocked
          ? () => context.push('/academy/course/${course.id}/lesson/${lesson.id}')
          // Құлыпталған: тек атауын көреді, басқанда сатушы upsell ашылады.
          : () => showCourseUnlockSheet(context, ref, course),
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
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? AppColors.profitGreen.withValues(alpha: 0.12) : accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: done
                  ? const Icon(Icons.check, color: AppColors.profitGreen, size: 22)
                  : Icon(unlocked ? Icons.play_arrow_rounded : Icons.lock_outline,
                      color: unlocked ? accent : AppColors.textMuted, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title,
                      style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700, height: 1.2)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(AppLocalizations.of(context).lesson_minutes(lesson.minutes),
                          style: AppTypography.label(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: unlocked ? accent : AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
