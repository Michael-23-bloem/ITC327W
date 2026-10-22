import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/portfolio_viewmodel.dart';

class PortfolioUploadEventView extends StatefulWidget {
  const PortfolioUploadEventView({super.key});

  @override
  State<PortfolioUploadEventView> createState() => _UploadEventViewState();
}

class _UploadEventViewState extends State<PortfolioUploadEventView> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _image = TextEditingController();
  String category = 'Wedding';

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PortfolioViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Upload event images')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Choose past event - Name')),
            DropdownButton<String>(
              value: category,
              items: ['Wedding', 'Birthday', 'Corporate']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: _image, decoration: const InputDecoration(labelText: 'Link to event - Image_url')),
            const SizedBox(height: 20),
            vm.loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      final viewModel = context.read<PortfolioViewModel>();
                      await viewModel.uploadEvent(
                        productId: '1',
                        name: _name.text,
                        category: category,
                        description: _desc.text,
                        imageUrl: _image.text,
                      );
                      if (mounted) context.go('/portfolio');
                    },
                    child: const Text('Upload'),
                  ),
          ],
        ),
      ),
    );
  }
}