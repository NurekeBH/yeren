import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/models/market_session.dart';
import '../../../../shared/utils/formatters.dart';

/// Үстіңгі баннер: ағымдағы нарық сессиясы.
/// "Сәлеметсіз бе / Trader" greeting-ы алып тасталды (user сұрауы).
/// Streak (🔥) функциясы алынып тасталды (user сұрауы).
class SessionBanner extends StatelessWidget {
  const SessionBanner({super.key});

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
          ],
        ),
      ),
    );
  }
}
