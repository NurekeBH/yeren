import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/formatters.dart';

/// TZ §9.5 калькулятор + user 2026-05-27: бірнеше режим.
/// Mode 1: SL pip арқылы (қарапайым)
/// Mode 2: Кіру + SL бағасы арқылы (нақты структура)
class PositionCalculatorScreen extends StatefulWidget {
  const PositionCalculatorScreen({
    super.key,
    this.entryFrom,
    this.entryTo,
    this.slPrice,
    this.tpPrice,
  });

  /// Идеядан алдын-ала толтыру (сатып алынған сигнал → «Есептеу»).
  /// Берілсе — деңгейлер автотолтырылады, қолданушы тек тәуекел сомасын енгізеді.
  final double? entryFrom;
  final double? entryTo;
  final double? slPrice;
  final double? tpPrice;

  @override
  State<PositionCalculatorScreen> createState() => _PositionCalculatorScreenState();
}

enum _Mode { byPrice, byPips }

class _PositionCalculatorScreenState extends State<PositionCalculatorScreen> {
  // 1-таб (әдепкі): кіру + SL бағасы арқылы.
  _Mode _mode = _Mode.byPrice;
  final _riskAmount = TextEditingController(text: '50'); // тәуекел сомасы ($), пайыз емес
  final _slPips = TextEditingController(text: '50');
  final _entry = TextEditingController(); // кіру бағасы (от)
  final _entryTo = TextEditingController(); // кіру бағасы (до) — опционал (зона)
  final _slPrice = TextEditingController();
  final _tpPrice = TextEditingController();
  // XAU/USD: 1 lot ≈ $10/pip (0.01 = $0.10)
  final _pipValue = TextEditingController(text: '10');

  _Result? _result;

  @override
  void initState() {
    super.initState();
    // Идеядан келген деңгейлерді толтыру (бар болса). Локаль-тәуелсіз сан форматы.
    String f(double? v) => (v == null || v <= 0) ? '' : v.toStringAsFixed(2);
    if (widget.entryFrom != null) _entry.text = f(widget.entryFrom);
    if (widget.entryTo != null && widget.entryTo != widget.entryFrom) _entryTo.text = f(widget.entryTo);
    if (widget.slPrice != null) _slPrice.text = f(widget.slPrice);
    if (widget.tpPrice != null) _tpPrice.text = f(widget.tpPrice);
    // Деңгейлер келсе — бірден есептеп көрсетеміз (тәуекел сомасы әдепкі $50).
    final prefilled = (widget.entryFrom ?? 0) > 0 && (widget.slPrice ?? 0) > 0;
    if (prefilled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _calc());
    }
  }

  @override
  void dispose() {
    _riskAmount.dispose();
    _slPips.dispose();
    _entry.dispose();
    _entryTo.dispose();
    _slPrice.dispose();
    _tpPrice.dispose();
    _pipValue.dispose();
    super.dispose();
  }

  double _p(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  void _calc() {
    final riskUsd = _p(_riskAmount);
    final pipValue = _p(_pipValue) <= 0 ? 10 : _p(_pipValue);
    if (riskUsd <= 0) {
      setState(() => _result = null);
      return;
    }

    double pips = 0;
    double? rr;
    if (_mode == _Mode.byPips) {
      pips = _p(_slPips);
    } else {
      // Кіру зонасы: «до» берілсе ортасын аламыз, әйтпесе «от».
      final from = _p(_entry);
      final to = _p(_entryTo);
      final entry = to > 0 ? (from + to) / 2 : from;
      final sl = _p(_slPrice);
      if (entry <= 0 || sl <= 0) {
        setState(() => _result = null);
        return;
      }
      // XAU/USD pip = 0.10 → diff/0.10
      pips = (entry - sl).abs() / 0.10;
      final tp = _p(_tpPrice);
      if (tp > 0) {
        final reward = (tp - entry).abs() / 0.10;
        rr = pips == 0 ? null : reward / pips;
      }
    }

    if (pips <= 0) {
      setState(() => _result = null);
      return;
    }

    // lot * pipValue * pips = riskUsd  ⇒  lot = riskUsd / (pipValue * pips)
    final lot = riskUsd / (pipValue * pips);
    setState(() => _result = _Result(lot: lot, risk: riskUsd, pips: pips, rr: rr));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.tools_position_calc)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SegmentedButton<_Mode>(
            segments: [
              ButtonSegment(value: _Mode.byPrice, label: Text(l.calc_mode_by_price)),
              ButtonSegment(value: _Mode.byPips, label: Text(l.calc_mode_by_pips)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() {
              _mode = s.first;
              _result = null;
            }),
          ),
          const SizedBox(height: 16),

          _NumField(c: _riskAmount, label: l.calc_risk_amount, signed: false),
          const SizedBox(height: 12),

          if (_mode == _Mode.byPips) ...[
            _NumField(c: _slPips, label: l.calc_sl_pips, signed: false),
          ] else ...[
            _NumField(c: _entry, label: l.calc_entry_from, signed: false),
            const SizedBox(height: 12),
            _NumField(c: _entryTo, label: l.calc_entry_to, signed: false),
            const SizedBox(height: 12),
            _NumField(c: _slPrice, label: l.calc_sl_price, signed: false),
            const SizedBox(height: 12),
            _NumField(c: _tpPrice, label: l.calc_tp_price, signed: false),
          ],
          const SizedBox(height: 12),
          _NumField(c: _pipValue, label: l.calc_pip_value, signed: false, helper: l.calc_help_pip_xau),
          const SizedBox(height: 20),

          ElevatedButton(onPressed: _calc, child: Text(l.calc_calculate)),
          const SizedBox(height: 20),

          if (_result != null) _ResultCard(result: _result!, l: l),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({required this.c, required this.label, required this.signed, this.helper});

  final TextEditingController c;
  final String label;
  final bool signed;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: signed),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]'))],
      decoration: InputDecoration(labelText: label, helperText: helper),
    );
  }
}

class _Result {
  const _Result({required this.lot, required this.risk, required this.pips, this.rr});
  final double lot;
  final double risk;
  final double pips;
  final double? rr;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.l});

  final _Result result;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.calc_result_lot, style: AppTypography.label(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              result.lot.toStringAsFixed(2),
              style: AppTypography.price(size: 36, weight: FontWeight.w700, color: AppColors.gold),
            ),
            const SizedBox(height: 12),
            _Row(label: l.calc_result_risk, value: Fmt.money(result.risk)),
            _Row(label: l.calc_sl_pips, value: result.pips.toStringAsFixed(1)),
            if (result.rr != null)
              _Row(label: l.calc_result_rr, value: '1:${result.rr!.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMedium(color: AppColors.textSecondary))),
          Text(value, style: AppTypography.price(size: 14, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
