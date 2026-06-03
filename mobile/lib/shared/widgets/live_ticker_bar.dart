import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/live_quotes_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../utils/formatters.dart';

/// TZ §5: барлық main экрандарда тұратын тёмная полоса.
/// Stooq REST polling арқылы әр 15 секунд сайын жаңарады.
/// Алғашқы жүктемеде SharedPreferences-те сақталған соңғы quote көрсетіледі.
class LiveTickerBar extends ConsumerWidget {
  const LiveTickerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(liveQuotesStreamProvider);
    final cached = ref.watch(cachedQuotesProvider);
    // Live > cached, әйтпесе мок жоқ.
    final quotes = async.value ?? cached;

    Color color(String sym) => switch (sym) {
          'XAU/USD' => AppColors.goldBright,
          'DXY' => AppColors.dxyBlue,
          'XAG/USD' => AppColors.silverGray,
          'USOIL' => AppColors.oilRed,
          _ => AppColors.textMuted,
        };

    final isFirstLoad = async.isLoading && cached.isEmpty;

    return Container(
      color: AppColors.midnight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (isFirstLoad) ...[
            const SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.goldBright),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final sym in StooqLiveQuotesService.symbols.keys) ...[
                    _TickerItem(
                      symbol: sym,
                      quote: quotes[sym],
                      color: color(sym),
                      prominent: sym == 'XAU/USD',
                    ),
                    const SizedBox(width: 16),
                  ],
                ],
              ),
            ),
          ),
          if (async.hasError && cached.isEmpty)
            const Icon(Icons.cloud_off, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _TickerItem extends StatelessWidget {
  const _TickerItem({required this.symbol, required this.quote, required this.color, this.prominent = false});

  final String symbol;
  final LiveQuote? quote;
  final Color color;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(symbol, style: AppTypography.label(color: color)),
        const SizedBox(width: 6),
        if (quote == null)
          Text('…', style: AppTypography.ticker(color: Colors.white54))
        else ...[
          Text(
            Fmt.price(quote!.price),
            style: AppTypography.ticker(color: Colors.white).copyWith(
              fontWeight: prominent ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            Fmt.pct(quote!.deltaPct),
            style: AppTypography.ticker(color: quote!.isUp ? AppColors.profitGreen : AppColors.lossRed),
          ),
        ],
      ],
    );
  }
}
