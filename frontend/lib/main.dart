import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'providers/auth_provider.dart' as custom_auth;
import 'constants/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optimize performance
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Test Firebase connectivity
    try {
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      print('✅ Firebase Auth connectivity verified');
    } catch (e) {
      print('⚠️ Firebase Auth connectivity test failed: $e');
    }
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => custom_auth.AuthProvider()),
      ],
      child: MaterialApp(
        title: 'TrashIQ',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    print('🏗️ AuthWrapper initState started');

    // Check authentication state on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<custom_auth.AuthProvider>(
        context,
        listen: false,
      );
      print('🏗️ AuthWrapper initState - checking auth state');
      authProvider.checkAuthState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<custom_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isLoading = authProvider.isLoading;
        final error = authProvider.error;
        final isLoggedIn = authProvider.isLoggedIn;

        // Add comprehensive debug logging
        print('🏠 === AUTHWRAPPER BUILD ===');
        print('🏠 User: ${user?.email ?? 'null'}');
        print('🏠 IsLoading: $isLoading');
        print('🏠 IsLoggedIn: $isLoggedIn');
        print('🏠 Error: ${error ?? 'null'}');
        print('🏠 UserData: ${authProvider.userData}');
        print('🏠 Decision: ${isLoggedIn ? 'HomeScreen' : 'LoginScreen'}');
        print('🏠 === END AUTHWRAPPER BUILD ===\n');

        // Show error state if there's a persistent error
        if (error != null && !isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Authentication Error',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      authProvider.clearError();
                      authProvider.checkAuthState();
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      authProvider.clearError();
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show loading screen with timeout
        if (isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Authenticating...',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        // Navigate based on authentication state
        if (isLoggedIn && user != null) {
          print('🏠 ✅ Navigating to HomeScreen');
          return const HomeScreen();
        } else {
          print('🏠 ❌ Navigating to LoginScreen');
          return const LoginScreen();
        }
      },
    );
  }
}
