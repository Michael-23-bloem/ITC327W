class OrderLineItem {
  final String name;
  final int quantity;
  final double amount;

  const OrderLineItem({
    required this.name,
    required this.quantity,
    required this.amount,
  });
}

class Order {
  final String id;
  final String customerId;
  final String status;
  final String eventType;
  final DateTime eventDate;
  final DateTime createdAt;
  final String? venue;
  final String? theme;
  final String? notes;
  final String? profiles;
  final String? customerEmail;
  final String? customerName;
  final String? customerPhone;
  final int guestCount;
  final double estimatedTotal;
  final double transportFee;
  final double serviceFee;
  final List<OrderLineItem> items;

  Order({
    required this.id,
    required this.customerId,
    required this.status,
    required this.eventType,
    required this.eventDate,
    DateTime? createdAt,
    this.venue,
    this.theme,
    this.notes,
    this.customerEmail,
    this.customerName,
    this.customerPhone,
    this.guestCount = 0,
    this.profiles,
    this.estimatedTotal = 0,
    this.transportFee = 0,
    this.serviceFee = 0,
    this.items = const [],
  }) : createdAt = createdAt ?? eventDate;

  int get guests => guestCount;

  factory Order.fromJson(Map<String, dynamic> json) {
    final prof = json['profiles'] as Map<String, dynamic>?;
    String? email = prof?['email'] as String?;
    String? phone = prof?['phone_number'] as String?;
    String? name = prof != null
        ? '${prof['first_name'] ?? ''} ${prof['last_name'] ?? ''}'.trim()
        : null;
    if (name != null && name.isEmpty) name = null;

    Map<String, dynamic>? quote;
    final quotes = json['quotations'];
    if (quotes is List && quotes.isNotEmpty && quotes.first is Map) {
      quote = Map<String, dynamic>.from(quotes.first as Map);
    } else if (quotes is Map<String, dynamic>) {
      quote = quotes;
    }

    double asDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse('$v') ?? 0;
    }

    final items = <OrderLineItem>[];
    final rawItems = json['order_items'];
    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final product = map['decor_products'];
        String itemName = 'Item';
        double price = 0;
        if (product is Map) {
          itemName = (product['name'] as String?)?.trim().isNotEmpty == true
              ? product['name'] as String
              : 'Item';
          price = asDouble(product['price']);
        }
        final qty = map['quantity'] is int
            ? map['quantity'] as int
            : int.tryParse('${map['quantity']}') ?? 1;
        final unit = map['unit_price'] ?? map['price_at_time'] ?? price;
        items.add(
          OrderLineItem(
            name: itemName,
            quantity: qty,
            amount: asDouble(unit) * qty,
          ),
        );
      }
    }

    return Order(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      status: json['status'] as String? ?? 'request_sent',
      eventType: json['event_type'] as String? ?? 'Event',
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      venue: json['venue'] as String?,
      theme: json['theme'] as String?,
      notes: json['notes'] as String?,
      customerEmail: email,
      customerName: name,
      customerPhone: phone,
      guestCount: (json['guest_count'] ?? json['guests'] ?? 0) is num
    ? ((json['guest_count'] ?? json['guests'] ?? 0) as num).toInt()
    : int.tryParse(
        '${json['guest_count'] ?? json['guests'] ?? 0}',
      ) ?? 0,
     // guestCount: json['guest_count'] as int? ?? json['guests'] as int? ?? 0,
      estimatedTotal: asDouble(quote?['estimated_total'] ?? quote?['final_total']),
      transportFee: asDouble(quote?['transportation_fee']),
      serviceFee: asDouble(quote?['service_fee']),
      items: items,
    );
  }

  String get eventTypeLabel => eventType;

  String get displayName =>
      (customerName != null && customerName!.isNotEmpty)
          ? customerName!
          : (customerEmail ?? 'Client');

  int get hoursLeft {
    final deadline = createdAt.add(const Duration(hours: 24));
    return deadline.difference(DateTime.now()).inHours;
  }

  double get computedTotal {
    if (estimatedTotal > 0) return estimatedTotal;
    final itemsTotal = items.fold<double>(0, (s, i) => s + i.amount);
    return itemsTotal + transportFee + serviceFee;
  }
}

extension OrderCompat on Order {
  String get customerEmailOrId => customerEmail ?? customerId.substring(0, 8);
}
