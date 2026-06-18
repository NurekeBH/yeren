import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Қолдау/әкімшілікке хабарлама жіберу. Хабар админ-панельге түседі
/// (Telegram/email көрсетілмейді — тек ішкі хабарлама).
Future<void> showSupportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _SupportSheet(),
  );
}

class _SupportSheet extends ConsumerStatefulWidget {
  const _SupportSheet();

  @override
  ConsumerState<_SupportSheet> createState() => _SupportSheetState();
}

class _SupportSheetState extends ConsumerState<_SupportSheet> {
  final _text = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send(AppLocalizations l) async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    setState(() => _busy = true);
    try {
      if (AppConfig.useRemoteApi) {
        await ref.read(apiServiceProvider).sendSupportMessage(text);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.support_sent)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.common_error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Icon(Icons.support_agent_outlined, color: AppColors.gold),
            const SizedBox(width: 8),
            Text(l.support_title, style: AppTypography.h2()),
          ]),
          const SizedBox(height: 6),
          Text(l.support_desc, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          TextField(
            controller: _text,
            maxLines: 5,
            maxLength: 1000,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l.support_message_hint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _busy ? null : () => _send(l),
            icon: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send, size: 18),
            label: Text(l.support_send),
          ),
        ],
      ),
    );
  }
}
