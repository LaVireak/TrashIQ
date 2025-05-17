import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  // Initialize user data
  Future<void> initUserData() async {
    if (isAuthenticated) {
      _userData = await _authService.getUserData();
      notifyListeners();
    }
  }

  // Sign in
  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
    await initUserData();
  }

  // Register
  Future<void> register(
    String email,
    String password,
    String name,
    String userType,
  ) async {
    await _authService.registerWithEmailAndPassword(
      email,
      password,
      name,
      userType,
    );
    await initUserData();
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _userData = null;
    notifyListeners();
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    await _authService.updateUserData(data);
    await initUserData();
  }
}
