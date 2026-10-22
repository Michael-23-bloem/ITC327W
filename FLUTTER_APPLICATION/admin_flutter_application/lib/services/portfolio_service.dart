import 'supabase_client.dart';

class PortfolioService {
  final supabase = SupabaseClientManager.client;

  Future<List<dynamic>> getPortfolio() async {
    return await supabase.from('Portfolio').select().order('Portfolio_id');
  }

  Future<void> uploadEventImage(Map<String,dynamic> data) async {
    await supabase.from('Portfolio').insert(data);
  }
}