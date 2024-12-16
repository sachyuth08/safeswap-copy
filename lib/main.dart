//main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';
import 'view_models/product_view_model.dart';
import 'views/borrowed_products_view_model.dart'; // Adjust path if needed
import 'views/login_view.dart'; // Adjust path if needed
import 'view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'models/cart_item.dart';
import 'views/home_view.dart';
import 'views/sell_view.dart';
import 'views/cart_view.dart';
import 'views/user_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:
        'https://rosailelekjoyiuwwthz.supabase.co', // Replace with your Supabase Project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJvc2FpbGVsZWtqb3lpdXd3dGh6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczMDI1ODIxMCwiZXhwIjoyMDQ1ODM0MjEwfQ.Asnv1Y93YUpfWSo9gLQv-N8qKpQmNwLkLBxMHrqtOYg', // Replace with your Supabase anon key
  );

  // Run the app with MultiProvider for dependency injection
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Swap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 19, 153, 255),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(
            const Color.fromARGB(255, 19, 153, 255).value,
            <int, Color>{
              50: const Color.fromARGB(255, 227, 242, 255),
              100: const Color.fromARGB(255, 179, 215, 255),
              200: const Color.fromARGB(255, 128, 184, 255),
              300: const Color.fromARGB(255, 77, 153, 255),
              400: const Color.fromARGB(255, 38, 128, 255),
              500: const Color.fromARGB(255, 19, 153, 255),
              600: const Color.fromARGB(255, 17, 137, 230),
              700: const Color.fromARGB(255, 15, 115, 191),
              800: const Color.fromARGB(255, 12, 96, 153),
              900: const Color.fromARGB(255, 9, 73, 115),
            },
          ),
        ).copyWith(
          secondary: const Color.fromARGB(255, 255, 152, 0),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
        ),
      ),
      // Define the initial route
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomeView(),
        '/sell': (context) => const SellView(),
        '/cart': (context) => const CartView(),
        '/user': (context) => const UserView(),
      },
    );
  }
}
