import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/signal_providers_fixtures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/utils/formatters.dart';

class SignalCard extends ConsumerWidget {
  const SignalCard({super.key, required this.signal});

  final Signal signal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final isBuy = signal.direction == SignalDirection.buy;
    final dirColor = isBuy ? AppColors.profitGreen : AppColors.lossRed;
    final providerMatches = ref.watch(signalProvidersProvider).where((p) => p.id == signal.providerId);
    final provider = providerMatches.isEmpty ? null : providerMatches.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/signals/${signal.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider != null) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => GoRouter.of(context).push('/providers/${provider.id}'),
                    child: Row(
                      children: [
                        Text(provider.avatar, style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(provider.name,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label(color: AppColors.gold).copyWith(fontWeight: FontWeight.w700)),
                        ),
                        if (provider.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 13, color: AppColors.dxyBlue),
                        ],
                        const SizedBox(width: 2),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: dirColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBuy ? l.signals_direction_buy : l.signals_direction_sell,
                        style: AppTypography.label(color: dirColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(signal.pair, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    _StatusChip(status: signal.status, l: l),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _MiniStat(label: l.signals_entry_zone, value: '${Fmt.price(signal.entryFrom)}–${Fmt.price(signal.entryTo)}')),
                    Expanded(child: _MiniStat(label: l.signals_rr, value: '1:${signal.rr.toStringAsFixed(1)}')),
                    Expanded(child: _MiniStat(label: l.signals_confidence, value: '${signal.confidence}%')),
                  ],
                ),
                if (signal.resultPips != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l.signals_result_pips(signal.resultPips!),
                    style: AppTypography.price(
                      size: 14,
                      weight: FontWeight.w700,
                      color: signal.resultPips! >= 0 ? AppColors.profitGreen : AppColors.lossRed,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  l.idea_disclaimer,
                  style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 10, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.price(size: 13, weight: FontWeight.w600)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l});
  final SignalStatus status;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      SignalStatus.active => (l.signals_status_active, AppColors.gold),
      SignalStatus.closedTp1 => (l.signals_status_tp1, AppColors.profitGreen),
      SignalStatus.closedTp2 => (l.signals_status_tp2, AppColors.profitGreen),
      SignalStatus.closedTp3 => (l.signals_status_tp3, AppColors.profitGreen),
      SignalStatus.closedSl => (l.signals_status_sl, AppColors.lossRed),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: AppTypography.label(color: color)),
    );
  }
}
