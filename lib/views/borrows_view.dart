import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'home_view.dart';
import 'sell_view.dart';
import 'cart_view.dart';
import 'user_view.dart';

class BorrowsView extends StatefulWidget {
  const BorrowsView({super.key});

  @override
  _BorrowsViewState createState() => _BorrowsViewState();
}

class _BorrowsViewState extends State<BorrowsView> {
  List<CartItem> borrowedItems = [];
  int _currentIndex = 0;

  final Color primaryColor = const Color.fromARGB(255, 19, 153, 255);

  @override
  void initState() {
    super.initState();
    loadBorrowedItems();
  }

  Future<void> loadBorrowedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> borrowedItemsJson =
        prefs.getStringList('checkedOutProducts') ?? [];

    // Deserialize the items
    List<CartItem> loadedItems = borrowedItemsJson.map((itemJson) {
      Map<String, dynamic> decodedItem = jsonDecode(itemJson);
      return CartItem.fromJson(decodedItem);
    }).toList();

    setState(() {
      borrowedItems = loadedItems;
    });
  }

  Future<void> revokeBorrowedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear the borrowed items from SharedPreferences
    await prefs.remove('checkedOutProducts');

    setState(() {
      borrowedItems = [];
    });

    // Show confirmation message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All borrowed items have been revoked')),
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
        backgroundColor: primaryColor,
        title: const Text(
          'Your Borrowed Items',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: borrowedItems.isEmpty
          ? const Center(child: Text('No borrowed items'))
          : ListView.builder(
              itemCount: borrowedItems.length,
              itemBuilder: (context, index) {
                CartItem cartItem = borrowedItems[index];
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
                      'Quantity: ${cartItem.quantity}\nPrice: \$${product.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Pop-up confirmation to revoke request
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Revoke Request'),
                          content: const Text(
                              'Are you sure you want to revoke this request?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Remove the specific item from SharedPreferences
                                setState(() {
                                  borrowedItems.removeAt(index);
                                });

                                saveUpdatedBorrowedItems();

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('${product.name} request revoked'),
                                  ),
                                );
                              },
                              child: const Text('Revoke'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: borrowedItems.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                // Revoke all borrowed items
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Revoke All Requests'),
                    content: const Text(
                        'Are you sure you want to revoke all requests?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          revokeBorrowedItems();
                          Navigator.pop(context);
                        },
                        child: const Text('Revoke All'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete_forever),
            )
          : null,
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

  Future<void> saveUpdatedBorrowedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the updated borrowed items back to JSON and save
    List<String> updatedBorrowedItemsJson =
        borrowedItems.map((item) => jsonEncode(item.toJson())).toList();

    await prefs.setStringList('checkedOutProducts', updatedBorrowedItemsJson);
  }
}
