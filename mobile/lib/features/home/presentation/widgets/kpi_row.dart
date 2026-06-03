import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/models/kpi.dart';
import '../../../../shared/utils/formatters.dart';

class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.kpi});

  final KpiSnapshot kpi;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: _KpiCard(label: l.home_kpi_win_rate, value: '${(kpi.winRate * 100).toStringAsFixed(0)}%', color: AppColors.profitGreen)),
        const SizedBox(width: 8),
        Expanded(child: _KpiCard(label: l.home_kpi_net_pnl, value: Fmt.money(kpi.netPnl), color: kpi.netPnl >= 0 ? AppColors.profitGreen : AppColors.lossRed)),
        const SizedBox(width: 8),
        Expanded(child: _KpiCard(label: l.home_kpi_active_signals, value: '${kpi.activeSignals}', color: AppColors.gold)),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.label(color: AppColors.textSecondary).copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: AppTypography.price(size: 14, weight: FontWeight.w700, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
