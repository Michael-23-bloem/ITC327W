import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../models/order_status.dart';

const double _laptopBreakpoint = 900;

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderViewModel>().loadQuotations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderVm = context.watch<OrderViewModel>();

    // Only requests still on the 24h decision clock count toward the
    // badge. Once a request moves to in_contact or quotation_approved,
    // it's being actively worked and no longer needs an urgent nudge here
    // — it's still visible on the Requests screen either way.
    final pendingCount = orderVm.quotations
        .where((o) => o.status == OrderStatus.requestSent)
        .length;

    final cards = [
      _CardData(title: 'Portfolio', subtitle: 'Upload recent work', icon: Icons.photo_library_outlined, color: const Color(0xFF8E5BD6), route: '/portfolio'),
      _CardData(title: 'Accounts', subtitle: 'Client Reports', icon: Icons.person_outline, color: const Color(0xFF3D4451), route: '/accounts'),
      _CardData(title: 'Event Product', subtitle: 'Upload decor items', icon: Icons.restaurant, color: const Color(0xFFE2662B), route: '/decor'),
      _CardData(title: 'Quotation Requests', subtitle: 'Review and respond', icon: Icons.description_outlined, color: const Color(0xFF4A52D4), route: '/quotations', badgeCount: pendingCount),
      _CardData(title: 'Analytics', subtitle: 'Client Analytics', icon: Icons.bar_chart, color: const Color(0xFF169E8B), route: '/analytics'),
      _CardData(title: 'Bookings', subtitle: 'Client Reports', icon: Icons.bookmark_border, color: const Color(0xFF53647A), route: '/bookings'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE9E9EA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLaptop = constraints.maxWidth >= _laptopBreakpoint;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isLaptop ? 40 : 20,
                24,
                isLaptop ? 40 : 20,
                16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isLaptop ? 1100 : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AkeaEvents Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                            SizedBox(height: 4),
                            Text('Every celebration, thoughtfully managed', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    isLaptop ? _laptopGrid(context, cards) : _mobileLayout(context, cards),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Laptop: all six cards together, in one grid, Portfolio and Accounts
  // (the two cards that sit at the bottom on mobile) lead the grid.
  Widget _laptopGrid(BuildContext context, List<_CardData> cards) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 18,
      crossAxisSpacing: 18,
      childAspectRatio: 1.25,
      children: cards.map((c) => _CardTile(data: c)).toList(),
    );
  }

  // Mobile: original shape — a 2x2 grid of the four square cards, then the
  // two wide cards underneath.
  Widget _mobileLayout(BuildContext context, List<_CardData> cards) {
    final square = cards.sublist(2); // Event Product, Quotation Requests, Analytics, Bookings
    final wide = cards.sublist(0, 2); // Portfolio, Accounts

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
          children: square.map((c) => _CardTile(data: c)).toList(),
        ),
        const SizedBox(height: 16),
        ...wide.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _CardTile(data: c, wide: true),
          ),
        ),
      ],
    );
  }
}

class _CardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final int badgeCount;

  _CardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    this.badgeCount = 0,
  });
}

class _CardTile extends StatefulWidget {
  final _CardData data;
  final bool wide;

  const _CardTile({required this.data, this.wide = false});

  @override
  State<_CardTile> createState() => _CardTileState();
}

class _CardTileState extends State<_CardTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.data;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovering ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color.lerp(Colors.white, c.color, 0.08)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: c.color.withValues(alpha: _hovering ? 0.22 : 0.14),
                blurRadius: _hovering ? 22 : 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => context.go(c.route),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: widget.wide ? _wideContent(c) : _squareContent(c),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _squareContent(_CardData c) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _iconBadge(c),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(c.subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        ),
        if (c.badgeCount > 0) _badge(c.badgeCount),
      ],
    );
  }

  Widget _wideContent(_CardData c) {
    return Row(
      children: [
        _iconBadge(c),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Text(c.subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
        if (c.badgeCount > 0) _badge(c.badgeCount, inline: true),
      ],
    );
  }

  Widget _iconBadge(_CardData c) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.color.withValues(alpha: 0.9), c.color.withValues(alpha: 0.6)],
        ),
        boxShadow: [
          BoxShadow(color: c.color.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(c.icon, color: Colors.white, size: 22),
    );
  }

  Widget _badge(int count, {bool inline = false}) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      constraints: const BoxConstraints(minWidth: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE2662B), Color(0xFFB4533D)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );

    if (inline) return chip;

    return Positioned(top: 0, right: 0, child: chip);
  }
}