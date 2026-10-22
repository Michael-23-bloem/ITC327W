import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../models/order.dart'; // adjust path to wherever your Order class actually lives

class BookingDetailView extends StatefulWidget {
  final String orderId;
  const BookingDetailView({super.key, required this.orderId});

  @override
  State<BookingDetailView> createState() => _BookingDetailViewState();
}

class _BookingDetailViewState extends State<BookingDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderViewModel>().selectOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final o = vm.selected;
    if (vm.loading || o == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Booking #${o.id.substring(0, 8)}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event: ${o.eventType}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Customer: ${o.customerName ?? o.customerEmailOrId}'),
            Text('Date: ${o.eventDate.toLocal()}'),
            if (o.venue != null) Text('Venue: ${o.venue}'),
            Text('Guests: ${o.guestCount}'),
            Text('Status: ${o.status}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/bookings/${o.id}/requests'),
              child: const Text('Ongoing requests'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/bookings/${o.id}/progress'),
              child: const Text('Update progress'),
            ),
          ],
        ),
      ),
    );
  }
}