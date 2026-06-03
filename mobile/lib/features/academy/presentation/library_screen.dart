import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/gallup.dart';
import '../../../shared/models/library_item.dart';
import '../data/lessons_repository.dart';
import 'widgets/library_cover.dart';

/// Библиотека — кітаптар/фильмдер/подкасттар каталогы (рейтингтерімен).
/// Ашқанда жеке summary көрсетіледі (тестсіз); подкаст приложение ішінде ойнайды.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  GallupProfile? _problemFilter;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<LibraryItem> _byCategory(List<LibraryItem> all, LibraryCategory c) =>
      all.where((x) => x.category == c).toList();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(libraryItemsProvider);
    final filtered = _problemFilter == null
        ? items
        : items.where((x) => x.profile == _problemFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.academy_library),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: '📖 ${l.academy_category_books}'),
            Tab(text: '🎬 ${l.academy_category_films}'),
            Tab(text: '▶️ ${l.academy_category_podcasts}'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: l.academy_filter_all,
                    selected: _problemFilter == null,
                    color: AppColors.textSecondary,
                    onTap: () => setState(() => _problemFilter = null),
                  ),
                  const SizedBox(width: 8),
                  for (final p in GallupProfile.values) ...[
                    _FilterChip(
                      label: '${p.emoji} ${_profileLabel(p, l)}',
                      selected: _problemFilter == p,
                      color: AppColors.purple,
                      onTap: () => setState(() => _problemFilter = p),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _CoverGrid(items: _byCategory(filtered, LibraryCategory.book), l: l),
                _CoverGrid(items: _byCategory(filtered, LibraryCategory.film), l: l),
                _CoverGrid(items: _byCategory(filtered, LibraryCategory.podcast), l: l),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverGrid extends StatelessWidget {
  const _CoverGrid({required this.items, required this.l});

  final List<LibraryItem> items;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(l.calendar_empty, style: AppTypography.bodyMedium()));
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 14,
        mainAxisSpacing: 18,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _CoverCard(item: items[i], l: l),
    );
  }
}

class _CoverCard extends StatelessWidget {
  const _CoverCard({required this.item, required this.l});

  final LibraryItem item;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/academy/library/${item.id}'),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: LibraryCover(item: item),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall().copyWith(fontWeight: FontWeight.w700, height: 1.2),
          ),
          const SizedBox(height: 2),
          Text(
            item.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          RatingBadge(item: item),
        ],
      ),
    );
  }
}

/// Рейтинг белгісі: кітап/фильм → ★ балл, подкаст → ▶ YouTube.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    if (item.isPodcast) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_fill, size: 14, color: Color(0xFFE53935)),
          const SizedBox(width: 4),
          Text('YouTube', style: AppTypography.label(color: AppColors.textSecondary)),
        ],
      );
    }
    final r = item.rating;
    if (r == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 15, color: AppColors.gold),
        const SizedBox(width: 3),
        Text(
          r.toStringAsFixed(item.ratingMax == 10 ? 1 : 2),
          style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          '/${item.ratingMax.toStringAsFixed(0)}',
          style: AppTypography.label(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.color, required this.onTap});

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Text(label, style: AppTypography.label(color: selected ? color : AppColors.textSecondary)),
      ),
    );
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
