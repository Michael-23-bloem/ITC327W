
class Quotation {
  final String id;
  final String orderId;
  final int version;
  final String status;

  final double estimatedTotal;
  final double transportationFee;
  final double serviceFee;
  final double? finalTotal;

  final String? bankingDetails;
  final String? noteToClient;
  final String? declineReason;

  // Items stored in the quotation_items JSONB column
  final List<QuotationItem> items;

  final DateTime createdAt;

  Quotation({
    required this.id,
    required this.orderId,
    required this.version,
    required this.status,
    required this.estimatedTotal,
    required this.transportationFee,
    required this.serviceFee,
    this.finalTotal,
    this.bankingDetails,
    this.noteToClient,
    this.declineReason,
    this.items = const [],
    required this.createdAt,
  });

  double get itemsSubtotal {
    return items.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );
  }

  double get calculatedTotal {
    return itemsSubtotal + transportationFee + serviceFee;
  }

  factory Quotation.fromJson(Map<String, dynamic> json) {
    final rawItems = json['quotation_items'];

    return Quotation(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      version: (json['version'] as num).toInt(),
      status: json['status']?.toString() ?? 'pending',
      estimatedTotal:
          (json['estimated_total'] as num?)?.toDouble() ?? 0,
      transportationFee:
          (json['transportation_fee'] as num?)?.toDouble() ?? 0,
      serviceFee:
          (json['service_fee'] as num?)?.toDouble() ?? 0,
      finalTotal: (json['final_total'] as num?)?.toDouble(),
      bankingDetails: json['banking_details']?.toString(),
      noteToClient: json['note_to_client']?.toString(),
      declineReason: json['decline_reason']?.toString(),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (item) => QuotationItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}

class QuotationItem {
  final String? productId;
  final String? packageId;
  final String productName;
  final String? imageUrl;

  final int quantity;
  final double unitPrice;

  const QuotationItem({
    this.productId,
    this.packageId,
    required this.productName,
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      productId: json['product_id']?.toString(),
      packageId: json['package_id']?.toString(),
      productName: json['product_name']?.toString() ?? 'Custom item',
      imageUrl: json['image_url']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'package_id': packageId,
      'product_name': productName,
      'image_url': imageUrl,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}
