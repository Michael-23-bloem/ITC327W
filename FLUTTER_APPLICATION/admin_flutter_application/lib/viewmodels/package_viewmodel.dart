
import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../services/package_services.dart';
import '../models/package.dart';
import '../models/decor_product.dart';

class PackageViewModel extends ChangeNotifier {
  final _service = PackageService();

  List<Package> packages = [];
  List<DecorProduct> products = [];

  bool loading = false;
  String? error;

  // Load all packages.
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final data = await _service.getPackages();

      packages = data
          .map((e) => Package.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Load active decor products.
  Future<void> loadProducts() async {
    try {
      final data = await _service.getActiveProducts();

      products = data
          .map(
            (e) => DecorProduct.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Load one package with its included products.
  Future<Map<String, dynamic>> loadPackage(String packageId) async {
    return await _service.getPackage(packageId);
  }

  // Create package.
  Future<void> createPackage(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> items,
  ) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await _service.createPackage(data, items);
      await load();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Edit package.
  Future<void> updatePackage(
    String packageId,
    Map<String, dynamic> data,
    List<Map<String, dynamic>> items,
  ) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await _service.updatePackage(packageId, data, items);
      await load();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Show or hide package.
  Future<void> toggleActive(
    String packageId,
    bool isActive,
  ) async {
    try {
      await _service.setActive(packageId, isActive);
      await load();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete package.
  Future<void> deletePackage(String packageId) async {
    try {
      await _service.deletePackage(packageId);
      await load();
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  
Future<String> uploadPackagePhoto(
  Uint8List bytes,
  String fileName,
  String contentType,
) async {
  return await _service.uploadPhoto(
    bytes,
    fileName,
    contentType,
  );
}

}
