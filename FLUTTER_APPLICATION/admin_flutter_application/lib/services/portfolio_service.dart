

import 'supabase_client.dart';

class PortfolioService {
  final supabase = SupabaseClientManager.client;

  // Load portfolio events
  Future<List<dynamic>> getPortfolio() async {
    return await supabase
        .from('portfolio')
        .select()
        .order('created_at', ascending: false);
  }

  // Upload a portfolio event record
  Future<void> uploadEventImage(Map<String, dynamic> data) async {
    await supabase.from('portfolio').insert(data);
  }

  /*// Load additional images for a portfolio event
  Future<List<String>> getPortfolioImages(String portfolioId) async {
    final data = await supabase
        .from('portfolio_images')
        .select('image_url')
        .eq('portfolio_id', portfolioId);

    return (data as List)
        .map((row) => row['image_url'] as String)
        .toList();
  }*/

  // Load names of décor products used in a portfolio event
  Future<List<String>> getPortfolioItemNames(
      String portfolioId) async {
    final data = await supabase
        .from('portfolio_product_links')
        .select('decor_products(name)')
        .eq('portfolio_id', portfolioId);

    return (data as List)
        .map((row) =>
            (row['decor_products']?['name'] as String?) ??
            'Unknown item')
        .toList();
  }

  // Delete a portfolio event and its associated records
  Future<void> deletePortfolio(String id) async {
    await supabase
        .from('portfolio_images')
        .delete()
        .eq('portfolio_id', id);

    await supabase
        .from('portfolio_product_links')
        .delete()
        .eq('portfolio_id', id);

    await supabase
        .from('portfolio')
        .delete()
        .eq('id', id);
  }

  // Update portfolio event details
  Future<void> updatePortfolio(
      String id, Map<String, dynamic> data) async {
    await supabase
        .from('portfolio')
        .update(data)
        .eq('id', id);
  }

  // Get product IDs linked to a portfolio event
  Future<List<String>> getProductIdsForPortfolio(
      String portfolioId) async {
    final data = await supabase
        .from('portfolio_product_links')
        .select('product_id')
        .eq('portfolio_id', portfolioId);

    return (data as List)
        .map((row) => row['product_id'] as String)
        .toList();
  }

  // Replace all décor product links for a portfolio event
  Future<void> replacePortfolioItems(
      String portfolioId, List<String> productIds) async {
    await supabase
        .from('portfolio_product_links')
        .delete()
        .eq('portfolio_id', portfolioId);

    if (productIds.isNotEmpty) {
      final rows = productIds
          .map((productId) => {
                'portfolio_id': portfolioId,
                'product_id': productId,
              })
          .toList();

      await supabase
          .from('portfolio_product_links')
          .insert(rows);
    }
  }

  // Replace your existing getPortfolioImages method with this version.
Future<List<String>> getPortfolioImages(String portfolioId) async {
  final data = await supabase
      .from('portfolio_images')
      .select('image_url')
      .eq('portfolio_id', portfolioId)
      .order('sort_order', ascending: true);

  return (data as List)
      .map((row) => row['image_url'] as String)
      .toList();
}

// Add this new method inside PortfolioService.
Future<void> replacePortfolioImages(
  String portfolioId,
  List<String> imageUrls,
) async {
  if (imageUrls.isEmpty) {
    throw Exception('At least one event picture is required.');
  }

  // The first image is the cover image.
  await supabase
      .from('portfolio')
      .update({'image_url': imageUrls.first})
      .eq('id', portfolioId);

  // Replace all additional image records.
  await supabase
      .from('portfolio_images')
      .delete()
      .eq('portfolio_id', portfolioId);

  if (imageUrls.length > 1) {
    final extraRows = imageUrls.skip(1).toList().asMap().entries.map(
      (entry) => {
        'portfolio_id': portfolioId,
        'image_url': entry.value,
        'sort_order': entry.key + 1,
      },
    ).toList();

    await supabase
        .from('portfolio_images')
        .insert(extraRows);
  }
}
}





/*import 'supabase_client.dart';

class PortfolioService {
  final supabase = SupabaseClientManager.client;

  Future<List<dynamic>> getPortfolio() async {
    return await supabase.from('portfolio').select().order('created_at', ascending: false);
  }

  Future<void> uploadEventImage(Map<String, dynamic> data) async {
    await supabase.from('portfolio').insert(data);
  }

  Future<List<String>> getPortfolioImages(String portfolioId) async {
  final data = await supabase
      .from('portfolio_images')
      .select('image_url')
      .eq('portfolio_id', portfolioId);
  return (data as List).map((row) => row['image_url'] as String).toList();
}

Future<List<String>> getPortfolioItemNames(String portfolioId) async {
  final data = await supabase
      .from('portfolio_items')
      .select('decor_products(name)')
      .eq('portfolio_id', portfolioId);
  return (data as List)
      .map((row) => (row['decor_products']?['name'] as String?) ?? 'Unknown item')
      .toList();
}

Future<void> deletePortfolio(String id) async {
  await supabase.from('portfolio_images').delete().eq('portfolio_id', id);
  await supabase.from('portfolio_items').delete().eq('portfolio_id', id);
  await supabase.from('portfolio').delete().eq('id', id);
}

Future<void> updatePortfolio(String id, Map<String, dynamic> data) async {
  await supabase.from('portfolio').update(data).eq('id', id);
}

Future<List<String>> getProductIdsForPortfolio(String portfolioId) async {
  final data = await supabase
      .from('portfolio_items')
      .select('product_id')
      .eq('portfolio_id', portfolioId);
  return (data as List).map((row) => row['product_id'] as String).toList();
}

Future<void> replacePortfolioItems(String portfolioId, List<String> productIds) async {
  await supabase.from('portfolio_items').delete().eq('portfolio_id', portfolioId);
  if (productIds.isNotEmpty) {
    final rows = productIds.map((id) => {'portfolio_id': portfolioId, 'product_id': id}).toList();
    await supabase.from('portfolio_items').insert(rows);
  }
}
}*/