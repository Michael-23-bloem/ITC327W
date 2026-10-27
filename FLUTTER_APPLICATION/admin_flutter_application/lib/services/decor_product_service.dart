
import 'dart:typed_data';

import 'supabase_client.dart';

class DecorProductService {
  final supabase = SupabaseClientManager.client;

 Future<List<dynamic>> getCatalogue() async {
  return await supabase
      .from('decor_products')
      .select()
      .eq('is_active', true)
      .order('created_at', ascending: false);
}
 /* Future<List<dynamic>> getCatalogue() async {
    return await supabase
        .from('decor_products')
        .select()
        .order('created_at', ascending: false);
  }*/

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

    await supabase.from('product_images').insert(rows);
  }

  Future<List<dynamic>> getProductImages(String productId) async {
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
  // Delete the additional photo records first.
  await supabase
      .from('product_images')
      .delete()
      .eq('product_id', productId);

  // Delete the décor item and check whether a row was deleted.
  final deletedRows = await supabase
      .from('decor_products')
      .delete()
      .eq('id', productId)
      .select('id');

  if (deletedRows.isEmpty) {
    throw Exception(
      'The item was not deleted. Check the item ID and Supabase DELETE permissions.',
    );
  }
}


  Future<String> uploadPhoto(
    String fileName,
    Uint8List bytes,
  ) async {
    final storage = supabase.storage.from('product-images');

    await storage.uploadBinary(fileName, bytes);

    return storage.getPublicUrl(fileName);
  }
}

/*import 'dart:typed_data';

import 'supabase_client.dart';

class DecorProductService {
  final supabase = SupabaseClientManager.client;

  Future<List<dynamic>> getCatalogue() async {
    return await supabase
        .from('decor_products')
        .select()
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> uploadDecor(
    Map<String, dynamic> data,
  ) async {
    final inserted = await supabase
        .from('decor_products')
        .insert(data)
        .select()
        .single();

    return inserted;
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

    await supabase.from('product_images').insert(rows);
  }

  Future<String> uploadPhoto(
    String fileName,
    Uint8List bytes,
  ) async {
    final storage = supabase.storage.from('product-images');

    await storage.uploadBinary(fileName, bytes);

    return storage.getPublicUrl(fileName);
  }
}*/
