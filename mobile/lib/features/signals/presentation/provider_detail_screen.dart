import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/signal_providers_fixtures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/widgets/error_view.dart';
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
    final mine = signalsAsync.valueOrNull?.where((s) => s.providerId == providerId).toList() ?? const [];
    final active = mine.where((s) => s.status == SignalStatus.active).toList();
    final past = mine.where((s) => s.status != SignalStatus.active).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final loading = signalsAsync.isLoading;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(provider.name)),
        body: Column(
          children: [
            // ── Тұрақты тақырып: провайдер картасы + bio ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProviderCard(provider: provider, tappable: false),
                  if (provider.bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(provider.bio, style: AppTypography.bodySmall(color: AppColors.textSecondary).copyWith(height: 1.4)),
                  ],
                ],
              ),
            ),
            TabBar(
              tabs: [
                Tab(text: l.prov_tab_active),
                Tab(text: l.prov_tab_past),
                Tab(text: l.prov_tab_posts),
              ],
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        // 1) Белсенді идеялар
                        _TabList(
                          empty: active.isEmpty,
                          emptyLabel: l.signals_empty,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                            children: [for (final s in active) SignalCard(signal: s)],
                          ),
                        ),
                        // 2) Өткен сигналдар (track record)
                        _TabList(
                          empty: past.isEmpty,
                          emptyLabel: l.prov_no_past_signals,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                            children: [
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
                          ),
                        ),
                        // 3) Посттар (Published Ideas)
                        ref.watch(traderPostsProvider(providerId)).when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, _) => ErrorRetryView(error: e, onRetry: () => ref.invalidate(traderPostsProvider(providerId))),
                              data: (posts) => _TabList(
                                empty: posts.isEmpty,
                                emptyLabel: l.posts_empty,
                                child: ListView(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                                  children: [for (final p in posts) TraderPostCard(post: p, provider: provider)],
                                ),
                              ),
                            ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Қойынды мазмұны — бос болса орталықтанған хабар, болмаса берілген тізім.
class _TabList extends StatelessWidget {
  const _TabList({required this.empty, required this.emptyLabel, required this.child});
  final bool empty;
  final String emptyLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (empty) {
      return Center(child: Text(emptyLabel, style: AppTypography.bodyMedium(color: AppColors.textSecondary)));
    }
    return child;
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
