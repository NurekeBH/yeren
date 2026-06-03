import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/models/market_session.dart';
import '../../../../shared/utils/formatters.dart';

/// Үстіңгі баннер: ағымдағы сессия + streak.
/// "Сәлеметсіз бе / Trader" greeting-ы алып тасталды (user сұрауы).
class SessionBanner extends StatelessWidget {
  const SessionBanner({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = MarketSession.current();
    final color = Fmt.sessionColor(session);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.access_time, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                Fmt.sessionName(session, l),
                style: AppTypography.bodyMedium(color: color).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (streak > 0) ...[
              const Icon(Icons.local_fire_department, color: AppColors.gold, size: 15),
              const SizedBox(width: 3),
              Text(
                '$streak',
                style: AppTypography.price(size: 13, weight: FontWeight.w700, color: AppColors.gold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
