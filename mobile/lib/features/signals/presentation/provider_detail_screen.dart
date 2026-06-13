import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/signal_providers_fixtures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
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
          ref.watch(traderPostsProvider(providerId)).when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('${l.common_error}: $e', style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                ),
                data: (posts) => posts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(l.posts_empty, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                      )
                    : Column(
                        children: [for (final p in posts) TraderPostCard(post: p, provider: provider)],
                      ),
              ),
          const SizedBox(height: 24),

          signalsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('${l.common_error}: $e'),
            data: (all) {
              final mine = all.where((s) => s.providerId == providerId).toList();
              final active = mine.where((s) => s.status == SignalStatus.active).toList();
              final past = mine.where((s) => s.status != SignalStatus.active).toList()
                ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Белсенді идеялар (ашық/ақылы — SignalCard paywall логикасымен) ──
                  Text(l.prov_active_ideas, style: AppTypography.h2()),
                  const SizedBox(height: 8),
                  if (active.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(l.signals_empty, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                    )
                  else
                    for (final s in active) SignalCard(signal: s),
                  const SizedBox(height: 24),

                  // ── Өткен сигналдар (track record) — нәтижесі ашық көрсетіледі ──
                  Text(l.prov_past_signals, style: AppTypography.h2()),
                  const SizedBox(height: 8),
                  if (past.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(l.prov_no_past_signals, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Column(
                          children: [
                            for (var i = 0; i < past.length; i++) ...[
                              if (i > 0) const Divider(height: 1),
                              _PastSignalRow(signal: past[i], l: l),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Өткен (жабылған) сигналдың track-record жолы: бағыт, жұп, нәтиже (TP1/TP2/TP3/SL) + пипс.
class _PastSignalRow extends StatelessWidget {
  const _PastSignalRow({required this.signal, required this.l});

  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final isBuy = signal.direction == SignalDirection.buy;
    final dirColor = isBuy ? AppColors.profitGreen : AppColors.lossRed;
    final (statusText, statusColor) = switch (signal.status) {
      SignalStatus.closedTp1 => (l.signals_status_tp1, AppColors.profitGreen),
      SignalStatus.closedTp2 => (l.signals_status_tp2, AppColors.profitGreen),
      SignalStatus.closedTp3 => (l.signals_status_tp3, AppColors.profitGreen),
      SignalStatus.closedSl => (l.signals_status_sl, AppColors.lossRed),
      SignalStatus.active => (l.signals_status_active, AppColors.gold),
    };
    final pips = signal.resultPips;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Бағыт
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: dirColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(isBuy ? l.signals_direction_buy : l.signals_direction_sell,
                style: AppTypography.label(color: dirColor).copyWith(fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Text(signal.pair, style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          // Нәтиже (TP1/TP2/TP3/SL) белгісі
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(statusText, style: AppTypography.label(color: statusColor).copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          if (pips != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 56,
              child: Text(
                l.signals_result_pips(pips),
                textAlign: TextAlign.right,
                style: AppTypography.price(size: 12, weight: FontWeight.w700,
                    color: pips >= 0 ? AppColors.profitGreen : AppColors.lossRed),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
