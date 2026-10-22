class DecorProduct {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? category;
  final int stockQuantity;
  final String? imageUrl;

  DecorProduct({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
    required this.stockQuantity,
    this.imageUrl,
  });

  factory DecorProduct.fromJson(Map<String, dynamic> json) {
    return DecorProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      stockQuantity: json['stock_quantity'],
      imageUrl: json['image_url'],
    );
  }
}