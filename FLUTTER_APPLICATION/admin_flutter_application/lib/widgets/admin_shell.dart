import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/akea_theme.dart';
import 'akea_ui.dart';

const Color kAdminBg = AkeaColors.bg;
const Color kAdminAccent = AkeaColors.purple;
const Color kAdminBrown = AkeaColors.gold;

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.location,
    required this.matchPrefixes,
  });

  final String label;
  final IconData icon;
  final String location;
  final List<String> matchPrefixes;
}

const _destinations = [
  _Destination(
    label: 'Home',
    icon: Icons.home_outlined,
    location: '/dashboard',
    matchPrefixes: ['/dashboard'],
  ),
  _Destination(
    label: 'Requests',
    icon: Icons.description_outlined,
    location: '/quotations',
    matchPrefixes: ['/quotations'],
  ),
  _Destination(
    label: 'Bookings',
    icon: Icons.calendar_month_outlined,
    location: '/bookings',
    matchPrefixes: ['/bookings'],
  ),
  _Destination(
    label: 'Products',
    icon: Icons.inventory_2_outlined,
    location: '/decor/upload',
    matchPrefixes: ['/decor'],
  ),
  _Destination(
    label: 'Analytics',
    icon: Icons.bar_chart_outlined,
    location: '/analytics',
    matchPrefixes: ['/analytics'],
  ),
  _Destination(
    label: 'Portfolio',
    icon: Icons.photo_outlined,
    location: '/portfolio/upload',
    matchPrefixes: ['/portfolio'],
  ),
  _Destination(
    label: 'Accounts',
    icon: Icons.person_outline,
    location: '/accounts',
    matchPrefixes: ['/accounts'],
  ),
];

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static int _selectedIndex(String location) {
    for (var i = 0; i < _destinations.length; i++) {
      for (final prefix in _destinations[i].matchPrefixes) {
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
    final index = _selectedIndex(location);

    if (!wide) {
      return Scaffold(
        backgroundColor: AkeaColors.bg,
        drawer: Drawer(
          backgroundColor: AkeaColors.sidebar,
          child: _Sidebar(
            selectedIndex: index,
            onSelect: (i) {
              Navigator.pop(context);
              context.go(_destinations[i].location);
            },
            onSignOut: () => _signOut(context),
          ),
        ),
        appBar: AppBar(
          backgroundColor: AkeaColors.sidebar,
          foregroundColor: Colors.white,
          title: const Text('AkeaEvents Admin'),
        ),
        body: child,
      );
    }

    return Scaffold(
      backgroundColor: AkeaColors.bg,
      body: Row(
        children: [
          SizedBox(
            width: 232,
            child: _Sidebar(
              selectedIndex: index,
              onSelect: (i) => context.go(_destinations[i].location),
              onSignOut: () => _signOut(context),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.onSelect,
    required this.onSignOut,
  });

  final int selectedIndex;
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'ADMIN',
                        style: GoogleFonts.sourceSans3(
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
              for (var i = 0; i < _destinations.length; i++)
                _NavTile(
                  destination: _destinations[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelect(i),
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
                        backgroundColor: AkeaColors.purple,
                        child: Text(
                          'A',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin',
                            style: GoogleFonts.sourceSans3(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Sign out',
                            style: GoogleFonts.sourceSans3(
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

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? AkeaColors.sidebarSelected : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(destination.icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  destination.label,
                  style: GoogleFonts.sourceSans3(
                    color: Colors.white,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
