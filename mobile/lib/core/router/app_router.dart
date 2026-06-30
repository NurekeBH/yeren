import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/academy/presentation/course_detail_screen.dart';
import '../../features/academy/presentation/course_lesson_screen.dart';
import '../../features/academy/presentation/courses_screen.dart';
import '../../features/academy/presentation/video_course_screen.dart';
import '../../features/academy/presentation/exam_screen.dart';
import '../../features/academy/presentation/gallup_result_screen.dart';
import '../../features/academy/presentation/gallup_test_screen.dart';
import '../../features/academy/presentation/lesson_detail_screen.dart';
import '../../features/academy/presentation/library_detail_screen.dart';
import '../../features/academy/presentation/library_screen.dart';
import '../../features/academy/presentation/saved_library_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/provider/presentation/provider_dashboard_screen.dart';
import '../../features/alerts/presentation/price_alerts_screen.dart';
import '../../features/tools/presentation/position_calculator_screen.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/password_screen.dart';
import '../../features/auth/presentation/phone_screen.dart';
import '../../features/auth/presentation/user_agreement_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/events/presentation/event_detail_screen.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/intel/presentation/intel_screen.dart';
import '../../features/journal/presentation/accounts_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/journal/presentation/link_broker_screen.dart';
import '../../features/onboarding/application/intro_controller.dart';
import '../../features/onboarding/presentation/intro_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/profile/application/profile_controller.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/bonuses_screen.dart';
import '../../features/profile/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/signals/presentation/my_publications_screen.dart';
import '../../features/signals/presentation/provider_detail_screen.dart';
import '../../features/signals/presentation/signal_detail_screen.dart';
import '../../features/signals/presentation/signals_screen.dart';
import '../../shared/widgets/auth_guard.dart';
import 'main_shell.dart';

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, _) => notifyListeners());
    _ref.listen<UserProfile>(profileControllerProvider, (_, _) => notifyListeners());
    _ref.listen<bool>(introControllerProvider, (_, _) => notifyListeners());
  }
  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final profile = ref.read(profileControllerProvider);
      final introSeen = ref.read(introControllerProvider);
      final path = state.matchedLocation;

      // Splash өзі таймермен негізгі ағынға өтеді — redirect араласпайды.
      if (path == '/splash') return null;

      // Бірінші іске қосу: таныстыру слайдтарын көрсетеміз (auth-қа дейін).
      if (!introSeen) return path == '/intro' ? null : '/intro';
      if (path == '/intro') return '/home';

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
      // Брендтелген splash (бірінші экран)
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),

      // Бірінші іске қосудағы таныстыру (intro)
      GoRoute(path: '/intro', builder: (_, _) => const IntroScreen()),

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
          country: s.uri.queryParameters['country'],
        ),
      ),
      GoRoute(path: '/auth/onboarding', builder: (_, _) => const OnboardingScreen()),

      // Protected push routes — AuthGuard артына жасырылады
      GoRoute(
        path: '/signals/:id',
        builder: (_, s) => AuthGuard(child: SignalDetailScreen(signalId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/providers/:id',
        builder: (_, s) => AuthGuard(child: ProviderDetailScreen(providerId: s.pathParameters['id']!)),
      ),
      GoRoute(path: '/intel', builder: (_, _) => const AuthGuard(child: IntelScreen())),
      GoRoute(path: '/calendar', builder: (_, _) => const AuthGuard(child: CalendarScreen())),
      GoRoute(path: '/notifications', builder: (_, _) => const AuthGuard(child: NotificationsScreen())),
      GoRoute(path: '/profile/edit', builder: (_, _) => const AuthGuard(child: EditProfileScreen())),
      GoRoute(path: '/profile/publications', builder: (_, _) => const AuthGuard(child: MyPublicationsScreen())),
      GoRoute(path: '/bonuses', builder: (_, _) => const AuthGuard(child: BonusesScreen())),
      GoRoute(path: '/alerts', builder: (_, _) => const AuthGuard(child: PriceAlertsScreen())),
      // BI-дашборд — тек админ JWT эндпоинттерін шақырады; кіру пунктін Профильде
      // тек isAdmin қолданушыға көрсетеміз (қосымша қорғаныс — серверде requireAdmin).
      GoRoute(path: '/admin/dashboard', builder: (_, _) => const AuthGuard(child: AdminDashboardScreen())),
      // Кабинет трейдера (статистика/баланс/выплаты) — пункт в Профиле виден только верифиц. трейдеру.
      GoRoute(path: '/provider/dashboard', builder: (_, _) => const AuthGuard(child: ProviderDashboardScreen())),
      GoRoute(path: '/legal/agreement', builder: (_, _) => const UserAgreementScreen(showAccept: false)),
      GoRoute(path: '/events', builder: (_, _) => const AuthGuard(child: EventsScreen())),
      GoRoute(
        path: '/events/:id',
        builder: (_, s) => AuthGuard(child: EventDetailScreen(eventId: s.pathParameters['id']!)),
      ),
      GoRoute(path: '/accounts', builder: (_, _) => const AuthGuard(child: AccountsScreen())),
      GoRoute(path: '/accounts/link', builder: (_, _) => const AuthGuard(child: LinkBrokerScreen())),
      GoRoute(path: '/academy/test', builder: (_, _) => const AuthGuard(child: GallupTestScreen())),
      GoRoute(path: '/academy/test/result', builder: (_, _) => const AuthGuard(child: GallupResultScreen())),
      GoRoute(path: '/academy/library', builder: (_, _) => const AuthGuard(child: LibraryScreen())),
      GoRoute(path: '/library/saved', builder: (_, _) => const AuthGuard(child: SavedLibraryScreen())),
      GoRoute(
        path: '/academy/library/:id',
        builder: (_, s) => AuthGuard(child: LibraryDetailScreen(itemId: s.pathParameters['id']!)),
      ),
      GoRoute(path: '/tools/calculator', builder: (_, _) => const AuthGuard(child: PositionCalculatorScreen())),
      GoRoute(
        path: '/academy/lesson/:id',
        builder: (_, s) => AuthGuard(child: LessonDetailScreen(lessonId: s.pathParameters['id']!)),
      ),
      // Премиум-курстар (Академия): тізім → курс деталі → сабақ (интерактив + тест).
      GoRoute(path: '/academy/courses', builder: (_, _) => const AuthGuard(child: CoursesScreen())),
      GoRoute(
        path: '/academy/video-course/:id',
        builder: (_, s) => AuthGuard(child: VideoCourseScreen(courseId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/academy/course/:id',
        builder: (_, s) => AuthGuard(child: CourseDetailScreen(courseId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/academy/course/:id/lesson/:lessonId',
        builder: (_, s) => AuthGuard(
          child: CourseLessonScreen(
            courseId: s.pathParameters['id']!,
            lessonId: s.pathParameters['lessonId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/academy/course/:id/exam',
        builder: (_, s) => AuthGuard(child: ExamScreen(courseId: s.pathParameters['id']!)),
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          // Edge Academy табы — әдепкіде Библиотека (кітаптар/фильмдер). Сабақтар алынды (user сұрауы).
          StatefulShellBranch(routes: [GoRoute(path: '/academy-tab', builder: (_, _) => const AuthGuard(child: LibraryScreen()))]),
          StatefulShellBranch(routes: [GoRoute(path: '/signals', builder: (_, _) => const AuthGuard(child: SignalsScreen()))]),
          StatefulShellBranch(routes: [GoRoute(path: '/journal', builder: (_, _) => const AuthGuard(child: JournalScreen()))]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const AuthGuard(child: ProfileScreen()))]),
        ],
      ),
    ],
  );
});
