import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
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
  late final TabController _tabs = TabController(length: 3, vsync: this)
    ..addListener(_onTab);
  String? _topic; // таңдалған категория (topic) — null = бәрі
  double _minRating = 0; // ★ фильтр (0 = бәрі)
  int _yearBand = 0; // 0=бәрі, 1=2020+, 2=2010+, 3=2000+, 4=<2000
  String? _lang; // подкаст тілі: null=бәрі, 'EN', 'RU'

  void _onTab() {
    // Қойынды ауысқанда категория сүзгісін тазалаймыз (топиктер әртүрлі).
    if (_tabs.indexIsChanging) {
      setState(() {
        _topic = null;
        _lang = null;
      });
    }
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTab);
    _tabs.dispose();
    super.dispose();
  }

  bool _yearOk(int? y) {
    if (_yearBand == 0) return true;
    final yr = y ?? 0;
    return switch (_yearBand) {
      1 => yr >= 2020,
      2 => yr >= 2010,
      3 => yr >= 2000,
      4 => yr != 0 && yr < 2000,
      _ => true,
    };
  }

  /// Рейтинг/жыл фильтрі + категория бойынша топтап сұрыптау (ішінде рейтинг ↓).
  List<LibraryItem> _apply(List<LibraryItem> items) {
    final r = items.where((x) {
      if (_topic != null && x.topic != _topic) return false;
      if (_minRating > 0 && (x.rating ?? 0) < _minRating) return false;
      if (!_yearOk(x.year)) return false;
      if (_lang != null && x.lang != _lang) return false;
      return true;
    }).toList();
    r.sort((a, b) {
      final t = (a.topic ?? '').compareTo(b.topic ?? '');
      if (t != 0) return t;
      return (b.rating ?? 0).compareTo(a.rating ?? 0);
    });
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final byCat = ref.watch(libraryByCategoryProvider);
    const cats = [LibraryCategory.book, LibraryCategory.film, LibraryCategory.podcast];
    final curCat = cats[_tabs.index.clamp(0, 2)];
    final topics = ((byCat[curCat] ?? const <LibraryItem>[])
        .map((x) => x.topic)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort());

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
          const _CoursesBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Категория (topic) — dropdown
                  if (topics.isNotEmpty) ...[
                    _TopicDropdown(
                      topics: topics,
                      selected: _topic,
                      allLabel: l.academy_filter_all,
                      onSelect: (t) => setState(() => _topic = t),
                    ),
                    const SizedBox(width: 8),
                    _Divider(),
                    const SizedBox(width: 8),
                  ],
                  // Рейтинг фильтрі
                  _FilterChip(label: l.academy_filter_all, selected: _minRating == 0, color: AppColors.gold, onTap: () => setState(() => _minRating = 0)),
                  const SizedBox(width: 8),
                  _FilterChip(label: '★ 4.0+', selected: _minRating == 4.0, color: AppColors.gold, onTap: () => setState(() => _minRating = 4.0)),
                  const SizedBox(width: 8),
                  _FilterChip(label: '★ 4.5+', selected: _minRating == 4.5, color: AppColors.gold, onTap: () => setState(() => _minRating = 4.5)),
                  const SizedBox(width: 8),
                  _Divider(),
                  const SizedBox(width: 8),
                  // Жыл фильтрі
                  for (final (band, lbl) in const [(1, '2020+'), (2, '2010+'), (3, '2000+'), (4, '<2000')]) ...[
                    _FilterChip(label: lbl, selected: _yearBand == band, color: AppColors.dxyBlue, onTap: () => setState(() => _yearBand = _yearBand == band ? 0 : band)),
                    const SizedBox(width: 8),
                  ],
                  // Тіл фильтрі — тек подкаст табында (видеолар EN/RU).
                  if (curCat == LibraryCategory.podcast) ...[
                    _Divider(),
                    const SizedBox(width: 8),
                    for (final lng in const ['EN', 'RU']) ...[
                      _FilterChip(label: lng == 'EN' ? '🇬🇧 EN' : '🇷🇺 RU', selected: _lang == lng, color: AppColors.profitGreen, onTap: () => setState(() => _lang = _lang == lng ? null : lng)),
                      const SizedBox(width: 8),
                    ],
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _CoverGrid(items: _apply(byCat[LibraryCategory.book] ?? const []), l: l),
                _CoverGrid(items: _apply(byCat[LibraryCategory.film] ?? const []), l: l),
                _CoverGrid(items: _apply(byCat[LibraryCategory.podcast] ?? const []), l: l),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Edge Academy табындағы премиум-курстарға кіру баннері.
class _CoursesBanner extends StatelessWidget {
  const _CoursesBanner();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: GestureDetector(
        onTap: () => GoRouter.of(context).push('/academy/courses'),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gold, AppColors.goldBright],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🎓', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l.academy_cta_title,
                        style: AppTypography.h2(color: Colors.white).copyWith(fontWeight: FontWeight.w800)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(l.academy_premium_badge,
                        style: AppTypography.label(color: Colors.white).copyWith(fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(l.academy_cta_sub,
                  style: AppTypography.bodySmall(color: Colors.white).copyWith(height: 1.35)),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(l.academy_cta_button,
                    style: AppTypography.button(color: AppColors.gold).copyWith(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverGrid extends StatefulWidget {
  const _CoverGrid({required this.items, required this.l});

  final List<LibraryItem> items;
  final AppLocalizations l;

  @override
  State<_CoverGrid> createState() => _CoverGridState();
}

class _CoverGridState extends State<_CoverGrid> {
  final _sc = ScrollController();
  bool _showTop = false;

  @override
  void initState() {
    super.initState();
    _sc.addListener(() {
      final show = _sc.hasClients && _sc.offset > 600;
      if (show != _showTop) setState(() => _showTop = show);
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(child: Text(widget.l.calendar_empty, style: AppTypography.bodyMedium()));
    }
    return Stack(
      children: [
        GridView.builder(
          controller: _sc,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.60,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
          ),
          itemCount: widget.items.length,
          itemBuilder: (_, i) => _CoverCard(item: widget.items[i], l: widget.l),
        ),
        // Жоғарыға қайту батырмасы — төмен скролл болғанда көрінеді.
        Positioned(
          right: 16,
          bottom: 16,
          child: AnimatedScale(
            scale: _showTop ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: FloatingActionButton.small(
              heroTag: null,
              onPressed: () => _sc.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOut),
              child: const Icon(Icons.keyboard_arrow_up),
            ),
          ),
        ),
      ],
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

/// Сүзгілер арасындағы тік бөлгіш.
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 22, color: AppColors.border);
}

/// Категория (topic) таңдау dropdown-ы.
class _TopicDropdown extends StatelessWidget {
  const _TopicDropdown({
    required this.topics,
    required this.selected,
    required this.allLabel,
    required this.onSelect,
  });

  final List<String> topics;
  final String? selected;
  final String allLabel;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final active = selected != null;
    return PopupMenuButton<String?>(
      onSelected: onSelect,
      itemBuilder: (_) => [
        PopupMenuItem<String?>(value: null, child: Text(allLabel)),
        for (final t in topics) PopupMenuItem<String?>(value: t, child: Text(t)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.purple.withValues(alpha: 0.14) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.purple : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined, size: 14, color: active ? AppColors.purple : AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(selected ?? allLabel,
                style: AppTypography.label(color: active ? AppColors.purple : AppColors.textSecondary)
                    .copyWith(fontWeight: FontWeight.w600)),
            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
