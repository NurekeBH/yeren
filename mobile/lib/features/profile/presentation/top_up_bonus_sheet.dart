import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/profile_controller.dart';

/// Бонус толтыру sheet-і — Kaspi Pay арқылы (1 бонус = 1 ₸).
/// Сәтті болса true қайтарады.
Future<bool> showTopUpBonusSheet(BuildContext context, {int suggested = 0}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.obsidian,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _TopUpSheet(suggested: suggested),
  );
  return ok ?? false;
}

const _packs = <int>[500, 1000, 2500, 5000];

class _TopUpSheet extends ConsumerStatefulWidget {
  const _TopUpSheet({required this.suggested});
  final int suggested;

  @override
  ConsumerState<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends ConsumerState<_TopUpSheet> {
  late int _amount;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Жетпеген сома болса — оны жабатын ең кіші пакетті таңдаймыз.
    _amount = _packs.firstWhere((p) => p >= widget.suggested, orElse: () => _packs.first);
  }

  Future<void> _pay(AppLocalizations l) async {
    setState(() => _busy = true);
    // Kaspi Pay имитациясы (mock). Remote режимде topUpBonus backend-ке тіркейді.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    ref.read(profileControllerProvider.notifier).topUpBonus(_amount);
    if (!mounted) return;
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.bonus_topup_success(_amount))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
              const Icon(Icons.add_card, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(l.bonus_topup_title, style: AppTypography.h2()),
            ],
          ),
          const SizedBox(height: 4),
          Text(l.bonus_topup_desc, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          // Пакеттер (1 бонус = 1 ₸)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: _packs.map((p) {
              final sel = p == _amount;
              return InkWell(
                onTap: () => setState(() => _amount = p),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: sel ? AppColors.gold.withValues(alpha: 0.12) : AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppColors.gold : AppColors.border, width: sel ? 1.5 : 1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.promo_bonus_amount(p),
                            style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700, color: sel ? AppColors.gold : AppColors.textPrimary)),
                        Text('$p ₸', style: AppTypography.label(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : () => _pay(l),
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.account_balance_wallet, size: 18),
              label: Text(_busy ? l.signals_paying : l.signals_pay_kaspi(_amount)),
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
