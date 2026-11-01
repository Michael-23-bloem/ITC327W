import 'dart:typed_data';

import 'supabase_client.dart';

class DecorProductService {
  final supabase = SupabaseClientManager.client;

  // Storage bucket (files)  -> hyphen:     'product-images'
  // Database table (rows)   -> underscore: 'product_images'
  static const String _bucket = 'product-images';

  Future<List<dynamic>> getCatalogue() async {
    return await supabase
        .from('decor_products')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> uploadDecor(
    Map<String, dynamic> data,
  ) async {
    return await supabase
        .from('decor_products')
        .insert(data)
        .select()
        .single();
  }

  Future<void> addProductImages(
    String productId,
    List<String> imageUrls,
  ) async {
    if (imageUrls.isEmpty) return;

    final rows = imageUrls.asMap().entries.map((entry) {
      return {
        'product_id': productId,
        'image_url': entry.value,
        'sort_order': entry.key + 2,
      };
    }).toList();

    // TABLE (underscore)
    await supabase.from('product_images').insert(rows);
  }

  Future<List<dynamic>> getProductImages(String productId) async {
    // TABLE (underscore)
    return await supabase
        .from('product_images')
        .select()
        .eq('product_id', productId)
        .order('sort_order');
  }

  Future<void> updateDecor(
    String productId,
    Map<String, dynamic> data,
  ) async {
    await supabase
        .from('decor_products')
        .update(data)
        .eq('id', productId);
  }

  Future<void> deleteDecor(String productId) async {
    // 1. Remember the extra photo links, then delete their rows.
    final extraRows = await supabase
        .from('product_images')
        .select('image_url')
        .eq('product_id', productId);

    await supabase
        .from('product_images')
        .delete()
        .eq('product_id', productId);

    // 2. Delete the décor item itself and make sure a row was removed.
    final deletedRows = await supabase
        .from('decor_products')
        .delete()
        .eq('id', productId)
        .select();

    if (deletedRows.isEmpty) {
      throw Exception(
        'The item was not deleted. Check the item ID and Supabase DELETE permissions.',
      );
    }

    // 3. Best-effort cleanup of the files in the bucket.
    //    A failure here must not undo the delete.
    try {
      final urls = <String>[
        if (deletedRows.first['image_url'] != null)
          deletedRows.first['image_url'].toString(),
        ...extraRows.map((r) => r['image_url'].toString()),
      ];

      final paths = urls
          .map(_storagePathFromUrl)
          .whereType<String>()
          .toList();

      if (paths.isNotEmpty) {
        await supabase.storage.from(_bucket).remove(paths);
      }
    } catch (_) {}
  }

  String? _storagePathFromUrl(String url) {
    if (url.isEmpty) return null;

    final segments = Uri.parse(url).pathSegments;
    final bucketIndex = segments.indexOf(_bucket);

    if (bucketIndex == -1 || bucketIndex >= segments.length - 1) return null;

    return segments.sublist(bucketIndex + 1).join('/');
  }

  Future<String> uploadPhoto(
    String fileName,
    Uint8List bytes,
  ) async {
    final storage = supabase.storage.from(_bucket);

    await storage.uploadBinary(fileName, bytes);

    return storage.getPublicUrl(fileName);
  }
}