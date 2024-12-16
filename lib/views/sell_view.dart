import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import '../models/product.dart';
import '../supabase_service.dart';
import '../view_models/product_view_model.dart';
import 'home_view.dart';
import 'cart_view.dart';
import 'user_view.dart';
import 'package:provider/provider.dart';

class SellView extends StatefulWidget {
  const SellView({super.key});

  @override
  SellViewState createState() => SellViewState();
}

class SellViewState extends State<SellView> {
  final SupabaseService supabaseService = SupabaseService();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Uint8List? imageBytes;
  final picker = ImagePicker();
  int _currentIndex = 1;

  final Color primaryColor = const Color.fromARGB(255, 19, 153, 255);
  final Color accentColor = const Color.fromARGB(255, 255, 152, 0);

  // Function to pick and resize the image
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final originalBytes = await pickedFile.readAsBytes();
      final image = img.decodeImage(originalBytes);

      // Adjust width dynamically based on screen size
      final double deviceWidth = MediaQuery.of(context).size.width;
      final int targetWidth =
          (deviceWidth * 0.75).toInt(); // Resize to 75% of screen width

      // Resize and compress the image with higher quality
      final resizedImage = img.copyResize(image!, width: targetWidth);
      setState(() {
        imageBytes = Uint8List.fromList(img.encodeJpg(resizedImage,
            quality: 90)); // High-quality compression
      });
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
        // Current page, do nothing
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
          'Lend Your Product',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Product Description',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8.0),
              imageBytes != null
                  ? Image.memory(
                      imageBytes!,
                      height: 200,
                    )
                  : TextButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('Add a Picture'),
                    ),
              const SizedBox(height: 8.0),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Product Price in dollars',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration in days',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8.0),
            ],
          ),
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
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  durationController.text.isEmpty ||
                  imageBytes == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill in all required fields.')),
                );
                return;
              }

              // Ensure the user is authenticated
              final user = supabaseService.supabase.auth.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please log in to post a product.')),
                );
                return;
              }

              String id = const Uuid().v4();
              String name = nameController.text;
              String description = descriptionController.text;
              double price = double.tryParse(priceController.text) ?? 0.0;
              int duration = int.tryParse(durationController.text) ?? 1;

              Product product = Product(
                id: id,
                name: name,
                description: description,
                price: price,
                imageUrl: null,
                createdAt: DateTime.now(),
                duration: duration,
              );

              try {
                await supabaseService.addProduct(product, imageBytes!);

                if (!mounted) return;

                final productViewModel = context.read<ProductViewModel>();
                productViewModel.addProduct(product);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product posted successfully')),
                );
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error posting product: $e")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: const Text('Post'),
          ),
        ),
      ),
    );
  }
}
