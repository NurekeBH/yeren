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
import 'journal_analytics_tab.dart';
import 'trade_detail_sheet.dart';

/// Журнал v2 — 2 таб: Сделки + Аналитика. Дереккөз — backend /journal/* (DB).
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.nav_journal),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => context.push('/accounts'),
                icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                label: Text(l.journal_link_broker),
                style: TextButton.styleFrom(foregroundColor: AppColors.dxyBlue),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l.journal_tab_trades),
              Tab(text: l.journal_tab_analytics),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _import(context, ref, l),
          icon: const Icon(Icons.upload_file),
          label: Text(l.journal_import),
        ),
        body: Column(
          children: [
            const _AccountFilter(),
            const Expanded(
              child: TabBarView(
                children: [
                  _TradesTab(),
                  JournalAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['html', 'htm', 'csv'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;
    messenger.showSnackBar(const SnackBar(content: Text('⏳ …')));
    try {
      final acc = ref.read(selectedAccountProvider);
      final res = await ref.read(journalControllerProvider).importStatement(path, accountId: acc);
      messenger.showSnackBar(SnackBar(
        content: Text('✅ +${res['inserted']} / ↻${res['updated']} (${res['parsed']} оқылды)'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyErrorText(e, l))));
    }
  }
}

/// Шот фильтрі — «Барлық» + әр аккаунт.
class _AccountFilter extends ConsumerWidget {
  const _AccountFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final accounts = ref.watch(journalAccountsProvider).valueOrNull ?? const [];
    if (accounts.isEmpty) return const SizedBox.shrink();
    final selected = ref.watch(selectedAccountProvider);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _Chip(label: l.journal_all_accounts, selected: selected == null, onTap: () => ref.read(selectedAccountProvider.notifier).state = null),
          const SizedBox(width: 8),
          for (final a in accounts) ...[
            _Chip(
              label: a.platform == 'manual' ? l.journal_add_trade : '${a.broker} ${a.login}',
              selected: selected == a.id,
              onTap: () => ref.read(selectedAccountProvider.notifier).state = a.id,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withValues(alpha: 0.14) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.gold : AppColors.border),
        ),
        child: Text(label,
            style: AppTypography.label(color: selected ? AppColors.gold : AppColors.textSecondary)
                .copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}

class _TradesTab extends ConsumerWidget {
  const _TradesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(journalTradesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorRetryView(error: e, onRetry: () => ref.invalidate(journalTradesProvider)),
      data: (trades) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(journalTradesProvider);
          await ref.read(journalTradesProvider.future);
        },
        child: trades.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                children: [
                  const SizedBox(height: 110),
                  Icon(Icons.candlestick_chart_outlined, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(l.journal_empty, textAlign: TextAlign.center, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(l.journal_import_hint, textAlign: TextAlign.center, style: AppTypography.label(color: AppColors.textMuted)),
                  const SizedBox(height: 18),
                  FilledButton.tonalIcon(
                    onPressed: () => context.push('/accounts'),
                    icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                    label: Text(l.journal_link_broker),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: trades.length,
                itemBuilder: (_, i) => _TradeTile(trade: trades[i]),
              ),
      ),
    );
  }
}

class _TradeTile extends StatelessWidget {
  const _TradeTile({required this.trade});
  final JournalTrade trade;

  @override
  Widget build(BuildContext context) {
    final buy = trade.side == 'buy';
    final dirColor = buy ? AppColors.profitGreen : AppColors.lossRed;
    final net = trade.net;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => showTradeDetailSheet(context, trade),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(buy ? Icons.north_east : Icons.south_east, size: 16, color: dirColor),
                    const SizedBox(width: 6),
                    Text(trade.symbol, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text('${trade.volume.toStringAsFixed(2)} lot',
                        style: AppTypography.label(color: AppColors.textSecondary)),
                    if (trade.emotion != null) ...[
                      const SizedBox(width: 8),
                      Text(trade.emotion!, style: const TextStyle(fontSize: 15)),
                    ],
                    const Spacer(),
                    Text(
                      '${net >= 0 ? '+' : '-'}\$${net.abs().toStringAsFixed(2)}',
                      style: AppTypography.price(
                        size: 16,
                        weight: FontWeight.w800,
                        color: net >= 0 ? AppColors.profitGreen : AppColors.lossRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('${trade.openPrice} → ${trade.closePrice ?? '—'}',
                        style: AppTypography.label(color: AppColors.textSecondary)),
                    if (trade.pips != null) ...[
                      const SizedBox(width: 10),
                      Text('${trade.pips!.toStringAsFixed(0)} pips',
                          style: AppTypography.label(
                              color: trade.pips! >= 0 ? AppColors.profitGreen : AppColors.lossRed)),
                    ],
                    const Spacer(),
                    if (trade.isOpen)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dxyBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('OPEN', style: AppTypography.label(color: AppColors.dxyBlue).copyWith(fontSize: 10)),
                      ),
                  ],
                ),
                if (trade.setupTag != null || trade.sessionTag != null || trade.grade != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (trade.grade != null) _MiniTag('[${trade.grade}]', AppColors.gold),
                      if (trade.setupTag != null) _MiniTag(trade.setupTag!, AppColors.dxyBlue),
                      if (trade.sessionTag != null) _MiniTag(trade.sessionTag!, AppColors.textSecondary),
                      _MiniTag(trade.broker, AppColors.textMuted),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag(this.text, this.color);
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: AppTypography.label(color: color).copyWith(fontSize: 11)),
    );
  }
}
