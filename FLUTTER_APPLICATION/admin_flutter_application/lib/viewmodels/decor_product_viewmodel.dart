
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/decor_product_service.dart';
import '../models/decor_product.dart';

/// Holds the information for one décor item being uploaded.
class DecorProductUploadDraft {
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final List<XFile> images;

  const DecorProductUploadDraft({
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.images,
  });
}

class DecorProductViewModel extends ChangeNotifier {
  final _service = DecorProductService();

  List<DecorProduct> catalogue = [];
  bool loading = false;

  Future<void> loadCatalogue() async {
    loading = true;
    notifyListeners();

    try {
      final data = await _service.getCatalogue();
      catalogue = data
          .map((e) => DecorProduct.fromJson(e))
          .toList();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Uploads multiple décor items under the selected category.
  ///
  /// Each item has its own name, description, price, stock
  /// quantity and unlimited list of selected images.
  Future<void> uploadMultipleDecorItems({
    required String category,
    required List<DecorProductUploadDraft> items,
  }) async {
    if (items.isEmpty) {
      throw Exception('Add at least one décor item.');
    }

    // Validate everything before starting the upload.
    for (final item in items) {
      if (item.name.trim().isEmpty) {
        throw Exception('Every décor item needs a name.');
      }

      if (item.price < 0) {
        throw Exception('Item prices cannot be negative.');
      }

      if (item.stockQuantity < 0) {
        throw Exception('Stock quantities cannot be negative.');
      }

      if (item.images.isEmpty) {
        throw Exception(
          'Add at least one photo for ${item.name}.',
        );
      }
    }

    loading = true;
    notifyListeners();

    try {
      for (final item in items) {
        final urls = <String>[];

        // Upload every photo belonging to this item.
        for (int i = 0; i < item.images.length; i++) {
          final image = item.images[i];
          final bytes = await image.readAsBytes();

          final fileName =
              '${DateTime.now().microsecondsSinceEpoch}'
              '_${i}_${image.name}';

          final url = await _service.uploadPhoto(
            fileName,
            bytes,
          );

          urls.add(url);
        }

        // Create this décor item using its first photo as cover.
        final inserted = await _service.uploadDecor({
          'name': item.name.trim(),
          'description': item.description.trim(),
          'category': category,
          'price': item.price,
          'stock_quantity': item.stockQuantity,
          'image_url': urls.first,
        });

        // Save any additional photos for this item.
        if (urls.length > 1) {
          await _service.addProductImages(
            inserted['id'].toString(),
            urls.skip(1).toList(),
          );
        }
      }

      // Refresh without changing the loading state mid-upload.
      final data = await _service.getCatalogue();
      catalogue = data
          .map((e) => DecorProduct.fromJson(e))
          .toList();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Retains support for the existing single-item upload screen.
  Future<void> uploadDecorWithImages({
    required List<XFile> images,
    required String name,
    required String category,
    required String description,
    required double price,
    int stockQuantity = 0,
  }) async {
    await uploadMultipleDecorItems(
      category: category,
      items: [
        DecorProductUploadDraft(
          name: name,
          description: description,
          price: price,
          stockQuantity: stockQuantity,
          images: images,
        ),
      ],
    );
  }

  
Future<void> deleteDecor(String productId) async {
  loading = true;
  notifyListeners();

  try {
    await _service.deleteDecor(productId);

    final data = await _service.getCatalogue();
    catalogue = data
        .map((e) => DecorProduct.fromJson(e))
        .toList();
  } finally {
    loading = false;
    notifyListeners();
  }
}


Future<void> updateDecor(
  String productId,
  Map<String, dynamic> changes,
) async {
  loading = true;
  notifyListeners();

  try {
    await _service.updateDecor(productId, changes);

    final rows = await _service.getCatalogue();
    catalogue = rows
        .map((e) => DecorProduct.fromJson(e))
        .toList();
  } finally {
    loading = false;
    notifyListeners();
  }
}

/*Future<void> updateDecor(
  String productId,
  Map<String, dynamic> data,
) async {
  loading = true;
  notifyListeners();

  try {
    await _service.updateDecor(productId, data);

    final data = await _service.getCatalogue();
    catalogue = data
        .map((e) => DecorProduct.fromJson(e))
        .toList();
  } finally {
    loading = false;
    notifyListeners();
  }
}*/

}
