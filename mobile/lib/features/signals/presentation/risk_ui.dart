import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';

/// Тәуекел деңгейінің локализацияланған толық атауы.
String riskLabel(RiskLevel r, AppLocalizations l) => switch (r) {
      RiskLevel.low => l.signals_risk_low,
      RiskLevel.medium => l.signals_risk_medium,
      RiskLevel.high => l.signals_risk_high,
    };

/// Қысқа атауы (картадағы шағын орынға).
String riskShort(RiskLevel r, AppLocalizations l) => switch (r) {
      RiskLevel.low => l.signals_risk_low_short,
      RiskLevel.medium => l.signals_risk_medium_short,
      RiskLevel.high => l.signals_risk_high_short,
    };

/// Тәуекел түсі: төмен → жасыл, орташа → алтын, жоғары → қызыл.
Color riskColor(RiskLevel r) => switch (r) {
      RiskLevel.low => AppColors.profitGreen,
      RiskLevel.medium => AppColors.gold,
      RiskLevel.high => AppColors.lossRed,
    };
