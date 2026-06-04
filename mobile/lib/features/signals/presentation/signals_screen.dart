import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/signal_providers_fixtures.dart';
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
                _SignalsList(items: active, emptyLabel: l.signals_empty),
                _SignalsList(items: closed, emptyLabel: l.signals_empty),
                ListView(
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
  const _SignalsList({required this.items, required this.emptyLabel});

  final List<Signal> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(emptyLabel, style: AppTypography.bodyMedium()));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [for (final s in items) SignalCard(signal: s)],
    );
  }
}
