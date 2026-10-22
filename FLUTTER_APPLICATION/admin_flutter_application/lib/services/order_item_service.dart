import 'supabase_client.dart';

class OrderItemService {
  final supabase = SupabaseClientManager.client;

  // wireframe 5 - Get Requested items for order
  Future<List<dynamic>> getItemsForOrder(String orderId) async {
    return await supabase
      .from('Order_item')
      .select('*, DecorProduct(Name, Price, Image_url), Package(Name, Price)')
      .eq('Order_id', orderId);
  }

  // wireframe 6 - Add item in Edit quotation
  Future<void> addItem(String orderId, String productId, int qty) async {
    // get price at time
    final product = await supabase.from('DecorProduct').select('Price').eq('Product_id', productId).single();
    await supabase.from('Order_item').insert({
      'Order_id': orderId,
      'Product_id': productId,
      'Quantity': qty,
      'Price_at_time': product['Price'],
    });
  }

  Future<void> removeItem(String orderItemId) async {
    await supabase.from('Order_item').delete().eq('Order_item_id', orderItemId);
  }
}