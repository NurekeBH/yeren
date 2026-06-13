import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/signal_providers_fixtures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../data/signals_repository.dart';
import 'provider_card.dart';
import 'signal_card.dart';

/// Ideas — сигнал провайдерлерінің агрегаторы.
/// Бірнеше трейдер идея береді; әрқайсының статистикасы (Win Rate, RR, рейтинг) бар.
class SignalsScreen extends ConsumerWidget {
  const SignalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(signalsListProvider);
    final providers = ref.watch(signalProvidersProvider).valueOrNull ?? const [];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.nav_signals),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(text: l.signals_tab_active),
              Tab(text: l.signals_tab_closed),
              Tab(text: l.providers_tab),
            ],
          ),
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l.common_error}: $e')),
          data: (all) {
            final active = all.where((s) => s.status == SignalStatus.active).toList();
            final closed = all.where((s) => s.status != SignalStatus.active).toList();
            return TabBarView(
              children: [
                _SignalsList(items: active, l: l, icon: Icons.bolt_outlined),
                _SignalsList(items: closed, l: l, icon: Icons.history),
                providers.isEmpty
                    ? _EmptyState(icon: Icons.groups_outlined, label: l.signals_empty)
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        children: [for (final p in providers) ProviderCard(provider: p)],
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SignalsList extends StatelessWidget {
  const _SignalsList({required this.items, required this.l, required this.icon});

  final List<Signal> items;
  final AppLocalizations l;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(icon: icon, label: l.signals_empty);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: items.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return _DisclaimerBanner(l: l);
        return SignalCard(signal: items[i - 1]);
      },
    );
  }
}

/// Тізімнің басындағы бір реттік дисклеймер (бұрын әр картада қайталанатын).
class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.idea_disclaimer,
              style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: 11, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Бос күй — иконка + хабар (жалаң мәтін орнына).
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.surfaceMuted, shape: BoxShape.circle),
            child: Icon(icon, size: 34, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Text(label, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
