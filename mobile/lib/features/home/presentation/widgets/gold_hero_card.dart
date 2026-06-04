import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/live_quotes_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/kpi.dart';
import '../../../../shared/utils/formatters.dart';
import 'sparkline.dart';

class GoldHeroCard extends ConsumerWidget {
  const GoldHeroCard({super.key, required this.fallback});

  /// Fallback (offline/loading) — mock fixtures-тен GoldQuote.
  final GoldQuote fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(liveQuotesStreamProvider);
    final cached = ref.watch(cachedQuotesProvider);
    final history = ref.watch(liveHistoryProvider);
    // Алдымен live → сосын cached → мок fallback.
    final quotes = async.value ?? cached;

    final gold = quotes['XAU/USD'];
    final dxy = quotes['DXY'];

    final price = gold?.price ?? fallback.price;
    final deltaAbs = gold?.deltaAbs ?? fallback.deltaAbs;
    final deltaPct = gold?.deltaPct ?? fallback.deltaPct;
    final dxyPrice = dxy?.price ?? fallback.dxy;
    final isLive = async.value != null && async.value!.containsKey('XAU/USD');
    final color = deltaAbs >= 0 ? AppColors.profitGreen : AppColors.lossRed;

    // Live sparkline: ≥3 нүкте жиналса live history, әйтпесе fallback.
    final liveSpark = history['XAU/USD'];
    final sparkValues = (liveSpark != null && liveSpark.length >= 3) ? liveSpark : fallback.sparkline;

    return Card(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFDF8), Color(0xFFFBF1DC)], // жылы крем → әлсіз алтын реңк
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('XAU/USD', style: AppTypography.label(color: AppColors.gold)),
                ),
                const SizedBox(width: 8),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.profitGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.profitGreen, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('LIVE', style: AppTypography.label(color: AppColors.profitGreen)),
                      ],
                    ),
                  ),
                const Spacer(),
                Text('DXY ${Fmt.price(dxyPrice)}',
                    style: AppTypography.bodySmall(color: AppColors.dxyBlue)),
              ],
            ),
            const SizedBox(height: 12),
            Text(Fmt.price(price),
                style: AppTypography.price(size: 36, weight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(deltaAbs >= 0 ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  '${Fmt.price(deltaAbs.abs())}  ${Fmt.pct(deltaPct)}',
                  style: AppTypography.price(size: 14, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Sparkline(values: sparkValues, color: AppColors.gold, height: 56),
          ],
        ),
      ),
    );
  }
}
