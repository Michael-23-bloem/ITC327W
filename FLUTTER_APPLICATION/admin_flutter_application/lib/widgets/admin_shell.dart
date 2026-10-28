
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Akea Events theme
const Color kAdminBg = Color(0xFFF8F4ED);
const Color kAdminAccent = Color(0xFFB58A45);
const Color kAdminBrown = Color(0xFF4A3425);
const Color kAdminSurface = Color(0xFFFFFFFF);
const Color kAdminText = Color(0xFF34291F);

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.location,
    required this.matchPrefixes,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String location;
  final List<String> matchPrefixes;
}

const _mobileDestinations = [
  _Destination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    location: '/dashboard',
    matchPrefixes: [
      '/dashboard',
      '/decor',
      '/bookings',
      '/portfolio',
    ],
  ),
  _Destination(
    label: 'Requests',
    icon: Icons.description_outlined,
    selectedIcon: Icons.description_rounded,
    location: '/quotations',
    matchPrefixes: ['/quotations'],
  ),
  _Destination(
    label: 'Analytics',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart_rounded,
    location: '/analytics',
    matchPrefixes: ['/analytics'],
  ),
  _Destination(
    label: 'Account',
    icon: Icons.person_outline,
    selectedIcon: Icons.person_rounded,
    location: '/accounts',
    matchPrefixes: ['/accounts'],
  ),
];

const _desktopDestinations = [
  _Destination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    location: '/dashboard',
    matchPrefixes: ['/dashboard'],
  ),
  _Destination(
    label: 'Requests',
    icon: Icons.description_outlined,
    selectedIcon: Icons.description_rounded,
    location: '/quotations',
    matchPrefixes: ['/quotations'],
  ),
  _Destination(
    label: 'Bookings',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month_rounded,
    location: '/bookings',
    matchPrefixes: ['/bookings'],
  ),
  _Destination(
    label: 'Analytics',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart_rounded,
    location: '/analytics',
    matchPrefixes: ['/analytics'],
  ),
  _Destination(
    label: 'Decor',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2_rounded,
    location: '/decor/upload',
    matchPrefixes: ['/decor'],
  ),
  _Destination(
    label: 'Portfolio',
    icon: Icons.photo_library_outlined,
    selectedIcon: Icons.photo_library_rounded,
    location: '/portfolio',
    matchPrefixes: ['/portfolio'],
  ),
  _Destination(
    label: 'Accounts',
    icon: Icons.people_outline,
    selectedIcon: Icons.people_rounded,
    location: '/accounts',
    matchPrefixes: ['/accounts'],
  ),
];

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  static int _selectedIndex(
    String location,
    List<_Destination> destinations,
  ) {
    for (var i = 0; i < destinations.length; i++) {
      for (final prefix in destinations[i].matchPrefixes) {
        if (location == prefix || location.startsWith('$prefix/')) {
          return i;
        }
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    if (wide) {
      final index = _selectedIndex(location, _desktopDestinations);

      return Scaffold(
        backgroundColor: kAdminBg,
        body: Row(
          children: [
            Container(
              width: 180,
              color: kAdminSurface,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Icon(
                    Icons.event_seat_rounded,
                    color: kAdminAccent,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Akea Events',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: kAdminBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ADMIN PANEL',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: kAdminAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  Expanded(
                    child: NavigationRail(
                      extended: true,
                      minExtendedWidth: 180,
                      selectedIndex: index,
                      backgroundColor: kAdminSurface,
                      indicatorColor: kAdminAccent.withOpacity(0.16),
                      selectedIconTheme: const IconThemeData(
                        color: kAdminBrown,
                      ),
                      unselectedIconTheme: const IconThemeData(
                        color: Color(0xFF8A8177),
                      ),
                      selectedLabelTextStyle: const TextStyle(
                        color: kAdminBrown,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      unselectedLabelTextStyle: const TextStyle(
                        color: Color(0xFF71675D),
                        fontSize: 13,
                      ),
                      labelType: NavigationRailLabelType.none,
                      useIndicator: true,
                      onDestinationSelected: (i) {
                        context.go(_desktopDestinations[i].location);
                      },
                      destinations: [
                        for (final d in _desktopDestinations)
                          NavigationRailDestination(
                            icon: Icon(d.icon),
                            selectedIcon: Icon(d.selectedIcon),
                            label: Text(d.label),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.spa_outlined,
                          color: kAdminAccent,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Creating beautiful moments',
                            style: TextStyle(
                              color: kAdminBrown,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color(0xFFE9E0D4),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    final index = _selectedIndex(location, _mobileDestinations);

    return Scaffold(
      backgroundColor: kAdminBg,
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: kAdminSurface,
        selectedItemColor: kAdminBrown,
        unselectedItemColor: const Color(0xFF8A8177),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        onTap: (i) {
          context.go(_mobileDestinations[i].location);
        },
        items: [
          for (final d in _mobileDestinations)
            BottomNavigationBarItem(
              icon: Icon(d.icon),
              activeIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
