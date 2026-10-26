import 'supabase_client.dart';

class DecorProductService {
  final supabase = SupabaseClientManager.client;

  Future<List<dynamic>> getCatalogue() async {
    return await supabase.from('decor_products').select().order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> uploadDecor(Map<String, dynamic> data) async {
    final inserted = await supabase.from('decor_products').insert(data).select().single();
    return inserted;
  }

  Future<void> addProductImages(String productId, List<String> imageUrls) async {
    if (imageUrls.isEmpty) return;
    final rows = imageUrls.map((url) => {'product_id': productId, 'image_url': url}).toList();
    await supabase.from('product_images').insert(rows);
  }

  Future<String> uploadPhoto(String fileName, List<int> bytes) async {
    await supabase.storage.from('product-images').uploadBinary(fileName, bytes as dynamic);
    return supabase.storage.from('product-images').getPublicUrl(fileName);
  }
}