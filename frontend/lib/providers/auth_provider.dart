import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;

  // Add a flag to prevent multiple notifications
  bool _isNotifying = false;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  String get userName => _userData?['name'] ?? _user?.displayName ?? 'User';
  String get userEmail => _user?.email ?? '';
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add points getter
  int get userPoints => _userData?['points'] ?? 0;

  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  AuthProvider() {
    print('🏗️ AuthProvider constructor called');
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    print('🔄 === AUTH STATE CHANGE EVENT ===');
    print('🔄 New user: ${user?.email ?? 'null'}');
    print('🔄 Current _user: ${_user?.email ?? 'null'}');
    print('🔄 User UID: ${user?.uid ?? 'null'}');
    print('🔄 Current _user UID: ${_user?.uid ?? 'null'}');

    // Prevent duplicate processing - Fixed condition
    if (_user?.uid == user?.uid && _user != null && user != null) {
      print('🔄 Same user, skipping duplicate processing');
      return;
    }

    _user = user;

    if (user != null) {
      print('🔄 User authenticated, fetching data...');
      await _fetchUserData();
      print('✅ Auth state processing complete - User logged in');
    } else {
      print('🔄 User logged out, clearing data...');
      _userData = null;
      _lastFetchTime = null;
      print('✅ Auth state processing complete - User logged out');
    }

    print('🔄 Current state after processing:');
    print('   - _user: ${_user?.email ?? 'null'}');
    print('   - isLoggedIn: $isLoggedIn');
    print('   - userName: $userName');
    print('🔄 Notifying listeners...');
    _safeNotifyListeners();
    print('🔄 === END AUTH STATE CHANGE EVENT ===\n');
  }

  void _safeNotifyListeners() {
    print('📢 _safeNotifyListeners called');
    if (!_isNotifying) {
      _isNotifying = true;
      print('📢 Scheduling notifyListeners');
      // Use a microtask to ensure the notification happens after the current frame
      Future.microtask(() {
        print('📢 Executing notifyListeners');
        _isNotifying = false;
        notifyListeners();
        print('📢 notifyListeners completed');
      });
    } else {
      print('📢 Already notifying, skipping');
    }
  }

  void _setLoading(bool loading) {
    print('⏳ Setting loading: $loading');
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  // Fetch user data from Firestore with caching
  Future<void> _fetchUserData() async {
    if (_user == null) {
      print('❌ Cannot fetch user data: _user is null');
      return;
    }

    // Check if we have recent cached data
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration &&
        _userData != null) {
      print('📋 Using cached user data');
      return; // Use cached data
    }

    try {
      print('📋 Fetching user data for: ${_user!.uid}');
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        final newData = doc.data();
        print('📋 Firestore document exists: ${doc.data()}');
        if (_userData != newData) {
          _userData = newData;
          _lastFetchTime = DateTime.now();
          print('✅ User data updated: $_userData');
          print('📋 User data from Firestore:');
          print('   - Name: ${_userData?['name']}');
          print('   - User Type: ${_userData?['userType']}');
          print('   - Email: ${_userData?['email']}');
        }
      } else {
        print('❌ Firestore document does not exist for user: ${_user!.uid}');
      }
    } catch (e) {
      print('❌ Error fetching user data: $e');
    }
  }

  // Public method to refresh user data
  Future<void> refreshUserData() async {
    print('🔄 Manual refresh user data requested');
    await _fetchUserData();
    _safeNotifyListeners();
  }

  // Clear error method
  void clearError() {
    print('🧹 Clearing error');
    _error = null;
    _safeNotifyListeners();
  }

  // Add the missing checkAuthState method
  Future<void> checkAuthState() async {
    print('🔍 === CHECKING AUTH STATE ===');
    _setLoading(true);
    _error = null;

    try {
      print('🔄 Checking authentication state...');

      // Add timeout to prevent infinite loading
      final currentUser = await Future.any([
        Future.value(_auth.currentUser),
        Future.delayed(const Duration(seconds: 10), () => null),
      ]);

      if (currentUser != null) {
        print('✅ Firebase user found: ${currentUser.email}');
        print('✅ User UID: ${currentUser.uid}');
        _user = currentUser;

        // Fetch user data with timeout
        await Future.any([
          _fetchUserData(),
          Future.delayed(const Duration(seconds: 10)),
        ]);

        print('✅ Auth state check complete - User authenticated');
      } else {
        print('❌ No authenticated user found in Firebase');
        _user = null;
        _userData = null;
        _lastFetchTime = null;
        print('✅ Auth state check complete - User not authenticated');
      }

      print('🔍 Final auth state:');
      print('   - _user: ${_user?.email ?? 'null'}');
      print('   - isLoggedIn: $isLoggedIn');
      print('   - userName: $userName');
    } catch (e) {
      print('❌ Auth state check failed: $e');
      _error = e.toString();
      _user = null;
      _userData = null;
      _lastFetchTime = null;
    } finally {
      _setLoading(false);
      _safeNotifyListeners();
      print('🔍 === AUTH STATE CHECK COMPLETE ===\n');
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String userType,
  ) async {
    print('📝 === REGISTRATION START ===');
    print('📝 Email: $email');
    print('📝 Name: $name');
    print('📝 User Type: $userType');

    _setLoading(true);
    _error = null; // Clear previous errors
    try {
      print('🔄 Attempting to register with email: $email');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.updateDisplayName(name);

      if (result.user != null) {
        print('✅ User created successfully: ${result.user!.uid}');
        // Store user data in Firestore with consistent field names
        await _firestore.collection('users').doc(result.user!.uid).set({
          'name': name,
          'email': email,
          'userType': userType,
          'points': 0, // Initialize with 0 points
          'createdAt': FieldValue.serverTimestamp(),
          'uid': result.user!.uid,
        });

        print('✅ User registered and data stored successfully');

        // Fetch the user data immediately after registration
        await _fetchUserData();
        print('📝 === REGISTRATION COMPLETE ===\n');
      }
    } catch (e) {
      print('❌ Registration error: $e');
      _error = e.toString();
      rethrow;
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
    print('🔐 === LOGIN START ===');
    print('🔐 Attempting login for: $email');
    _setLoading(true);
    _error = null;

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase login successful');
      print('✅ UID: ${result.user!.uid}');

      // Explicitly set the user and fetch data immediately
      _user = result.user;
      await _fetchUserData();

      print('✅ Login process completed');
      print('🔐 === LOGIN COMPLETE ===\n');
    } catch (e) {
      print('❌ Login failed: $e');
      _error = e.toString();
      throw Exception('Login failed: ${e.toString()}');
    } finally {
      _setLoading(false);
      _safeNotifyListeners();
    }
  }

  Future<void> logout() async {
    print('🚪 === LOGOUT START ===');
    print('🚪 Current user: ${_user?.email ?? 'null'}');

    _setLoading(true);
    _error = null;
    try {
      await _auth.signOut();
      print('✅ Firebase logout successful');

      // Clear local state
      _user = null;
      _userData = null;
      _lastFetchTime = null;

      print('✅ Local state cleared');
      print('🚪 === LOGOUT COMPLETE ===\n');
    } catch (e) {
      print('❌ Logout error: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
      // Ensure UI updates even if logout fails
      _safeNotifyListeners();
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (_user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      return doc.data();
    } catch (e) {
      _error = e.toString();
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Add method to update points
  Future<void> addPoints(int points, String itemName) async {
    if (_user == null) return;

    try {
      print('🎯 Adding $points points for $itemName');

      // Update points in Firestore
      await _firestore.collection('users').doc(_user!.uid).update({
        'points': FieldValue.increment(points),
        'lastDetection': {
          'itemName': itemName,
          'points': points,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });

      // Update local data
      _userData?['points'] = userPoints + points;

      print('✅ Points updated successfully');
      _safeNotifyListeners();
    } catch (e) {
      print('❌ Error updating points: $e');
    }
  }

  // Add this method to clear any existing sessions
  Future<void> clearSession() async {
    print('🧹 === CLEARING SESSION ===');
    try {
      await _auth.signOut();
      _user = null;
      _userData = null;
      _lastFetchTime = null;
      print('✅ Session cleared');
      _safeNotifyListeners();
      print('🧹 === SESSION CLEAR COMPLETE ===\n');
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }
}
