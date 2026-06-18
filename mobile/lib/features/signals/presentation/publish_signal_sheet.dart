import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/signal.dart';
import '../../profile/application/profile_controller.dart';
import '../application/my_signals_controller.dart';

/// Расталған трейдер идея жариялау — ЖЫЛДАМ режим:
/// график фотосы + бағыт + 1-2 сөйлем мәтін (entry/TP/SL мәтінде) + баға.
/// Деңгейлерді бір-бірлеп енгізу қажет емес (трейдер UX-і үшін жылдам).
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
  final _text = TextEditingController();
  SignalDirection _direction = SignalDirection.buy;
  RiskLevel _risk = RiskLevel.medium; // тәуекел деңгейі (сенімділікке айналады)
  int _price = 500; // 0 = тегін, 500, 1000
  String? _photoPath;
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1280);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _publish(AppLocalizations l) async {
    final text = _text.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.signals_publish_need_text)));
      return;
    }
    setState(() => _busy = true);
    final name = ref.read(profileControllerProvider).name;
    final now = DateTime.now();
    final signal = Signal(
      id: 'my-${now.microsecondsSinceEpoch}',
      pair: 'XAU/USD',
      direction: _direction,
      // Деңгейлер мәтінде — сандық өрістер 0 (hasLevels=false).
      entryFrom: 0, entryTo: 0, tp1: 0, tp2: 0, tp3: 0, sl: 0,
      rr: 0, confidence: Signal.confidenceForRisk(_risk),
      screenshotUrl: _photoPath ?? '',
      analysis: text,
      status: SignalStatus.active,
      publishedAt: now,
      isFree: _price == 0,
      isMine: true,
      authorName: name.isEmpty ? 'You' : name,
      priceOverride: _price == 0 ? null : _price,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.signals_publish_title, style: AppTypography.h2()),
            const SizedBox(height: 4),
            Text('XAU/USD', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            // График фотосы
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  image: _photoPath != null
                      ? DecorationImage(image: FileImage(File(_photoPath!)), fit: BoxFit.cover)
                      : null,
                ),
                child: _photoPath != null
                    ? null
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.gold),
                          const SizedBox(height: 8),
                          Text(l.signals_publish_add_photo, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Бағыт
            SegmentedButton<SignalDirection>(
              segments: [
                ButtonSegment(value: SignalDirection.buy, label: Text(l.signals_direction_buy), icon: const Icon(Icons.trending_up)),
                ButtonSegment(value: SignalDirection.sell, label: Text(l.signals_direction_sell), icon: const Icon(Icons.trending_down)),
              ],
              selected: {_direction},
              onSelectionChanged: (s) => setState(() => _direction = s.first),
            ),
            const SizedBox(height: 16),

            // 1-2 сөйлем мәтін (entry/TP/SL)
            TextField(
              controller: _text,
              maxLines: 3,
              maxLength: 280,
              decoration: InputDecoration(
                labelText: l.signals_publish_text,
                hintText: l.signals_publish_text_hint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Тәуекел деңгейі (сенімділіктің орнына)
            Text(l.signals_risk, style: AppTypography.label()),
            const SizedBox(height: 8),
            SegmentedButton<RiskLevel>(
              segments: [
                ButtonSegment(value: RiskLevel.low, label: Text(l.signals_risk_low_short)),
                ButtonSegment(value: RiskLevel.medium, label: Text(l.signals_risk_medium_short)),
                ButtonSegment(value: RiskLevel.high, label: Text(l.signals_risk_high_short)),
              ],
              selected: {_risk},
              onSelectionChanged: (s) => setState(() => _risk = s.first),
            ),
            const SizedBox(height: 16),

            // Баға
            Text(l.signals_price_label, style: AppTypography.label()),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(l.signals_free_badge)),
                ButtonSegment(value: 500, label: Text(l.signals_price_tg(500))),
                ButtonSegment(value: 1000, label: Text(l.signals_price_tg(1000))),
              ],
              selected: {_price},
              onSelectionChanged: (s) => setState(() => _price = s.first),
            ),
            const SizedBox(height: 16),

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
    );
  }
}
