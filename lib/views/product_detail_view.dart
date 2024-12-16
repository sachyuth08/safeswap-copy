import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/cart_item.dart'; // Import CartItem model
import 'home_view.dart';
import 'sell_view.dart';
import 'cart_view.dart';
import 'user_view.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;

  const ProductDetailView({super.key, required this.product});

  @override
  _ProductDetailViewState createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _currentIndex = 0;

  void addToCart(BuildContext context, Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cartProducts') ?? [];

    // Deserialize existing cart items
    List<CartItem> cartItems = cartItemsJson.map((itemJson) {
      Map<String, dynamic> decodedItem = jsonDecode(itemJson);
      return CartItem.fromJson(decodedItem);
    }).toList();

    // Check if the product is already in the cart
    bool found = false;
    for (var item in cartItems) {
      if (item.product.id == product.id) {
        item.quantity += 1; // Increment quantity
        found = true;
        break;
      }
    }

    // If not found, add as a new cart item
    if (!found) {
      CartItem newItem = CartItem(product: product, quantity: 1);
      cartItems.add(newItem);
    }

    // Save updated cart items
    List<String> updatedCartItemsJson =
        cartItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cartProducts', updatedCartItemsJson);

    // Ensure the context is still mounted before showing Snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart')),
      );
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SellView()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CartView()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserView()),
        );
        break;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (widget.product.imageUrl != null)
              Image.network(
                widget.product.imageUrl!,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 100),
              ),
            const SizedBox(height: 16),
            // Product Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.product.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            // Product Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '\$${widget.product.price}',
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            // Product Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                widget.product.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            // Add to Cart Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  addToCart(context, widget.product);
                },
                child: const Text('Add to Cart'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'Lend'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
      ),
    );
  }
}
