import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/order_viewmodel.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({super.key});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderViewModel>().loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings - Past bookings')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vm.bookings.length,
              itemBuilder: (_, i) {
                final o = vm.bookings[i];
                return ListTile(
                  title: Text(o.eventType),
                  subtitle: Text('${o.eventDate.toLocal()} - ${o.status}'),
                  onTap: () => context.go('/bookings/${o.id}'),
                );
              },
            ),
    );
  }
}