import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/academy/presentation/academy_screen.dart';
import '../../features/academy/presentation/gallup_result_screen.dart';
import '../../features/academy/presentation/gallup_test_screen.dart';
import '../../features/academy/presentation/lesson_detail_screen.dart';
import '../../features/academy/presentation/library_detail_screen.dart';
import '../../features/academy/presentation/library_screen.dart';
import '../../features/tools/presentation/position_calculator_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/password_screen.dart';
import '../../features/auth/presentation/phone_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/intel/presentation/intel_screen.dart';
import '../../features/journal/presentation/accounts_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/journal/presentation/link_broker_screen.dart';
import '../../features/profile/application/profile_controller.dart';
import '../../features/profile/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/signals/presentation/signal_detail_screen.dart';
import '../../features/signals/presentation/signals_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';
import '../../shared/widgets/auth_guard.dart';
import 'main_shell.dart';

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, _) => notifyListeners());
    _ref.listen<UserProfile>(profileControllerProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: listenable,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final profile = ref.read(profileControllerProvider);
      final path = state.matchedLocation;

      // Authenticated, бірақ onboarding өтпеген: міндетті түрде onboarding
      if (auth.status == AuthStatus.authenticated && !profile.isOnboarded) {
        return path == '/auth/onboarding' ? null : '/auth/onboarding';
      }
      // Authenticated + onboarded: auth экрандарға қажет жоқ
      if (auth.status == AuthStatus.authenticated && path.startsWith('/auth')) {
        return '/home';
      }
      return null;
    },
    routes: [
      // Auth экрандары — push арқылы ашылады
      GoRoute(
        path: '/auth/phone',
        builder: (_, s) => PhoneScreen(mode: s.uri.queryParameters['mode'] ?? 'register'),
      ),
      GoRoute(
        path: '/auth/password',
        builder: (_, s) => PasswordScreen(
          mode: s.uri.queryParameters['mode'] ?? 'register',
          phone: s.uri.queryParameters['phone'] ?? '',
        ),
      ),
      GoRoute(path: '/auth/onboarding', builder: (_, _) => const OnboardingScreen()),

      // Protected push routes — AuthGuard артына жасырылады
      GoRoute(
        path: '/signals/:id',
        builder: (_, s) => AuthGuard(child: SignalDetailScreen(signalId: s.pathParameters['id']!)),
      ),
      GoRoute(path: '/subscription', builder: (_, _) => const AuthGuard(child: SubscriptionScreen())),
      GoRoute(path: '/intel', builder: (_, _) => const AuthGuard(child: IntelScreen())),
      GoRoute(path: '/calendar', builder: (_, _) => const AuthGuard(child: CalendarScreen())),
      GoRoute(path: '/notifications', builder: (_, _) => const AuthGuard(child: NotificationsScreen())),
      GoRoute(path: '/accounts', builder: (_, _) => const AuthGuard(child: AccountsScreen())),
      GoRoute(path: '/accounts/link', builder: (_, _) => const AuthGuard(child: LinkBrokerScreen())),
      GoRoute(path: '/academy/test', builder: (_, _) => const AuthGuard(child: GallupTestScreen())),
      GoRoute(path: '/academy/test/result', builder: (_, _) => const AuthGuard(child: GallupResultScreen())),
      GoRoute(path: '/academy/library', builder: (_, _) => const AuthGuard(child: LibraryScreen())),
      GoRoute(
        path: '/academy/library/:id',
        builder: (_, s) => AuthGuard(child: LibraryDetailScreen(itemId: s.pathParameters['id']!)),
      ),
      GoRoute(path: '/tools/calculator', builder: (_, _) => const AuthGuard(child: PositionCalculatorScreen())),
      GoRoute(
        path: '/academy/lesson/:id',
        builder: (_, s) => AuthGuard(child: LessonDetailScreen(lessonId: s.pathParameters['id']!)),
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/academy-tab', builder: (_, _) => const AuthGuard(child: AcademyScreen()))]),
          StatefulShellBranch(routes: [GoRoute(path: '/signals', builder: (_, _) => const AuthGuard(child: SignalsScreen()))]),
          StatefulShellBranch(routes: [GoRoute(path: '/journal', builder: (_, _) => const AuthGuard(child: JournalScreen()))]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const AuthGuard(child: ProfileScreen()))]),
        ],
      ),
    ],
  );
});
