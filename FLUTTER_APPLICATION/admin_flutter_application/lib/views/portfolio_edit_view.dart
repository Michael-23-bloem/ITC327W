
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../models/portfolio.dart';
import '../viewmodels/portfolio_viewmodel.dart';

class PortfolioEditView extends StatefulWidget {
  final Portfolio portfolio;

  const PortfolioEditView({
    super.key,
    required this.portfolio,
  });

  @override
  State<PortfolioEditView> createState() =>
      _PortfolioEditViewState();
}

class _PortfolioEditViewState extends State<PortfolioEditView> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _price;

  final ImagePicker _picker = ImagePicker();

  static const int maxImages = 4;

  // Existing URLs and newly selected files occupy matching slots.
  final List<String?> _imageUrls =
      List<String?>.filled(maxImages, null);

  final List<XFile?> _newImages =
      List<XFile?>.filled(maxImages, null);

  late String category;

  final Set<String> selectedProductIds = {};

  bool _initialLoading = true;
  bool _saving = false;

  final List<String> categories = const [
    'Wedding',
    'Birthday',
    'Corporate',
    'Baby Shower',
    'Anniversary',
  ];

  @override
  void initState() {
    super.initState();

    final p = widget.portfolio;

    _name = TextEditingController(text: p.name ?? '');
    _desc = TextEditingController(text: p.description ?? '');
    _price = TextEditingController(
      text: p.price?.toStringAsFixed(2) ?? '',
    );

    category = categories.contains(p.category)
        ? p.category!
        : categories.first;

    // The portfolio table stores the cover image.
    _imageUrls[0] = p.imageUrl;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final vm = context.read<PortfolioViewModel>();

        await vm.loadAvailableProducts();

        final results = await Future.wait([
          vm.getProductIdsForPortfolio(p.id),
          vm.loadDetail(p.id),
        ]);

        final existingIds = results[0] as List<String>;
        final details = results[1] as Map<String, dynamic>;
        final extraImages =
            List<String>.from(details['images'] as List);

        if (!mounted) return;

        setState(() {
          selectedProductIds.addAll(existingIds);

          // Additional pictures follow the cover image.
          for (int i = 0;
              i < extraImages.length && i < maxImages - 1;
              i++) {
            _imageUrls[i + 1] = extraImages[i];
          }

          _initialLoading = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() => _initialLoading = false);

        await _showPopup(
          title: 'Loading failed',
          message: 'Could not load portfolio details.\n\n$e',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
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

  Future<void> _pickImage(int index) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (!mounted || picked == null) return;

    setState(() {
      _newImages[index] = picked;
      _imageUrls[index] = null;
    });
  }

  void _removeImage(int index) {
    final imageCount = List.generate(maxImages, (i) {
      return _newImages[i] != null || _imageUrls[i] != null;
    }).where((hasImage) => hasImage).length;

    if (imageCount <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'At least one event picture must remain.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _newImages[index] = null;
      _imageUrls[index] = null;
    });
  }

  Widget _imageSlot(int index) {
    final newImage = _newImages[index];
    final existingUrl = _imageUrls[index];
    final hasImage = newImage != null || existingUrl != null;

    Widget imageWidget;

    if (newImage != null) {
      imageWidget = FutureBuilder<Uint8List>(
        future: newImage.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        },
      );
    } else if (existingUrl != null) {
      imageWidget = Image.network(
        existingUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image_outlined, size: 36),
          );
        },
      );
    } else {
      imageWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: Colors.black54,
            ),
            const SizedBox(height: 6),
            Text(
              index == 0 ? 'Add cover image' : 'Add picture',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,
            if (hasImage)
              Positioned(
                top: 4,
                right: 4,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Remove picture',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _removeImage(index),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            if (index == 0)
              const Positioned(
                left: 6,
                bottom: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.all(
                      Radius.circular(6),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    child: Text(
                      'Cover',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      await _showPopup(
        title: 'Event name required',
        message: 'Please enter an event name before saving.',
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange,
      );
      return;
    }

    final priceText = _price.text.trim();
    final parsedPrice =
        priceText.isEmpty ? null : double.tryParse(priceText);

    if (priceText.isNotEmpty &&
        (parsedPrice == null || parsedPrice < 0)) {
      await _showPopup(
        title: 'Invalid price',
        message: 'Please enter a valid, non-negative price.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
      return;
    }

    final imageCount = List.generate(maxImages, (i) {
      return _newImages[i] != null || _imageUrls[i] != null;
    }).where((hasImage) => hasImage).length;

    if (imageCount == 0) {
      await _showPopup(
        title: 'Picture required',
        message: 'Please keep at least one event picture.',
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange,
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final vm = context.read<PortfolioViewModel>();

      await vm.updatePortfolio(
        id: widget.portfolio.id,
        name: _name.text.trim(),
        category: category,
        description: _desc.text.trim(),
        price: parsedPrice,
        productIds: selectedProductIds.toList(),
        imageFiles: List<XFile?>.from(_newImages),
        existingImageUrls: List<String?>.from(_imageUrls),
      );

      if (!mounted) return;

      await _showPopup(
        title: 'Update successful',
        message: 'Your event details and pictures have been saved.',
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      await _showPopup(
        title: 'Update failed',
        message: 'Your changes could not be saved.\n\n$e',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PortfolioViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit portfolio item'),
        backgroundColor: const Color(0xFFBDBAB5),
        foregroundColor: Colors.black,
      ),
      body: _initialLoading || vm.loading || _saving
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Event Pictures (1–4)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap a picture to replace it. Use the bin icon to remove '
                  'an extra picture. At least one picture is required.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                  children: List.generate(
                    maxImages,
                    (index) => _imageSlot(index),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Event Name',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    hintText: 'Enter event name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => category = value);
                    }
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Price',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter price (optional)',
                    prefixText: 'R ',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _desc,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Enter event description',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Items used',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                if (vm.availableProducts.isEmpty)
                  const Text('No products available.')
                else
                  ...vm.availableProducts.map((product) {
                    final productId = product['id'].toString();
                    final productName =
                        product['name']?.toString() ??
                            'Unnamed product';

                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(productName),
                      value: selectedProductIds.contains(productId),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            selectedProductIds.add(productId);
                          } else {
                            selectedProductIds.remove(productId);
                          }
                        });
                      },
                    );
                  }),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCE9448),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
