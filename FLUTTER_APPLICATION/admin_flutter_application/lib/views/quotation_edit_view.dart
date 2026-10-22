import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_viewmodel.dart';

class QuotationEditView extends StatefulWidget {
  final String orderId;
 const QuotationEditView({super.key, required this.orderId});
  @override
  State<QuotationEditView> createState() => _EditQuotationViewState();
}

class _EditQuotationViewState extends State<QuotationEditView> {
  final _total = TextEditingController();
  final _transport = TextEditingController();
  final _service = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Quotation')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _total, decoration: InputDecoration(labelText: 'Total Price')),
          TextField(controller: _transport, decoration: InputDecoration(labelText: 'Transport fee - Package / Transport fee')),
          TextField(controller: _service, decoration: InputDecoration(labelText: 'Service fee')),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () async {
            await context.read<OrderViewModel>().editQuotation(widget.orderId, double.tryParse(_total.text) ?? 0, double.tryParse(_transport.text) ?? 0, double.tryParse(_service.text) ?? 0);
            if (mounted) Navigator.pop(context);
          }, child: Text('Save')),
        ]),
      ),
    );
  }
}