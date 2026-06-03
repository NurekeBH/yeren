import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/models/signal.dart';
import '../../../../shared/utils/formatters.dart';

class ActiveSignalPreview extends StatelessWidget {
  const ActiveSignalPreview({super.key, required this.signal});

  final Signal signal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isBuy = signal.direction == SignalDirection.buy;
    final color = isBuy ? AppColors.profitGreen : AppColors.lossRed;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/signals/${signal.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.gold, size: 18),
                  const SizedBox(width: 6),
                  Text(l.home_active_signal_preview, style: AppTypography.label(color: AppColors.gold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isBuy ? l.signals_direction_buy : l.signals_direction_sell,
                      style: AppTypography.label(color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(signal.pair, style: AppTypography.h2()),
              const SizedBox(height: 6),
              Text(
                '${l.signals_entry_zone}: ${Fmt.price(signal.entryFrom)}–${Fmt.price(signal.entryTo)}',
                style: AppTypography.price(size: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Pill(label: 'TP1', value: Fmt.price(signal.tp1), color: AppColors.profitGreen),
                  const SizedBox(width: 6),
                  _Pill(label: 'SL', value: Fmt.price(signal.sl), color: AppColors.lossRed),
                  const SizedBox(width: 6),
                  _Pill(label: 'RR', value: '1:${signal.rr.toStringAsFixed(1)}', color: AppColors.gold),
                  const Spacer(),
                  Text('${signal.confidence}%', style: AppTypography.price(size: 14, color: AppColors.gold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('$label $value', style: AppTypography.label(color: color)),
    );
  }
}
