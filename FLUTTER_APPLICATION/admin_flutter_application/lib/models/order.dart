
class Order {
  final String id;
  final String customerId;
  final String status;
  final String eventType;
  final DateTime eventDate;
  final String? venue;
  final String? theme;
  final String? notes;
  final String? profiles; // raw profiles object
  final String? customerEmail;
  final String? customerName;
  final int guests;
  

  Order({
    required this.id,
    required this.customerId,
    required this.status,
    required this.eventType,
    required this.eventDate,
    this.venue,
    this.theme,
    this.notes,
    this.customerEmail,
    this.customerName,
    this.guests = 0,
    this.profiles,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // profiles comes as Map from join
    final prof = json['profiles'] as Map<String, dynamic>?;
    String? email = prof?['email'];
    String? name = prof != null 
      ? '${prof['first_name'] ?? ''} ${prof['last_name'] ?? ''}'.trim()
      : null;

    return Order(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      status: json['status'] as String? ?? 'pending',
      eventType: json['event_type'] as String? ?? 'Event',
      eventDate: json['event_date'] != null 
        ? DateTime.parse(json['event_date']) 
        : DateTime.now(),
      venue: json['venue'] as String?,
      theme: json['theme'] as String?,
      notes: json['notes'] as String?,
      customerEmail: email,
      customerName: name,
      guests: json['guest_count'] as int? ?? 0,
    );
  }

  String get eventTypeLabel => eventType;
  DateTime get createdAt => eventDate;
  int get hoursLeft => eventDate.difference(DateTime.now()).inHours;
}

extension OrderCompat on Order {
  String get customerEmailOrId => customerEmail ?? customerId.substring(0, 8);
}



/*class Order {
  final String id;
  final String customerId;
  final String? customerEmail; // we will join from profiles when fetching
  final String? eventType;
  final DateTime eventDate;
  final String? venue;
  final int? guests;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerId,
    this.customerEmail,
    this.eventType,
    required this.eventDate,
    this.venue,
    this.guests,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customer_id'],
      // if we did .select('*, profiles(email)') it will come as nested
      customerEmail: json['profiles'] != null ? json['profiles']['email'] : json['customer_email'],
      eventType: json['event_type'],
      eventDate: DateTime.parse(json['event_date']),
      venue: json['venue'],
      guests: json['guests'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // For list display
  int get hoursLeft {
    final diff = eventDate.difference(DateTime.now());
    return diff.inHours;
  }
}*/