import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime; // This field was missing!

  // Add a flag to prevent multiple notifications
  bool _isNotifying = false;

  // Web detection for deployment
  bool get isWebDeployment => kIsWeb;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  String get userName => _userData?['name'] ?? _user?.displayName ?? 'User';
  String get userEmail => _user?.email ?? 'No email';
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add this missing getter
  int get userPoints => _userData?['points'] ?? 0;

  // Constructor to set up auth state listener
  AuthProvider() {
    _initializeAuthListener();
  }

  // Initialize auth state listener
  void _initializeAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      print('🔄 Auth state changed: ${user?.email ?? 'No user'}');
      if (user != null && user != _user) {
        print('🔄 Current _user: ${_user?.email ?? 'No current user'}');
        if (_user?.uid != user.uid) {
          print('🔄 User authenticated, fetching data...');
          _user = user;
          _fetchUserData();
        } else {
          print('🔄 Same user, skipping duplicate processing');
        }
      } else if (user == null && _user != null) {
        print('🔄 User signed out, clearing data...');
        _user = null;
        _userData = null;
        _lastFetchTime = null;
        _safeNotifyListeners();
      }
    });
  }

  // Add method to update points
  Future<void> addPoints(int points, String itemName) async {
    if (_user == null) return;

    try {
      print('🎯 Adding $points points for $itemName');

      if (isWebDeployment) {
        // For web testing, simulate the API call
        print('🌐 Web mode: Simulating points addition');

        // Update local data only for testing
        if (_userData != null) {
          _userData!['points'] = userPoints + points;
          _userData!['lastDetection'] = {
            'itemName': itemName,
            'points': points,
            'timestamp': DateTime.now().toIso8601String(),
          };
        }
      } else {
        // Original Firestore update for production
        await _firestore.collection('users').doc(_user!.uid).update({
          'points': FieldValue.increment(points),
          'lastDetection': {
            'itemName': itemName,
            'points': points,
            'timestamp': FieldValue.serverTimestamp(),
          },
        });

        // Update local data
        if (_userData != null) {
          _userData!['points'] = userPoints + points;
        }
      }

      print('✅ Points updated successfully');
      _safeNotifyListeners();
    } catch (e) {
      print('❌ Error updating points: $e');
    }
  }

  // Add method to refresh user data
  Future<void> refreshUserData() async {
    if (_user != null) {
      await _fetchUserData();
    }
  }

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
    _error = null;

    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.updateDisplayName(name);

      if (result.user != null) {
        print('✅ User created successfully: ${result.user!.uid}');

        // Store user data in Firestore with points initialized
        await _firestore.collection('users').doc(result.user!.uid).set({
          'name': name,
          'email': email,
          'userType': userType,
          'points': 0, // Initialize points to 0
          'createdAt': FieldValue.serverTimestamp(),
          'uid': result.user!.uid,
        });

        _user = result.user;
        await _fetchUserData();

        print('✅ Registration completed successfully');
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_isNotifying) {
      _isNotifying = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          notifyListeners();
        }
        _isNotifying = false;
      });
    }
  }

  bool get mounted {
    try {
      // Simple check to see if we can safely call notifyListeners
      return true;
    } catch (e) {
      return false;
    }
  }

  // Fetch user data from Firestore with caching
  Future<void> _fetchUserData() async {
    if (_user == null) return;

    try {
      print('📋 Fetching user data for: ${_user!.uid}');

      // Check cache to avoid unnecessary fetches
      final now = DateTime.now();
      if (_lastFetchTime != null &&
          now.difference(_lastFetchTime!).inMinutes < 5 &&
          _userData != null) {
        print('📋 Using cached user data');
        return;
      }

      final doc = await _firestore.collection('users').doc(_user!.uid).get();

      if (doc.exists) {
        _userData = doc.data();
        _lastFetchTime = now;

        // Ensure points field exists - this is the key fix
        if (_userData != null && !_userData!.containsKey('points')) {
          print('⚠️ Points field missing, adding it...');
          _userData!['points'] = 0;
          // Update Firestore to include points field
          await _firestore.collection('users').doc(_user!.uid).update({
            'points': 0,
          });
          print('✅ Points field added to Firestore');
        }

        print('✅ User data updated: $_userData');
        print('📋 User data from Firestore:');
        print('   - Name: ${_userData?['name']}');
        print('   - User Type: ${_userData?['userType']}');
        print('   - Email: ${_userData?['email']}');
        print('   - Points: ${_userData?['points'] ?? 0}');
        print('🔄 Notifying listeners...');
      } else {
        print('❌ User document not found');
        _userData = null;
      }

      _safeNotifyListeners();
    } catch (e) {
      print('❌ Error fetching user data: $e');
      _userData = null;
    }
  }
}
