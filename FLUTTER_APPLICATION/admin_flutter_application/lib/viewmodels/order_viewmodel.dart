import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/order_service.dart';
import '../services/order_item_service.dart';
import '../models/order_item.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/quotation.dart';

class OrderViewModel extends ChangeNotifier {
  final _service = OrderService();
  final _orderItemService = OrderItemService();
  final supabase = Supabase.instance.client;

  List<Order> quotations = [];
  List<Order> bookings = [];
  Order? selected;
  bool loading = false;
  // Items being prepared for the quotation.
List<QuotationItem> quotationItems = [];
List<QuotationItem> originalOrderItems = [];

// Quotation fees.
double transportationFee = 0;
double serviceFee = 0;

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
  String orderId,
) async {
  try {
    // Always load the original customer request for comparison.
    final originalData =
        await _orderItemService.getItemsForOrder(orderId);

    originalOrderItems = originalData.map((row) {
      final item = row as Map<String, dynamic>;

      final product = item['decor_products'];
      final package = item['packages'];

      final productData = product is Map
          ? Map<String, dynamic>.from(product)
          : <String, dynamic>{};

      final packageData = package is Map
          ? Map<String, dynamic>.from(package)
          : <String, dynamic>{};

      final productPrice = productData['price'] as num?;
      final packagePrice = packageData['price'] as num?;

      return QuotationItem(
        productId: item['product_id']?.toString(),
        packageId: item['package_id']?.toString(),
        productName: productData['name']?.toString() ??
            packageData['name']?.toString() ??
            'Unknown item',
        imageUrl: productData['image_url']?.toString(),
        quantity: (item['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (item['unit_price'] as num?)?.toDouble() ??
            productPrice?.toDouble() ??
            packagePrice?.toDouble() ??
            0,
      );
    }).toList();

    final data = await _service.getLatestQuotation(orderId);

    if (data != null) {
      final rawItems = data['quotation_items'];

      if (rawItems is List && rawItems.isNotEmpty) {
        quotationItems = rawItems
            .whereType<Map>()
            .map(
              (item) => QuotationItem.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      } else {
        // Older quotation without saved items.
        quotationItems = originalOrderItems.map((item) {
          return QuotationItem(
            productId: item.productId,
            packageId: item.packageId,
            productName: item.productName,
            imageUrl: item.imageUrl,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          );
        }).toList();
      }

      transportationFee =
          (data['transportation_fee'] as num?)?.toDouble() ?? 0;

      serviceFee =
          (data['service_fee'] as num?)?.toDouble() ?? 0;
    } else {
      // First quotation.
      quotationItems = originalOrderItems.map((item) {
        return QuotationItem(
          productId: item.productId,
          packageId: item.packageId,
          productName: item.productName,
          imageUrl: item.imageUrl,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
        );
      }).toList();

      transportationFee = 0;
      serviceFee = 0;
    }

    notifyListeners();
    return data;
  } catch (e) {
    debugPrint('loadQuotationForEdit error: $e');
    rethrow;
  }
}
/*Future<void> _loadOriginalOrderItems(String orderId) async {
  final data = await _orderItemService.getItemsForOrder(orderId);

  originalOrderItems = data.map((row) {
    final item = row as Map<String, dynamic>;

    final product = item['decor_products'];
    final package = item['packages'];

    final productData = product is Map
        ? Map<String, dynamic>.from(product)
        : <String, dynamic>{};

    final packageData = package is Map
        ? Map<String, dynamic>.from(package)
        : <String, dynamic>{};

    final productPrice = productData['price'] as num?;
    final packagePrice = packageData['price'] as num?;

    final unitPrice =
        (item['unit_price'] as num?)?.toDouble() ??
        productPrice?.toDouble() ??
        packagePrice?.toDouble() ??
        0;

    return QuotationItem(
      productId: item['product_id']?.toString(),
      packageId: item['package_id']?.toString(),
      productName: productData['name']?.toString() ??
          packageData['name']?.toString() ??
          'Unknown item',
      imageUrl: productData['image_url']?.toString(),
      quantity: (item['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: unitPrice,
    );
  }).toList();

  // Make an independent editable copy.
  quotationItems = originalOrderItems.map((item) {
    return QuotationItem(
      productId: item.productId,
      packageId: item.packageId,
      productName: item.productName,
      imageUrl: item.imageUrl,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
    );
  }).toList();
}*/
/*Future<Map<String, dynamic>?> loadQuotationForEdit(
  String orderId,
) async {
  try {
    final data = await _service.getLatestQuotation(orderId);

    if (data != null) {
      // Load the items from the latest quotation version.
      final rawItems = data['quotation_items'];

      quotationItems = rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (item) => QuotationItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [];

      // Load the existing fees.
      transportationFee =
          (data['transportation_fee'] as num?)?.toDouble() ?? 0;

      serviceFee =
          (data['service_fee'] as num?)?.toDouble() ?? 0;
    } else {
      // No quotation exists yet.
      quotationItems = [];
      transportationFee = 0;
      serviceFee = 0;
    }

    notifyListeners();
    return data;
  } catch (e) {
    debugPrint('loadQuotationForEdit error: $e');
    rethrow;
  }
}*/
/*Future<Map<String, dynamic>?> loadQuotationForEdit(
    String orderId) async {
  try {
    return await _service.getLatestQuotation(orderId);
  } catch (e) {
    debugPrint('loadQuotationForEdit error: $e');
    rethrow;
  }
}*/


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

  Future<void> editQuotation(String orderId) async {
  await _service.editQuotation(
    orderId,
    quotationItems,
    transportationFee,
    serviceFee,
  );

  await loadQuotations();

  // Refresh the selected order if it is currently open.
  if (selected != null && selected!.id == orderId) {
    await selectOrder(orderId);
  }
}/*Future<void> editQuotation(String orderId, double total, double transport, double service) async {
    await _service.editQuotation(orderId, total, transport, service);
    await loadQuotations();
  }*/

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