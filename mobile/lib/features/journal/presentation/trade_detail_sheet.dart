import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/error_view.dart';
import '../data/journal_controller.dart';
import '../data/journal_models.dart';

const _setups = ['retest', 'breakout', 'smc_ob', 'reversal', 'news', 'fvg'];
const _sessions = ['asia', 'london', 'new_york', 'overlap'];
const _emotions = ['😤', '😬', '😐', '🙂', '😌'];
const _grades = ['A', 'B', 'C'];

Future<void> showTradeDetailSheet(BuildContext context, JournalTrade trade) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TradeDetailSheet(trade: trade),
  );
}

class _TradeDetailSheet extends ConsumerStatefulWidget {
  const _TradeDetailSheet({required this.trade});
  final JournalTrade trade;
  @override
  ConsumerState<_TradeDetailSheet> createState() => _TradeDetailSheetState();
}

class _TradeDetailSheetState extends ConsumerState<_TradeDetailSheet> {
  late String? _setup = widget.trade.setupTag;
  late String? _session = widget.trade.sessionTag;
  late String? _emotion = widget.trade.emotion;
  late String? _grade = widget.trade.grade;
  late final _notes = TextEditingController(text: widget.trade.notes ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l) async {
    setState(() => _busy = true);
    try {
      await ref.read(journalControllerProvider).setMetadata(widget.trade.id, {
        'setup_tag': _setup,
        'session_tag': _session,
        'emotion': _emotion,
        'grade': _grade,
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.journal_saved)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorText(e, l))));
    }
  }

  Future<void> _delete(AppLocalizations l) async {
    await ref.read(journalControllerProvider).deleteTrade(widget.trade.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = widget.trade;
    final net = t.net;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('${t.side.toUpperCase()} ${t.symbol}', style: AppTypography.h2()),
                const Spacer(),
                Text('${net >= 0 ? '+' : '-'}\$${net.abs().toStringAsFixed(2)}',
                    style: AppTypography.price(
                        size: 18, weight: FontWeight.w800, color: net >= 0 ? AppColors.profitGreen : AppColors.lossRed)),
              ],
            ),
            const SizedBox(height: 4),
            Text('#${t.ticketId} · ${t.broker} · ${t.source}',
                style: AppTypography.label(color: AppColors.textMuted)),
            const SizedBox(height: 14),
            _factRow('${t.volume.toStringAsFixed(2)} lot', '${t.openPrice} → ${t.closePrice ?? '—'}',
                t.pips == null ? '—' : '${t.pips!.toStringAsFixed(0)} pips'),
            const SizedBox(height: 6),
            _factRow('Comm \$${t.commission.toStringAsFixed(2)}', 'Swap \$${t.swap.toStringAsFixed(2)}',
                'P \$${t.profit.toStringAsFixed(2)}'),
            const Divider(height: 26),

            // ── Метадата (синхрон оны өшірмейді) ──
            _chips(l.journal_setup_tag, _setups, _setup, (v) => setState(() => _setup = v)),
            const SizedBox(height: 12),
            _chips(l.journal_session_tag, _sessions, _session, (v) => setState(() => _session = v)),
            const SizedBox(height: 12),
            Text(l.journal_emotion_check, style: AppTypography.label()),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final e in _emotions)
                  GestureDetector(
                    onTap: () => setState(() => _emotion = _emotion == e ? null : e),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _emotion == e ? AppColors.gold.withValues(alpha: 0.2) : Colors.transparent,
                        border: Border.all(color: _emotion == e ? AppColors.gold : Colors.transparent),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _chips(l.journal_grade, _grades, _grade, (v) => setState(() => _grade = v)),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: InputDecoration(labelText: l.journal_notes, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : () => _save(l),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(l.lib_save),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: l.journal_delete,
                  onPressed: _busy ? null : () => _delete(l),
                  icon: const Icon(Icons.delete_outline, color: AppColors.lossRed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _factRow(String a, String b, String c) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(a, style: AppTypography.label(color: AppColors.textSecondary)),
          Text(b, style: AppTypography.label(color: AppColors.textSecondary)),
          Text(c, style: AppTypography.label(color: AppColors.textSecondary)),
        ],
      );

  Widget _chips(String label, List<String> options, String? value, ValueChanged<String?> onSelect) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label()),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in options)
                GestureDetector(
                  onTap: () => onSelect(value == o ? null : o),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: value == o ? AppColors.gold.withValues(alpha: 0.15) : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: value == o ? AppColors.gold : AppColors.border),
                    ),
                    child: Text(o, style: AppTypography.label(color: value == o ? AppColors.gold : AppColors.textSecondary)),
                  ),
                ),
            ],
          ),
        ],
      );
}
