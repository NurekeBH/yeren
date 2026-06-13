import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/market_session.dart';
import '../../../shared/models/signal.dart';
import '../../../shared/models/trade.dart';
import '../../../shared/utils/formatters.dart';
import '../data/journal_repository.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  String? _broker;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(tradesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.nav_journal),
        actions: [
          IconButton(
            tooltip: l.journal_accounts_title,
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => context.push('/accounts'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTradeSheet(context, l),
        icon: const Icon(Icons.add),
        label: Text(l.journal_add_trade),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.common_error}: $e')),
        data: (trades) {
          final brokers = {for (final t in trades) t.broker};
          final filtered = _broker == null ? trades : trades.where((t) => t.broker == _broker).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _BrokerChip(label: l.journal_filter_all_brokers, selected: _broker == null, onTap: () => setState(() => _broker = null)),
                      const SizedBox(width: 8),
                      for (final b in brokers) ...[
                        _BrokerChip(label: b, selected: _broker == b, onTap: () => setState(() => _broker = b)),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
              if (filtered.isEmpty)
                Expanded(child: Center(child: Text(l.journal_empty, style: AppTypography.bodyMedium())))
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _TradeTile(trade: filtered[i], l: l),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showAddTradeSheet(BuildContext context, AppLocalizations l) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _AddTradeSheet(l: l),
    );
  }
}

class _BrokerChip extends StatelessWidget {
  const _BrokerChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withValues(alpha: 0.18) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.gold : AppColors.border),
        ),
        child: Text(label, style: AppTypography.label(color: selected ? AppColors.gold : AppColors.textSecondary)),
      ),
    );
  }
}

class _TradeTile extends StatelessWidget {
  const _TradeTile({required this.trade, required this.l});

  final Trade trade;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final isBuy = trade.direction == SignalDirection.buy;
    final color = trade.isWin ? AppColors.profitGreen : AppColors.lossRed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(isBuy ? Icons.arrow_upward : Icons.arrow_downward, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(trade.instrument, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(trade.broker, style: AppTypography.label(color: AppColors.gold)),
                            ),
                            if (trade.emotion != null) ...[
                              const SizedBox(width: 6),
                              Text(trade.emotion!, style: const TextStyle(fontSize: 16)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Fmt.price(trade.openPrice)} → ${Fmt.price(trade.closePrice)} • ${trade.lot} lot',
                          style: AppTypography.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                  Text(Fmt.money(trade.pnl),
                      style: AppTypography.price(size: 14, weight: FontWeight.w700, color: color)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Tag(text: '${l.journal_setup_tag}: ${_setupLabel(trade.setup, l)}', color: AppColors.purple),
                  _Tag(text: '${l.journal_session_tag}: ${Fmt.sessionName(trade.session, l)}', color: AppColors.dxyBlue),
                  if (trade.rrPlanned != null && trade.rrActual != null)
                    _Tag(
                      text: '${l.journal_rr_planned} 1:${trade.rrPlanned!.toStringAsFixed(1)} → ${l.journal_rr_actual} 1:${trade.rrActual!.toStringAsFixed(1)}',
                      color: AppColors.gold,
                    ),
                ],
              ),
              if (trade.notes != null) ...[
                const SizedBox(height: 8),
                Text(trade.notes!, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _setupLabel(TradeSetup s, AppLocalizations l) {
    switch (s) {
      case TradeSetup.retest:
        return l.setup_retest;
      case TradeSetup.breakout:
        return l.setup_breakout;
      case TradeSetup.smcOb:
        return l.setup_smc_ob;
      case TradeSetup.reversal:
        return l.setup_reversal;
      case TradeSetup.news:
        return l.setup_news;
      case TradeSetup.fvg:
        return l.setup_fvg;
    }
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: AppTypography.label(color: color)),
    );
  }
}

/// TZ §9.5: толық сделка енгізу — Lot, Entry, Close, P&L, RR, Notes
/// + эмоциялық чекин + setup + session тегтер. SharedPreferences-те сақталады.
class _AddTradeSheet extends ConsumerStatefulWidget {
  const _AddTradeSheet({required this.l});

  final AppLocalizations l;

  @override
  ConsumerState<_AddTradeSheet> createState() => _AddTradeSheetState();
}

class _AddTradeSheetState extends ConsumerState<_AddTradeSheet> {
  static const _emojis = ['😤', '😬', '😐', '🙂', '😌'];
  final _formKey = GlobalKey<FormState>();
  final _instrument = TextEditingController(text: 'XAU/USD');
  final _lot = TextEditingController(text: '0.10');
  final _openPrice = TextEditingController();
  final _closePrice = TextEditingController();
  final _rrPlanned = TextEditingController();
  final _rrActual = TextEditingController();
  final _notes = TextEditingController();
  SignalDirection _direction = SignalDirection.buy;
  String _emotion = '😐';
  TradeSetup _setup = TradeSetup.retest;
  MarketSession _session = MarketSession.london;
  bool _busy = false;

  @override
  void dispose() {
    _instrument.dispose();
    _lot.dispose();
    _openPrice.dispose();
    _closePrice.dispose();
    _rrPlanned.dispose();
    _rrActual.dispose();
    _notes.dispose();
    super.dispose();
  }

