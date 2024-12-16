//product_view_model.dart 
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../supabase_service.dart';

class ProductViewModel extends ChangeNotifier {
  List<Product> _products = [];
  final String productsKey = 'local_products';
  final SupabaseService supabaseService = SupabaseService();

  List<Product> get products => _products;

  ProductViewModel() {
    loadProducts();
  }

  // Method to add a new product locally
  void addProduct(Product product) {
    _products.add(product);
    saveLocalProducts();
    notifyListeners();
  }

  // Method to load products from both local storage and Supabase database
  Future<void> loadProducts() async {
    try {
      // Load products from local storage
      List<Product> localProducts = await _loadLocalProducts();

      // Load products from the Supabase database
      List<Product> supabaseProducts = await supabaseService.fetchProducts();

      // Combine the lists, prioritizing local images if they exist
      Map<String, Product> combinedProducts = {
        for (var product in supabaseProducts) product.id: product,
        for (var product in localProducts) product.id: product
      };

      _products = combinedProducts.values.toList();
      notifyListeners();
    } catch (e) {
      // Handle errors gracefully
      debugPrint('Error loading products: $e');
    }
  }

  // Method to save products to local storage
  Future<void> saveLocalProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> productsJson = _products
          .map((product) => jsonEncode(product.toJson()))
          .toList();
      await prefs.setStringList(productsKey, productsJson);
    } catch (e) {
      debugPrint('Error saving local products: $e');
    }
  }

  // Helper method to load products from local storage
  Future<List<Product>> _loadLocalProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? productStrings = prefs.getStringList(productsKey) ?? [];
      return productStrings
          .map((productStr) => Product.fromJson(jsonDecode(productStr)))
          .toList();
    } catch (e) {
      debugPrint('Error loading local products: $e');
      return [];
    }
  }
}
