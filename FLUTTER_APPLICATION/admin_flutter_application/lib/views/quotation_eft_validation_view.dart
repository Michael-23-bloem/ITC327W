import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_viewmodel.dart';

class ValidatePaymentView extends StatelessWidget {
  final String orderId;
  const ValidatePaymentView({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Validate EFT Payment')),
      body: Center(
        child: ElevatedButton(onPressed: () async {
          await context.read<OrderViewModel>().validateEft(orderId);
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Validated & Converted to Booking')));
        }, child: Text('Validate & Convert to Booking')),
      ),
    );
  }
}