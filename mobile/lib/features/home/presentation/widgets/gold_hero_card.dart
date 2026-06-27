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
    final live = async.value;

    // ТЕК шынайы баға көрсетеміз: live, әйтпесе ЖАҚЫНДА (≤15 мин) кэштелген баға.
    // Ескі кэш пен мок fallback КӨРСЕТІЛМЕЙДІ — оның орнына loading күйі.
    LiveQuote? fresh(String sym) {
      if (live != null && live.containsKey(sym)) return live[sym];
      final q = cached[sym];
      if (q == null) return null;
      return DateTime.now().difference(q.timestamp).inMinutes <= 15 ? q : null;
    }

    final gold = fresh('XAU/USD');
    final dxy = fresh('DXY');
    final isLive = live != null && live.containsKey('XAU/USD');
    final color = (gold?.deltaAbs ?? 0) >= 0 ? AppColors.profitGreen : AppColors.lossRed;

    // Live sparkline: ≥3 нүкте жиналғанда ғана (мок sparkline көрсетпейміз).
    final liveSpark = history['XAU/USD'];

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
                if (dxy != null)
                  Text('DXY ${Fmt.price(dxy.price)}',
                      style: AppTypography.bodySmall(color: AppColors.dxyBlue)),
              ],
            ),
            const SizedBox(height: 12),
            if (gold != null) ...[
              Text(Fmt.price(gold.price),
                  style: AppTypography.price(size: 36, weight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(gold.deltaAbs >= 0 ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(
                    '${Fmt.price(gold.deltaAbs.abs())}  ${Fmt.pct(gold.deltaPct)}',
                    style: AppTypography.price(size: 14, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (liveSpark != null && liveSpark.length >= 3)
                Sparkline(values: liveSpark, color: AppColors.gold, height: 56)
              else
                const SizedBox(height: 56),
            ] else
              // Мок/ескі баға көрсетпейміз — тек шынайы баға келгенше loading.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                    ),
                    const SizedBox(width: 12),
                    Text('Тікелей баға жүктелуде…',
                        style: AppTypography.bodyMedium(color: AppColors.textMuted)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
