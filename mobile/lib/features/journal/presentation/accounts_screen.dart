import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/broker_account.dart';
import '../../../shared/utils/formatters.dart';
import '../data/brokers_repository.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final accounts = ref.watch(brokersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.journal_accounts_title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/accounts/link'),
        icon: const Icon(Icons.add_link),
        label: Text(l.journal_link_broker),
      ),
      body: accounts.isEmpty
          ? _EmptyState(l: l)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: accounts.length,
              itemBuilder: (_, i) => _AccountTile(account: accounts[i], l: l),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.gold),
            const SizedBox(height: 16),
            Text(l.journal_no_accounts, style: AppTypography.h2(), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(l.journal_add_first_broker, style: AppTypography.bodyMedium(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.account, required this.l});

  final BrokerAccount account;
  final AppLocalizations l;

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(l.broker_remove_confirm(account.brokerLabel)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.common_cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.broker_remove, style: const TextStyle(color: AppColors.lossRed)),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(brokersControllerProvider.notifier).remove(account.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.gold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(account.brokerLabel, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                        Text(account.platform.displayName, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (account.balance != null)
                    Text(
                      Fmt.money(account.balance!),
                      style: AppTypography.price(size: 14, weight: FontWeight.w700, color: AppColors.profitGreen),
                    ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MetaRow(label: l.broker_account_number, value: account.accountNumber),
                  ),
                  if (account.isOAuth)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.dxyBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('OAuth', style: AppTypography.label(color: AppColors.dxyBlue)),
                    ),
                ],
              ),
              if (account.server != null) ...[
                const SizedBox(height: 6),
                _MetaRow(label: l.broker_server, value: account.server!),
              ],
              if (account.investorPasswordMasked != null) ...[
                const SizedBox(height: 6),
                _MetaRow(
                  label: l.broker_investor_password,
                  value: account.investorPasswordMasked!,
                  icon: Icons.lock_outline,
                ),
              ],
              if (account.syncedAt != null) ...[
                const SizedBox(height: 6),
                _MetaRow(
                  label: l.broker_synced,
                  value: Fmt.relativeTime(account.syncedAt!, context),
                  icon: Icons.sync,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(brokersControllerProvider.notifier).sync(account.id),
                      icon: const Icon(Icons.sync, size: 16),
                      label: Text(l.broker_sync_now),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: l.broker_remove,
                    onPressed: () => _confirmRemove(context, ref),
                    icon: const Icon(Icons.delete_outline, color: AppColors.lossRed),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
        ],
        Text('$label: ', style: AppTypography.label(color: AppColors.textMuted)),
        Expanded(
          child: Text(value, style: AppTypography.price(size: 12, weight: FontWeight.w600)),
        ),
      ],
    );
  }
}
