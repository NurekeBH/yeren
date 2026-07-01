import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Экран-заглушка «защита от тильта»: после 2 минусов подряд не предлагаем новые
/// сигналы, а бережно уводим на паузу (сохранение капитала > дофамин отыгрыша).
class TiltPauseView extends StatelessWidget {
  const TiltPauseView({super.key, this.until, this.onBreak});

  final DateTime? until;
  final VoidCallback? onBreak;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final left = until?.difference(DateTime.now());
    final mins = left != null && !left.isNegative ? left.inMinutes : null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: AppColors.lossRed.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lossRed.withValues(alpha: 0.30), width: 2),
              ),
              child: const Icon(Icons.self_improvement, size: 46, color: AppColors.lossRed),
            ),
            const SizedBox(height: 24),
            Text(l.tilt_title, style: AppTypography.h1(), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(l.tilt_body,
                style: AppTypography.bodyMedium(color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (mins != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text('${mins ~/ 60}ч ${mins % 60}м',
                        style: AppTypography.price(size: 15, weight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onBreak,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(l.tilt_break),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
