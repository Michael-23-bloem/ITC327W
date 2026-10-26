import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';
import '../models/portfolio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PortfolioViewModel extends ChangeNotifier {
  final _service = PortfolioService();
  List<Portfolio> events = [];
  bool loading = false;

  List<Map<String, dynamic>> availableProducts = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.getPortfolio();
      events = data.map((e) => Portfolio.fromJson(e as Map<String, dynamic>)).toList();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableProducts() async {
    final client = Supabase.instance.client;
    final data = await client.from('decor_products').select('id, name');
    availableProducts = List<Map<String, dynamic>>.from(data as List);
    notifyListeners();
  }

  /// Pulls product ids already recorded on a past order's order_items —
  /// used to pre-check "items used" chips when a past event is linked.
  Future<List<String>> getProductIdsForOrder(String orderId) async {
    final client = Supabase.instance.client;
    final data = await client
        .from('order_items')
        .select('product_id')
        .eq('order_id', orderId);
    return (data as List)
        .map((row) => row['product_id'] as String?)
        .whereType<String>()
        .toList();
  }

  Future<Map<String, dynamic>> loadDetail(String portfolioId) async {
  final images = await _service.getPortfolioImages(portfolioId);
  final items = await _service.getPortfolioItemNames(portfolioId);
  return {'images': images, 'items': items};
}

  Future<void> uploadEventWithImages({
    required List<XFile> images, // images[0] is treated as the cover image
    required String category,
    required String description,
    double? price,
    String? eventId, // optional link to a past order
    String? name,
    List<String> productIds = const [],
  }) async {
    if (images.isEmpty) {
      throw Exception('At least one image is required');
    }

    loading = true;
    notifyListeners();
    try {
      final client = Supabase.instance.client;
      final storage = client.storage.from('portfolio-images');

      final urls = <String>[];
      for (final img in images) {
        final fileBytes = await img.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${img.name}';
        await storage.uploadBinary(fileName, fileBytes);
        urls.add(storage.getPublicUrl(fileName));
      }

      final inserted = await client
          .from('portfolio')
          .insert({
            'name': name,
            'description': description,
            'category': category,
            'image_url': urls.first,
            'price': price,
            'event_id': eventId,
          })
          .select()
          .single();

      final portfolioId = inserted['id'];

     if (urls.length > 1) {
  final extraRows = urls.skip(1).toList().asMap().entries.map((entry) {
    return {
      'portfolio_id': portfolioId,
      'image_url': entry.value,
      'sort_order': entry.key + 1,
    };
  }).toList();

  await client.from('portfolio_images').insert(extraRows);
} 
      /*if (urls.length > 1) {
        final extraRows = urls
            .skip(1)
            .map((url) => {'portfolio_id': portfolioId, 'image_url': url})
            .toList();
        await client.from('portfolio_images').insert(extraRows);
      }*/

      if (productIds.isNotEmpty) {
        final itemRows = productIds
            .map((id) => {'portfolio_id': portfolioId, 'product_id': id})
            .toList();
            await client.from('portfolio_product_links').insert(itemRows);
        //await client.from('portfolio_items').insert(itemRows);
      }

      await load();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deletePortfolio(String id) async {
  await _service.deletePortfolio(id);
  events.removeWhere((e) => e.id == id);
  notifyListeners();
}

Future<void> updatePortfolio({
  required String id,
  required String name,
  required String category,
  required String description,
  double? price,
  List<String> productIds = const [],
  List<XFile?>? imageFiles,
  List<String?>? existingImageUrls,
}) async {
  loading = true;
  notifyListeners();

  try {
    final client = Supabase.instance.client;

    // Update the event details.
    await _service.updatePortfolio(id, {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
    });

    // Update linked décor products.
    await _service.replacePortfolioItems(id, productIds);

    // Update images only when the edit screen supplies image data.
    if (imageFiles != null && existingImageUrls != null) {
      final storage = client.storage.from('portfolio-images');
      final imageUrls = <String>[];

      for (int i = 0; i < 4; i++) {
        final newImage =
            i < imageFiles.length ? imageFiles[i] : null;

        final existingUrl =
            i < existingImageUrls.length
                ? existingImageUrls[i]
                : null;

        if (newImage != null) {
          final bytes = await newImage.readAsBytes();
          final fileName =
              '${id}_${DateTime.now().microsecondsSinceEpoch}_${newImage.name}';

          await storage.uploadBinary(fileName, bytes);

          imageUrls.add(storage.getPublicUrl(fileName));
        } else if (existingUrl != null) {
          imageUrls.add(existingUrl);
        }
      }

      if (imageUrls.isEmpty) {
        throw Exception('At least one event picture is required.');
      }

      await _service.replacePortfolioImages(id, imageUrls);
    }

    await load();
  } finally {
    loading = false;
    notifyListeners();
  }
}
/*Future<void> updatePortfolio({
  required String id,
  required String name,
  required String category,
  required String description,
  double? price,
  List<String> productIds = const [],
}) async {
  loading = true;
  notifyListeners();

  try {
    await _service.updatePortfolio(id, {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
    });

    await _service.replacePortfolioItems(id, productIds);

    await load();
  } finally {
    loading = false;
    notifyListeners();
  }
}*/

Future<List<String>> getProductIdsForPortfolio(String portfolioId) {
  return _service.getProductIdsForPortfolio(portfolioId);
}

  List<Portfolio> getByCategory(String category) {
    if (category == 'All') return events;
    return events.where((e) => e.category == category).toList();
  }
}