import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../profile/application/profile_controller.dart';
import '../application/my_signals_controller.dart';

/// Расталған трейдер идея (сигнал) жариялау формасы.
Future<void> showPublishSignalSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _PublishSheet(),
  );
}

class _PublishSheet extends ConsumerStatefulWidget {
  const _PublishSheet();

  @override
  ConsumerState<_PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends ConsumerState<_PublishSheet> {
  final _formKey = GlobalKey<FormState>();
  final _entryFrom = TextEditingController();
  final _entryTo = TextEditingController();
  final _tp1 = TextEditingController();
  final _tp2 = TextEditingController();
  final _tp3 = TextEditingController();
  final _sl = TextEditingController();
  final _confidence = TextEditingController(text: '75');
  final _analysis = TextEditingController();
  SignalDirection _direction = SignalDirection.buy;
  bool _free = false;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_entryFrom, _entryTo, _tp1, _tp2, _tp3, _sl, _confidence, _analysis]) {
      c.dispose();
    }
    super.dispose();
  }

  double _d(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  String? _num(String? v, AppLocalizations l) {
    if (v == null || v.trim().isEmpty) return l.common_error;
    if (double.tryParse(v.replaceAll(',', '.')) == null) return l.common_error;
    return null;
  }

  Future<void> _publish(AppLocalizations l) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final entryMid = (_d(_entryFrom) + _d(_entryTo)) / 2;
    final risk = (_d(_sl) - entryMid).abs();
    final reward = (_d(_tp1) - entryMid).abs();
    final rr = risk == 0 ? 0.0 : reward / risk;
    final name = ref.read(profileControllerProvider).name;
    final now = DateTime.now();
    final signal = Signal(
      id: 'my-${now.microsecondsSinceEpoch}',
      pair: 'XAU/USD',
      direction: _direction,
      entryFrom: _d(_entryFrom),
      entryTo: _d(_entryTo),
      tp1: _d(_tp1),
      tp2: _d(_tp2),
      tp3: _d(_tp3),
      sl: _d(_sl),
      rr: double.parse(rr.toStringAsFixed(2)),
      confidence: int.tryParse(_confidence.text) ?? 70,
      screenshotUrl: '',
      analysis: _analysis.text.trim(),
      status: SignalStatus.active,
      publishedAt: now,
      isFree: _free,
      isMine: true,
      authorName: name.isEmpty ? 'You' : name,
    );
    await ref.read(mySignalsProvider.notifier).publish(signal);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.signals_published)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.signals_publish_title, style: AppTypography.h2()),
              const SizedBox(height: 4),
              Text('XAU/USD', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              SegmentedButton<SignalDirection>(
                segments: [
                  ButtonSegment(value: SignalDirection.buy, label: Text(l.signals_direction_buy), icon: const Icon(Icons.trending_up)),
                  ButtonSegment(value: SignalDirection.sell, label: Text(l.signals_direction_sell), icon: const Icon(Icons.trending_down)),
                ],
                selected: {_direction},
                onSelectionChanged: (s) => setState(() => _direction = s.first),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_entryFrom, l.signals_entry_from, l)),
                const SizedBox(width: 10),
                Expanded(child: _field(_entryTo, l.signals_entry_to, l)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_tp1, l.signals_tp1, l)),
                const SizedBox(width: 10),
                Expanded(child: _field(_tp2, l.signals_tp2, l)),
                const SizedBox(width: 10),
                Expanded(child: _field(_tp3, l.signals_tp3, l)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_sl, l.signals_sl, l)),
                const SizedBox(width: 10),
                Expanded(child: _field(_confidence, l.signals_confidence, l, intOnly: true)),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _analysis,
                maxLines: 3,
                maxLength: 400,
                decoration: InputDecoration(labelText: l.signals_analysis, border: const OutlineInputBorder()),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.signals_free_idea, style: AppTypography.bodyMedium()),
                subtitle: Text(l.signals_free_idea_desc, style: AppTypography.bodySmall()),
                value: _free,
                activeThumbColor: AppColors.profitGreen,
                onChanged: (v) => setState(() => _free = v),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _busy ? null : () => _publish(l),
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.publish, size: 18),
                label: Text(l.signals_publish),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, AppLocalizations l, {bool intOnly = false}) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.numberWithOptions(decimal: !intOnly),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(intOnly ? r'[0-9]' : r'[0-9.,]'))],
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
      validator: (v) => _num(v, l),
    );
  }
}
