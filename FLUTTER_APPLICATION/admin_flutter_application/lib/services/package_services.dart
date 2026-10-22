import 'supabase_client.dart';

class PackageService {
  final supabase = SupabaseClientManager.client;

  Future<List<dynamic>> getPackages() async {
    return await supabase.from('Package').select().order('Package_id');
  }

  Future<void> createPackage(Map<String,dynamic> data) async {
    await supabase.from('Package').insert(data);
  }
}