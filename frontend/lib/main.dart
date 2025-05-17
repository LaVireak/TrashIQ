import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'constants/theme.dart';
import 'constants/routes.dart';

import 'providers/auth_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
// import 'screens/home/home_screen.dart';
// import 'screens/home/profile_screen.dart';
// import 'screens/waste_detection/camera_screen.dart';
// import 'screens/waste_detection/result_screen.dart';
// import 'screens/marketplace/browse_screen.dart';
// import 'screens/marketplace/item_detail_screen.dart';
// import 'screens/marketplace/add_item_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TrashIQ',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => LoginScreen(),
          AppRoutes.register: (context) => RegisterScreen(),
          // AppRoutes.home: (context) => const HomeScreen(),
          // AppRoutes.profile: (context) => const ProfileScreen(),
          // AppRoutes.wasteDetection: (context) => const CameraScreen(),
          // AppRoutes.wasteResult: (context) => const ResultScreen(),
          // AppRoutes.marketplace: (context) => const BrowseScreen(),
          // AppRoutes.itemDetail: (context) => const ItemDetailScreen(),
          // AppRoutes.addItem: (context) => const AddItemScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('TrashIQ', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
