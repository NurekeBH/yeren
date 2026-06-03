import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';

/// TZ §10.4: провайдер статистикасы (Win Rate, Profit Factor, орташа RR).
class ProviderStatsCard extends StatelessWidget {
  const ProviderStatsCard({super.key, required this.signals});

  final List<Signal> signals;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final closed = signals.where((s) => s.status.isClosed).toList();
    final wins = closed.where((s) => s.status.isWin).length;
    final losses = closed.length - wins;
    final winRate = closed.isEmpty ? 0.0 : wins / closed.length;

    final grossWin = closed.where((s) => s.status.isWin).fold<double>(0, (a, s) => a + (s.resultPips ?? 0));
    final grossLossPos = closed.where((s) => !s.status.isWin).fold<double>(0, (a, s) => a + (s.resultPips ?? 0).abs());
    final pf = grossLossPos == 0 ? double.infinity : grossWin / grossLossPos;

    final avgRr = signals.isEmpty ? 0.0 : signals.map((s) => s.rr).reduce((a, b) => a + b) / signals.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.signals_provider_stats, style: AppTypography.label(color: AppColors.gold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: l.signals_provider_win_rate,
                    value: '${(winRate * 100).toStringAsFixed(0)}%',
                    color: AppColors.profitGreen,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: l.signals_provider_profit_factor,
                    value: pf.isFinite ? pf.toStringAsFixed(2) : '∞',
                    color: AppColors.gold,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: l.signals_provider_avg_rr,
                    value: '1:${avgRr.toStringAsFixed(1)}',
                    color: AppColors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${closed.length}  •  W: $wins  •  L: $losses',
              style: AppTypography.bodySmall(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.price(size: 18, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}
