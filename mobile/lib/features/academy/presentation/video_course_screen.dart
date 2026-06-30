import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/secure_screen.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/presentation/top_up_bonus_sheet.dart';
import '../data/courses_repository.dart';
import '../data/video_course.dart';

/// Видео-курс деталі: тегін intro видео + мұқаба + модуль видеолары (сатып алынса ашық).
class VideoCourseScreen extends ConsumerStatefulWidget {
  const VideoCourseScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<VideoCourseScreen> createState() => _VideoCourseScreenState();
}

class _VideoCourseScreenState extends ConsumerState<VideoCourseScreen> {
  YoutubePlayerController? _yt;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // BI: курс қаралды (view_course) — конверсия view→purchase үшін.
    ref.read(apiServiceProvider).track('view_course', entityType: 'course', entityId: widget.courseId);
  }

  void _ensurePlayer(String? videoId) {
    if (videoId == null) return;
    if (_yt == null) {
      _yt = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(showControls: true, showFullscreenButton: true),
      );
    } else {
      _yt!.loadVideoById(videoId: videoId);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _yt?.close();
    super.dispose();
  }

  Future<void> _buy(VideoCourse c, AppLocalizations l) async {
    final balance = ref.read(profileControllerProvider).bonusBalance;
    if (balance < c.priceBonus) {
      await showTopUpBonusSheet(context, suggested: c.priceBonus);
      return;
    }
    setState(() => _busy = true);
    ref.read(purchasedCoursesProvider.notifier).unlock(c.id);
    ref.read(apiServiceProvider).purchaseCourse(c.id, c.priceBonus).catchError((_) {});
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(videoCourseByIdProvider(widget.courseId));
    final course = async.valueOrNull;
    // Ақылы курс мазмұнын экран жазудан/скриншоттан қорғау.
    return SecureScreen(
      child: Scaffold(
        appBar: AppBar(title: Text(course?.title ?? '')),
        body: course == null
            ? Center(child: async.isLoading ? const CircularProgressIndicator() : Text(l.common_error))
            : _body(course, l),
      ),
    );
  }

  Widget _body(VideoCourse c, AppLocalizations l) {
    final unlocked = c.isFree || ref.watch(purchasedCoursesProvider).contains(c.id);
    // Алғашқы видео — intro (немесе бірінші сабақ).
    final firstVideo = c.introVideoId ?? (c.allLessons.isNotEmpty ? c.allLessons.first.videoId : null);
    if (_yt == null && firstVideo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePlayer(firstVideo));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // Плеер немесе мұқаба
        if (_yt != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: YoutubePlayer(controller: _yt!, aspectRatio: 16 / 9),
          )
        else if (c.coverImageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: c.coverImageUrl!,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              memCacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
            ),
          ),
        const SizedBox(height: 14),
        Text(c.title, style: AppTypography.h1()),
        if (c.subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(c.subtitle, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
        ],
        if (c.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(c.description, style: AppTypography.bodyMedium()),
        ],
        const SizedBox(height: 8),
        if (c.introVideoId != null)
          Row(children: [
            const Icon(Icons.play_circle_outline, size: 16, color: AppColors.profitGreen),
            const SizedBox(width: 6),
            Text(l.signals_free_badge, style: AppTypography.label(color: AppColors.profitGreen)),
            const SizedBox(width: 6),
            Text('· intro', style: AppTypography.label(color: AppColors.textSecondary)),
          ]),
        const SizedBox(height: 16),

        // Сатып алу CTA
        if (!unlocked)
          ElevatedButton.icon(
            onPressed: _busy ? null : () => _buy(c, l),
            icon: const Icon(Icons.lock_open, size: 18),
            label: Text('${l.signals_unlock_for(c.priceBonus)} · ${l.academy_premium_badge}'),
          ),
        const SizedBox(height: 16),

        // Жалаң курс (модульсіз): бір атаусыз модуль → модуль тақырыбын көрсетпей,
        // тек сабақтарды тегіс тізіммен береміз. Әйтпесе модуль секциялары (M1, M2…).
        if (_isFlat(c)) ...[
          Text(l.course_lessons_count(c.lessonCount), style: AppTypography.h2()),
          const SizedBox(height: 10),
          for (final lesson in c.allLessons)
            _LessonTile(
              lesson: lesson,
              unlocked: unlocked,
              onPlay: () => _ensurePlayer(lesson.videoId),
              onBuy: () => _buy(c, l),
            ),
        ] else ...[
          Text(l.course_modules_count(c.modules.length), style: AppTypography.h2()),
          const SizedBox(height: 10),
          for (var mi = 0; mi < c.modules.length; mi++) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text('M${mi + 1}',
                        style: AppTypography.label(color: AppColors.gold).copyWith(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.modules[mi].title.isEmpty ? '—' : c.modules[mi].title,
                      style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            for (final lesson in c.modules[mi].lessons)
              _LessonTile(
                lesson: lesson,
                unlocked: unlocked,
                onPlay: () => _ensurePlayer(lesson.videoId),
                onBuy: () => _buy(c, l),
              ),
          ],
        ],
      ],
    );
  }

  /// Жалаң курс: модуль жоқ немесе жалғыз атаусыз модуль (90% курс осылай).
  bool _isFlat(VideoCourse c) =>
      c.modules.length <= 1 && (c.modules.isEmpty || c.modules.first.title.trim().isEmpty);
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.unlocked,
    required this.onPlay,
    required this.onBuy,
  });
  final VideoLesson lesson;
  final bool unlocked;
  final VoidCallback onPlay;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final hasVideo = lesson.videoId != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(unlocked ? Icons.play_circle_outline : Icons.lock_outline,
                  size: 18, color: unlocked ? AppColors.gold : AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(lesson.title.isEmpty ? '—' : lesson.title,
                    style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700)),
              ),
              if (hasVideo)
                IconButton(
                  onPressed: unlocked ? onPlay : onBuy,
                  icon: Icon(unlocked ? Icons.play_circle_fill : Icons.lock,
                      color: unlocked ? AppColors.gold : AppColors.textMuted, size: 28),
                ),
            ],
          ),
          if (lesson.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(lesson.text,
                maxLines: unlocked ? null : 2,
                overflow: unlocked ? null : TextOverflow.ellipsis,
                style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
