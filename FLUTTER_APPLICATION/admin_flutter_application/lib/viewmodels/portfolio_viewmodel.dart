import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';
import '../models/portfolio.dart';

class PortfolioViewModel extends ChangeNotifier {
  final _service = PortfolioService();
  List<Portfolio> events = [];
  bool loading = false;

  Future<void> load() async {
    loading = true; notifyListeners();
    final data = await _service.getPortfolio();
    events = data.map((e) => Portfolio.fromJson(e as Map<String, dynamic>)).toList();
    loading = false; notifyListeners();
  }

  Future<void> uploadEvent({
    required String productId,
    required String name,
    required String category,
    required String description,
    required String imageUrl,
  }) async {
    loading = true; notifyListeners();
    await _service.uploadEventImage({
      'Product_id': productId,
      'Name': name,
      'Category': category,
      'Description': description,
      'Image_url': imageUrl,
    });
    await load();
  }

  List<Portfolio> getByCategory(String category) {
    if (category == 'All') return events;
    return events.where((e) => e.category == category).toList();
  }
}