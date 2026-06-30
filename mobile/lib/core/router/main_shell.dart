import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../network/api_service.dart';
import '../theme/app_colors.dart';

// BI feature-audit: индекс вкладки → событие активности (DAU/MAU по разделам).
const _tabEvents = ['view_home', 'view_academy', 'view_signals', 'view_journal', 'view_profile'];

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    // Live ticker bar жоғарыдан алынды — басты бетте XAU/USD live баға (gold hero
    // card) бар, сондықтан үстіңгі таспа артық еді (user 2026-06-13).
    return Scaffold(
      body: navigationShell,
      // Премиум-навбар: единый rounded-набор (контурный → залитый при активации),
      // фиксированный тип (без «прыжков»), бренд-акцент на активной вкладке.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardSurface,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11.5),
        elevation: 8,
        onTap: (i) {
          // BI: бөлімге кіру оқиғасы (feature DAU/MAU). Fire-and-forget.
          if (i >= 0 && i < _tabEvents.length) ref.read(apiServiceProvider).track(_tabEvents[i]);
          navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.space_dashboard_outlined), activeIcon: const Icon(Icons.space_dashboard), label: l.nav_home),
          BottomNavigationBarItem(icon: const Icon(Icons.school_outlined), activeIcon: const Icon(Icons.school_rounded), label: l.academy_title),
          BottomNavigationBarItem(icon: const Icon(Icons.candlestick_chart_outlined), activeIcon: const Icon(Icons.candlestick_chart_rounded), label: l.nav_signals),
          BottomNavigationBarItem(icon: const Icon(Icons.auto_stories_outlined), activeIcon: const Icon(Icons.auto_stories_rounded), label: l.nav_journal),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline_rounded), activeIcon: const Icon(Icons.person_rounded), label: l.nav_profile),
        ],
      ),
    );
  }
}
