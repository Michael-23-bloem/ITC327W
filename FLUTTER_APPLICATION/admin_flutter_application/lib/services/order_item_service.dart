
import 'supabase_client.dart';
 
class OrderItemService {
  final supabase = SupabaseClientManager.client;
 
  // wireframe 5 - Get Requested items for order
  Future<List<dynamic>> getItemsForOrder(String orderId) async {
    return await supabase
        .from('order_items')
        .select('''
          *,
          decor_products(name, price, image_url),
          packages(name, price)
        ''')
        .eq('order_id', orderId);
  }
 
  // wireframe 6 - Add item in Edit quotation
  Future<void> addItem(String orderId, String productId, int qty) async {
    final product = await supabase
        .from('decor_products')
        .select('price')
        .eq('id', productId)
        .single();
 
    await supabase.from('order_items').insert({
      'order_id': orderId,
      'product_id': productId,
      'quantity': qty,
      'unit_price': product['price'],
    });
  }
 
  Future<void> removeItem(String orderItemId) async {
    await supabase.from('order_items').delete().eq('id', orderItemId);
  }
}
 
