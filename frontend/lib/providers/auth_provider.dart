import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  String get userName => _userData?['name'] ?? _user?.displayName ?? 'User';
  String get userEmail => _user?.email ?? '';
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (_user?.uid != user?.uid) {
      _user = user;
      if (user != null) {
        await _fetchUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    }
  }

  // Fetch user data from Firestore with caching
  Future<void> _fetchUserData() async {
    if (_user == null) return;

    try {
      print('📋 Fetching user data for: ${_user!.uid}');
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        final newData = doc.data();
        if (_userData != newData) {
          _userData = newData;
          print('✅ User data updated: $_userData');
          print('📋 User data from Firestore:');
          print('   - Name: ${_userData?['name']}');
          print('   - User Type: ${_userData?['userType']}');
          print('   - Email: ${_userData?['email']}');
        }
      }
    } catch (e) {
      print('❌ Error fetching user data: $e');
    }
  }

  // Public method to refresh user data
  Future<void> refreshUserData() async {
    await _fetchUserData();
    notifyListeners();
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String userType,
  ) async {
    _setLoading(true);
    try {
      print('🔄 Attempting to register with email: $email');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.updateDisplayName(name);

      if (result.user != null) {
        await _createUserDocument(result.user!, name, userType);
      }

      _user = result.user;
      await _fetchUserData();
      print('✅ Registration successful for: ${result.user!.email}');
    } catch (e) {
      print('❌ Registration failed: $e');
      throw Exception('Registration failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    User user,
    String name,
    String userType,
  ) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'userType': userType,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      print('🔄 Attempting to log in with email: $email');
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = result.user;
      await _fetchUserData();

      // If userData is null, create Firestore document
      if (_user != null && _userData == null) {
        print('⚠️ No user data found, creating Firestore document...');
        await _createUserDocument(
          _user!,
          _user!.displayName ?? 'User',
          'user', // Default userType, adjust as needed
        );
        await _fetchUserData();
      }

      print('✅ Successfully logged in as: ${result.user!.email}');
      print('📧 User ID: ${result.user!.uid}');
      print('👤 Display Name: ${result.user!.displayName}');
    } catch (e) {
      print('❌ Login failed: $e');
      throw Exception('Login failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      _user = null;
      _userData = null;
      print('✅ Successfully logged out');
    } catch (e) {
      print('❌ Logout failed: $e');
      throw Exception('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (_user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }
}
