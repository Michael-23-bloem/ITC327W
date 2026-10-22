import 'package:flutter/material.dart';
import '../services/decor_product_service.dart';
import '../models/decor_product.dart';

class DecorProductViewModel extends ChangeNotifier {
  final _service = DecorProductService();
  List<DecorProduct> catalogue = [];
  bool loading = false;

  Future<void> loadCatalogue() async {
    loading = true; notifyListeners();
    final data = await _service.getCatalogue();
    catalogue = data.map((e) => DecorProduct.fromJson(e)).toList();
    loading = false; notifyListeners();
  }

  Future<void> uploadDecor(Map<String,dynamic> data) async {
    loading = true; notifyListeners();
    await _service.uploadDecor(data);
    await loadCatalogue();
  }

  Future<String> uploadPhoto(String fileName, List<int> bytes) async {
    return await _service.uploadPhoto(fileName, bytes);
  }
}