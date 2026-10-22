import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/decor_product_viewmodel.dart';

class DecorUploadItemView extends StatefulWidget {
  const DecorUploadItemView({super.key});

  @override
  State<DecorUploadItemView > createState() => _UploadDecorViewState();
}

class _UploadDecorViewState extends State<DecorUploadItemView > {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  String category = 'Chairs';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DecorProductViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text('Upload Décor')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: InputDecoration(labelText: 'Add Decor Details - Name')),
          TextField(controller: _price, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          DropdownButton<String>(value: category, items: ['Chairs','Tables','Draping','Lighting'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => category = v!)),
          TextField(controller: _desc, decoration: InputDecoration(labelText: 'Description')),
          SizedBox(height: 20),
          vm.loading ? CircularProgressIndicator() : ElevatedButton(onPressed: () async {
            await vm.uploadDecor({
              'Name': _name.text,
              'Price': double.tryParse(_price.text) ?? 0,
              'Category': category,
              'Description': _desc.text,
            });
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved')));
          }, child: Text('Save')),
        ]),
      ),
    );
  }
}