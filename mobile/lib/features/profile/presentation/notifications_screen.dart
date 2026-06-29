import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/city_field.dart';
import '../application/profile_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final profile = ref.watch(profileControllerProvider);
    final ctrl = ref.read(profileControllerProvider.notifier);

    final items = [
      (NotificationCategory.signals, l.notif_signals, l.notif_signals_desc, Icons.lightbulb_outline, AppColors.gold),
      (NotificationCategory.events, l.notif_events, l.notif_events_desc, Icons.event_available_outlined, AppColors.gold),
      (NotificationCategory.intel, l.notif_intel, l.notif_intel_desc, Icons.bolt, AppColors.gold),
      (NotificationCategory.calendar, l.notif_calendar, l.notif_calendar_desc, Icons.event, AppColors.gold),
      (NotificationCategory.academy, l.notif_academy, l.notif_academy_desc, Icons.school_outlined, AppColors.gold),
      (NotificationCategory.broker, l.notif_broker, l.notif_broker_desc, Icons.account_balance_wallet_outlined, AppColors.gold),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.notif_title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.add_alert, size: 18, color: AppColors.gold),
              ),
              title: Text(l.alerts_title, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(l.alerts_add, style: AppTypography.bodySmall()),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              onTap: () => context.push('/alerts'),
            ),
          ),
          const SizedBox(height: 12),
          for (final (cat, title, desc, icon, color) in items)
            _NotifTile(
              icon: icon,
              color: color,
              title: title,
              description: desc,
              value: profile.notifications.isOn(cat),
              onChanged: (_) => ctrl.toggleNotification(cat),
            ),
          // Оқиға push детальді сүзгісі (events қосулы болса).
          if (profile.notifications.isOn(NotificationCategory.events)) _EventFilters(l: l),
          const SizedBox(height: 20),
          _NotifTile(
            icon: Icons.bedtime_outlined,
            color: AppColors.gold,
            title: l.notif_dnd,
            description: l.notif_dnd_desc,
            value: profile.notifications.dndUntilMorning,
            onChanged: (_) => ctrl.toggleDnd(),
          ),
        ],
      ),
    );
  }
}

/// Оқиға push детальді сүзгілері — backend prefs-ке тікелей жазады (ev_city/free/online/type).
/// Бос болса барлық оқиғаға push (жалпы режим). Толтырса — тек сәйкес оқиғаларға.
class _EventFilters extends ConsumerStatefulWidget {
  const _EventFilters({required this.l});
  final AppLocalizations l;
  @override
  ConsumerState<_EventFilters> createState() => _EventFiltersState();
}

class _EventFiltersState extends ConsumerState<_EventFilters> {
  String _city = '';
  bool _freeOnly = false;
  bool _onlineOnly = false;
  String _type = ''; // '', masterclass, live_trade, webinar
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ref.read(apiServiceProvider).notificationPrefs();
      if (!mounted) return;
      setState(() {
        _city = (p['ev_city'] ?? '').toString();
        _freeOnly = p['ev_free_only'] == true;
        _onlineOnly = p['ev_online_only'] == true;
        _type = (p['ev_type'] ?? '').toString();
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  void _patch(Map<String, dynamic> body) {
    ref.read(apiServiceProvider).updateNotificationPrefs(body).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    if (!_loaded) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.notif_events_filter, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700)),
            Text(l.notif_events_filter_hint, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            CityField(
              initial: _city,
              label: l.events_filter_city,
              onChanged: (v) {
                _city = v;
                _patch({'ev_city': v.trim()});
              },
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(l.events_filter_free, style: AppTypography.bodyMedium()),
              value: _freeOnly,
              activeThumbColor: AppColors.gold,
              onChanged: (v) {
                setState(() => _freeOnly = v);
                _patch({'ev_free_only': v});
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(l.events_filter_online, style: AppTypography.bodyMedium()),
              value: _onlineOnly,
              activeThumbColor: AppColors.gold,
              onChanged: (v) {
                setState(() => _onlineOnly = v);
                _patch({'ev_online_only': v});
              },
            ),
            Row(
              children: [
                Text('${l.notif_events_type}: ', style: AppTypography.bodyMedium()),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _type,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: '', child: Text(l.events_filter_all)),
                    DropdownMenuItem(value: 'masterclass', child: Text(l.event_type_masterclass)),
                    DropdownMenuItem(value: 'live_trade', child: Text(l.event_type_live)),
                    DropdownMenuItem(value: 'webinar', child: Text(l.event_type_webinar)),
                  ],
                  onChanged: (v) {
                    setState(() => _type = v ?? '');
                    _patch({'ev_type': v ?? ''});
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                    Text(description, style: AppTypography.bodySmall()),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
