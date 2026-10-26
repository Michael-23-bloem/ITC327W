import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/decor_product_service.dart';
import '../models/decor_product.dart';

class DecorProductViewModel extends ChangeNotifier {
  final _service = DecorProductService();
  List<DecorProduct> catalogue = [];
  bool loading = false;

  Future<void> loadCatalogue() async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.getCatalogue();
      catalogue = data.map((e) => DecorProduct.fromJson(e)).toList();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// images[0] becomes the product's main image_url; any extra images
  /// go into product_images.
  Future<void> uploadDecorWithImages({
    required List<XFile> images,
    required String name,
    required String category,
    required String description,
    required double price,
    int stockQuantity = 0,
  }) async {
    if (images.isEmpty) {
      throw Exception('At least one image is required');
    }

    loading = true;
    notifyListeners();
    try {
      final urls = <String>[];
      for (final img in images) {
        final bytes = await img.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${img.name}';
        final url = await _service.uploadPhoto(fileName, bytes);
        urls.add(url);
      }

      final inserted = await _service.uploadDecor({
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'stock_quantity': stockQuantity,
        'image_url': urls.first,
      });

      if (urls.length > 1) {
        await _service.addProductImages(inserted['id'] as String, urls.skip(1).toList());
      }

      await loadCatalogue();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}