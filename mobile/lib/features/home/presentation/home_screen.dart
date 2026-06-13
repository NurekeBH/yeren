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
            Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.add_alert, color: AppColors.gold),
                ),
                title: Text(l.alerts_title, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(l.home_alert_sub, style: AppTypography.bodySmall()),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: () => showCreateAlertSheet(
                  context,
                  ref,
                  instrument: 'XAU/USD',
                  refPrice: goldPrice,
                  defaultText: l.alerts_default_manual('XAU/USD'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const CalendarModule(),
            const SizedBox(height: 12),
            _PositionCalcCard(l: l),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.event_available, color: AppColors.gold),
                ),
                title: Text(l.home_events, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(l.home_events_sub, style: AppTypography.bodySmall()),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: () => context.push('/events'),
              ),
            ),
            const SizedBox(height: 12),
            const IntelModule(),
          ],
        ),
      ),
    );
  }
}

/// Басты беттегі «Позиция калькуляторы» жылдам сілтемесі.
class _PositionCalcCard extends StatelessWidget {
  const _PositionCalcCard({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calculate_outlined, color: AppColors.gold),
        ),
        title: Text(
          l.tools_position_calc,
          style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(l.tools_position_calc_subtitle, style: AppTypography.bodySmall()),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: () => context.push('/tools/calculator'),
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
