import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hashiru/app/shell/custom_widgets.dart';
import 'package:hashiru/core/theme/app_theme.dart';

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
    } else if (location.startsWith(AppRoutes.calendar)) {
      currentIndex = 2;
    } else if (location.startsWith(AppRoutes.analytics)) {
      currentIndex = 3;
    } else if (location.startsWith(AppRoutes.profile)) {
      currentIndex = 4;
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
              context.go(AppRoutes.calendar);
              break;
            case 3:
              context.go(AppRoutes.analytics);
              break;
            case 4:
              context.go(AppRoutes.profile);
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/home_outlined.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/home_filled.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/history_outlined.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/history_filled.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
            label: 'History',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/calendar_outlined.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/calendar_filled.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/analytics_outlined.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/analytics_filled.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/profile_outlined.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/profile_filled.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
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
