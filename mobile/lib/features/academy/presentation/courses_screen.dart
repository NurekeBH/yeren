import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/course.dart';
import '../data/courses_repository.dart';
import '../data/video_course.dart';

/// Премиум-курстар тізімі (Академия) — жеке экран.
class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.academy_courses)),
      body: const CoursesList(),
    );
  }
}

/// Курстар тізімі (Scaffold-сыз) — Библиотека табындағы «Курсы» қойындысында да қолданылады.
class CoursesList extends ConsumerWidget {
  const CoursesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final coursesAsync = ref.watch(coursesProvider);
    final videoCourses = ref.watch(videoCoursesProvider).valueOrNull ?? const [];
    return coursesAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
      error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('${l.common_error}: $e'))),
      data: (courses) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(courseCatalogRawProvider);
          ref.invalidate(coursesProvider);
          ref.invalidate(videoCoursesProvider);
          await ref.read(coursesProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Text(l.academy_courses_subtitle,
                style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            for (final c in courses) ...[
              _CourseCard(course: c),
              const SizedBox(height: 16),
            ],
            for (final v in videoCourses) ...[
              _VideoCourseCard(course: v),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

/// Видео-курс картасы (мұқаба + атау + баға) → видео-курс деталіне.
class _VideoCourseCard extends ConsumerWidget {
  const _VideoCourseCard({required this.course});
  final VideoCourse course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final unlocked = course.isFree || ref.watch(purchasedCoursesProvider).contains(course.id);
    final cover = course.coverImageUrl;
    return GestureDetector(
      onTap: () => context.push('/academy/video-course/${course.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 8))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: cover != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover),
                        const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 52)),
                      ],
                    )
                  : Container(
                      color: AppColors.midnight,
                      child: Center(child: Text(course.emoji, style: const TextStyle(fontSize: 44))),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: AppTypography.h2()),
                  if (course.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(course.subtitle,
                        style: AppTypography.bodySmall(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MetaChip(icon: Icons.movie_outlined, text: l.course_modules_count(course.modules.length)),
                      const Spacer(),
                      if (unlocked)
                        Text(l.course_unlocked,
                            style: AppTypography.label(color: AppColors.profitGreen).copyWith(fontWeight: FontWeight.w700))
                      else if (course.isFree)
                        Text(l.signals_free_badge,
                            style: AppTypography.label(color: AppColors.profitGreen).copyWith(fontWeight: FontWeight.w700))
                      else
                        Row(children: [
                          const Icon(Icons.toll, size: 16, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text('${course.priceBonus}', style: AppTypography.h2(color: AppColors.gold)),
                        ]),
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

class _CourseCard extends ConsumerWidget {
  const _CourseCard({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final accent = Color(course.accent);
    final unlocked = ref.watch(purchasedCoursesProvider).contains(course.id);
    final done = ref.watch(courseDoneCountProvider(course.id));
    final total = course.lessonCount;

    return GestureDetector(
      onTap: () => context.push('/academy/course/${course.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 8))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шапка-градиент.
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(l.academy_premium_badge,
                            style: AppTypography.label(color: Colors.white).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1)),
                      ),
                      const Spacer(),
                      if (unlocked)
                        const Icon(Icons.lock_open, color: Colors.white, size: 18)
                      else
                        const Icon(Icons.workspace_premium, color: Colors.white, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(course.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(course.title,
                      style: AppTypography.h2(color: Colors.white).copyWith(height: 1.15)),
                  const SizedBox(height: 6),
                  Text(course.subtitle,
                      style: AppTypography.bodySmall(color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            // Тело.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.description,
                      style: AppTypography.bodySmall(color: AppColors.textSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _MetaChip(icon: Icons.layers, text: l.course_modules_count(course.modules.length)),
                      const SizedBox(width: 8),
                      _MetaChip(icon: Icons.menu_book, text: l.course_lessons_count(total)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (unlocked) ...[
                    LinearProgressIndicator(
                      value: total == 0 ? 0 : done / total,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceMuted,
                      color: accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.course_progress(done, total),
                            style: AppTypography.label(color: AppColors.textSecondary)),
                        Text(l.course_unlocked,
                            style: AppTypography.label(color: AppColors.profitGreen).copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ] else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.toll, size: 18, color: accent),
                            const SizedBox(width: 6),
                            Text('${course.priceBonus}',
                                style: AppTypography.h2(color: accent)),
                            const SizedBox(width: 4),
                            Text('бонусов', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                          ],
                        ),
                        Icon(Icons.arrow_forward, color: accent),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(text, style: AppTypography.label(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
