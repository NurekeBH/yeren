import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/course.dart';
import '../../profile/application/profile_controller.dart';
import '../../profile/presentation/top_up_bonus_sheet.dart';
import '../data/courses_repository.dart';

/// Сатушы (маркетинг) upsell sheet — құлыпталған сабаққа басқанда ашылады.
/// Курсты ашса true қайтарады.
Future<bool> showCourseUnlockSheet(BuildContext context, WidgetRef ref, Course course) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.obsidian,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _UnlockSheet(course: course),
  );
  return ok ?? false;
}

class _UnlockSheet extends ConsumerStatefulWidget {
  const _UnlockSheet({required this.course});
  final Course course;

  @override
  ConsumerState<_UnlockSheet> createState() => _UnlockSheetState();
}

class _UnlockSheetState extends ConsumerState<_UnlockSheet> {
  bool _busy = false;

  Future<void> _unlock(AppLocalizations l, int cost) async {
    setState(() => _busy = true);
    if (cost > 0) ref.read(profileControllerProvider.notifier).spendBonus(cost);
    ref.read(purchasedCoursesProvider.notifier).unlock(widget.course.id);
    // Backend синхрондау (best-effort): леджерге жазылады.
    ref.read(apiServiceProvider).purchaseCourse(widget.course.id, cost).catchError((_) {});
    if (!mounted) return;
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.course_unlocked)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = Color(widget.course.accent);
    final cost = widget.course.priceBonus;
    final balance = ref.watch(profileControllerProvider).bonusBalance;
    final canAfford = balance >= cost;
    final shortfall = (cost - balance).clamp(0, cost);
    final p = ref.watch(profileControllerProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
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
                const Icon(Icons.lock, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(l.course_locked_lesson_title, style: AppTypography.h2())),
              ],
            ),
            const SizedBox(height: 6),
            Text(l.course_locked_lesson_desc, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Text(l.course_sell_headline, style: AppTypography.bodyLarge().copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _Bullet(l.course_sell_b1),
            _Bullet(l.course_sell_b2),
            _Bullet(l.course_sell_b3),
            _Bullet(l.course_sell_b4),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
              child: Text('💡 ${l.course_sell_footer}',
                  style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.course_unlock_balance, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                Text(l.promo_bonus_amount(balance),
                    style: AppTypography.bodyMedium(color: canAfford ? AppColors.profitGreen : AppColors.lossRed)
                        .copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            if (canAfford)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: accent),
                  onPressed: _busy ? null : () => _unlock(l, cost),
                  icon: _busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.lock_open, size: 18),
                  label: Text(l.course_unlock_for(cost)),
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: accent),
                  onPressed: _busy
                      ? null
                      : () async {
                          final ok = await showTopUpBonusSheet(context, suggested: shortfall);
                          if (ok && mounted && ref.read(profileControllerProvider).bonusBalance >= cost) {
                            await _unlock(l, cost);
                          }
                        },
                  icon: const Icon(Icons.add_card, size: 18),
                  label: Text(l.bonus_topup),
                ),
              ),
              const SizedBox(height: 6),
              Text(l.signals_not_enough(shortfall), style: AppTypography.label(color: AppColors.lossRed)),
              const SizedBox(height: 8),
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
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 17, color: AppColors.profitGreen),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(height: 1.35))),
        ],
      ),
    );
  }
}
