import 'package:flutter/material.dart';
import '../models/decor_product.dart';

class DecorProductCard extends StatelessWidget {
  final DecorProduct product;
  const DecorProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: product.imageUrl != null ? Image.network(product.imageUrl!, width: 50, height: 50, fit: BoxFit.cover) : const Icon(Icons.image),
        title: Text(product.name),
        subtitle: Text('R${product.price.toStringAsFixed(2)} • Stock: ${product.stockQuantity}'),
      ),
    );
  }
}




/*import 'package:flutter/material.dart';
import '../services/decor_product_service.dart';
import '../models/decor_product.dart';

class DecorProductViewModel extends ChangeNotifier {
  final _service = DecorProductService();
  List<DecorProduct> catalogue = [];

  Future<void> loadCatalogue() async {
    final data = await _service.getCatalogue();
    catalogue = data.map((e) => DecorProduct.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> upload(Map<String,dynamic> data) async {
    await _service.uploadDecor(data); // Name, Description, Price, Category, Image_url, Stock
    await loadCatalogue();
  }
}*/