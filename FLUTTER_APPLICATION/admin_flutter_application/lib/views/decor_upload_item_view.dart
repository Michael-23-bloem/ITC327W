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
  final _picker = ImagePicker();

  String category = 'Chairs';
  bool _submitting = false;

  final categories = const [
    'Chairs',
    'Tables',
    'Plates',
    'Glasses',
    'Tents',
    'Candles Holders',
    'Plinths',
    'Frames & other decors',
    'Cutlery & Underplates',
  ];

  final List<_DecorItemForm> _items = [_DecorItemForm()];

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages(_DecorItemForm item) async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 85);

      if (!mounted || picked.isEmpty) return;

      setState(() {
        item.images.addAll(picked);
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not select photos: $e');
    }
  }

  Future<void> _pickOneImage(_DecorItemForm item) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (!mounted || picked == null) return;

      setState(() {
        item.images.add(picked);
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not select photo: $e');
    }
  }

  void _addItem() {
    setState(() {
      _items.add(_DecorItemForm());
    });
  }

  void _removeItem(int index) {
    if (_items.length == 1) {
      _showMessage('At least one décor item is required.');
      return;
    }

    setState(() {
      final removed = _items.removeAt(index);
      removed.dispose();
    });
  }

  void _removeImage(_DecorItemForm item, int index) {
    setState(() {
      item.images.removeAt(index);
    });
  }

  Future<void> _showPopup({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(icon, color: iconColor, size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
   void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final drafts = <DecorProductUploadDraft>[];

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];

      final name = item.name.text.trim();
      final price = double.tryParse(item.price.text.trim());
      final stockText = item.stock.text.trim();
      final stock = int.tryParse(stockText);
      final description = item.description.text.trim();

      if (name.isEmpty) {
        await _showPopup(
          title: 'Name required',
          message: 'Enter a name for item ${i + 1}.',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
        );
        return;
      }

     
     
      if (price == null || price < 0) {
        await _showPopup(
          title: 'Valid price required',
          message: 'Enter a valid, non-negative price for $name.',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
        );
        return;
      }
     /* if (price == null || price < 0) {
        _showMessage('Enter a valid, non-negative price for $name.');
        return;
      }*/

      
       if (stock == null || stock < 0) {
        await _showPopup(
          title: 'Fill in quantity',
          message: 'Enter a valid stock quantity for $name.',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
        );
        return;
      }
      /*if (stock == null || stock < 0) {
        _showMessage('Enter a valid stock quantity for $name.');
        return;
      }*/

       if (item.images.isEmpty) {
        await _showPopup(
          title: 'ADD a photo',
          message: 'Add at least one photo for $name.',
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
        );
        return;
      }
     /* if (item.images.isEmpty) {
        _showMessage('Add at least one photo for $name.');
        return;
      }*/

      drafts.add(
        DecorProductUploadDraft(
          name: name,
          description: description,
          price: price,
          stockQuantity: stock,
          images: List<XFile>.from(item.images),
        ),
      );
    }

    setState(() => _submitting = true);

    /*try {
      await context.read<DecorProductViewModel>().uploadMultipleDecorItems(
        category: category,
        items: drafts,
      );

      /*  if (!mounted) return;

      _showMessage('Décor items uploaded successfully.');
      context.go('/decor');*/
    } catch (e) {
      if (!mounted) return;

      await _showPopup(
        title: 'Upload failed',
        message:
            'Your décor items could not be uploaded.\n\n'
            '${e.toString().replaceFirst('Exception: ', '')}',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      ); /*_showMessage(
        'Upload failed: ${e.toString().replaceFirst('Exception: ', '')}',
      );*/
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }*/
    try {
  await context.read<DecorProductViewModel>().uploadMultipleDecorItems(
    category: category,
    items: drafts,
  );

  if (!mounted) return;

  await _showPopup(
    title: 'Upload complete',
    message: 'Successfully uploaded ${drafts.length} item${drafts.length == 1 ? '' : 's'}.',
    icon: Icons.check_circle_outline,
    iconColor: Colors.green,
  );

  if (!mounted) return;
  context.go('/decor');
} catch (e) {
  if (!mounted) return;

  await _showPopup(
    title: 'Upload failed',
    message: 'Your décor items could not be uploaded.\n\n'
        '${e.toString().replaceFirst('Exception: ', '')}',
    icon: Icons.error_outline,
    iconColor: Colors.red,
  );
} finally {
  if (mounted) {
    setState(() => _submitting = false);
  }
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBDBAB5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _submitting ? null : () => context.go('/decor'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Expanded(
                    child: Text(
                      'Add Décor Items',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  const Text(
                    'Add several items under one category. Each item can '
                    'have its own photos, price, stock and description.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Category for all items',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _fieldContainer(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: category,
                        items: categories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: _submitting
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() => category = value);
                                }
                              },
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  ...List.generate(
                    _items.length,
                    (index) => _buildItemCard(_items[index], index),
                  ),

                  OutlinedButton.icon(
                    onPressed: _submitting ? null : _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Décor Item'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black45),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(
                        _submitting
                            ? 'Uploading Items...'
                            : 'Upload ${_items.length} Item${_items.length == 1 ? '' : 's'}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE9448),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(_DecorItemForm item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Item ${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_items.length > 1)
                IconButton(
                  tooltip: 'Remove item',
                  onPressed: _submitting ? null : () => _removeItem(index),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          const Text('Photos', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...List.generate(
                item.images.length,
                (imageIndex) => _imagePreview(
                  item.images[imageIndex],
                  () => _removeImage(item, imageIndex),
                ),
              ),
              InkWell(
                onTap: _submitting ? null : () => _pickImages(item),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 28),
                      SizedBox(height: 4),
                      Text('Add photos', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
              /*InkWell(
                onTap: _submitting ? null : () => _pickOneImage(item),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECECEC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 28),
                      SizedBox(height: 4),
                      Text('One photo', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),*/
            ],
          ),

          const SizedBox(height: 18),

          const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _fieldContainer(
            child: TextField(
              controller: item.name,
              enabled: !_submitting,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'e.g. Chiavari Chair',
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price (R)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    _fieldContainer(
                      child: TextField(
                        controller: item.price,
                        enabled: !_submitting,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stock quantity',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    _fieldContainer(
                      child: TextField(
                        controller: item.stock,
                        enabled: !_submitting,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _fieldContainer(
            height: 110,
            child: TextField(
              controller: item.description,
              enabled: !_submitting,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Describe the item...',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePreview(XFile image, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 92,
          height: 92,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFECECEC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FutureBuilder<Uint8List>(
            future: image.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Icon(Icons.broken_image_outlined));
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: 92,
                height: 92,
              );
            },
          ),
        ),
        Positioned(
          top: 3,
          right: 3,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _submitting ? null : onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ],
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

class _DecorItemForm {
  final name = TextEditingController();
  final price = TextEditingController();
  final stock = TextEditingController();
  final description = TextEditingController();
  final List<XFile> images = [];

  void dispose() {
    name.dispose();
    price.dispose();
    stock.dispose();
    description.dispose();
  }
}
