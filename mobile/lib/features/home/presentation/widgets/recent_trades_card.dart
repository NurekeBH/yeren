import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/models/signal.dart';
import '../../../../shared/models/trade.dart';
import '../../../../shared/utils/formatters.dart';

class RecentTradesCard extends StatelessWidget {
  const RecentTradesCard({super.key, required this.trades});

  final List<Trade> trades;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.home_recent_trades, style: AppTypography.h2()),
            const SizedBox(height: 8),
            for (final t in trades) _TradeRow(trade: t),
          ],
        ),
      ),
    );
  }
}

class _TradeRow extends StatelessWidget {
  const _TradeRow({required this.trade});

  final Trade trade;

  @override
  Widget build(BuildContext context) {
    final isBuy = trade.direction == SignalDirection.buy;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isBuy ? AppColors.profitGreen : AppColors.lossRed).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBuy ? Icons.arrow_upward : Icons.arrow_downward,
              size: 18,
              color: isBuy ? AppColors.profitGreen : AppColors.lossRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trade.instrument, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${Fmt.price(trade.openPrice)} → ${Fmt.price(trade.closePrice)}',
                  style: AppTypography.bodySmall(),
                ),
              ],
            ),
          ),
          Text(
            Fmt.money(trade.pnl),
            style: AppTypography.price(
              size: 14,
              weight: FontWeight.w700,
              color: trade.isWin ? AppColors.profitGreen : AppColors.lossRed,
            ),
          ),
        ],
      ),
    );
  }
}
