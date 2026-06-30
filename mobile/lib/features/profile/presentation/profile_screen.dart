import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/language_switcher.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_controller.dart';
import 'promo_section.dart';
import 'support_sheet.dart';
import 'trader_application_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Аватар суреті: тұрақты URL (Supabase) болса — желіден, әйтпесе жергілікті файл.
  ImageProvider _avatarImage(String path) =>
      path.startsWith('http') ? NetworkImage(path) : FileImage(File(path));

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    // Контекст-тәуелді нысандарды кез келген await-қа дейін ұстап аламыз.
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 600);
    if (file == null) return;
    // Бірден жергілікті жолды көрсетеміз (тез әрі офлайн), сосын серверге жүктейміз.
    ref.read(profileControllerProvider.notifier).setAvatar(file.path);
    try {
      final url = await ref.read(apiServiceProvider).uploadImage(file.path);
      ref.read(profileControllerProvider.notifier).setAvatar(url);
      messenger.showSnackBar(SnackBar(content: Text(l.profile_avatar_updated)));
    } catch (e) {
      // Сәтсіз болса — шынайы қатені көрсетеміз (формат/өлшем/желі), «жалған сәттілік» жоқ.
      messenger.showSnackBar(SnackBar(content: Text(friendlyErrorText(e, l))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final profile = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.nav_profile),
        actions: [
          IconButton(
            tooltip: l.profile_edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
          const LanguageSwitcher(),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileControllerProvider.notifier).hydrateFromRemote(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                        onTap: () => _pickAvatar(context, ref),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.gold,
                              backgroundImage: profile.avatarPath != null ? _avatarImage(profile.avatarPath!) : null,
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
                  if (profile.styles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(l.onboarding_style_label, style: AppTypography.label(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final s in profile.styles)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.purple.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(tradingStyleLabel(s, l), style: AppTypography.label(color: AppColors.purple)),
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
          // «Менің бонустарым» — ықшам тілке, толық бетке өтеді (/bonuses).
          const BonusBalanceTile(),
          // Расталған трейдер: расталса — мәртебе; әйтпесе — өтінім беру.
          if (profile.isVerifiedTrader)
            Card(
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.profitGreen.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.verified, size: 18, color: AppColors.profitGreen),
                ),
                title: Text(l.profile_verified_trader, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(l.profile_verified_trader_desc, style: AppTypography.bodySmall()),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            )
          else
            _MenuItem(
              icon: Icons.verified_user_outlined,
              label: l.profile_become_trader,
              onTap: () => showTraderApplicationSheet(context),
            ),
          // Трейдер: өзі жариялаған идеялар (белсенді/жабық) мен жазбалар.
          if (profile.isVerifiedTrader)
            _MenuItem(
              icon: Icons.campaign_outlined,
              label: l.my_publications,
              onTap: () => context.push('/profile/publications'),
            ),
          // Админ: BI-дашборд (бизнес-аналитика). Тек админ қолданушыға көрінеді.
          if (profile.isAdmin)
            _MenuItem(
              icon: Icons.insights_outlined,
              label: 'BI Dashboard',
              onTap: () => context.push('/admin/dashboard'),
            ),
          _MenuItem(
            icon: Icons.bookmark_outline,
            label: l.profile_saved,
            onTap: () => context.push('/library/saved'),
          ),
          _MenuItem(
            icon: Icons.notifications_outlined,
            label: l.profile_notifications,
            onTap: () => context.push('/notifications'),
          ),
          _MenuItem(
            icon: Icons.description_outlined,
            label: l.agreement_title,
            onTap: () => context.push('/legal/agreement'),
          ),
          _MenuItem(
            icon: Icons.support_agent_outlined,
            label: l.profile_support,
            onTap: () => showSupportSheet(context),
          ),
          _MenuItem(
            icon: Icons.logout,
            label: l.journal_logout,
            onTap: () {
              // Logout: тек auth token өшіріледі. Профиль сақталады —
              // сол құрылғыда қайта кіргенде онбординг қажет болмайды.
              ref.read(authControllerProvider.notifier).logout();
              // Явная навигация (redirect-ке тәуелсіз) — басты бетке қайтамыз.
              if (context.mounted) context.go('/home');
            },
          ),
          // Аккаунтты жою — Apple App Store талабы бойынша қол жетімді болуы керек,
          // бірақ ҚОЛДАНУШЫЛАР БАЙҚАУСЫЗ ЖОЙМАСЫН деп көзге түспейтін кіші мәтін
          // (үлкен қызыл батырма емес).
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => _confirmDeleteAccount(context, ref, l),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l.profile_delete_account,
                style: AppTypography.label(color: AppColors.textMuted)
                    .copyWith(fontSize: 12, decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
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

/// Аккаунтты жою растауы — қайтарымсыз әрекет.
Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref, AppLocalizations l) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.profile_delete_account),
      content: Text(l.profile_delete_account_warning),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.common_cancel)),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l.profile_delete_account_confirm, style: const TextStyle(color: AppColors.lossRed)),
        ),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await ref.read(authControllerProvider.notifier).deleteAccount();
  } catch (_) {/* best-effort — локалдан шығып кетеміз */}
  if (context.mounted) context.go('/home');
}
