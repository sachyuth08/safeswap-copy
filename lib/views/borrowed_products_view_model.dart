import 'package:flutter/material.dart';
import '../models/product.dart';

class BorrowedProductsViewModel extends ChangeNotifier {
  List<Product> borrowedProducts = [];

  void addBorrowedProduct(Product product) {
    borrowedProducts.add(product);
    notifyListeners();
  }

  void removeBorrowedProduct(Product product) {
    borrowedProducts.remove(product);
    notifyListeners();
  }

  void clearBorrowedProducts() {
    borrowedProducts.clear();
    notifyListeners();
  }

  // Always return a non-null Product
  Product findBorrowedProduct(String id) {
    return borrowedProducts.firstWhere(
      (product) => product.id == id,
      orElse: () => Product(
        id: '',
        name: 'Unknown',
        description: 'No description available',
        price: 0.0,
        imageUrl: null,
        createdAt: null,
        duration: 0,
      ),
    );
  }

  List<Product> getBorrowedProducts() {
    return List.from(borrowedProducts);
  }
}
