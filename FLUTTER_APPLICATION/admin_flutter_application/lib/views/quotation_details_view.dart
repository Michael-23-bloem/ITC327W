import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/order_item_viewmodel.dart';
import '../../models/order.dart'; // adjust path to match where your Order class actually lives

class QuotationDetailView extends StatefulWidget {
  final String orderId;
  const QuotationDetailView({super.key, required this.orderId});

  @override
  State<QuotationDetailView> createState() => _QuotationDetailViewState();
}

class _QuotationDetailViewState extends State<QuotationDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrderViewModel>().selectOrder(widget.orderId);
      context.read<OrderItemViewModel>().loadForOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderVm = context.watch<OrderViewModel>();
    final itemVm = context.watch<OrderItemViewModel>();
    final o = orderVm.selected;
    if (orderVm.loading || o == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Quotation #${o.id.substring(0, 8)}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Details: ${o.customerName ?? o.customerEmailOrId}'),
            Text('Event Overview: ${o.eventType} - ${o.eventDate.toLocal()}'),
            Text('Status: ${o.status}'),
            const SizedBox(height: 12),
            const Text('Requested items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...itemVm.items.map((it) => Text('${it.productId} x${it.quantity}')),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/quotations/${o.id}/edit'),
                  child: const Text('Edit Quotation'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => context.go('/quotations/${o.id}/validate'),
                  child: const Text('Validate Payment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}