import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import 'success_view.dart';
import 'home_view.dart';
import 'sell_view.dart';
import 'cart_view.dart';
import 'user_view.dart';

class CheckoutView extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutView({super.key, required this.cartItems});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  String _paymentMethod = 'Credit Card';
  int _currentIndex = 2; // Default to the Cart page
  final Color primaryColor = const Color.fromARGB(255, 19, 153, 255);

  Future<void> saveCheckedOutProducts(List<CartItem> checkedOutItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the cart items to JSON format
    List<String> cartItemsJson =
        checkedOutItems.map((item) => jsonEncode(item.toJson())).toList();

    // Save the checked-out items to SharedPreferences under a specific key
    await prefs.setStringList('checkedOutProducts', cartItemsJson);
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.cartItems.fold(0.0, (sum, item) {
      return sum + item.product.price * item.quantity;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                CartItem cartItem = widget.cartItems[index];
                Product product = cartItem.product;
                return ListTile(
                  leading:
                      (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                          ? Image.network(
                              product.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image),
                            ),
                  title: Text(product.name),
                  subtitle: Text(
                    'Quantity: ${cartItem.quantity}\nTotal: \$${(product.price * cartItem.quantity).toStringAsFixed(2)}',
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Select Payment Method - Insurance / Credit'),
            trailing: DropdownButton<String>(
              value: _paymentMethod,
              items: <String>['Credit Card', 'Insurance'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _paymentMethod = newValue!;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12.0), // Add padding on both sides
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Save checked-out products to SharedPreferences
                  await saveCheckedOutProducts(widget.cartItems);

                  // Clear the current cart from SharedPreferences
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('cartProducts');

                  if (!mounted) return;

                  // Navigate to SuccessView
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SuccessView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 255, 152, 0), // Accent yellow
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.black), // Black text
                ),
              ),
            ),
          ),
        ],
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
        onTap: (index) {
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
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
      ),
    );
  }
}
