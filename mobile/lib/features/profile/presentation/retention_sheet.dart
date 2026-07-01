import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';

const int _kRetentionBonus = 500;

/// Экран удержания при отмене/удалении. Опрос «почему уходите» → динамический оффер.
/// Возвращает true, если пользователь ВСЁ РАВНО хочет уйти; false — если остался.
Future<bool> showRetentionSheet(BuildContext context, WidgetRef ref) async {
  final res = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardSurface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => const _RetentionSheet(),
  );
  return res ?? false; // закрыл свайпом → считаем, что остался
}

class _RetentionSheet extends ConsumerStatefulWidget {
  const _RetentionSheet();
  @override
  ConsumerState<_RetentionSheet> createState() => _RetentionSheetState();
}

class _RetentionSheetState extends ConsumerState<_RetentionSheet> {
  String? _reason;
  bool _busy = false;

  Future<void> _stay() async {
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).retentionOffer(_reason ?? 'other');
    } catch (_) {/* уже получал оффер / офлайн — всё равно оставляем */}
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.retention_thanks(_kRetentionBonus)), backgroundColor: AppColors.profitGreen),
    );
    Navigator.of(context).pop(false); // остался
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reasons = <(String, String)>[
      ('too_expensive', l.retention_r_expensive),
      ('not_useful', l.retention_r_useless),
      ('no_time', l.retention_r_notime),
      ('other', l.retention_r_other),
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text(l.retention_title, style: AppTypography.h1()),
            const SizedBox(height: 6),
            Text(l.retention_q, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                for (final (v, label) in reasons)
                  ChoiceChip(
                    label: Text(label),
                    selected: _reason == v,
                    onSelected: (_) => setState(() => _reason = v),
                    selectedColor: AppColors.gold,
                    labelStyle: TextStyle(
                      color: _reason == v ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600),
                    backgroundColor: AppColors.surfaceMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            // Динамический оффер появляется после выбора причины.
            if (_reason != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.30)),
                ),
                child: Text(l.retention_offer(_kRetentionBonus),
                    style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700, color: AppColors.gold)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _stay,
                  child: _busy
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.retention_stay),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(true),
                  child: Text(l.retention_leave, style: const TextStyle(color: AppColors.textMuted)),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l.retention_leave, style: const TextStyle(color: AppColors.textMuted)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
