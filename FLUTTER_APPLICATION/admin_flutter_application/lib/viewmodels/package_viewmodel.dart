import 'package:flutter/material.dart';
import '../services/package_services.dart';
import '../models/package.dart';

class PackageViewModel extends ChangeNotifier {
  final _service = PackageService();
  List<Package> packages = [];
  bool loading = false;

  Future<void> load() async {
    loading = true; notifyListeners();
    final data = await _service.getPackages();
packages = data.map((e) => Package.fromJson(e as Map<String, dynamic>)).toList();
    loading = false; notifyListeners();
  }

  Future<void> createPackage(Map<String,dynamic> data) async {
    await _service.createPackage(data);
    await load();
  }
}