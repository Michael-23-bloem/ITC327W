import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/portfolio_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';
import '../models/order.dart';

class PortfolioUploadEventView extends StatefulWidget {
  const PortfolioUploadEventView({super.key});

  @override
  State<PortfolioUploadEventView> createState() => _UploadEventViewState();
}

class _UploadEventViewState extends State<PortfolioUploadEventView> {
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _name = TextEditingController();
  final _picker = ImagePicker();

    static const int maxImages = 4;

  String? category;
  String? selectedPastEventId;
  final List<XFile?> _images = [null, null, null, null];
  final Set<String> selectedProductIds = {};

  final categories = const [
    'Wedding',
    'Birthday',
    'Corporate',
    'Baby Shower',
    'Anniversary',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderViewModel>().loadBookings();
        context.read<PortfolioViewModel>().loadAvailableProducts();
      }
    });
  }

  @override
  void dispose() {
    _desc.dispose();
    _price.dispose();
    _name.dispose();
    super.dispose();
  }


Future<void> _pickImage(int index) async {
  final selectedCount = _images.whereType<XFile>().length;

  // Do not open the picker for an empty slot if all 4 are filled.
  if (_images[index] == null && selectedCount >= maxImages) {
    return;
  }

  final picked = await _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );

  if (!mounted || picked == null) return;

  setState(() {
    _images[index] = picked;
  });
}
  
  /*Future<void> _pickImage(int index) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _images[index] = picked);
    }
  }*/

  Future<void> _submit() async {
    final selected = _images.whereType<XFile>().toList();
    if (selected.isEmpty || category == null || _desc.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one image, a category and a description'),
        ),
      );
      return;
    }
    if (_images.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please upload at least one event picture.'),
      backgroundColor: Colors.red,
    ),
  );
  return;
}

    final viewModel = context.read<PortfolioViewModel>();
    double? price;
    if (_price.text.trim().isNotEmpty) {
      price = double.tryParse(_price.text.trim());
    }

    await viewModel.uploadEventWithImages(
      images: selected,
      name: _name.text.trim(),
      category: category!,
      description: _desc.text.trim(),
      price: price,
      eventId: selectedPastEventId,
      productIds: selectedProductIds.toList(),
    );

    if (mounted) context.go('/portfolio');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PortfolioViewModel>();
    final orderVm = context.watch<OrderViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFBDBAB5),
          // 1. AppBar belongs directly inside Scaffold.
    appBar: AppBar(
      backgroundColor: const Color(0xFFBDBAB5),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/portfolio');
          }
        },
      ),),
      body: SafeArea(
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  const Text(
                    'Upload Event Images',
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
                    children: List.generate(4, (i) => _imageSlot(i)),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Event Title',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _fieldContainer(
                    child: TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter event title',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Category',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            _fieldContainer(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: category,
                                  hint: const Text('Select'),
                                  items: categories
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => category = v),
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
                            const Text(
                              'Price',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            _fieldContainer(
                              child: TextField(
                                controller: _price,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'R0.00',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _fieldContainer(
                    height: 110,
                    child: TextField(
                      controller: _desc,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Describe the event...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Link to previous event (optional)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _fieldContainer(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedPastEventId,
                        hint: const Text('Choose past event'),
                        items: orderVm.bookings
                            .map(
                              (o) => DropdownMenuItem(
                                value: o.id,
                                child: Text(
                                  '${o.eventType} • ${o.customerName ?? o.customerEmailOrId}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) async {
                          setState(() => selectedPastEventId = v);
                          if (v != null) {
                            final ids = await context
                                .read<PortfolioViewModel>()
                                .getProductIdsForOrder(v);
                            setState(() {
                              selectedProductIds
                                ..clear()
                                ..addAll(ids);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Items used',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: vm.availableProducts.map((p) {
                      final id = p['id'] as String;
                      final name = p['name'] as String? ?? 'Unnamed';
                      final selected = selectedProductIds.contains(id);
                      return FilterChip(
                        label: Text(name),
                        selected: selected,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              selectedProductIds.add(id);
                            } else {
                              selectedProductIds.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE9448),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
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
