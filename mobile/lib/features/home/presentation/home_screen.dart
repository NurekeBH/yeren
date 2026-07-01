import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/models/market_session.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/language_switcher.dart';
import '../../alerts/presentation/create_alert_sheet.dart';
import '../../auth/application/auth_controller.dart';
import '../application/streak_controller.dart';
import '../data/dashboard_repository.dart';
import 'widgets/calendar_module.dart';
import 'widgets/gold_hero_card.dart';
import 'widgets/intel_module.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final goldAsync = ref.watch(goldQuoteProvider);
    final goldPrice = goldAsync.valueOrNull?.price ?? 2374.20;
    final auth = ref.watch(authControllerProvider);
    final isAuthed = auth.status == AuthStatus.authenticated;
    final session = MarketSession.current();
    final sessionColor = Fmt.sessionColor(session);

    // Retention: при достижении награды за стрейк показываем «+50 бонусов».
    ref.listen(streakProvider, (prev, next) {
      final awarded = (next.valueOrNull?['awarded'] as num?)?.toInt() ?? 0;
      if (awarded > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.streak_reward(awarded)), backgroundColor: AppColors.profitGreen),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        // Қолданба атауы алынды. Сессия аты (сол жақ) + тіл иконкасы (оң жақ) — бір жолда.
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 18, color: sessionColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                Fmt.sessionName(session, l),
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium(color: sessionColor).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
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
          if (isAuthed) const _StreakChip(),
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

/// Огонёк-счётчик дней подряд (эффект привычки). Тап по нему запускает чек-ин
/// (провайдер), поэтому просто присутствие в appbar фиксирует заход за день.
class _StreakChip extends ConsumerWidget {
  const _StreakChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = (ref.watch(streakProvider).valueOrNull?['streak'] as num?)?.toInt() ?? 0;
    if (streak <= 0) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Tooltip(
        message: l.streak_days(streak),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text('$streak',
                  style: AppTypography.label(color: AppColors.gold).copyWith(fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
