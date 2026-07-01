import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';

/// «Как тебе комфортно работать?» — частота + стиль + фокус-часы.
/// Данные → user_psyche_preferences (учитываются при пуш-кампаниях на бэкенде).
class PsychePreferencesScreen extends ConsumerStatefulWidget {
  const PsychePreferencesScreen({super.key});

  @override
  ConsumerState<PsychePreferencesScreen> createState() => _PsychePreferencesScreenState();
}

class _PsychePreferencesScreenState extends ConsumerState<PsychePreferencesScreen> {
  String _frequency = 'every';
  String _style = 'direct';
  bool _focus = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ref.read(apiServiceProvider).psychePrefs();
      if (!mounted) return;
      setState(() {
        _frequency = (p['frequency'] ?? 'every').toString();
        _style = (p['style'] ?? 'direct').toString();
        _focus = p['focus_hours'] != false;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    // TZ-смещение телефона (мин) — для фокус-часов на сервере.
    final tz = DateTime.now().timeZoneOffset.inMinutes;
    try {
      await ref.read(apiServiceProvider).updatePsyche({
        'frequency': _frequency,
        'style': _style,
        'focus_hours': _focus,
        'tz_offset_min': tz,
      });
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.psyche_saved)));
    } catch (_) {/* тихо */} finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.psyche_title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _Group(
                  title: l.psyche_freq,
                  options: [('every', l.psyche_freq_every), ('summary', l.psyche_freq_summary)],
                  value: _frequency,
                  onChanged: (v) => setState(() => _frequency = v),
                ),
                const SizedBox(height: 20),
                _Group(
                  title: l.psyche_style,
                  options: [('direct', l.psyche_style_direct), ('gamified', l.psyche_style_gamified)],
                  value: _style,
                  onChanged: (v) => setState(() => _style = v),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  value: _focus,
                  onChanged: (v) => setState(() => _focus = v),
                  activeThumbColor: AppColors.gold,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.psyche_focus, style: AppTypography.bodyMedium()),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.common_save),
                ),
              ],
            ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.options, required this.value, required this.onChanged});
  final String title;
  final List<(String, String)> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h2().copyWith(fontSize: 16)),
        const SizedBox(height: 10),
        for (final (v, label) in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(v),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: value == v ? AppColors.gold.withValues(alpha: 0.10) : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: value == v ? AppColors.gold : AppColors.border, width: value == v ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Icon(value == v ? Icons.radio_button_checked : Icons.radio_button_off,
                        size: 20, color: value == v ? AppColors.gold : AppColors.textMuted),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
