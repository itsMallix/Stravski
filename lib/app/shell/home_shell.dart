import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stravski/app/shell/custom_widgets.dart';
import 'package:stravski/core/theme/app_theme.dart';

import '../../core/constants/app_routes.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final colorScheme = Theme.of(context).colorScheme;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.history)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.analytics)) {
      currentIndex = 2;
    } else if (location.startsWith(AppRoutes.profile)) {
      currentIndex = 3;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              context.go(AppRoutes.history);
              break;
            case 2:
              context.go(AppRoutes.analytics);
              break;
            case 3:
              context.go(AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: currentIndex == 0
          ? GestureDetector(
              onTap: () => context.push(AppRoutes.record),
              child: CustomPaint(
                painter: CustomRecordButton(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.play_arrow_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Start Run',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
