import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/gallup.dart';
import '../../../shared/models/library_item.dart';
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
  }

  @override
  void dispose() {
    _yt?.close();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!ok) {
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(url)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(libraryItemsProvider);
    final matches = items.where((x) => x.id == widget.itemId);

    return Scaffold(
      appBar: AppBar(),
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
            if (item.lang != null) LangChip(lang: item.lang!, onCover: false),
            if (item.profile != null)
              _Chip(text: '${item.profile!.emoji} ${_profileLabel(item.profile!, l)}', color: AppColors.gold),
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

        Text(l.library_summary, style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text(item.summary, style: AppTypography.bodyMedium().copyWith(height: 1.5)),
        const SizedBox(height: 26),

        if (item.externalUrl != null)
          SizedBox(
            width: double.infinity,
            child: item.isPodcast
                ? ElevatedButton.icon(
                    onPressed: () => _open(item.externalUrl!),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(l.library_open_youtube),
                  )
                : OutlinedButton.icon(
                    onPressed: () => _open(item.externalUrl!),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(l.academy_open_source),
                  ),
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
