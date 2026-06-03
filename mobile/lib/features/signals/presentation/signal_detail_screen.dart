import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/utils/formatters.dart';
import '../../alerts/presentation/create_alert_sheet.dart';
import '../data/signals_repository.dart';

class SignalDetailScreen extends ConsumerWidget {
  const SignalDetailScreen({super.key, required this.signalId});

  final String signalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(signalByIdProvider(signalId));

    return Scaffold(
      appBar: AppBar(),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.common_error}: $e')),
        data: (signal) {
          if (signal == null) return Center(child: Text(l.signals_empty));
          return _Body(signal: signal, l: l);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.signal, required this.l});

  final Signal signal;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final isBuy = signal.direction == SignalDirection.buy;
    final dirColor = isBuy ? AppColors.profitGreen : AppColors.lossRed;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: dirColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isBuy ? l.signals_direction_buy : l.signals_direction_sell,
                style: AppTypography.button(color: dirColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(signal.pair, style: AppTypography.h1()),
          ],
        ),
        const SizedBox(height: 16),
        // Скриншот placeholder
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.midnight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.candlestick_chart, color: AppColors.gold, size: 48),
                SizedBox(height: 8),
                Text('Chart screenshot', style: TextStyle(color: Colors.white54)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _Row(label: l.signals_entry_zone, value: '${Fmt.price(signal.entryFrom)} – ${Fmt.price(signal.entryTo)}'),
                const Divider(height: 24),
                _Row(label: l.signals_tp1, value: Fmt.price(signal.tp1), color: AppColors.profitGreen),
                _Row(label: l.signals_tp2, value: Fmt.price(signal.tp2), color: AppColors.profitGreen),
                _Row(label: l.signals_tp3, value: Fmt.price(signal.tp3), color: AppColors.profitGreen),
                const Divider(height: 24),
                _Row(label: l.signals_sl, value: Fmt.price(signal.sl), color: AppColors.lossRed),
                const Divider(height: 24),
                _Row(label: l.signals_rr, value: '1 : ${signal.rr.toStringAsFixed(2)}'),
                _Row(label: l.signals_confidence, value: '${signal.confidence}%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.signals_analysis, style: AppTypography.label(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text(signal.analysis, style: AppTypography.bodyMedium()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, _) => SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showCreateAlertSheet(
                context,
                ref,
                instrument: signal.pair,
                refPrice: signal.entryMid,
                ideaId: signal.id,
                defaultText: l.alerts_default_idea(signal.pair),
              ),
              icon: const Icon(Icons.notifications_active, size: 18),
              label: Text(l.alerts_notify),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l.idea_disclaimer,
          style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 10, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMedium(color: AppColors.textSecondary))),
          Text(value, style: AppTypography.price(size: 16, weight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
