import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  bool _isLoggedIn = false;
  String? _currentUserEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;

  AuthViewModel() {
    _checkAuthState();
  }

  // Check if the user is already authenticated
  Future<void> _checkAuthState() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      _isLoggedIn = true;
      _currentUserEmail = supabase.auth.currentUser?.email;
    } else {
      _isLoggedIn = false;
      _currentUserEmail = null;
    }
    notifyListeners();
  }

  // Sign up a user and insert additional data into the `users` table
  Future<void> signUp(String email, String password,
      {required String name}) async {
    try {
      // Sign up the user using Supabase Auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Insert additional user data into the `users` table
        await supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'password':
              password, // Avoid storing plain text passwords in production
        });

        _isLoggedIn = true;
        _currentUserEmail = response.user!.email;
        notifyListeners();
      }
    } on AuthException catch (e) {
      throw Exception('Sign-up error: ${e.message}');
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    }
  }

  // Log in a user
  Future<void> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isLoggedIn = true;
        _currentUserEmail = response.user!.email;
        notifyListeners();
      }
    } on AuthException catch (e) {
      throw Exception('Login error: ${e.message}');
    }
  }

  // Log out the user
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      _isLoggedIn = false;
      _currentUserEmail = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }
}
