import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../profile/application/profile_controller.dart';
import '../application/signal_unlock_controller.dart';

/// Идеяны ашу (сатып алу) sheet-і. Kaspi Pay арқылы төлем → идея ашылады.
/// Сәтті аяқталса true қайтарады.
Future<bool> showUnlockSignalSheet(BuildContext context, WidgetRef ref, Signal signal) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.obsidian,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _UnlockSheet(signal: signal),
  );
  return ok ?? false;
}

class _UnlockSheet extends ConsumerStatefulWidget {
  const _UnlockSheet({required this.signal});
  final Signal signal;

  @override
  ConsumerState<_UnlockSheet> createState() => _UnlockSheetState();
}

class _UnlockSheetState extends ConsumerState<_UnlockSheet> {
  bool _paying = false;

  Future<void> _pay(AppLocalizations l, int bonusUsed) async {
    setState(() => _paying = true);
    try {
      // Kaspi Pay интеграциясы орнына — төлемді имитациялаймыз (mock).
      // Remote режимде unlock() backend-ке сатып алуды тіркейді.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      await ref.read(signalUnlockProvider.notifier).unlock(widget.signal.id);
      // Қолданылған бонусты баланстан шегереміз.
      if (bonusUsed > 0) ref.read(profileControllerProvider.notifier).spendBonus(bonusUsed);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.signals_unlock_success)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.common_error}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = widget.signal;
    final isBuy = s.direction == SignalDirection.buy;
    final dirColor = isBuy ? AppColors.profitGreen : AppColors.lossRed;
    // Бонус балансы бағаны азайтады (қалғаны Kaspi арқылы төленеді).
    final bonus = ref.watch(profileControllerProvider).bonusBalance;
    final price = s.priceTg;
    final bonusUsed = bonus.clamp(0, price);
    final payable = price - bonusUsed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.lock_open, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(l.signals_unlock_title, style: AppTypography.h2()),
            ],
          ),
          const SizedBox(height: 4),
          Text(l.signals_unlock_desc, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          // Идея қысқаша
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
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
                Text(s.pair, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(l.signals_tp_pips(s.tpPips.round()),
                    style: AppTypography.label(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Баға
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.signals_price_label, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
              Text(l.signals_price_tg(price),
                  style: AppTypography.bodyMedium(color: AppColors.textSecondary)
                      .copyWith(decoration: bonusUsed > 0 ? TextDecoration.lineThrough : null)),
            ],
          ),
          if (bonusUsed > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.promo_bonus_balance, style: AppTypography.bodyMedium(color: AppColors.profitGreen)),
                Text('− ${l.promo_bonus_amount(bonusUsed)}', style: AppTypography.bodyMedium(color: AppColors.profitGreen)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.signals_to_pay, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                Text(l.signals_price_tg(payable),
                    style: AppTypography.h2().copyWith(color: AppColors.gold)),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(l.signals_price_tg(payable),
                  style: AppTypography.h2().copyWith(color: AppColors.gold)),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _paying ? null : () => _pay(l, bonusUsed),
              icon: _paying
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.account_balance_wallet, size: 18),
              label: Text(_paying
                  ? l.signals_paying
                  : (payable > 0 ? l.signals_pay_kaspi(payable) : l.signals_unlock_with_bonus)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(l.signals_pay_secure,
                style: AppTypography.label(color: AppColors.textMuted).copyWith(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
