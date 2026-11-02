
class Package {
  final String packageId;
  final String name;
  final double price;
  final String description;
  final String? imageUrl;
  final bool isActive;
  final int itemCount;

  Package({
    required this.packageId,
    required this.name,
    required this.price,
    required this.description,
    this.imageUrl,
    this.isActive = true,
    this.itemCount = 0,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    final packageItems = json['package_items'] as List?;

    return Package(
      packageId: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      itemCount: packageItems?.length ?? 0,
    );
  }
}
