import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Color kAdminBg = Color(0xFFE8E4DE);
const Color kAdminAccent = Color(0xFF6A1B9A);
const Color kAdminBrown = Color(0xFFB5651D);

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
    selectedIcon: Icons.home,
    location: '/dashboard',
    matchPrefixes: ['/dashboard', '/decor', '/bookings', '/portfolio'],
  ),
  _Destination(
    label: 'Requests',
    icon: Icons.chat_bubble_outline,
    selectedIcon: Icons.chat_bubble,
    location: '/quotations',
    matchPrefixes: ['/quotations'],
  ),
  _Destination(
    label: 'Analytics',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    location: '/analytics',
    matchPrefixes: ['/analytics'],
  ),
  _Destination(
    label: 'Account',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    location: '/accounts',
    matchPrefixes: ['/accounts'],
  ),
];

const _desktopDestinations = [
  _Destination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    location: '/dashboard',
    matchPrefixes: ['/dashboard'],
  ),
  _Destination(
    label: 'Requests',
    icon: Icons.description_outlined,
    selectedIcon: Icons.description,
    location: '/quotations',
    matchPrefixes: ['/quotations'],
  ),
  _Destination(
    label: 'Bookings',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    location: '/bookings',
    matchPrefixes: ['/bookings'],
  ),
  _Destination(
    label: 'Analytics',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    location: '/analytics',
    matchPrefixes: ['/analytics'],
  ),
  _Destination(
    label: 'Decor',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
    location: '/decor/upload',
    matchPrefixes: ['/decor'],
  ),
  _Destination(
    label: 'Portfolio',
    icon: Icons.photo_library_outlined,
    selectedIcon: Icons.photo_library,
    location: '/portfolio',
    matchPrefixes: ['/portfolio'],
  ),
  _Destination(
    label: 'Accounts',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    location: '/accounts',
    matchPrefixes: ['/accounts'],
  ),
];

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static int _selectedIndex(String location, List<_Destination> destinations) {
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
            NavigationRail(
              scrollable: true,
              selectedIndex: index,
              backgroundColor: Colors.white,
              indicatorColor: kAdminAccent.withValues(alpha: 0.12),
              selectedIconTheme: const IconThemeData(color: kAdminAccent),
              selectedLabelTextStyle: const TextStyle(
                color: kAdminAccent,
                fontWeight: FontWeight.w700,
              ),
              unselectedIconTheme: const IconThemeData(color: Colors.black54),
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(Icons.event_seat, color: kAdminAccent, size: 28),
                    SizedBox(height: 6),
                    Text(
                      'Akea',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
              ),
              onDestinationSelected: (i) =>
                  context.go(_desktopDestinations[i].location),
              destinations: [
                for (final d in _desktopDestinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
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
        backgroundColor: Colors.white,
        selectedItemColor: kAdminAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (i) => context.go(_mobileDestinations[i].location),
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
