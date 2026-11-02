
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

class PackageService {
  final supabase = SupabaseClientManager.client;

  // Load all packages and their included product IDs.
  Future<List<dynamic>> getPackages() async {
    return await supabase
        .from('packages')
        .select('*, package_items(product_id, quantity)')
        .order('name');
  }

  // Load one package with its included product details.
  Future<Map<String, dynamic>> getPackage(String packageId) async {
    return await supabase
        .from('packages')
        .select('''
          *,
          package_items(
            product_id,
            quantity,
            decor_products(name, price, image_url)
          )
        ''')
        .eq('id', packageId)
        .single();
  }

  // Load active decor products for package creation/editing.
  Future<List<dynamic>> getActiveProducts() async {
    return await supabase
        .from('decor_products')
        .select()
        .eq('is_active', true)
        .order('name');
  }

  // Upload package image.
  Future<String> uploadPhoto(
    Uint8List bytes,
    String fileName,
    String contentType,
  ) async {
    final path =
        'packages/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await supabase.storage
        .from('product-images')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    return supabase.storage
        .from('product-images')
        .getPublicUrl(path);
  }

  // Create package and its included products.
  Future<void> createPackage(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> items,
  ) async {
    final result = await supabase
        .from('packages')
        .insert(data)
        .select('id')
        .single();

    final packageId = result['id'].toString();

    try {
      await _insertItems(packageId, items);
    } catch (e) {
      // Remove the package if its items could not be saved.
      await supabase
          .from('packages')
          .delete()
          .eq('id', packageId);

      rethrow;
    }
  }

  // Update package details and replace its included products.
  Future<void> updatePackage(
    String packageId,
    Map<String, dynamic> data,
    List<Map<String, dynamic>> items,
  ) async {
    await supabase
        .from('packages')
        .update(data)
        .eq('id', packageId);

    await supabase
        .from('package_items')
        .delete()
        .eq('package_id', packageId);

    await _insertItems(packageId, items);
  }

  // Insert package items.
  Future<void> _insertItems(
    String packageId,
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) return;

    final rows = items.map((item) {
      return {
        'package_id': packageId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
      };
    }).toList();

    await supabase
        .from('package_items')
        .insert(rows);
  }

  // Show or hide package on the website.
  Future<void> setActive(
    String packageId,
    bool isActive,
  ) async {
    await supabase
        .from('packages')
        .update({'is_active': isActive})
        .eq('id', packageId);
  }

  // Delete only if the package is not used in customer requests.
  Future<void> deletePackage(String packageId) async {
    try {
      final usedPackage = await supabase
          .from('order_items')
          .select('package_id')
          .eq('package_id', packageId)
          .limit(1)
          .maybeSingle();

      if (usedPackage != null) {
        throw Exception(
          'This package is part of customer requests, '
          'so it can\'t be deleted. '
          'Turn off "Show on website" to hide it instead.',
        );
      }

      await supabase
          .from('package_items')
          .delete()
          .eq('package_id', packageId);

      await supabase
          .from('packages')
          .delete()
          .eq('id', packageId);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        throw Exception(
          'This package is part of customer requests, '
          'so it can\'t be deleted. '
          'Turn off "Show on website" to hide it instead.',
        );
      }

      rethrow;
    }
  }
}
