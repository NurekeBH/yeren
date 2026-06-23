import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/intel_post.dart';
import '../../../shared/utils/formatters.dart';
import '../data/intel_repository.dart';

class IntelScreen extends ConsumerWidget {
  const IntelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(intelListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.nav_intel)),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async {
          ref.invalidate(intelListProvider);
          await ref.read(intelListProvider.future);
        },
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            // Жаңартуға (pull-to-refresh) мүмкіндік қалу үшін скроллды сақтаймыз.
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.35),
              Center(child: Text('${l.common_error}: $e')),
            ],
          ),
          data: (posts) => posts.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.28),
                    const Icon(Icons.travel_explore, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(l.intel_empty,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: posts.length,
                  itemBuilder: (_, i) => _IntelCard(post: posts[i], l: l),
                ),
        ),
      ),
    );
  }
}

class _IntelCard extends StatelessWidget {
  const _IntelCard({required this.post, required this.l});

  final IntelPost post;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final (impactText, color) = switch (post.impact) {
      GoldImpact.bullish => (l.intel_impact_bullish, AppColors.profitGreen),
      GoldImpact.bearish => (l.intel_impact_bearish, AppColors.lossRed),
      GoldImpact.neutral => (l.intel_impact_neutral, AppColors.textSecondary),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (post.isUrgent) ...[
                    const Icon(Icons.bolt, size: 16, color: AppColors.lossRed),
                    const SizedBox(width: 4),
                  ],
                  Text(post.source, style: AppTypography.label(color: AppColors.gold)),
                  const Spacer(),
                  Text(Fmt.relativeTime(post.publishedAt, context),
                      style: AppTypography.label(color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 8),
              Text(post.text, style: AppTypography.bodyMedium().copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(impactText, style: AppTypography.label(color: color)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'XAU ${post.xauMove >= 0 ? '+' : ''}${Fmt.price(post.xauMove)}',
                    style: AppTypography.price(
                      size: 13,
                      color: post.xauMove >= 0 ? AppColors.profitGreen : AppColors.lossRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(post.analysis, style: AppTypography.bodyMedium()),
              const SizedBox(height: 12),
              _SentimentBar(value: post.sentiment, l: l),
            ],
          ),
        ),
      ),
    );
  }
}

class _SentimentBar extends StatelessWidget {
  const _SentimentBar({required this.value, required this.l});

  final int value;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 100)) / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l.intel_bears, style: AppTypography.label(color: AppColors.lossRed)),
            const Spacer(),
            Text('${l.intel_sentiment} $value%', style: AppTypography.label(color: AppColors.textSecondary)),
            const Spacer(),
            Text(l.intel_bulls, style: AppTypography.label(color: AppColors.profitGreen)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(height: 8, color: AppColors.lossRed.withValues(alpha: 0.18)),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 8,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.lossRed, AppColors.profitGreen]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
