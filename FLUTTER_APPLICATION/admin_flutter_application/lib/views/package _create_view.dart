
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/decor_product.dart';
import '../viewmodels/package_viewmodel.dart';

class PackageCreateView extends StatefulWidget {
  final String? packageId;

  const PackageCreateView({
    super.key,
    this.packageId,
  });

  bool get isEditing => packageId != null;

  @override
  State<PackageCreateView> createState() => _PackageCreateViewState();
}

class _PackageCreateViewState extends State<PackageCreateView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final Map<String, int> _selectedProducts = {};

  Uint8List? _imageBytes;
  String? _imageName;
  String? _imageContentType;
  String? _existingImageUrl;

  bool _isActive = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final vm = context.read<PackageViewModel>();

    try {
      await vm.loadProducts();

      if (widget.packageId != null) {
        final data = await vm.loadPackage(widget.packageId!);

        _nameController.text = data['name']?.toString() ?? '';
        _descriptionController.text =
            data['description']?.toString() ?? '';
        _priceController.text = data['price']?.toString() ?? '';

        _existingImageUrl = data['image_url']?.toString();
        _isActive = data['is_active'] as bool? ?? true;

        final rawItems = data['package_items'];

        if (rawItems is List) {
          for (final raw in rawItems) {
            if (raw is Map) {
              final productId = raw['product_id']?.toString();
              final quantity = raw['quantity'];

              if (productId != null) {
                _selectedProducts[productId] = quantity is num
                    ? quantity.toInt()
                    : int.tryParse('$quantity') ?? 1;
              }
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load package: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    if (!mounted) return;

    setState(() {
      _imageBytes = bytes;
      _imageName = image.name;
      _imageContentType = image.mimeType ?? 'image/jpeg';
    });
  }

  void _changeQuantity(String productId, int change) {
    setState(() {
      final current = _selectedProducts[productId] ?? 1;
      final updated = current + change;

      if (updated <= 0) {
        _selectedProducts.remove(productId);
      } else {
        _selectedProducts[productId] = updated;
      }
    });
  }

  Future<void> _savePackage() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one decor product.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final vm = context.read<PackageViewModel>();

    try {
      String? imageUrl = _existingImageUrl;

      if (_imageBytes != null &&
          _imageName != null &&
          _imageContentType != null) {
        imageUrl = await vm.uploadPackagePhoto(
          _imageBytes!,
          _imageName!,
          _imageContentType!,
        );
      }

      final packageData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'image_url': imageUrl,
        'is_active': _isActive,
      };

      final items = _selectedProducts.entries.map((entry) {
        return {
          'product_id': entry.key,
          'quantity': entry.value,
        };
      }).toList();

      if (widget.isEditing) {
        await vm.updatePackage(
          widget.packageId!,
          packageData,
          items,
        );
      } else {
        await vm.createPackage(
          packageData,
          items,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Package updated successfully.'
                : 'Package created successfully.',
          ),
        ),
      );

      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save package: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PackageViewModel>();

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Package' : 'Add Package',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Package name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a package name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a description.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Package price (R)',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final price = double.tryParse(value ?? '');

                if (price == null || price <= 0) {
                  return 'Enter a valid package price.';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: const Text('Choose package image'),
            ),
            const SizedBox(height: 12),

            if (_imageBytes != null)
              Image.memory(
                _imageBytes!,
                height: 180,
                fit: BoxFit.cover,
              )
            else if (_existingImageUrl != null &&
                _existingImageUrl!.isNotEmpty)
              Image.network(
                _existingImageUrl!,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Text('Could not display package image.'),
              ),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text('Show on website'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),

            const Divider(height: 32),

            Text(
              'Included Decor Products',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            if (vm.products.isEmpty)
              const Text('No active decor products available.'),

            ...vm.products.map((DecorProduct product) {
              final selected =
                  _selectedProducts.containsKey(product.id);
              final quantity =
                  _selectedProducts[product.id] ?? 1;

              return Card(
                child: ListTile(
                  leading: Checkbox(
                    value: selected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedProducts[product.id] = 1;
                        } else {
                          _selectedProducts.remove(product.id);
                        }
                      });
                    },
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    'R${product.price.toStringAsFixed(2)}',
                  ),
                  trailing: selected
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _changeQuantity(product.id, -1),
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$quantity'),
                            IconButton(
                              onPressed: () =>
                                  _changeQuantity(product.id, 1),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            }),

            const SizedBox(height: 24),

            FilledButton(
              onPressed: _saving ? null : _savePackage,
              child: _saving
                  ? const CircularProgressIndicator()
                  : Text(
                      widget.isEditing
                          ? 'Save Changes'
                          : 'Create Package',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
