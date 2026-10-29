import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/order_service.dart';
import '../models/order.dart';
import '../models/order_status.dart';

class OrderViewModel extends ChangeNotifier {
  final _service = OrderService();
  final supabase = Supabase.instance.client;

  List<Order> quotations = [];
  List<Order> bookings = [];
  Order? selected;
  bool loading = false;

 /* Future<void> loadQuotations() async {
    loading = true;
    notifyListeners();
    try {
      final data = await supabase
          .from('orders')
          .select('*, profiles(email, first_name, last_name)')
          .inFilter('status', ['request_sent', 'in_contact', 'quotation_approved'])
          .order('created_at', ascending: false);

      quotations = (data as List).map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('loadQuotations error: $e');
    }
    loading = false;
    notifyListeners();
  }
*/

Future<Map<String, dynamic>?> loadQuotationForEdit(
    String orderId) async {
  try {
    return await _service.getLatestQuotation(orderId);
  } catch (e) {
    debugPrint('loadQuotationForEdit error: $e');
    rethrow;
  }
}


Future<void> loadQuotations() async {
  loading = true;
  notifyListeners();

  try {
    final data = await supabase
        .from('orders')
        .select('*, profiles(email, first_name, last_name)')
        .inFilter('status', [
          OrderStatus.requestSent,
          OrderStatus.inContact,
          OrderStatus.quotationApproved,
          OrderStatus.orderConfirmed,
          OrderStatus.depositReceived,
          OrderStatus.preparationsBegin,
          OrderStatus.completed,
          OrderStatus.declined,
          OrderStatus.cancelled,
        ])
        .order('created_at', ascending: false);

    quotations = (data as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint('loadQuotations error: $e');
  } finally {
    loading = false;
    notifyListeners();
  }
}

  Future<void> loadBookings() async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.getBookings();
      bookings = data.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      debugPrint('loadBookings error: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<void> selectOrder(String orderId) async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.getOrder(orderId);
      selected = Order.fromJson(data);
    } catch (e) {
      debugPrint('selectOrder error: $e');
    }
    loading = false;
    notifyListeners();
  }

  Future<void> editQuotation(String orderId, double total, double transport, double service) async {
    await _service.editQuotation(orderId, total, transport, service);
    await loadQuotations();
  }

  Future<void> validateEft(String orderId) async {
    await _service.validateEftAndConvert(orderId);
    await loadQuotations();
    await loadBookings();
  }

  Future<void> updateProgress(String orderId, String status, String note) async {
    await _service.updateProgress(orderId, status, note);
    if (selected != null) await selectOrder(orderId);
    // A status change can move an order between the requests list and the
    // calendar (or out of both, e.g. "declined"), so refresh both.
    await loadQuotations();
    await loadBookings();
  }

  Future<void> confirmQuotation(String orderId) async {
    await _service.confirmQuotation(orderId);
    await loadQuotations();
    await selectOrder(orderId);
  }

  Future<void> markInContact(String orderId) async {
    await _service.markInContact(orderId);
    await loadQuotations();
    await selectOrder(orderId);
  }
}