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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<custom_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isLoading = authProvider.isLoading;
        final error = authProvider.error;

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
                    'Connection Error',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to connect to authentication service',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Try to refresh the auth state
                      authProvider.checkAuthState();
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Navigate to login anyway for offline mode
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Continue Offline'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show loading while authentication is in progress
        if (isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // If user is authenticated, show home screen
        if (user != null) {
          return const HomeScreen();
        }

        // If no user, show login screen
        return const LoginScreen();
      },
    );
  }
}
