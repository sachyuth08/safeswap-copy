import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'borrows_view.dart';
import 'home_view.dart';
import 'cart_view.dart';
import 'sell_view.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  UserViewState createState() => UserViewState();
}

class UserViewState extends State<UserView> {
  bool isDataCleared = false;
  String userName = '';
  String userEmail = '';
  int _currentIndex = 3;

  final Color primaryColor = const Color.fromARGB(255, 19, 153, 255);

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Unknown User';
      userEmail = prefs.getString('email') ?? 'No email available';
    });
  }

  void clearAllUserData() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text(
              'Are you sure you want to log out and clear all data?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      setState(() {
        isDataCleared = true;
      });
    }
  }

  void showUserDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person, size: 30),
                  const SizedBox(width: 8),
                  Text(
                    'Name: $userName',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.email, size: 30),
                  const SizedBox(width: 8),
                  Text(
                    'Email: $userEmail',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCustomerServiceDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Service',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.developer_mode, size: 30),
                  const SizedBox(width: 8),
                  const Text(
                    'Please contact our Developer:',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.person, size: 30),
                  SizedBox(width: 8),
                  Text(
                    'Achyuth Sambaraju',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.email, size: 30),
                  SizedBox(width: 8),
                  Text(
                    'achyuthsambaraju@gmail.com',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        // Current page, no action needed
        break;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isDataCleared) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Your Swaps'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Your Borrows'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BorrowsView(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('My Account'),
            onTap: () {
              showUserDetails(context);
            },
          ),
          ListTile(
            title: const Text('Customer Service'),
            onTap: () {
              showCustomerServiceDetails(context);
            },
          ),
          ListTile(
            title: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: clearAllUserData,
            trailing: const Icon(
              Icons.delete,
              color: Colors.red,
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
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
      ),
    );
  }
}
