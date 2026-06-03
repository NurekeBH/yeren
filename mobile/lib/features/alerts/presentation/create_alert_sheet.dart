import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/price_alert.dart';
import '../application/price_alert_controller.dart';

/// Баға ескертуін жасау sheet-і. Идеядан да, қолмен де ашылады.
Future<void> showCreateAlertSheet(
  BuildContext context,
  WidgetRef ref, {
  required String instrument,
  required double refPrice,
  String? ideaId,
  String? defaultText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.obsidian,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CreateAlertSheet(
      instrument: instrument,
      refPrice: refPrice,
      ideaId: ideaId,
      defaultText: defaultText,
    ),
  );
}

enum _Mode { pips, price }

class _CreateAlertSheet extends ConsumerStatefulWidget {
  const _CreateAlertSheet({
    required this.instrument,
    required this.refPrice,
    this.ideaId,
    this.defaultText,
  });

  final String instrument;
  final double refPrice;
  final String? ideaId;
  final String? defaultText;

  @override
  ConsumerState<_CreateAlertSheet> createState() => _CreateAlertSheetState();
}

class _CreateAlertSheetState extends ConsumerState<_CreateAlertSheet> {
  _Mode _mode = _Mode.pips;
  late final TextEditingController _pips = TextEditingController(text: '50');
  late final TextEditingController _price =
      TextEditingController(text: widget.refPrice.toStringAsFixed(2));
  late final TextEditingController _text =
      TextEditingController(text: widget.defaultText ?? '');

  @override
  void dispose() {
    _pips.dispose();
    _price.dispose();
    _text.dispose();
    super.dispose();
  }

  void _create(AppLocalizations l) {
    final pips = double.tryParse(_pips.text.replaceAll(',', '.'));
    final price = double.tryParse(_price.text.replaceAll(',', '.'));
    final isPips = _mode == _Mode.pips;
    final target = isPips ? widget.refPrice : (price ?? widget.refPrice);

    final alert = PriceAlert(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      instrument: widget.instrument,
      targetPrice: target,
      pips: isPips ? (pips ?? 50) : null,
      ideaId: widget.ideaId,
      text: _text.text.trim().isEmpty
          ? (widget.defaultText ?? '${widget.instrument} ${target.toStringAsFixed(2)}')
          : _text.text.trim(),
      createdAtIso: DateTime.now().toIso8601String(),
    );
    ref.read(priceAlertControllerProvider.notifier).add(alert);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.alerts_created)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.notifications_active, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(l.alerts_notify, style: AppTypography.h2()),
            ],
          ),
          const SizedBox(height: 4),
          Text('${widget.instrument} · ${widget.refPrice.toStringAsFixed(2)}',
              style: AppTypography.bodySmall(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          SegmentedButton<_Mode>(
            segments: [
              ButtonSegment(value: _Mode.pips, label: Text(l.alerts_mode_pips)),
              ButtonSegment(value: _Mode.price, label: Text(l.alerts_mode_price)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: 16),
          if (_mode == _Mode.pips)
            _NumField(c: _pips, label: l.alerts_pips_hint)
          else
            _NumField(c: _price, label: l.alerts_price_hint),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l.alerts_text_hint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _create(l),
              icon: const Icon(Icons.add_alert, size: 18),
              label: Text(l.alerts_create),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({required this.c, required this.label});
  final TextEditingController c;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
