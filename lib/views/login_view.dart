import 'package:flutter/material.dart';
import 'sign_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placement with adjusted size
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Image.asset(
                'assets/logo.png', // Ensure you replace with the correct image path
                height: 300, // Adjust height as needed
                fit: BoxFit.contain,
              ),
            ),
            // Sign In / Sign Up Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[500],
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignView()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person,
                        size: 24, color: Colors.white), // White icon
                    SizedBox(width: 8),
                    Text(
                      'Sign In / Sign Up',
                      style: TextStyle(
                          fontSize: 18, color: Colors.white), // White text
                    ),
                  ],
                ),
              ),
            ),
            // Continue with Apple Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignView()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apple,
                        size: 24, color: Colors.white), // White icon
                    SizedBox(width: 8),
                    Text(
                      'Continue with Apple',
                      style: TextStyle(
                          fontSize: 18, color: Colors.white), // White text
                    ),
                  ],
                ),
              ),
            ),
            // Continue with Gmail Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignView()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email,
                        size: 24, color: Colors.white), // White icon
                    SizedBox(width: 8),
                    Text(
                      'Continue with Gmail',
                      style: TextStyle(
                          fontSize: 18, color: Colors.white), // White text
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // Add spacing at the bottom
          ],
        ),
      ),
    );
  }
}
