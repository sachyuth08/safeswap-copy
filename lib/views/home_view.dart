import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart'; // Import CartItem
import '../supabase_service.dart';
import 'sell_view.dart';
import 'cart_view.dart';
import 'user_view.dart';
import 'product_detail_view.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

enum SortOption { name, priceLowToHigh, priceHighToLow }

class HomeViewState extends State<HomeView> {
  final SupabaseService supabaseService = SupabaseService();
  String userName = '';
  String userId = '';
  SortOption sortOption = SortOption.name;
  TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;
  List<Product> products = []; // List of products from database
  late Map<String, dynamic> cartBox;

  // Define custom colors
  final Color primaryColor = const Color.fromARGB(255, 19, 153, 255);
  final Color accentColor = const Color.fromARGB(255, 255, 152, 0);
  final Color backgroundColor = const Color(0xFFF3F4F6);
  final Color cardColor = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    loadCartFromPreferences(); // Load cart from SharedPreferences
    loadUserName();
    fetchProducts(); // Fetch products from Supabase
  }

  Future<void> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Guest'; // Retrieve name
      userId = prefs.getString('email') ?? ''; // Keep email as backup if needed
    });
  }

  Map<String, CartItem> cartItems = {};
  Future<void> loadCartFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartJson = prefs.getString('cart');
    if (cartJson != null) {
      Map<String, dynamic> cartMap =
          Map<String, dynamic>.from(jsonDecode(cartJson));
      setState(() {
        cartItems = cartMap.map((key, value) {
          return MapEntry(
            key,
            CartItem.fromJson(value),
          );
        });
      });
    } else {
      cartItems = {};
    }
  }

  Future<void> fetchProducts() async {
    try {
      List<Product> fetchedProducts = await supabaseService.fetchProducts();
      setState(() {
        products = fetchedProducts;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading products: $e")),
      );
    }
  }

//add to cart
  void addToCart(Product product) async {
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

    // Show confirmation Snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to cart')),
      );
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        break; // Already on Home
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SellView()),
        ).then((_) {
          fetchProducts(); // Refresh products when returning to HomeView
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartView()),
        ).then((_) {
          fetchProducts(); // Refresh products when returning to HomeView
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserView()),
        ).then((_) {
          fetchProducts(); // Refresh products when returning to HomeView
        });
        break;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Apply sorting
    List<Product> sortedProducts = List.from(products);
    switch (sortOption) {
      case SortOption.name:
        sortedProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.priceLowToHigh:
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    // Apply search filtering
    List<Product> displayedProducts = sortedProducts.where((product) {
      return product.name
          .toLowerCase()
          .contains(searchController.text.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title:
            Text('Welcome, $userName'), // Use username from SharedPreferences
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Products',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to apply search filter
              },
            ),
          ),
          // Sort Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Sort by: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<SortOption>(
                  value: sortOption,
                  dropdownColor: Colors.white,
                  iconEnabledColor: primaryColor,
                  items: const [
                    DropdownMenuItem(
                      value: SortOption.name,
                      child: Text('Name'),
                    ),
                    DropdownMenuItem(
                      value: SortOption.priceLowToHigh,
                      child: Text('Price: Low to High'),
                    ),
                    DropdownMenuItem(
                      value: SortOption.priceHighToLow,
                      child: Text('Price: High to Low'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortOption = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: displayedProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.75),
              itemBuilder: (context, index) {
                Product product = displayedProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailView(product: product),
                      ),
                    );
                  },
                  child: Card(
                    color: cardColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16.0)),
                            child: product.imageUrl != null &&
                                    product.imageUrl!.isNotEmpty
                                ? Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image,
                                          size:
                                              48); // Placeholder for broken image
                                    },
                                  )
                                : Image.asset(
                                    'assets/logo.png', // Fallback image if URL is null or empty
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Duration: ${product.duration} days',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              addToCart(product);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: Text(
                              'Add to Cart',
                              style: const TextStyle(
                                  color: Colors.black), // Change color to black
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home,
                  color: _currentIndex == 0 ? accentColor : Colors.black),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sell,
                  color: _currentIndex == 1 ? accentColor : Colors.black),
              label: 'Lend'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart,
                  color: _currentIndex == 2 ? accentColor : Colors.black),
              label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person,
                  color: _currentIndex == 3 ? accentColor : Colors.black),
              label: 'User'),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
