import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../data/journal_controller.dart';

const _setups = ['retest', 'breakout', 'smc_ob', 'reversal', 'news', 'fvg'];
const _sessions = ['asia', 'london', 'new_york', 'overlap'];
const _emotions = ['😤', '😬', '😐', '🙂', '😌'];
const _grades = ['A', 'B', 'C'];

Future<void> showAddTradeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _AddTradeSheet(),
  );
}

class _AddTradeSheet extends ConsumerStatefulWidget {
  const _AddTradeSheet();
  @override
  ConsumerState<_AddTradeSheet> createState() => _AddTradeSheetState();
}

class _AddTradeSheetState extends ConsumerState<_AddTradeSheet> {
  final _symbol = TextEditingController(text: 'XAUUSD');
  final _volume = TextEditingController();
  final _open = TextEditingController();
  final _close = TextEditingController();
  final _profit = TextEditingController();
  final _notes = TextEditingController();
  String _side = 'buy';
  String? _setup;
  String? _session;
  String? _emotion;
  String _grade = 'B';
  bool _busy = false;

  double _n(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  @override
  void dispose() {
    for (final c in [_symbol, _volume, _open, _close, _profit, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(AppLocalizations l) async {
    if (_symbol.text.trim().isEmpty || _n(_volume) <= 0 || _n(_open) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.common_error)));
      return;
    }
    setState(() => _busy = true);
    final now = DateTime.now();
    final body = {
      'symbol': _symbol.text.trim(),
      'side': _side,
      'volume': _n(_volume),
      'open_price': _n(_open),
      'close_price': _close.text.trim().isEmpty ? null : _n(_close),
      'profit': _n(_profit),
      'opened_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
      'closed_at': now.toIso8601String(),
      'setup_tag': _setup,
      'session_tag': _session,
      'emotion': _emotion,
      'grade': _grade,
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    };
    try {
      await ref.read(journalControllerProvider).addManual(body);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.journal_saved)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l.common_error}: $e')));
    }
  }

  Widget _field(TextEditingController c, String label, {bool number = true}) => TextField(
        controller: c,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.journal_add_trade, style: AppTypography.h2()),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _field(_symbol, l.journal_instrument, number: false)),
              const SizedBox(width: 10),
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'buy', label: Text('BUY')),
                    ButtonSegment(value: 'sell', label: Text('SELL')),
                  ],
                  selected: {_side},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _side = s.first),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _field(_volume, l.journal_lot)),
              const SizedBox(width: 10),
              Expanded(child: _field(_open, l.journal_open_price)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _field(_close, l.journal_close_price)),
              const SizedBox(width: 10),
              Expanded(child: _field(_profit, '${l.journal_pnl} (\$)')),
            ]),
            const SizedBox(height: 16),
            _ChipRow(label: l.journal_setup_tag, options: _setups, value: _setup, onSelect: (v) => setState(() => _setup = v)),
            const SizedBox(height: 12),
            _ChipRow(label: l.journal_session_tag, options: _sessions, value: _session, onSelect: (v) => setState(() => _session = v)),
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
            _ChipRow(label: l.journal_grade, options: _grades, value: _grade, onSelect: (v) => setState(() => _grade = v ?? 'B')),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: InputDecoration(labelText: l.journal_notes, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _busy ? null : () => _save(l),
              child: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l.journal_add_trade),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.label, required this.options, required this.value, required this.onSelect});
  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
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
}
