import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/referral/referral_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/profile_controller.dart';
import '../application/promo_registry.dart';
import 'top_up_bonus_sheet.dart';

/// Профильдегі ықшам «Менің бонустарым» тілкесі — толық бетке өтеді (/bonuses).
/// Реферал табысын ашылғанда есептейді (баланс жаңа болады).
class BonusBalanceTile extends ConsumerStatefulWidget {
  const BonusBalanceTile({super.key});

  @override
  ConsumerState<BonusBalanceTile> createState() => _BonusBalanceTileState();
}

class _BonusBalanceTileState extends ConsumerState<BonusBalanceTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(profileControllerProvider.notifier).creditReferralEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(profileControllerProvider);
    return Card(
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.14), shape: BoxShape.circle),
          child: const Icon(Icons.card_giftcard, size: 19, color: AppColors.gold),
        ),
        title: Text(l.promo_my_bonuses, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(l.promo_bonus_tile_sub, style: AppTypography.bodySmall()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.promo_bonus_amount(p.bonusBalance),
                style: AppTypography.bodyMedium(color: AppColors.gold).copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: () => context.push('/bonuses'),
      ),
    );
  }
}

/// «Менің бонустарым» — бонусқа қатысты барлығы бір картада (баланс, қалай табу,
/// промокод, бөлісу CTA, тіркелулер саны, код енгізу).
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
    if (p.promoCode.isEmpty) return const SizedBox.shrink();

    final referrals = math.max(
      p.referralCount,
      ref.watch(promoRegistryProvider)[p.promoCode.toUpperCase()] ?? 0,
    );
    final notReferred = p.referredBy == null || p.referredBy!.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: тақырып + баланс ──
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.14), shape: BoxShape.circle),
                  child: const Icon(Icons.card_giftcard, size: 18, color: AppColors.gold),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(l.promo_my_bonuses, style: AppTypography.h2())),
                Text(l.promo_bonus_amount(p.bonusBalance),
                    style: AppTypography.h2().copyWith(color: AppColors.gold)),
              ],
            ),
            const SizedBox(height: 12),
            // ── Қалай табу/жұмсау ──
            Text(
              l.promo_how_it_works(kReferrerBonusTg, kPromoBonusTg),
              style: AppTypography.bodySmall(color: AppColors.textSecondary).copyWith(height: 1.4),
            ),
            const SizedBox(height: 14),
            // ── Промокод + көшіру ──
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
            const SizedBox(height: 10),
            // ── CTA: толтыру (негізгі) + бөлісу (тегін табу) — толық ені, бөлек жол ──
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => showTopUpBonusSheet(context),
                icon: const Icon(Icons.add_card, size: 18),
                label: Text(l.bonus_topup, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Deferred deep link: к сообщению добавляем реф-ссылку — друг устанавливает
                  // приложение, и промокод подставляется АВТОМАТИЧЕСКИ (без ручного ввода).
                  final link = ref.read(referralServiceProvider).inviteLink(p.promoCode);
                  Share.share('${l.promo_share_message(p.promoCode, kPromoBonusTg)}\n\n$link');
                },
                icon: const Icon(Icons.ios_share, size: 18),
                label: Text(l.promo_share, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(height: 10),
            // ── Footer: тіркелулер саны + код енгізу ──
            Row(
              children: [
                const Icon(Icons.group_outlined, size: 16, color: AppColors.profitGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(l.promo_referrals(referrals),
                      style: AppTypography.bodySmall().copyWith(fontWeight: FontWeight.w600)),
                ),
                if (notReferred)
                  TextButton(
                    onPressed: () => _showEnterPromoDialog(context, ref),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 32)),
                    child: Text(l.promo_enter_title),
                  ),
              ],
            ),
          ],
        ),
      ),
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
