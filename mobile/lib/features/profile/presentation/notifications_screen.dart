import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
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
