import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';

/// TZ §11.5: апта прогресі — 7 ұяшық (✓ / бос).
class WeeklyProgress extends StatelessWidget {
  const WeeklyProgress({super.key, required this.completed});

  final List<bool> completed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now().weekday - 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.academy_weekly_progress, style: AppTypography.label(color: AppColors.purple)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 7; i++) _Cell(label: labels[i], done: i < completed.length && completed[i], isToday: i == today),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.done, required this.isToday});

  final String label;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final fillColor = done ? AppColors.purple : AppColors.cardSurface;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: fillColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isToday ? AppColors.gold : (done ? AppColors.purple : AppColors.border),
              width: isToday ? 2 : 1,
            ),
          ),
          child: done
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : isToday
                  ? const Center(child: Text('•', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)))
                  : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.label(color: AppColors.textMuted)),
      ],
    );
  }
}
