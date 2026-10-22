import 'supabase_client.dart';

class DecorProductService {
  final supabase = SupabaseClientManager.client;

  Future<List<dynamic>> getCatalogue() async {
    return await supabase.from('DecorProduct').select().order('Product_id');
  }

  Future<void> uploadDecor(Map<String,dynamic> data) async {
    await supabase.from('DecorProduct').insert(data);
  }

  Future<String> uploadPhoto(String fileName, List<int> bytes) async {
    await supabase.storage.from('decor-images').uploadBinary(fileName, bytes as dynamic);
    return supabase.storage.from('decor-images').getPublicUrl(fileName);
  }
}