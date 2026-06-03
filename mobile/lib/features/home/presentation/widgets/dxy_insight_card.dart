import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';

/// TZ §6.2: DXY ±0.15%-тен жоғары қозғалса — баннер көрсету.
/// Баннер ішінде кіші әріппен логиканың қандай тиімділікке негізделгенін көрсету.
class DxyInsightCard extends StatelessWidget {
  const DxyInsightCard({super.key, required this.dxyDeltaPct});

  final double dxyDeltaPct;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (dxyDeltaPct.abs() < 0.15) return const SizedBox.shrink();

    final isBullishGold = dxyDeltaPct < 0;
    final color = isBullishGold ? AppColors.profitGreen : AppColors.lossRed;
    final text = isBullishGold ? l.home_dxy_bullish : l.home_dxy_bearish;
    final icon = isBullishGold ? Icons.trending_up : Icons.trending_down;
    final pctStr = (dxyDeltaPct >= 0 ? '+' : '') + dxyDeltaPct.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: AppTypography.bodyMedium(color: color)),
                const SizedBox(height: 2),
                Text(
                  l.home_dxy_logic(pctStr),
                  style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
