import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/error_view.dart';
import '../data/journal_controller.dart';
import '../data/journal_models.dart';

/// Брокерлік шоттар — MT4/MT5 investor-password арқылы синхрондалады + statement импорт.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(journalAccountsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.journal_accounts_title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/accounts/link'),
        icon: const Icon(Icons.add_link),
        label: Text(l.journal_link_account),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetryView(error: e, onRetry: () => ref.invalidate(journalAccountsProvider)),
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_outlined, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 14),
                    Text(l.journal_no_accounts,
                        textAlign: TextAlign.center, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.push('/accounts/link'),
                      icon: const Icon(Icons.add_link),
                      label: Text(l.journal_add_first_broker),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(journalAccountsProvider);
              await ref.read(journalAccountsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [for (final a in accounts) _AccountTile(account: a)],
            ),
          );
        },
      ),
    );
  }
}

class _AccountTile extends ConsumerStatefulWidget {
  const _AccountTile({required this.account});
  final JournalAccount account;
  @override
  ConsumerState<_AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends ConsumerState<_AccountTile> {
  bool _busy = false;

  Future<void> _sync(AppLocalizations l) async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final res = await ref.read(journalControllerProvider).sync(widget.account.id);
      if (res['ok'] == true) {
        messenger.showSnackBar(SnackBar(content: Text('✅ +${res['inserted']} / ↻${res['updated']}')));
      } else {
        messenger.showSnackBar(SnackBar(content: Text('⚠️ ${res['error']}')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyErrorText(e, l))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import(AppLocalizations l) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['html', 'htm', 'csv']);
    final path = picked?.files.single.path;
    if (path == null) return;
    setState(() => _busy = true);
    try {
      final res = await ref.read(journalControllerProvider).importStatement(path, accountId: widget.account.id);
      messenger.showSnackBar(SnackBar(content: Text('✅ +${res['inserted']} / ↻${res['updated']} (${res['parsed']})')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyErrorText(e, l))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(AppLocalizations l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.broker_remove_confirm('${widget.account.broker} #${widget.account.login}')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.common_cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l.broker_remove)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(journalControllerProvider).removeAccount(widget.account.id);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyErrorText(e, l))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final a = widget.account;
    final (stateColor, stateText) = switch (a.syncState) {
      'ok' => (AppColors.profitGreen, 'OK'),
      'error' => (AppColors.lossRed, a.syncError ?? 'error'),
      'idle' => (AppColors.textMuted, 'idle'),
      _ => (AppColors.dxyBlue, a.syncState),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${a.broker} · ${a.platform.toUpperCase()}',
                  style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: stateColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(stateText, style: AppTypography.label(color: stateColor).copyWith(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('#${a.login}  ·  ${a.server}', style: AppTypography.label(color: AppColors.textSecondary)),
          if (a.balance != null) ...[
            const SizedBox(height: 4),
            Text('${l.broker_balance}: ${a.balance!.toStringAsFixed(2)} ${a.currency}',
                style: AppTypography.label(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 12),
          if (_busy)
            const Padding(padding: EdgeInsets.all(4), child: LinearProgressIndicator())
          else
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _sync(l),
                  icon: const Icon(Icons.sync, size: 16),
                  label: Text(l.journal_sync),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _import(l),
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: Text(l.journal_import),
                ),
                const Spacer(),
                IconButton(
                  tooltip: l.broker_remove,
                  onPressed: () => _remove(l),
                  icon: const Icon(Icons.delete_outline, color: AppColors.lossRed),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
