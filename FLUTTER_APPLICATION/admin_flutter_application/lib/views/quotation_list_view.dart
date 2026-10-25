import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../models/order.dart'; // make sure this exists

class QuotationListView extends StatefulWidget {
  const QuotationListView({super.key});

  @override
  State<QuotationListView> createState() => _QuotationListViewState();
}

class _QuotationListViewState extends State<QuotationListView> {
  @override
  void initState() {
    super.initState();
    // FIXED: add mounted check to remove that warning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderViewModel>().loadQuotations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Quotation Requests')),
      body: vm.loading 
        ? const Center(child: CircularProgressIndicator()) 
        : vm.quotations.isEmpty
          ? const Center(child: Text('No pending quotations'))
          : ListView.builder(
              itemCount: vm.quotations.length,
              itemBuilder: (_, i) {
                final Order o = vm.quotations[i];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.request_quote)),
                    // FIXED: use .property not ['property']
                    title: Text('${o.customerEmail ?? 'Customer'} - ${o.status}'),
                    subtitle: Text('${o.eventType ?? 'Event'} • ${o.eventDate.day}/${o.eventDate.month} • ${o.venue ?? ''}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/quotations/${o.id}'),
                  ),
                );
              },
            ),
    );
  }
}