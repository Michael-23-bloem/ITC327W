import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_viewmodel.dart';

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
    final pendingCount = orderVm.quotations.length; // already filtered to status='pending' in the viewmodel

    return Scaffold(
      backgroundColor: const Color(0xFFE9E9EA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AkeaEvents Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                      SizedBox(height: 4),
                      Text('Every celebration, throughtfully managed', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.deepPurple),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  _squareCard(context, title: 'Event Product', subtitle: 'Upload decor items', icon: Icons.restaurant, iconColor: Colors.deepOrange, route: '/decor/upload'),
                  _squareCard(context, title: 'Quotation Requests', subtitle: 'Review and respond', icon: Icons.description_outlined, iconColor: Colors.indigo, route: '/quotations', badgeCount: pendingCount),
                  _squareCard(context, title: 'Analytics', subtitle: 'Client Analytics', icon: Icons.bar_chart, iconColor: Colors.teal, route: '/analytics'),
                  _squareCard(context, title: 'Bookings', subtitle: 'Client Reports', icon: Icons.bookmark_border, iconColor: Colors.blueGrey, route: '/bookings'),
                ],
              ),
              const SizedBox(height: 16),
              _wideCard(context, title: 'Portfolio', subtitle: 'Upload recent work', icon: Icons.photo_library_outlined, iconColor: Colors.purple, route: '/portfolio'),
              const SizedBox(height: 16),
              _wideCard(context, title: 'Accounts', subtitle: 'Client Reports', icon: Icons.person_outline, iconColor: Colors.black87, route: '/accounts'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _squareCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color iconColor, required String route, int badgeCount = 0}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go(route),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(radius: 22, backgroundColor: iconColor.withValues(alpha: 0.12), child: Icon(icon, color: iconColor, size: 22)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  constraints: const BoxConstraints(minWidth: 22),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 3, offset: const Offset(0, 1))],
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _wideCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color iconColor, required String route}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(radius: 22, backgroundColor: iconColor.withValues(alpha: 0.12), child: Icon(icon, color: iconColor, size: 22)),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}