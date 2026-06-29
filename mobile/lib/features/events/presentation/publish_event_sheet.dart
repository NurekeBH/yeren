import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/trading_event.dart';
import '../../../shared/widgets/city_field.dart';
import '../../profile/application/profile_controller.dart';
import '../application/my_events_controller.dart';
import 'events_screen.dart' show eventDate;

/// Расталған трейдер іс-шара жариялау формасы.
Future<void> showPublishEventSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _PublishEventSheet(),
  );
}

class _PublishEventSheet extends ConsumerStatefulWidget {
  const _PublishEventSheet();

  @override
  ConsumerState<_PublishEventSheet> createState() => _PublishEventSheetState();
}

class _PublishEventSheetState extends ConsumerState<_PublishEventSheet> {
  final _title = TextEditingController();
  String _cityValue = ''; // CityField autocomplete мәні
  final _price = TextEditingController(text: '0');
  final _desc = TextEditingController();
  EventType _type = EventType.masterclass;
  bool _online = false;
  DateTime _date = DateTime.now().add(const Duration(days: 3));
  String? _posterPath; // таңдалған мұқаба (жергілікті жол, кейін жүктеледі)
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    if (!mounted) return;
    setState(() => _date = DateTime(d.year, d.month, d.day, t?.hour ?? 19, t?.minute ?? 0));
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1280);
    if (file != null) setState(() => _posterPath = file.path);
  }

  Future<void> _publish(AppLocalizations l) async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.event_need_title)));
      return;
    }
    setState(() => _busy = true);
    final name = ref.read(profileControllerProvider).name;
    // Мұқабаны серверге жүктейміз (сәтсіз болса — жергілікті жол, офлайн көрінеді).
    var poster = _posterPath ?? '';
    if (poster.isNotEmpty && !poster.startsWith('http')) {
      final url = await ref.read(apiServiceProvider).uploadImage(poster);
      if (url != null) poster = url;
    }
    final now = DateTime.now();
    final event = TradingEvent(
      id: 'ev-${now.microsecondsSinceEpoch}',
      type: _type,
      title: title,
      speaker: name.isEmpty ? 'You' : name,
      city: _online ? 'Online' : (_cityValue.trim().isEmpty ? '—' : _cityValue.trim()),
      dateIso: _date.toIso8601String(),
      price: double.tryParse(_price.text.replaceAll(',', '.')) ?? 0,
      isOnline: _online,
      description: _desc.text.trim(),
      posterUrl: poster.isEmpty ? null : poster,
      isMine: true,
    );
    await ref.read(myEventsProvider.notifier).publish(event);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.event_published)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final dateLabel = eventDate(_date.toIso8601String());

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.event_publish_title, style: AppTypography.h2()),
            const SizedBox(height: 16),
            // Түрі
            SegmentedButton<EventType>(
              segments: [
                ButtonSegment(value: EventType.masterclass, label: Text(l.event_type_masterclass)),
                ButtonSegment(value: EventType.liveTrade, label: Text(l.event_type_live)),
                ButtonSegment(value: EventType.webinar, label: Text(l.event_type_webinar)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 12),
            // Мұқаба (афиша) — қалауыңша
            _CoverPicker(path: _posterPath, onPick: _pickPhoto, onClear: () => setState(() => _posterPath = null)),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: l.event_field_title, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            // Күн + уақыт
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(labelText: l.event_field_date, border: const OutlineInputBorder()),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Text(dateLabel, style: AppTypography.bodyMedium()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Онлайн / қала
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.event_field_online, style: AppTypography.bodyMedium()),
              value: _online,
              activeThumbColor: AppColors.gold,
              onChanged: (v) => setState(() => _online = v),
            ),
            if (!_online) ...[
              CityField(
                initial: _cityValue,
                label: l.event_field_city,
                onChanged: (v) => _cityValue = v,
              ),
              const SizedBox(height: 12),
            ],
            // Баға (0 = тегін)
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: InputDecoration(labelText: l.event_field_price, helperText: l.event_field_price_help, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(labelText: l.event_field_desc, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _busy ? null : () => _publish(l),
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.publish, size: 18),
              label: Text(l.event_publish),
            ),
          ],
        ),
      ),
    );
  }
}

/// Іс-шара мұқабасын (афиша) таңдау — таңдалса алдын ала көрсетеді.
class _CoverPicker extends StatelessWidget {
  const _CoverPicker({required this.path, required this.onPick, required this.onClear});
  final String? path;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.image_outlined, size: 18),
        label: const Text('Добавить обложку (необязательно)'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.border),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: path!.startsWith('http')
                ? Image.network(path!, fit: BoxFit.cover)
                : Image.file(File(path!), fit: BoxFit.cover),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Row(
              children: [
                _MiniBtn(icon: Icons.edit, onTap: onPick),
                const SizedBox(width: 6),
                _MiniBtn(icon: Icons.close, onTap: onClear),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  const _MiniBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
