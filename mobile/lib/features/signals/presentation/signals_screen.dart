import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../data/signals_repository.dart';
import 'provider_stats_card.dart';
import 'signal_card.dart';

class SignalsScreen extends ConsumerWidget {
  const SignalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(signalsListProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.nav_signals),
          bottom: TabBar(
            tabs: [
              Tab(text: l.signals_tab_active),
              Tab(text: l.signals_tab_closed),
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
                _SignalsList(items: active, allForStats: all, emptyLabel: l.signals_empty),
                _SignalsList(items: closed, allForStats: all, emptyLabel: l.signals_empty),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SignalsList extends StatelessWidget {
  const _SignalsList({required this.items, required this.allForStats, required this.emptyLabel});

  final List<Signal> items;
  final List<Signal> allForStats;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        ProviderStatsCard(signals: allForStats),
        const SizedBox(height: 16),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text(emptyLabel, style: AppTypography.bodyMedium())),
          )
        else
          for (final s in items) SignalCard(signal: s),
      ],
    );
  }
}
