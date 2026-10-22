import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OwnerDashboardView extends StatelessWidget {
  const OwnerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: GridView.count(
        crossAxisCount: 2, padding: EdgeInsets.all(16),
        children: [
          _card(context, 'Quotations', '/quotations', Icons.request_quote),
          _card(context, 'Bookings', '/bookings', Icons.book_online),
          _card(context, 'Accounts', '/accounts', Icons.people),
          _card(context, 'Upload Decor', '/decor/upload', Icons.chair),
          _card(context, 'Portfolio', '/portfolio', Icons.photo_library),
        ],
      ),
    );
  }

  Widget _card(BuildContext ctx, String title, String route, IconData icon) {
    return Card(child: InkWell(onTap: () => ctx.go(route), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 40), SizedBox(height: 8), Text(title)])));
  }
}