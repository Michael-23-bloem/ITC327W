import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';
import '../models/portfolio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PortfolioViewModel extends ChangeNotifier {
  final _service = PortfolioService();
  List<Portfolio> events = [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await _service.getPortfolio();
      events = data.map(Portfolio.fromJson).toList();
    } catch (e) {
      debugPrint('Portfolio load failed: $e');
      error = 'Could not load portfolio.';
      events = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Add these imports to the top of portfolio_viewmodel.dart if not already there:
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> uploadEventWithImages({
  required List<XFile> images, // images[0] is treated as the cover image
  required String category,
  required String description,
  double? price,
  String? eventId, // optional link to a past order
  String? name,
}) async {
  if (images.isEmpty) {
    throw Exception('At least one image is required');
  }

  loading = true;
  notifyListeners();
  try {
    final client = Supabase.instance.client;
    final storage = client.storage.from('portfolio');

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
      final extraRows = urls
          .skip(1)
          .map((url) => {'portfolio_id': portfolioId, 'image_url': url})
          .toList();
      await client.from('portfolio_images').insert(extraRows);
    }

    await load();
  } finally {
    loading = false;
    notifyListeners();
  }
}

  Future<void> uploadEvent({
    required String productId,
    required String name,
    required String category,
    required String description,
    required String imageUrl,
  }) async {
    loading = true;
    notifyListeners();
    try {
      await _service.uploadEventImage({
        'Name': name,
        'Category': category,
        'Description': description,
        'Image_url': imageUrl,
      });
      await load();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  List<Portfolio> getByCategory(String category) {
    if (category == 'All') return events;
    return events.where((e) => e.category == category).toList();
  }
}