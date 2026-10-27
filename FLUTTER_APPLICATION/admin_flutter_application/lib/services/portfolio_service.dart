import 'supabase_client.dart';

class PortfolioService {
  final supabase = SupabaseClientManager.client;

  Future<List<dynamic>> getPortfolio() async {
    return await supabase
        .from('portfolio')
        .select()
        .order('created_at', ascending: false);
  }

  Future<void> uploadEventImage(Map<String, dynamic> data) async {
    await supabase.from('portfolio').insert(data);
  }

  Future<List<String>> getPortfolioItemNames(String portfolioId) async {
    final data = await supabase
        .from('portfolio_product_links')
        .select('decor_products(name)')
        .eq('portfolio_id', portfolioId);

    return (data as List)
        .map((row) => (row['decor_products']?['name'] as String?) ?? 'Unknown item')
        .toList();
  }

  Future<void> deletePortfolio(String id) async {
    await supabase.from('portfolio_images').delete().eq('portfolio_id', id);
    await supabase.from('portfolio_product_links').delete().eq('portfolio_id', id);
    await supabase.from('portfolio').delete().eq('id', id);
  }

  Future<void> updatePortfolio(String id, Map<String, dynamic> data) async {
    await supabase.from('portfolio').update(data).eq('id', id);
  }

  Future<List<String>> getProductIdsForPortfolio(String portfolioId) async {
    final data = await supabase
        .from('portfolio_product_links')
        .select('product_id')
        .eq('portfolio_id', portfolioId);

    return (data as List).map((row) => row['product_id'] as String).toList();
  }

  Future<void> replacePortfolioItems(String portfolioId, List<String> productIds) async {
    await supabase.from('portfolio_product_links').delete().eq('portfolio_id', portfolioId);

    if (productIds.isNotEmpty) {
      final rows = productIds
          .map((productId) => {'portfolio_id': portfolioId, 'product_id': productId})
          .toList();
      await supabase.from('portfolio_product_links').insert(rows);
    }
  }

  Future<List<String>> getPortfolioImages(String portfolioId) async {
    final data = await supabase
        .from('portfolio_images')
        .select('image_url')
        .eq('portfolio_id', portfolioId)
        .order('sort_order', ascending: true);

    return (data as List).map((row) => row['image_url'] as String).toList();
  }

  Future<void> replacePortfolioImages(String portfolioId, List<String> imageUrls) async {
    if (imageUrls.isEmpty) {
      throw Exception('At least one event picture is required.');
    }

    await supabase
        .from('portfolio')
        .update({'image_url': imageUrls.first})
        .eq('id', portfolioId);

    await supabase.from('portfolio_images').delete().eq('portfolio_id', portfolioId);

    if (imageUrls.length > 1) {
      final extraRows = imageUrls.skip(1).toList().asMap().entries.map(
        (entry) => {
          'portfolio_id': portfolioId,
          'image_url': entry.value,
          'sort_order': entry.key + 1,
        },
      ).toList();

      await supabase.from('portfolio_images').insert(extraRows);
    }
  }
}