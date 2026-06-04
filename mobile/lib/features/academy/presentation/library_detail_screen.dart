import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/gallup.dart';
import '../../../shared/models/library_item.dart';
import '../application/library_saved_controller.dart';
import '../data/lessons_repository.dart';
import 'library_screen.dart' show RatingBadge;
import 'widgets/library_cover.dart';

/// Библиотека элементінің беті — жеке summary (тестсіз).
/// Подкаст болса, YouTube видеосы приложение ішінде ойнайды.
class LibraryDetailScreen extends ConsumerStatefulWidget {
  const LibraryDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<LibraryDetailScreen> createState() => _LibraryDetailScreenState();
}

class _LibraryDetailScreenState extends ConsumerState<LibraryDetailScreen> {
  YoutubePlayerController? _yt;
  final TextEditingController _review = TextEditingController();

  @override
  void initState() {
    super.initState();
    final items = ref.read(libraryItemsProvider);
    final matches = items.where((x) => x.id == widget.itemId);
    final yid = matches.isEmpty ? null : matches.first.youtubeId;
    if (yid != null) {
      _yt = YoutubePlayerController.fromVideoId(
        videoId: yid,
        autoPlay: false,
        params: const YoutubePlayerParams(showControls: true, showFullscreenButton: true),
      );
    }
    _review.text = ref.read(librarySavedProvider.notifier).entry(widget.itemId).review;
  }

  @override
  void dispose() {
    _yt?.close();
    _review.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(libraryItemsProvider);
    final matches = items.where((x) => x.id == widget.itemId);
    final saved = ref.watch(librarySavedProvider)[widget.itemId]?.saved ?? false;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l.lib_save,
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                color: saved ? AppColors.gold : null),
            onPressed: () => ref.read(librarySavedProvider.notifier).toggleSaved(widget.itemId),
          ),
        ],
      ),
      body: matches.isEmpty
          ? Center(child: Text(l.common_error, style: AppTypography.bodyMedium()))
          : _body(context, l, matches.first),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l, LibraryItem item) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // Мұқаба немесе подкаст плеері
        if (_yt != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: YoutubePlayer(controller: _yt!, aspectRatio: 16 / 9),
          )
        else
          Center(
            child: SizedBox(
              width: 168,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: LibraryCover(item: item, radius: 14),
              ),
            ),
          ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Chip(text: '${item.category.emoji} ${_categoryLabel(item.category, l)}', color: AppColors.purple),
            if (item.genre != null) _Chip(text: item.genre!, color: AppColors.gold),
            if (item.lang != null) LangChip(lang: item.lang!, onCover: false),
            if (item.profile != null)
              _Chip(text: '${item.profile!.emoji} ${_profileLabel(item.profile!, l)}', color: AppColors.dxyBlue),
          ],
        ),
        const SizedBox(height: 14),

        Text(item.title, style: AppTypography.display()),
        const SizedBox(height: 6),
        Text(
          item.year == null ? item.author : '${item.author} · ${item.year}',
          style: AppTypography.bodyMedium(color: AppColors.purple),
        ),
        const SizedBox(height: 12),
        RatingBadge(item: item),
        const SizedBox(height: 22),

        // ── Структурированный разбор: О чём / Основные идеи / Заключение ──
        _Section(
          title: item.ideas.isEmpty ? l.library_summary : l.library_about,
          child: Text(item.summary, style: AppTypography.bodyMedium().copyWith(height: 1.5)),
        ),
        if (item.ideas.isNotEmpty) ...[
          const SizedBox(height: 22),
          _Section(
            title: l.library_key_ideas,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final idea in item.ideas) _Bullet(text: idea)],
            ),
          ),
        ],
        if (item.conclusion != null) ...[
          const SizedBox(height: 22),
          _Section(
            title: l.library_conclusion,
            child: Text(
              item.conclusion!,
              style: AppTypography.bodyMedium(color: AppColors.gold).copyWith(height: 1.5, fontStyle: FontStyle.italic),
            ),
          ),
        ],
        const SizedBox(height: 26),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        Text(l.lib_your_rating, style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        _RatingStars(itemId: widget.itemId),
        const SizedBox(height: 18),
        Text(l.lib_your_review, style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text(l.lib_review_hint, style: AppTypography.bodySmall(color: AppColors.textMuted)),
        const SizedBox(height: 8),
        TextField(
          controller: _review,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(librarySavedProvider.notifier).setReview(widget.itemId, _review.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.lib_review_saved)));
            },
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(l.lib_save_review),
          ),
        ),
      ],
    );
  }
}

/// 5 жұлдызды баға — басып таңдауға болады.
class _RatingStars extends ConsumerWidget {
  const _RatingStars({required this.itemId});
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = ref.watch(librarySavedProvider)[itemId]?.rating ?? 0;
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: Icon(
              i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.gold,
              size: 30,
            ),
            onPressed: () => ref.read(librarySavedProvider.notifier)
                .setRating(itemId, rating == i ? 0 : i),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: AppTypography.label(color: color)),
    );
  }
}

/// Тақырыпша + мазмұн блогы (О чём / Основные идеи / Заключение).
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Негізгі идея тармағы (gold нүкте + мәтін).
class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 10),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: Text(text, style: AppTypography.bodyMedium().copyWith(height: 1.45)),
          ),
        ],
      ),
    );
  }
}

String _categoryLabel(LibraryCategory c, AppLocalizations l) {
  switch (c) {
    case LibraryCategory.book:
      return l.academy_category_books;
    case LibraryCategory.film:
      return l.academy_category_films;
    case LibraryCategory.podcast:
      return l.academy_category_podcasts;
  }
}

String _profileLabel(GallupProfile p, AppLocalizations l) {
  switch (p) {
    case GallupProfile.revenge:
      return l.gallup_profile_revenge;
    case GallupProfile.uncontrolledRisk:
      return l.gallup_profile_risk;
    case GallupProfile.hope:
      return l.gallup_profile_hope;
    case GallupProfile.disciplined:
      return l.gallup_profile_disciplined;
  }
}
