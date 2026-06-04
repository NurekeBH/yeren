import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/signal_providers_fixtures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/trader_posts_controller.dart';
import '../data/signals_repository.dart';
import 'provider_card.dart';
import 'signal_card.dart';
import 'trader_post_card.dart';

class ProviderDetailScreen extends ConsumerWidget {
  const ProviderDetailScreen({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final providers = ref.watch(signalProvidersProvider).valueOrNull ?? const [];
    final matches = providers.where((p) => p.id == providerId);
    if (matches.isEmpty) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.common_error)));
    }
    final provider = matches.first;
    final signalsAsync = ref.watch(signalsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(provider.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          ProviderCard(provider: provider, tappable: false),
          const SizedBox(height: 8),
          if (provider.verified)
            Row(
              children: [
                const Icon(Icons.verified, size: 16, color: AppColors.dxyBlue),
                const SizedBox(width: 6),
                Text(l.prov_verified, style: AppTypography.label(color: AppColors.dxyBlue)),
              ],
            ),
          const SizedBox(height: 12),
          Text(provider.bio, style: AppTypography.bodyMedium().copyWith(height: 1.5)),
          const SizedBox(height: 24),

          // ── Published Ideas — трейдердің посттары (фото/мәтін/лайк/коммент) ──
          Text(l.posts_published, style: AppTypography.h2()),
          const SizedBox(height: 10),
          Builder(builder: (context) {
            final posts = ref.watch(traderPostsProvider(providerId));
            if (posts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l.posts_empty, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
              );
            }
            return Column(
              children: [for (final p in posts) TraderPostCard(post: p, provider: provider)],
            );
          }),
          const SizedBox(height: 24),

          Text(l.prov_ideas, style: AppTypography.h2()),
          const SizedBox(height: 8),
          signalsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('${l.common_error}: $e'),
            data: (all) {
              final ideas = all.where((s) => s.providerId == providerId).toList();
              if (ideas.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(l.signals_empty, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                );
              }
              return Column(children: [for (final s in ideas) SignalCard(signal: s)]);
            },
          ),
        ],
      ),
    );
  }
}
