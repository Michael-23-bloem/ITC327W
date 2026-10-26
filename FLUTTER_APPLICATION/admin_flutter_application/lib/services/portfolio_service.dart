import 'supabase_client.dart';

class PortfolioService {
  final supabase = SupabaseClientManager.client;

  Future<List<Map<String, dynamic>>> getPortfolio() async {
    final data = await supabase
        .from('portfolio')
        .select()
        .order('created_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(data as List);
    if (rows.isNotEmpty) return rows;

    try {
      final items = await supabase
          .from('portfolio_items')
          .select()
          .order('event_date', ascending: false);
      return List<Map<String, dynamic>>.from(items as List).map(_fromPortfolioItem).toList();
    } catch (_) {
      return rows;
    }
  }

  Map<String, dynamic> _fromPortfolioItem(Map<String, dynamic> row) {
    final eventDate = row['event_date'];
    return {
      'id': row['id'].toString(),
      'name': row['title'],
      'description': row['description'],
      'category': row['category'],
      'image_url': row['image_url'],
      'event_id': null,
      'price': row['event_cost'],
      'created_at': eventDate ?? DateTime.now().toIso8601String(),
    };
  }

  Future<void> uploadEventImage(Map<String, dynamic> data) async {
    await supabase.from('portfolio').insert({
      'name': data['Name'],
      'category': data['Category'],
      'description': data['Description'],
      'image_url': data['Image_url'],
    });
  }
}
