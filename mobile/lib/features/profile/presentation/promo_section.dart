import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:math' as math;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/profile_controller.dart';
import '../application/promo_registry.dart';

/// Профильдегі промокод/бонус бөлімі:
/// • бонус балансы (промокодпен тіркелсе);
/// • трейдердің жеке промокоды (копиялау/бөлісу);
/// • промокод енгізу (әлі қолданбаған қолданушыға).
class PromoSection extends ConsumerWidget {
  const PromoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileControllerProvider);

    return Column(
      children: [
        // Бонус балансы
        if (p.bonusBalance > 0)
          Card(
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.14), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet, size: 18, color: AppColors.gold),
              ),
              title: Text(l.promo_bonus_balance, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(l.promo_bonus_balance_desc, style: AppTypography.bodySmall()),
              trailing: Text('${p.bonusBalance} ₸',
                  style: AppTypography.h2().copyWith(color: AppColors.gold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),

        // Трейдердің жеке промокоды
        if (p.isVerifiedTrader && p.promoCode.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.card_giftcard, size: 18, color: AppColors.profitGreen),
                      const SizedBox(width: 8),
                      Text(l.promo_my_code_title,
                          style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(l.promo_my_code_desc(kPromoBonusTg), style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(p.promoCode,
                              style: AppTypography.h2().copyWith(letterSpacing: 2, color: AppColors.textPrimary)),
                        ),
                      ),
                      IconButton(
                        tooltip: l.promo_copy,
                        icon: const Icon(Icons.copy, size: 20, color: AppColors.gold),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: p.promoCode));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.promo_copied)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Кодпен тіркелгендер саны — трейдер әрқашан көреді.
                  // Remote: backend санайды; mock: құрылғы-жергілікті тізілім.
                  Builder(builder: (_) {
                    final local = ref.watch(promoRegistryProvider)[p.promoCode.toUpperCase()] ?? 0;
                    final count = math.max(p.referralCount, local);
                    return Row(
                      children: [
                        const Icon(Icons.group_outlined, size: 16, color: AppColors.profitGreen),
                        const SizedBox(width: 6),
                        Text(l.promo_referrals(count),
                            style: AppTypography.bodySmall().copyWith(fontWeight: FontWeight.w600)),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

        // Промокод енгізу (әлі қолданбаған қолданушыға)
        if (p.referredBy == null || p.referredBy!.isEmpty)
          Card(
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.dxyBlue.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.redeem, size: 18, color: AppColors.dxyBlue),
              ),
              title: Text(l.promo_enter_title, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(l.promo_enter_desc(kPromoBonusTg), style: AppTypography.bodySmall()),
              trailing: const Icon(Icons.chevron_right, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: () => _showEnterPromoDialog(context, ref),
            ),
          ),
      ],
    );
  }
}

Future<void> _showEnterPromoDialog(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final controller = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(l.promo_enter_title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: l.promo_field_hint,
          prefixIcon: const Icon(Icons.card_giftcard, size: 18),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: Text(l.common_cancel),
        ),
        FilledButton(
          onPressed: () {
            final res = ref.read(profileControllerProvider.notifier).applyPromoCode(controller.text);
            Navigator.of(dialogCtx).pop();
            final msg = switch (res) {
              PromoResult.applied => l.promo_applied(kPromoBonusTg),
              PromoResult.alreadyUsed => l.promo_already_used,
              PromoResult.invalid => l.promo_invalid,
              PromoResult.ownCode => l.promo_own_code,
            };
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          },
          child: Text(l.promo_apply),
        ),
      ],
    ),
  );
}
