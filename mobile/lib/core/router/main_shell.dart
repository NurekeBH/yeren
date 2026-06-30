import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../network/api_service.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) {
          // BI: бөлімге кіру оқиғасы (feature DAU/MAU). Fire-and-forget.
          if (i >= 0 && i < _tabEvents.length) ref.read(apiServiceProvider).track(_tabEvents[i]);
          navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard_outlined), activeIcon: const Icon(Icons.dashboard), label: l.nav_home),
          BottomNavigationBarItem(icon: const Icon(Icons.school_outlined), activeIcon: const Icon(Icons.school), label: l.academy_title),
          BottomNavigationBarItem(icon: const Icon(Icons.trending_up), activeIcon: const Icon(Icons.show_chart), label: l.nav_signals),
          BottomNavigationBarItem(icon: const Icon(Icons.menu_book_outlined), activeIcon: const Icon(Icons.menu_book), label: l.nav_journal),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: l.nav_profile),
        ],
      ),
    );
  }
}
