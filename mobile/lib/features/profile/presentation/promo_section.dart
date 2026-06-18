import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/profile_controller.dart';
import '../application/promo_registry.dart';

/// Профиль басындағы бонус баланс картасы (UX: жоғарыда тұрады).
class PromoBalanceCard extends ConsumerWidget {
  const PromoBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileControllerProvider);
    if (p.bonusBalance <= 0) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.14), shape: BoxShape.circle),
          child: const Icon(Icons.account_balance_wallet, size: 19, color: AppColors.gold),
        ),
        title: Text(l.promo_bonus_balance, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(l.promo_bonus_balance_desc, style: AppTypography.bodySmall()),
        trailing: Text(l.promo_bonus_amount(p.bonusBalance),
            style: AppTypography.h2().copyWith(color: AppColors.gold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Промокод бөлімі: жеке код + бөлісу + қалай табу + енгізу.
class PromoSection extends ConsumerStatefulWidget {
  const PromoSection({super.key});

  @override
  ConsumerState<PromoSection> createState() => _PromoSectionState();
}

class _PromoSectionState extends ConsumerState<PromoSection> {
  @override
  void initState() {
    super.initState();
    // Профиль ашылғанда реферал табысын есептейміз (mock; remote-та backend санайды).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(profileControllerProvider.notifier).creditReferralEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileControllerProvider);

    return Column(
      children: [
        // Жеке промокод — әр қолданушыда болады (досын шақыру + бонус).
        if (p.promoCode.isNotEmpty)
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
                  Text(l.promo_my_code_desc(kPromoBonusTg),
                      style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  // Реферер табысы: әр тіркелуге +500.
                  Text(l.promo_my_code_earn(kReferrerBonusTg),
                      style: AppTypography.bodySmall(color: AppColors.profitGreen).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.promo_copied)));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Share.share(l.promo_share_message(p.promoCode, kPromoBonusTg)),
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: Text(l.promo_share),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.group_outlined, size: 16, color: AppColors.profitGreen),
                      const SizedBox(width: 6),
                      Text(
                        l.promo_referrals(math.max(
                          p.referralCount,
                          ref.watch(promoRegistryProvider)[p.promoCode.toUpperCase()] ?? 0,
                        )),
                        style: AppTypography.bodySmall().copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Бонусты қалай табу/жұмсау туралы түсіндірме.
        Card(
          color: AppColors.surfaceMuted,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.dxyBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.promo_how_it_works(kReferrerBonusTg, kPromoBonusTg),
                    style: AppTypography.bodySmall(color: AppColors.textSecondary).copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Промокод енгізу (әлі қолданбаған қолданушыға).
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
        TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: Text(l.common_cancel)),
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
