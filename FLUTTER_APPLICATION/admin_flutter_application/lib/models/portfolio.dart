
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
    final createdRaw = json['created_at'];
    final priceRaw = json['price'];
    return Portfolio(
<<<<<<< HEAD
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
=======
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
>>>>>>> a0c017d4b93d3185ef6d57be63911b5d6a4cec49
    );
  }
}
