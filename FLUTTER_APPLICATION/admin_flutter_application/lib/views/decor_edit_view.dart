
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/decor_product.dart';
import '../viewmodels/decor_product_viewmodel.dart';

class DecorEditView extends StatefulWidget {
  final DecorProduct product;

  const DecorEditView({
    super.key,
    required this.product,
  });

  @override
  State<DecorEditView> createState() => _DecorEditViewState();
}

class _DecorEditViewState extends State<DecorEditView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;

  late String _category;
  bool _saving = false;

  final List<String> _categories = const [
    'Chairs',
    'Tables',
    'Draping',
    'Lighting',
    'Tents',
    'Crockery',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.product.name,
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stockQuantity.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );

    final existingCategory = widget.product.category;
    _category = _categories.contains(existingCategory)
        ? existingCategory!
        : _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

 /* Future<void> _saveChanges() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await context.read<DecorProductViewModel>().updateDecor(
        widget.product.id,
        {
          'name': _nameController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'stock_quantity': int.parse(_stockController.text.trim()),
          'description': _descriptionController.text.trim(),
          'category': _category,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' Décor item updated successfully!'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' Could not update décor item: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }*/
  Future<void> _saveChanges() async {
  if (_saving) return;

  if (!_formKey.currentState!.validate()) return;

  setState(() => _saving = true);

  try {
    await context.read<DecorProductViewModel>().updateDecor(
      widget.product.id,
      {
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'stock_quantity': int.parse(_stockController.text.trim()),
        'description': _descriptionController.text.trim(),
        'category': _category,
      },
    );

    if (!mounted) return;

    await _showPopup(
      title: 'Saved',
      message: 'Décor item updated successfully.',
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  } catch (e) {
    if (!mounted) return;

    await _showPopup(
      title: 'Update failed',
      message: 'Could not update décor item.\n\n'
          '${e.toString().replaceFirst('Exception: ', '')}',
      icon: Icons.error_outline,
      iconColor: Colors.red,
    );
  } finally {
    if (mounted) {
      setState(() => _saving = false);
    }
  }
}
  Future<void> _showPopup({
  required String title,
  required String message,
  required IconData icon,
  required Color iconColor,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCE9448),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBDBAB5),
      appBar: AppBar(
        title: const Text('Edit Décor Item'),
        backgroundColor: const Color(0xFFBDBAB5),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.product.imageUrl != null &&
                  widget.product.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    widget.product.imageUrl!,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 120,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              _label('Item name'),
              TextFormField(
                controller: _nameController,
                enabled: !_saving,
                decoration: _decoration('Enter item name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an item name.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Category'),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: _decoration('Select category'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
              ),

              const SizedBox(height: 16),

              _label('Price (R)'),
              TextFormField(
                controller: _priceController,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _decoration('0.00'),
                validator: (value) {
                  final price = double.tryParse(value?.trim() ?? '');

                  if (price == null || !price.isFinite || price < 0) {
                    return 'Enter a valid, non-negative price.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Stock quantity'),
              TextFormField(
                controller: _stockController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                decoration: _decoration('Enter stock quantity'),
                validator: (value) {
                  final stock = int.tryParse(value?.trim() ?? '');

                  if (stock == null || stock < 0) {
                    return 'Enter a valid, non-negative quantity.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _label('Description'),
              TextFormField(
                controller: _descriptionController,
                enabled: !_saving,
                maxLines: 4,
                decoration: _decoration('Describe the item'),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveChanges,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _saving ? 'Saving Changes...' : 'Save Changes',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCE9448),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF7F6F3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
