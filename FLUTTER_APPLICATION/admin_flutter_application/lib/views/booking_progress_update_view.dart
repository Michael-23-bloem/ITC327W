import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_viewmodel.dart';

class UpdateProgressView extends StatefulWidget {
  final String orderId;
  const UpdateProgressView({super.key, required this.orderId});
  @override
  State<UpdateProgressView> createState() => _UpdateProgressViewState();
}

class _UpdateProgressViewState extends State<UpdateProgressView> {
  final _note = TextEditingController();
  String status = 'In Progress';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update progress')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          DropdownButton<String>(value: status, items: ['Confirmed','In Progress','Completed','Delivered'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => status = v!)),
          TextField(controller: _note, decoration: InputDecoration(labelText: 'Add note')),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () async {
            await context.read<OrderViewModel>().updateProgress(widget.orderId, status, _note.text);
            if (mounted) Navigator.pop(context);
          }, child: Text('Save')),
        ]),
      ),
    );
  }
}