  double _d(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  /// XAU/USD: 1 лот = 100 унция → бағаның $1 қозғалысы = лот×$100.
  /// Нәтиже бағыт + кіру/шығу бағасынан автоматты есептеледі (қолмен P&L жоқ).
  ({double pnl, double pips})? _result() {
    final o = double.tryParse(_openPrice.text.replaceAll(',', '.'));
    final c = double.tryParse(_closePrice.text.replaceAll(',', '.'));
    final lot = double.tryParse(_lot.text.replaceAll(',', '.'));
    if (o == null || c == null || lot == null || lot <= 0) return null;
    final sign = _direction == SignalDirection.buy ? 1 : -1;
    final diff = (c - o) * sign;
    return (pnl: diff * lot * 100, pips: diff / 0.10);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final now = DateTime.now();
      final res = _result();
      final trade = Trade(
        id: 'tr-${now.millisecondsSinceEpoch}',
        instrument: _instrument.text.trim(),
        direction: _direction,
        openPrice: _d(_openPrice),
        closePrice: _d(_closePrice),
        lot: _d(_lot),
        pnl: res?.pnl ?? 0,
        setup: _setup,
        session: _session,
        openedAt: now.subtract(const Duration(hours: 1)),
        closedAt: now,
        broker: 'Manual',
        rrPlanned: double.tryParse(_rrPlanned.text.replaceAll(',', '.')),
        rrActual: double.tryParse(_rrActual.text.replaceAll(',', '.')),
        emotion: _emotion,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      );
      await ref.read(journalRepositoryProvider).addTrade(trade);
      ref.invalidate(tradesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l.journal_saved)),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _required(String? v, AppLocalizations l) =>
      (v == null || v.trim().isEmpty) ? l.common_error : null;

  String? _number(String? v, AppLocalizations l) {
    if (v == null || v.trim().isEmpty) return l.common_error;
    if (double.tryParse(v.replaceAll(',', '.')) == null) return l.common_error;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + viewInsets),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.journal_add_trade, style: AppTypography.h2()),
              const SizedBox(height: 16),

              // Instrument + Direction
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _instrument,
                      decoration: InputDecoration(labelText: l.journal_instrument),
                      validator: (v) => _required(v, l),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SegmentedButton<SignalDirection>(
                      segments: [
                        ButtonSegment(value: SignalDirection.buy, label: Text(l.signals_direction_buy)),
                        ButtonSegment(value: SignalDirection.sell, label: Text(l.signals_direction_sell)),
                      ],
                      selected: {_direction},
                      onSelectionChanged: (s) => setState(() => _direction = s.first),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Open + Close price (нәтиже тірі есептеледі)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _openPrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l.journal_open_price),
                      validator: (v) => _number(v, l),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _closePrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l.journal_close_price),
                      validator: (v) => _number(v, l),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lot
              TextFormField(
                controller: _lot,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l.journal_lot),
                validator: (v) => _number(v, l),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Есептелген нәтиже (P&L + пипс) — қолмен енгізілмейді
              _ResultBox(result: _result(), l: l),
              const SizedBox(height: 12),

              // RR planned + actual
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rrPlanned,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l.journal_rr_planned),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _rrActual,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l.journal_rr_actual),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Emotion check-in
              Text(l.journal_emotion_check, style: AppTypography.label()),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final e in _emojis)
                    GestureDetector(
                      onTap: () => setState(() => _emotion = e),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _emotion == e ? AppColors.gold.withValues(alpha: 0.18) : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _emotion == e ? AppColors.gold : AppColors.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(e, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Setup
              Text(l.journal_setup_tag, style: AppTypography.label()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in TradeSetup.values)
                    ChoiceChip(
                      label: Text(_setupLabel(s, l)),
                      selected: _setup == s,
                      onSelected: (_) => setState(() => _setup = s),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Session
              Text(l.journal_session_tag, style: AppTypography.label()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in MarketSession.values)
                    ChoiceChip(
                      label: Text(Fmt.sessionName(s, l)),
                      selected: _session == s,
                      onSelected: (_) => setState(() => _session = s),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Notes
              TextFormField(
                controller: _notes,
                maxLines: 2,
                maxLength: 300,
                decoration: InputDecoration(labelText: l.journal_notes),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l.common_save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _setupLabel(TradeSetup s, AppLocalizations l) {
    switch (s) {
      case TradeSetup.retest:
        return l.setup_retest;
      case TradeSetup.breakout:
        return l.setup_breakout;
      case TradeSetup.smcOb:
        return l.setup_smc_ob;
      case TradeSetup.reversal:
        return l.setup_reversal;
      case TradeSetup.news:
        return l.setup_news;
      case TradeSetup.fvg:
        return l.setup_fvg;
    }
  }
}

/// Кіру/шығу бағасы мен лоттан автоматты есептелген нәтиже (P&L + пипс).
class _ResultBox extends StatelessWidget {
  const _ResultBox({required this.result, required this.l});

  final ({double pnl, double pips})? result;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final hasResult = r != null;
    final win = hasResult && r.pnl >= 0;
    final color = !hasResult
        ? AppColors.textMuted
        : (win ? AppColors.profitGreen : AppColors.lossRed);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(hasResult ? (win ? Icons.trending_up : Icons.trending_down) : Icons.calculate_outlined, color: color, size: 20),
          const SizedBox(width: 10),
          Text(l.journal_pnl, style: AppTypography.label(color: AppColors.textSecondary)),
          const Spacer(),
          if (hasResult) ...[
            Text('${Fmt.pipsSigned(r.pips.round())} pips',
                style: AppTypography.label(color: color).copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            Text(Fmt.money(r.pnl),
                style: AppTypography.price(size: 16, weight: FontWeight.w800, color: color)),
          ] else
            Text('—', style: AppTypography.price(size: 16, weight: FontWeight.w700, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
