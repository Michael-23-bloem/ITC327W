import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/decor_product_viewmodel.dart';

class DecorUploadItemView extends StatefulWidget {
  const DecorUploadItemView({super.key});

  @override
  State<DecorUploadItemView> createState() => _UploadDecorViewState();
}

class _UploadDecorViewState extends State<DecorUploadItemView> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _desc = TextEditingController();
  final _picker = ImagePicker();

  String category = 'Chairs';
  final List<XFile?> _images = [null, null, null, null];

  final categories = const ['Chairs', 'Tables', 'Draping', 'Lighting', 'Tents', 'Crockery'];

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _images[index] = picked);
    }
  }

  Future<void> _submit() async {
    final selected = _images.whereType<XFile>().toList();
    final price = double.tryParse(_price.text.trim());

    if (selected.isEmpty || _name.text.trim().isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one image, a name and a valid price')),
      );
      return;
    }

    final vm = context.read<DecorProductViewModel>();
    await vm.uploadDecorWithImages(
      images: selected,
      name: _name.text.trim(),
      category: category,
      description: _desc.text.trim(),
      price: price,
      stockQuantity: int.tryParse(_stock.text.trim()) ?? 0,
    );

    if (mounted) context.go('/decor');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DecorProductViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFBDBAB5),
      body: SafeArea(
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  const Text(
                    'Add Décor Item',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1,
                    children: List.generate(1, (i) => _imageSlot(i)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  _fieldContainer(
                    child: TextField(
                      controller: _name,
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'e.g. Chiavari Chair'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            _fieldContainer(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: category,
                                  items: categories
                                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                      .toList(),
                                  onChanged: (v) => setState(() => category = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Price', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            _fieldContainer(
                              child: TextField(
                                controller: _price,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(border: InputBorder.none, hintText: 'R0.00'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Stock quantity', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  _fieldContainer(
                    child: TextField(
                      controller: _stock,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  _fieldContainer(
                    height: 110,
                    child: TextField(
                      controller: _desc,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Describe the item...'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE9448),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Upload'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _imageSlot(int index) {
    final image = _images[index];
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: image == null
            ? Center(
                child: Icon(
                  index == 0 ? Icons.add : Icons.image_outlined,
                  size: 32,
                  color: Colors.black45,
                ),
              )
            : FutureBuilder<Uint8List>(
                future: image.readAsBytes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  return Image.memory(snapshot.data!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
                },
              ),
      ),
    );
  }

  Widget _fieldContainer({required Widget child, double height = 48}) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}