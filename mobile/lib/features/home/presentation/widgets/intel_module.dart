import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/models/intel_post.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../intel/data/intel_repository.dart';

/// Home-да Market Intel модулі: ең соңғы пост толық көрінеді.
/// Expand арқылы қалған посттар ашылады.
class IntelModule extends ConsumerStatefulWidget {
  const IntelModule({super.key});

  @override
  ConsumerState<IntelModule> createState() => _IntelModuleState();
}

class _IntelModuleState extends ConsumerState<IntelModule> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(intelListProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.lossRed, size: 18),
                const SizedBox(width: 6),
                Text(l.home_intel_module, style: AppTypography.label(color: AppColors.lossRed)),
                const Spacer(),
                IconButton(
                  tooltip: l.home_intel_open_full,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  onPressed: () => context.push('/intel'),
                ),
              ],
            ),
            async.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => Text('${l.common_error}: $e', style: AppTypography.bodySmall()),
              data: (posts) {
                if (posts.isEmpty) return const SizedBox.shrink();
                final sorted = [...posts]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
                final latest = sorted.first;
                final rest = sorted.skip(1).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IntelPostBlock(post: latest, l: l, compact: false),
                    if (rest.isNotEmpty) ...[
                      if (_expanded)
                        for (final p in rest) _IntelPostBlock(post: p, l: l, compact: true)
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+${rest.length}',
                            style: AppTypography.bodySmall(color: AppColors.textMuted),
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _expanded = !_expanded),
                          icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18),
                          label: Text(_expanded ? l.common_back : l.home_intel_expand,
                              style: AppTypography.bodySmall(color: AppColors.gold)),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IntelPostBlock extends StatelessWidget {
  const _IntelPostBlock({required this.post, required this.l, required this.compact});

  final IntelPost post;
  final AppLocalizations l;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (impactText, color) = switch (post.impact) {
      GoldImpact.bullish => (l.intel_impact_bullish, AppColors.profitGreen),
      GoldImpact.bearish => (l.intel_impact_bearish, AppColors.lossRed),
      GoldImpact.neutral => (l.intel_impact_neutral, AppColors.textSecondary),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (post.isUrgent) ...[
                const Icon(Icons.bolt, size: 14, color: AppColors.lossRed),
                const SizedBox(width: 4),
              ],
              Text(post.source, style: AppTypography.label(color: AppColors.gold)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                child: Text(impactText, style: AppTypography.label(color: color)),
              ),
              const SizedBox(width: 6),
              Text(
                'XAU ${post.xauMove >= 0 ? '+' : ''}${Fmt.price(post.xauMove)}',
                style: AppTypography.price(size: 11, color: post.xauMove >= 0 ? AppColors.profitGreen : AppColors.lossRed),
              ),
              const Spacer(),
              Text(Fmt.relativeTime(post.publishedAt, context),
                  style: AppTypography.label(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            post.text,
            style: AppTypography.bodySmall().copyWith(fontStyle: FontStyle.italic),
            maxLines: compact ? 2 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(post.analysis, style: AppTypography.bodySmall()),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: _Pill(label: l.intel_sentiment, value: '${post.sentiment}%', color: AppColors.gold),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(4)),
      child: Text('$label: $value', style: AppTypography.label(color: color)),
    );
  }
}
