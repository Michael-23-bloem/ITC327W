
class Portfolio {
  final String id;
  final String? name;
  final String? description;
  final String? category;
  final String imageUrl;
  final String? eventId;
  final DateTime createdAt;
  final double? price;

  Portfolio({
    required this.id,
    this.name,
    this.description,
    this.category,
    required this.imageUrl,
    this.eventId,
    required this.createdAt,
    this.price,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      imageUrl: json['image_url'],
      eventId: json['event_id'],
      createdAt: DateTime.parse(json['created_at']),
      price: json['price'] == null
          ? null
          : (json['price'] as num).toDouble(),
    );
  }
}
