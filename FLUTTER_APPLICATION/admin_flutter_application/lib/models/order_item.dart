
class Order_item {
  String orderItemId; // Order item primary key
  String orderId; // Foreign key -> Order

  String? productId; // Foreign key -> DecorProduct
  String? packageId; // Foreign key -> Package

  // Details retrieved from Supabase
  String? productName;
  String? packageName;
  String? imageUrl;
  double? cataloguePrice;

  int quantity;
  double priceAtTime;

  Order_item({
    required this.orderItemId,
    required this.orderId,
    this.productId,
    this.packageId,
    this.productName,
    this.packageName,
    this.imageUrl,
    this.cataloguePrice,
    required this.quantity,
    required this.priceAtTime,
  });

  // Display the product or package name
  String get itemName =>
      productName ?? packageName ?? 'Unknown item';

  // Calculate the total for this item
  double get totalPrice => quantity * priceAtTime;
}
