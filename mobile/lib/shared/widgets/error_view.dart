import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/gen/app_localizations.dart';

/// Backend қате КОДЫН (мыс. 'invalid_credentials') қолданушы тіліндегі мәтінге аудару.
/// Белгісіз код → null (жоғарыда жалпы хабарға түседі). Шикі ағылшын код ЕШҚАШАН көрінбейді.
String? _messageForCode(String? code, AppLocalizations l) {
  switch (code) {
    case 'invalid_credentials':
      return l.err_invalid_credentials;
    case 'phone_already_registered':
      return l.err_phone_already_registered;
    case 'account_blocked':
    case 'account_not_found': // қолданушыға: телефон/құпиясөз қате деп көрсету қауіпсіз
      return code == 'account_blocked' ? l.err_account_blocked : l.err_invalid_credentials;
    case 'bad_request':
      return l.err_bad_request;
    case 'not_found':
    case 'not_found_or_reviewed':
    case 'not_found_or_not_pending':
      return l.err_not_found;
    case 'locked':
      return l.err_locked;
    case 'insufficient_bonus':
      return l.err_insufficient_bonus;
    case 'invalid_code':
      return l.err_invalid_code;
    case 'already_used':
      return l.err_already_used;
    case 'own_code':
      return l.err_own_code;
    case 'not_owner':
      return l.err_not_owner;
    case 'unsupported_type':
    case 'bad_image':
    case 'upload_bad_format':
      return l.upload_bad_format;
    case 'upload_too_large':
      return l.upload_too_large;
    case 'upload_failed':
      return l.upload_failed;
    default:
      return null;
  }
}

/// Қатені қолданушыға түсінікті мәтінге айналдыру.
/// Желі/таймаут → «Интернетті тексеріңіз»; белгілі backend коды → тілдегі хабар;
/// басқасы → жалпы хабар. Шикі `ApiException(null): ...` мәтіні ЕШҚАШАН көрсетілмейді.
String friendlyErrorText(Object? error, AppLocalizations l) {
  if (isNetworkError(error)) return l.error_network;
  if (error is ApiException) {
    // 5xx — сервер жағындағы ақаулық: «біздің жақта» деген жұмсақ хабар.
    if ((error.statusCode ?? 0) >= 500) return l.error_server;
    final mapped = _messageForCode(error.message, l);
    if (mapped != null) return mapped;
  }
  return l.error_generic;
}

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
