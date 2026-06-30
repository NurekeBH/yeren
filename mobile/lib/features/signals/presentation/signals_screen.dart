import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/signal_providers_fixtures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/premium.dart';
import '../../profile/application/profile_controller.dart';
import '../data/signals_repository.dart';
import 'provider_card.dart';
import 'publish_signal_sheet.dart';
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
    final isTrader = ref.watch(profileControllerProvider).isVerifiedTrader;

    Future<void> onRefresh() async {
      ref.invalidate(signalProvidersProvider);
      ref.invalidate(signalsListProvider);
      await ref.read(signalsListProvider.future);
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: isTrader
            ? FloatingActionButton.extended(
                onPressed: () => showPublishSignalSheet(context),
                icon: const Icon(Icons.add),
                label: Text(l.signals_publish),
              )
            : null,
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
          loading: () => const _SignalsSkeleton(),
          error: (e, _) => ErrorRetryView(error: e, onRetry: () => ref.invalidate(signalsListProvider)),
          data: (all) {
            final active = all.where((s) => s.status == SignalStatus.active).toList();
            final closed = all.where((s) => s.status != SignalStatus.active).toList();
            return TabBarView(
              children: [
                _SignalsList(items: active, l: l, icon: Icons.bolt_outlined, onRefresh: onRefresh),
                _SignalsList(items: closed, l: l, icon: Icons.history, onRefresh: onRefresh),
                RefreshIndicator(
                  onRefresh: onRefresh,
                  child: providers.isEmpty
                      ? _PullableEmpty(icon: Icons.groups_outlined, label: l.signals_empty)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                          itemCount: providers.length,
                          itemBuilder: (_, i) => ProviderCard(provider: providers[i]),
                        ),
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
  const _SignalsList({required this.items, required this.l, required this.icon, required this.onRefresh});

  final List<Signal> items;
  final AppLocalizations l;
  final IconData icon;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? _PullableEmpty(icon: icon, label: l.signals_empty)
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: items.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) return _DisclaimerBanner(l: l);
                return SignalCard(signal: items[i - 1]);
              },
            ),
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

/// Бос күй — иконка + хабар. Scroll-мүмкін (AlwaysScrollable) болғандықтан
/// бос табта да төмен тартып жаңартуға (pull-to-refresh) болады.
class _PullableEmpty extends StatelessWidget {
  const _PullableEmpty({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(
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
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer-скелетон вместо спиннера при загрузке списка идей (премиум-ощущение).
class _SignalsSkeleton extends StatelessWidget {
  const _SignalsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: 5,
      itemBuilder: (_, _) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(children: [
              SkeletonBox(width: 44, height: 44, radius: 22),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SkeletonBox(width: 140, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 90, height: 11),
              ])),
            ]),
            SizedBox(height: 16),
            SkeletonBox(height: 12),
            SizedBox(height: 8),
            SkeletonBox(width: 220, height: 12),
          ],
        ),
      ),
    );
  }
}
