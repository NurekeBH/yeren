import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Celebration & Off-Ramp: когда сделка по купленному сигналу закрылась в плюс.
/// Дофамин от победы + чёткий выбор «выйти из рынка на сегодня» (opt-out completion).
Future<void> showTakeProfitCelebration(BuildContext context, {required int points, VoidCallback? onMore}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _CelebrationDialog(points: points, onMore: onMore),
  );
}

class _CelebrationDialog extends StatefulWidget {
  const _CelebrationDialog({required this.points, this.onMore});
  final int points;
  final VoidCallback? onMore;

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  late final Animation<double> _scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: AppColors.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: AppColors.profitGreen,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.profitGreen.withValues(alpha: 0.4), blurRadius: 28, spreadRadius: 2)],
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 46),
              ),
            ),
            const SizedBox(height: 20),
            Text(l.celebrate_title, style: AppTypography.h1(), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(l.celebrate_body(widget.points),
                style: AppTypography.bodyMedium(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            // Главный off-ramp: закончить на сегодня (защита от переторговки).
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  // «Call it for now» — сворачиваем приложение (Android). На iOS — просто закрытие поп-апа.
                  SystemNavigator.pop();
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text(l.celebrate_stop),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onMore?.call();
              },
              child: Text(l.celebrate_more, style: const TextStyle(color: AppColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}
