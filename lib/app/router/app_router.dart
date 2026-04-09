import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/activity/presentation/pages/recording_page.dart';
import '../../features/activity/presentation/pages/activity_detail_page.dart';
import '../../features/activity/presentation/pages/activity_history_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../core/constants/app_routes.dart';
import '../shell/home_shell.dart';
import '../../features/home/presentation/pages/home_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, __) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.record,
      builder: (_, __) => const RecordingPage(),
    ),
    GoRoute(
      path: '/activity/:id',
      builder: (_, state) => ActivityDetailPage(
        activityId: state.pathParameters['id']!,
      ),
    ),
    ShellRoute(
      builder: (_, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.history,
          builder: (_, __) => const ActivityHistoryPage(),
        ),
        GoRoute(
          path: AppRoutes.analytics,
          builder: (_, __) => const AnalyticsPage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (_, __) => const ProfilePage(),
        ),
      ],
    ),
  ],
);
