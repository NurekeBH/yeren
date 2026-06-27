import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/library_saved_controller.dart';
import '../data/lessons_repository.dart';
import 'library_screen.dart' show RatingBadge;
import 'widgets/library_cover.dart';

/// «Сохранённые» — пайдаланушы сақтаған кітап/фильм/подкастар.
class SavedLibraryScreen extends ConsumerWidget {
  const SavedLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final savedIds = ref.watch(librarySavedProvider.notifier).savedIds.toSet();
    final catalog = ref.watch(libraryCatalogProvider).valueOrNull ?? const [];
    final items = catalog.where((x) => savedIds.contains(x.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.profile_saved)),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmark_border, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(l.saved_empty,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 14,
                mainAxisSpacing: 18,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return GestureDetector(
                  onTap: () => GoRouter.of(context).push('/academy/library/${item.id}'),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: LibraryCover(item: item)),
                      const SizedBox(height: 8),
                      Text(item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall().copyWith(fontWeight: FontWeight.w700, height: 1.2)),
                      const SizedBox(height: 2),
                      Text(item.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.label(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      RatingBadge(item: item),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
