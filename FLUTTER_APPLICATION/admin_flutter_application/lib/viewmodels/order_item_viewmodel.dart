
import 'package:flutter/material.dart';
import '../services/order_item_service.dart';
import '../models/order_item.dart';

class OrderItemViewModel extends ChangeNotifier {
  final _service = OrderItemService();

  List<Order_item> items = [];
  bool loading = false;
  String? error;

  Future<void> loadForOrder(String orderId) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final data = await _service.getItemsForOrder(orderId);

      items = data.map((e) {
        final map = e as Map<String, dynamic>;

        // Retrieve the joined product and package information.
        final product = map['decor_products']
            as Map<String, dynamic>?;

        final package = map['packages']
            as Map<String, dynamic>?;

        // Get the name of the product or package.
        final productName = product?['name']?.toString();
        final packageName = package?['name']?.toString();

        // Get the image belonging to the selected item.
        final imageUrl =
            product?['image_url']?.toString() ??
            package?['image_url']?.toString();

        return Order_item(
          orderItemId: map['id'].toString(),
          orderId: map['order_id'].toString(),
          productId: map['product_id']?.toString(),
          packageId: map['package_id']?.toString(),
          quantity: (map['quantity'] as num?)?.toInt() ?? 1,
          priceAtTime:
              (map['unit_price'] as num?)?.toDouble() ?? 0.0,

          // New display fields in your existing model.
          productName: productName,
          packageName: packageName,
          imageUrl: imageUrl,
        );
      }).toList();
    } catch (e) {
      debugPrint('loadForOrder error: $e');
      error = e.toString().replaceFirst('Exception: ', '');
      items = [];
    }

    loading = false;
    notifyListeners();
  }

  Future<void> addItem(
      String orderId, String productId, int qty) async {
    await _service.addItem(orderId, productId, qty);
    await loadForOrder(orderId);
  }

  Future<void> removeItem(
      String orderItemId, String orderId) async {
    await _service.removeItem(orderItemId);
    await loadForOrder(orderId);
  }
}
