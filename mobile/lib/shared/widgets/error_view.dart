import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/gen/app_localizations.dart';

/// Қатені қолданушыға түсінікті мәтінге айналдыру.
/// Желі/таймаут → «Интернетті тексеріңіз»; басқасы → жалпы хабар.
/// Шикі `ApiException(null): ...` мәтіні ЕШҚАШАН көрсетілмейді.
String friendlyErrorText(Object? error, AppLocalizations l) =>
    isNetworkError(error) ? l.error_network : l.error_generic;

/// Қате күйін біркелкі көрсететін виджет: белгіше + түсінікті мәтін + «Қайталау».
/// [compact] — карточка ішіндегі шағын нұсқа (үй экранының модульдері үшін).
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  final Object? error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final network = isNetworkError(error);
    final text = friendlyErrorText(error, l);
    final icon = network ? Icons.wifi_off_rounded : Icons.error_outline_rounded;

    if (compact) {
      // Үй модульдеріндегі шағын: бір қатар белгіше + мәтін + кіші «Қайталау».
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l.common_retry),
              ),
          ],
        ),
      );
    }

    // Толық экран: ортада белгіше + мәтін + «Қайталау» батырмасы.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(text,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l.common_retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
