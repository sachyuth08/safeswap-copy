//supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import 'dart:typed_data';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Sign up a new user
  Future<void> signUpUser(String email, String password, {String? name}) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null
            ? {'name': name}
            : null, // Removed invalid 'options' parameter
      );

      if (response.user == null) {
        throw Exception('Sign-up failed.');
      }
    } on AuthException catch (e) {
      throw Exception('Sign-up error: ${e.message}');
    }
  }

  // Sign in a user
  Future<void> signInUser(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign-in failed.');
      }
    } on AuthException catch (e) {
      throw Exception('Sign-in error: ${e.message}');
    }
  }

  // Fetch authenticated user's profile
  Future<Map<String, dynamic>> fetchCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    try {
      final response =
          await supabase.from('users').select().eq('id', user.id).single();

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  // Fetch products from the 'products' table
  Future<List<Product>> fetchProducts() async {
    try {
      final List<dynamic> response = await supabase.from('products').select(
          'id, name, description, price, duration, image_url, created_at');

      return response
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

// Add a product to the 'products' table
  Future<void> addProduct(Product product, Uint8List imageBytes) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated.');
    }

    try {
      // Upload image to Supabase storage bucket
      final String filePath = 'products/${product.id}.jpg';
      await supabase.storage.from('images-bucket').uploadBinary(
            filePath,
            imageBytes,
            fileOptions: FileOptions(cacheControl: '3600', upsert: false),
          );
      // Get the public URL of the uploaded image
      final imageUrl =
          supabase.storage.from('images-bucket').getPublicUrl(filePath);

      if (imageUrl.isEmpty) {
        throw Exception('Failed to generate public URL for the uploaded image');
      }

      // Insert product data into 'products' table
      await supabase.from('products').insert({
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'image_url': imageUrl,
        'duration': product.duration,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'user_id': user.id,
      });
    } catch (e) {
      throw Exception('Error adding product: $e');
    }
  }

  // Add a product to the cart
  Future<void> addToCart(String userId, String productId) async {
    try {
      await supabase.from('cart_items').insert({
        'user_id': userId,
        'product_id': productId,
        'quantity': 1,
        'added_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }
}
