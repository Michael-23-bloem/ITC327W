import 'package:flutter/material.dart';
import '../services/order_item_service.dart';
import '../models/order_item.dart';

class OrderItemViewModel extends ChangeNotifier {
  final _service = OrderItemService();
  List<Order_item> items = [];
  bool loading = false;

  Future<void> loadForOrder(String orderId) async {
    loading = true; notifyListeners();
    final data = await _service.getItemsForOrder(orderId);
    items = data.map((e) => Order_item(
      orderItemId: e['Order_item_id'].toString(),
      orderId: e['Order_id'].toString(),
      productId: e['Product_id']?.toString(),
      packageId: e['Package_id']?.toString(),
      quantity: e['Quantity'] ?? 1,
      priceAtTime: (e['Price_at_time'] ?? e['Price'] ?? 0).toDouble(),
    )).toList();
    loading = false; notifyListeners();
  }

  Future<void> addItem(String orderId, String productId, int qty) async {
    await _service.addItem(orderId, productId, qty);
    await loadForOrder(orderId);
  }

  Future<void> removeItem(String orderItemId, String orderId) async {
    await _service.removeItem(orderItemId);
    await loadForOrder(orderId);
  }
}