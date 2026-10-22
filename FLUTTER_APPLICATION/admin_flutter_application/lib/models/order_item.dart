class Order_item {
  String orderItemId; // Order_item_id PK
  String orderId; // Order_id FK -> Order
  String? productId; // Product_id FK -> DecorProduct - Contain in ERD
  String? packageId; // Package_id FK -> Package - Contain in ERD
  int quantity; // x40, x5 wireframe 5
  double priceAtTime;

  Order_item({
    required this.orderItemId,
    required this.orderId,
    this.productId,
    this.packageId,
    required this.quantity,
    required this.priceAtTime,
  });
}