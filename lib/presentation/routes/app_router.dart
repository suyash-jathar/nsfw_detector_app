import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/scan/result_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/tips/tips_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../core/models/scan_result.dart';
import '../navigation/main_navigation.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String result = '/result';
  static const String history = '/history';
  static const String tips = '/tips';
  static const String settings = '/settings';

  static final router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            MainNavigation(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: home,
            pageBuilder: (_, state) => _noTransitionPage(
              state, const HomeScreen(),
            ),
          ),
          GoRoute(
            path: scan,
            pageBuilder: (_, state) => _noTransitionPage(
              state, const ScanScreen(),
            ),
          ),
          GoRoute(
            path: history,
            pageBuilder: (_, state) => _noTransitionPage(
              state, const HistoryScreen(),
            ),
          ),
          GoRoute(
            path: tips,
            pageBuilder: (_, state) => _noTransitionPage(
              state, const TipsScreen(),
            ),
          ),
          GoRoute(
            path: settings,
            pageBuilder: (_, state) => _noTransitionPage(
              state, const SettingsScreen(),
            ),
          ),
        ],
      ),
      // Result is outside shell so it gets a full-screen push
      GoRoute(
        path: result,
        builder: (context, state) {
          final scanResult = state.extra as ScanResult?;
          return ResultScreen(result: scanResult!);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );

  static NoTransitionPage<void> _noTransitionPage(
    GoRouterState state,
    Widget child,
  ) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
}
