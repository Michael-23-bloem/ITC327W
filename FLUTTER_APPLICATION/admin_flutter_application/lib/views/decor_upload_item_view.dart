import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/akea_theme.dart';
import '../viewmodels/decor_product_viewmodel.dart';
import '../widgets/akea_ui.dart';

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
    return AkeaPage(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
            child: AkeaPageHeader(
              title: 'New decor item',
              subtitle: 'Add an item to the catalogue',
              actions: [
                AkeaButton(
                  label: 'Upload',
                  loading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(32, 4, 32, 24),
              children: [
                  ...List.generate(
                    _items.length,
                    (index) => _buildItemCard(_items[index], index),
                  ),
                  AkeaButton(
                    label: '+ Add another décor item',
                    style: AkeaButtonStyle.outline,
                    onPressed: _submitting ? null : _addItem,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(_DecorItemForm item, int index) {
    final photos = AkeaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(index == 0 ? 'Photos' : 'Photos · item ${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              if (_items.length > 1)
                IconButton(
                  tooltip: 'Remove item',
                  onPressed: _submitting ? null : () => _removeItem(index),
                  icon: const Icon(Icons.delete_outline, color: AkeaColors.statusDangerInk),
                ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _submitting ? null : () => _pickImages(item),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AkeaColors.cream,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AkeaColors.gold, width: 1.2),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFE8D9B0),
                    child: Icon(Icons.add, color: AkeaColors.ink),
                  ),
                  SizedBox(height: 10),
                  Text('Add photos', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text(
                    'PNG or JPG, up to 5 MB each',
                    style: TextStyle(color: AkeaColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: i < item.images.length
                        ? _imagePreview(item.images[i], () => _removeImage(item, i), expand: true)
                        : Container(
                            decoration: BoxDecoration(
                              color: AkeaColors.cream,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.image_outlined, color: AkeaColors.muted),
                          ),
                  ),
                ),
              ],
            ],
          ),
          if (item.images.length > 3) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 3; i < item.images.length; i++)
                  _imagePreview(item.images[i], () => _removeImage(item, i)),
              ],
            ),
          ],
        ],
      ),
    );

    final details = AkeaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Item details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const AkeaFieldLabel('Item name'),
          _fieldContainer(
            child: TextField(
              controller: item.name,
              enabled: !_submitting,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'e.g. Gold chiavari chair',
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (index == 0)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AkeaFieldLabel('Category'),
                      _fieldContainer(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: category,
                            items: categories
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: _submitting
                                ? null
                                : (value) {
                                    if (value != null) setState(() => category = value);
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (index == 0) const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AkeaFieldLabel('Price'),
                    _fieldContainer(
                      child: TextField(
                        controller: item.price,
                        enabled: !_submitting,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'R 0.00',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AkeaFieldLabel('Stock quantity'),
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
          const SizedBox(height: 14),
          const AkeaFieldLabel('Description'),
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
                hintText: 'Describe the item, size and colour options…',
              ),
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 860) {
            return Column(children: [photos, const SizedBox(height: 16), details]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: photos),
              const SizedBox(width: 16),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }

  Widget _imagePreview(XFile image, VoidCallback onRemove, {bool expand = false}) {
    final size = expand ? double.infinity : 92.0;
    return Stack(
      fit: expand ? StackFit.expand : StackFit.loose,
      children: [
        Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AkeaColors.cream,
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
                width: size,
                height: size,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AkeaColors.border),
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
