import 'package:flutter/material.dart';

import '../../data/session/session_manager.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentRoute,
  });

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final session = SessionManager.instance.currentUser;
    final isAdmin = session?.isAdmin ?? false;

    final navItems = <_NavItem>[
      const _NavItem(
        route: '/home',
        label: 'Home',
        icon: Icons.home_outlined,
      ),
      const _NavItem(
        route: '/community',
        label: 'Público',
        icon: Icons.people_outline,
      ),
      const _NavItem(
        route: '/profile',
        label: 'Perfil',
        icon: Icons.person_outline,
      ),
    ];

    if (isAdmin) {
      navItems.add(
        const _NavItem(
          route: '/members',
          label: 'Membros',
          icon: Icons.groups_outlined,
        ),
      );
    }

    final resolvedIndex = _resolveIndex(currentRoute, navItems);

    return BottomNavigationBar(
      currentIndex: resolvedIndex,
      selectedItemColor: const Color(0xFFFF9F43),
      unselectedItemColor: const Color(0xFFC8CCD8),
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
      items: navItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
      onTap: (index) {
        if (index == resolvedIndex) return;
        final routeName = navItems[index].route;
        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }

  int _resolveIndex(String route, List<_NavItem> items) {
    final foundIndex = items.indexWhere((item) => item.route == route);
    if (foundIndex >= 0) {
      return foundIndex;
    }
    return 0;
  }
}

class _NavItem {
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
  });

  final String route;
  final String label;
  final IconData icon;
}
