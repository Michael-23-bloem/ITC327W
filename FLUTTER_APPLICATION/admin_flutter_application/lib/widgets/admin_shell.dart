import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/akea_theme.dart';
import 'akea_ui.dart';

const Color kAdminBg = AkeaColors.bg;
const Color kAdminAccent = AkeaColors.plum;
const Color kAdminBrown = AkeaColors.ink;
const Color kAdminSurface = AkeaColors.card;
const Color kAdminText = AkeaColors.ink;

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
    matchPrefixes: ['/dashboard', '/decor', '/bookings', '/portfolio'],
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
    location: '/decor',
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

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    if (wide) {
      final index = _selectedIndex(location, _desktopDestinations);
      return Scaffold(
        backgroundColor: AkeaColors.bg,
        body: Row(
          children: [
            SizedBox(
              width: 232,
              child: _Sidebar(
                selectedIndex: index,
                destinations: _desktopDestinations,
                onSelect: (i) => context.go(_desktopDestinations[i].location),
                onSignOut: () => _signOut(context),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    final index = _selectedIndex(location, _mobileDestinations);
    return Scaffold(
      backgroundColor: AkeaColors.bg,
      body: child,
      bottomNavigationBar: _GoldPillTabBar(
        index: index,
        destinations: _mobileDestinations,
        onSelect: (i) => context.go(_mobileDestinations[i].location),
      ),
    );
  }
}

class _GoldPillTabBar extends StatelessWidget {
  const _GoldPillTabBar({
    required this.index,
    required this.destinations,
    required this.onSelect,
  });

  final int index;
  final List<_Destination> destinations;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AkeaColors.card,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onSelect(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: i == index
                                  ? AkeaColors.gold.withValues(alpha: 0.28)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              i == index
                                  ? destinations[i].selectedIcon
                                  : destinations[i].icon,
                              color: i == index
                                  ? AkeaColors.plum
                                  : AkeaColors.muted,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destinations[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  i == index ? FontWeight.w700 : FontWeight.w500,
                              color: i == index
                                  ? AkeaColors.plum
                                  : AkeaColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelect,
    required this.onSignOut,
  });

  final int selectedIndex;
  final List<_Destination> destinations;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AkeaColors.sidebar,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AkeaLogoMark(size: 36),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AkeaEvents',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'ADMIN',
                        style: GoogleFonts.inter(
                          color: AkeaColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              for (var i = 0; i < destinations.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: i == selectedIndex
                        ? AkeaColors.sidebarSelected
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => onSelect(i),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              i == selectedIndex
                                  ? destinations[i].selectedIcon
                                  : destinations[i].icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              destinations[i].label,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: i == selectedIndex
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              InkWell(
                onTap: onSignOut,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AkeaColors.plum,
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Sign out',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
