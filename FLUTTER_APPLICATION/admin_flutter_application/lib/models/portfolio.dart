class Portfolio {
  final String id;
  final String? name;
  final String? description;
  final String? category;
  final String imageUrl;
  final String? eventId;
  final double? price;
  final DateTime createdAt;

  Portfolio({
    required this.id,
    this.name,
    this.description,
    this.category,
    required this.imageUrl,
    this.eventId,
    this.price,
    required this.createdAt,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'];
    final priceRaw = json['price'];
    return Portfolio(
      id: json['id'].toString(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      imageUrl: (json['image_url'] as String?) ?? '',
      eventId: json['event_id']?.toString(),
      price: priceRaw == null
          ? null
          : priceRaw is num
              ? priceRaw.toDouble()
              : double.tryParse('$priceRaw'),
      createdAt: createdRaw == null
          ? DateTime.now()
          : DateTime.parse(createdRaw.toString()),
    );
  }
}