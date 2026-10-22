class Package {
  final String packageId;
  final String name;
  final double price;
  final String description;
  final String? imageUrl;

  Package({
    required this.packageId,
    required this.name,
    required this.price,
    required this.description,
    this.imageUrl,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      packageId: json['Package_id']?.toString() ?? json['package_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['Name']?.toString() ?? json['name']?.toString() ?? '',
      price: json['Price'] != null ? (json['Price'] as num).toDouble() : json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      description: json['Description']?.toString() ?? json['description']?.toString() ?? '',
      imageUrl: json['Image_url']?.toString() ?? json['image_url']?.toString(),
    );
  }
}