// test/home_view_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:safe_swap/view_models/product_view_model.dart';
import 'package:safe_swap/views/home_view.dart';

void main() {
  testWidgets('HomeView displays welcome message', (WidgetTester tester) async {
    // Mock SharedPreferences to return a userName
    // You can use a package like `shared_preferences_mocks` for this purpose

    // For simplicity, we'll assume userName is 'Test User'
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProductViewModel(),
        child: const MaterialApp(
          home: HomeView(),
        ),
      ),
    );

    // Wait for async operations
    await tester.pumpAndSettle();

    // Verify that the welcome message is displayed
    expect(find.text('Welcome, Test User'), findsOneWidget);
  });
}
