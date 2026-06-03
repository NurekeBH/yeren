import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/subscription.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/language_switcher.dart';
import '../../auth/application/auth_controller.dart';
import '../../subscription/application/subscription_controller.dart';
import '../application/profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _pickAvatar(WidgetRef ref) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 600);
    if (file != null) {
      ref.read(profileControllerProvider.notifier).setAvatar(file.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final profile = ref.watch(profileControllerProvider);
    final sub = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.nav_profile),
        actions: const [LanguageSwitcher(), SizedBox(width: 8)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _pickAvatar(ref),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.gold,
                              backgroundImage: profile.avatarPath != null ? FileImage(File(profile.avatarPath!)) : null,
                              child: profile.avatarPath == null
                                  ? Text(
                                      (profile.name.isEmpty ? '?' : profile.name[0]).toUpperCase(),
                                      style: AppTypography.h1(color: Colors.white),
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.name.isEmpty ? '—' : profile.name, style: AppTypography.h2()),
                            const SizedBox(height: 2),
                            if (profile.city.isNotEmpty)
                              Text('📍 ${profile.city}', style: AppTypography.bodySmall()),
                            Text(auth.phone ?? '—', style: AppTypography.bodySmall(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (profile.bio.isNotEmpty) ...[
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l.profile_about_me}: ', style: AppTypography.label(color: AppColors.textSecondary)),
                        Expanded(child: Text(profile.bio, style: AppTypography.bodySmall())),
                      ],
                    ),
                  ],
                  if (profile.preferredSessions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(l.profile_preferred_sessions, style: AppTypography.label(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final s in profile.preferredSessions)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Fmt.sessionColor(s).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(Fmt.sessionName(s, l), style: AppTypography.label(color: Fmt.sessionColor(s))),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SubscriptionTile(sub: sub, l: l),
          const SizedBox(height: 16),
          _MenuItem(
            icon: Icons.notifications_outlined,
            label: l.profile_notifications,
            onTap: () => context.push('/notifications'),
          ),
          _MenuItem(
            icon: Icons.event_note,
            label: l.calendar_title,
            onTap: () => context.push('/calendar'),
          ),
          _MenuItem(
            icon: Icons.logout,
            label: l.journal_logout,
            onTap: () {
              // Logout: тек auth token өшіріледі. Профиль сақталады —
              // сол құрылғыда қайта кіргенде онбординг қажет болмайды.
              ref.read(authControllerProvider.notifier).logout();
              ref.read(subscriptionControllerProvider.notifier).reset();
            },
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({required this.sub, required this.l});
  final Subscription sub;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final (text, color, icon) = switch (sub.status) {
      SubscriptionStatus.inactive => (l.subscription_inactive, AppColors.lossRed, Icons.lock_outline),
      SubscriptionStatus.pendingReview => (l.subscription_pending, AppColors.gold, Icons.hourglass_top),
      SubscriptionStatus.active => (l.subscription_active, AppColors.profitGreen, Icons.verified),
      SubscriptionStatus.expired => (l.subscription_inactive, AppColors.lossRed, Icons.lock_outline),
    };
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => GoRouter.of(context).push('/subscription'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600, color: color)),
                    if (sub.daysLeft != null && sub.isActive)
                      Text(l.subscription_expires_in(sub.daysLeft!), style: AppTypography.bodySmall()),
                    if (sub.status == SubscriptionStatus.inactive)
                      Text(l.subscription_get_access, style: AppTypography.bodySmall()),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.gold),
        title: Text(label, style: AppTypography.bodyMedium()),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
