import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/editor/ui/editor_screen.dart';
import '../features/history/ui/history_screen.dart';
import '../features/onboarding/ui/onboarding_screen.dart';
import '../features/reading/ui/reading_result_screen.dart';
import '../features/reference/ui/reference_screen.dart';
import '../features/scanner/ui/scanner_screen.dart';
import '../features/settings/ui/settings_screen.dart';

GoRouter buildRouter({bool onboardingCompleted = false}) => GoRouter(
  initialLocation: onboardingCompleted ? '/scanner' : '/onboarding',
  routes: [
    // Onboarding (full-screen, outside shell)
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scanner',
              builder: (context, state) => const ScannerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reference',
              builder: (context, state) => const ReferenceScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Full-screen routes (outside the shell)
    GoRoute(
      path: '/editor/:scanId',
      builder: (context, state) {
        final scanId = int.parse(state.pathParameters['scanId']!);
        return EditorScreen(scanId: scanId);
      },
    ),
    GoRoute(
      path: '/result/:scanId',
      builder: (context, state) {
        final scanId = int.parse(state.pathParameters['scanId']!);
        return ReadingResultScreen(scanId: scanId);
      },
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.back_hand_outlined),
            selectedIcon: Icon(Icons.back_hand),
            label: 'Сканер',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'История',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Справочник',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
