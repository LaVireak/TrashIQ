import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Create user document in Firestore
  Future<void> _createUserDocument(
    User user,
    String name,
    String userType,
  ) async {
    try {
      print('📋 Creating user document for: ${user.uid}');
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ User document created successfully');
    } catch (e) {
      print('❌ Error creating user document: $e');
      throw 'Failed to create user document: ${e.toString()}';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Get current user
  User? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      print('👤 Current user: ${user.email} (${user.uid})');
    } else {
      print('❌ No current user');
    }
    return user;
  }

  // Auth state changes stream
  Stream<User?> get authStateChanges =>
      _auth.authStateChanges().map((user) {
        if (user != null) {
          print('🔄 Auth state changed: User logged in - ${user.email}');
        } else {
          print('🔄 Auth state changed: User logged out');
        }
        return user;
      });

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      print('🔐 Signing in with email: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        print('✅ Sign in successful for: ${credential.user!.email}');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ Sign in failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Alternative method name for compatibility with AuthProvider
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await signInWithEmail(email, password);
  }

  // Create account with email and password
  Future<UserCredential?> createAccountWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      print('📝 Creating account with email: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Store user data in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!, name, 'user');
        print('✅ Account created successfully for: ${credential.user!.email}');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ Account creation failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Register with email and password (for AuthProvider compatibility)
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String userType,
  ) async {
    try {
      print('📝 Registering user with email: $email, userType: $userType');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Store user data in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!, name, userType);
        print('✅ Registration successful for: ${credential.user!.email}');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('❌ Registration failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) {
      print('❌ Cannot get user data: No current user');
      return null;
    }

    try {
      print('📋 Getting user data for: ${currentUser!.uid}');
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        final data = doc.data();
        print('✅ User data retrieved: $data');
        return data;
      } else {
        print('⚠️ User document does not exist in Firestore');
        return null;
      }
    } catch (e) {
      print('❌ Error getting user data: $e');
      throw 'Failed to get user data: ${e.toString()}';
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (currentUser == null) throw 'No user logged in';

    try {
      print('📝 Updating user data for: ${currentUser!.uid}');
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(currentUser!.uid).update(data);
      print('✅ User data updated successfully');
    } catch (e) {
      print('❌ Error updating user data: $e');
      throw 'Failed to update user data: ${e.toString()}';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔐 Attempting Google sign in...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ Google sign in cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create user document if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser == true &&
          userCredential.user != null) {
        await _createUserDocument(
          userCredential.user!,
          userCredential.user!.displayName ?? 'Google User',
          'user',
        );
      }

      print('✅ Google sign in successful for: ${userCredential.user!.email}');
      return userCredential;
    } catch (e) {
      print('❌ Google sign in failed: $e');
      throw 'Google sign in failed: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('🔓 Signing out user...');
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      print('✅ Sign out successful');
    } catch (e) {
      print('❌ Sign out failed: $e');
      throw 'Sign out failed: ${e.toString()}';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      print('📧 Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      print('❌ Password reset failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    }
  }
}
