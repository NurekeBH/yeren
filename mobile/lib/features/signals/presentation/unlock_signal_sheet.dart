import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/presentation/top_up_bonus_sheet.dart';
import '../application/signal_unlock_controller.dart';

/// Идеяны ашу sheet-і. Идея бонус ұпайымен ашылады (баланстан шегеріледі).
/// Бонус жетпесе — досын шақырып табуды ұсынады. Сәтті болса true қайтарады.
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
  bool _busy = false;

  Future<void> _unlock(AppLocalizations l, int cost) async {
    setState(() => _busy = true);
    try {
      await ref.read(signalUnlockProvider.notifier).unlock(widget.signal.id);
      // Идея құнын бонус баланстан шегереміз.
      if (cost > 0) ref.read(profileControllerProvider.notifier).spendBonus(cost);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.signals_unlock_success)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
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

    final p = ref.watch(profileControllerProvider);
    final cost = s.priceTg; // идея құны — бонус ұпайымен
    final balance = p.bonusBalance;
    final canAfford = balance >= cost;
    final shortfall = (cost - balance).clamp(0, cost);

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
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
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
                  decoration: BoxDecoration(color: dirColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(isBuy ? l.signals_direction_buy : l.signals_direction_sell,
                      style: AppTypography.label(color: dirColor)),
                ),
                const SizedBox(width: 8),
                Text(s.pair, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(l.signals_tp_pips(s.tpPips.round()), style: AppTypography.label(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Баға (бонус)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.signals_price_label, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
              Text(l.promo_bonus_amount(cost), style: AppTypography.h2().copyWith(color: AppColors.gold)),
            ],
          ),
          const SizedBox(height: 8),
          // Баланс
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.signals_your_balance, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
              Text(l.promo_bonus_amount(balance),
                  style: AppTypography.bodyMedium(color: canAfford ? AppColors.profitGreen : AppColors.lossRed)
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),
          if (canAfford)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : () => _unlock(l, cost),
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.lock_open, size: 18),
                label: Text(_busy ? l.signals_paying : l.signals_unlock_for(cost)),
              ),
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lossRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lossRed.withValues(alpha: 0.25)),
              ),
              child: Text(l.signals_not_enough(shortfall),
                  style: AppTypography.bodySmall(color: AppColors.lossRed).copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            // Негізгі: Kaspi арқылы бонус толтыру (жетпеген сомаға жетеді).
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        final ok = await showTopUpBonusSheet(context, suggested: shortfall);
                        // Толтырғаннан кейін баланс жетсе — бірден ашамыз.
                        if (ok && mounted && ref.read(profileControllerProvider).bonusBalance >= cost) {
                          await _unlock(l, cost);
                        }
                      },
                icon: const Icon(Icons.add_card, size: 18),
                label: Text(l.bonus_topup),
              ),
            ),
            const SizedBox(height: 8),
            // Қосымша: досын шақырып тегін бонус табу.
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Share.share(l.promo_share_message(p.promoCode, kPromoBonusTg)),
                icon: const Icon(Icons.ios_share, size: 18),
                label: Text(l.promo_share),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
