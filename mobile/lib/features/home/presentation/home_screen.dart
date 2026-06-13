import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/language_switcher.dart';
import '../../alerts/presentation/create_alert_sheet.dart';
import '../../auth/application/auth_controller.dart';
import '../data/dashboard_repository.dart';
import 'widgets/calendar_module.dart';
import 'widgets/gold_hero_card.dart';
import 'widgets/intel_module.dart';
import 'widgets/session_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final goldAsync = ref.watch(goldQuoteProvider);
    final goldPrice = goldAsync.valueOrNull?.price ?? 2374.20;
    final auth = ref.watch(authControllerProvider);
    final isAuthed = auth.status == AuthStatus.authenticated;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        // «Главная» жазуы алынды (орынды көп алатын — төменгі навигацияда бар).
        // Оның орнына шағын ALTYN сөзбелгісі.
        title: Text('ALTYN',
            style: AppTypography.h2(color: AppColors.gold).copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w800)),
        actions: [
          if (!isAuthed) ...[
            TextButton(
              onPressed: () => context.push('/auth/phone?mode=login'),
              child: Text(l.auth_login_button, style: AppTypography.label(color: AppColors.gold)),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                onPressed: () => context.push('/auth/phone?mode=register'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: AppTypography.label(color: Colors.white),
                ),
                child: Text(l.auth_register_button),
              ),
            ),
            const SizedBox(width: 4),
          ],
          const LanguageSwitcher(),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(goldQuoteProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const SessionBanner(),
            const SizedBox(height: 12),
            goldAsync.when(
              data: (q) => GoldHeroCard(fallback: q),
              loading: () => const _CardSkeleton(height: 180),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            // Жылдам әрекеттер — 3 жинақы тайл (бұрын 3 бөлек ListTile карта еді).
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_alert,
                    label: l.home_qa_alerts,
                    onTap: () => showCreateAlertSheet(
                      context,
                      ref,
                      instrument: 'XAU/USD',
                      refPrice: goldPrice,
                      defaultText: l.alerts_default_manual('XAU/USD'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.calculate_outlined,
                    label: l.home_qa_calc,
                    onTap: () => context.push('/tools/calculator'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.event_available,
                    label: l.home_qa_events,
                    onTap: () => context.push('/events'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const CalendarModule(),
            const SizedBox(height: 12),
            const IntelModule(),
          ],
        ),
      ),
    );
  }
}

/// Басты беттегі жинақы «жылдам әрекет» тайлы (иконка + қысқа атау).
class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.gold, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, height: 1.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
