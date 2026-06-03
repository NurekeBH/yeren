import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.purple, size: 18),
                const SizedBox(width: 8),
                Text(l.home_ai_insight_title, style: AppTypography.label(color: AppColors.purple)),
              ],
            ),
            const SizedBox(height: 12),
            Text(text, style: AppTypography.bodyMedium()),
          ],
        ),
      ),
    );
  }
}
