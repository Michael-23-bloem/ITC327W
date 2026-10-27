import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (order.status == 'pending') statusColor = Colors.orange;
    if (order.status == 'confirmed') statusColor = Colors.green;
    if (order.status == 'completed') statusColor = Colors.purple;//18h left , Quotation approved, declin
    if (order.status == 'declined') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: statusColor, child: const Icon(Icons.event, color: Colors.white)),
        title: Text('${order.customerEmail ?? order.customerId.substring(0, 8)} - ${order.status}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${order.eventType} - ${order.eventDate.day} ${_month(order.eventDate.month)} • ${order.venue ?? ''}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${order.hoursLeft}h left', style: TextStyle(fontSize: 12, color: order.hoursLeft < 24 ? Colors.red : Colors.grey)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: Text(order.status, style: TextStyle(fontSize: 10, color: statusColor)),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _month(int m) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m];
  }
}