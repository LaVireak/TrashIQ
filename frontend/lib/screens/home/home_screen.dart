import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/profile_screen.dart';
import '../waste_detection/camera_screen.dart';
import '../home/plastic_category.dart';
import '../home/glass_category.dart';
import '../home/can_category.dart';
import '../home/paper_category.dart';
import '../../providers/auth_provider.dart' as custom_auth;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<custom_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        final userName = authProvider.userName;
        final userData = authProvider.userData;

        print('🏠 HomeScreen - Username: $userName');
        print('🏠 HomeScreen - UserData: $userData');

        return Scaffold(
          appBar: AppBar(
            title: Text('Hey, $userName!'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Refresh user data
              await authProvider.refreshUserData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card - Updated
                  _WelcomeCard(userName: userName, userData: userData),

                  const SizedBox(height: 16),

                  // Selling History Card - Optimized
                  const _SellingHistoryCard(),

                  const SizedBox(height: 16),

                  // Categories Section
                  const Text(
                    'Waste Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Optimized GridView
                  _CategoriesGrid(),

                  const SizedBox(height: 24),

                  const Text(
                    'Type of selling trash',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Placeholder for statistics
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Chart visualization\n(Coming Soon)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _OptimizedBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (_currentIndex != index) {
                setState(() {
                  _currentIndex = index;
                });
                _handleNavigation(index);
              }
            },
          ),
        );
      },
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanScreen()),
        );
        break;
      case 2:
        // Cart functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart feature coming soon!')),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }
}

// Updated Welcome Card with proper greeting
class _WelcomeCard extends StatelessWidget {
  final String userName;
  final Map<String, dynamic>? userData;

  const _WelcomeCard({required this.userName, required this.userData});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey, $userName! 👋',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back to TrashIQ',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              if (userData != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(
                      userData!['userType'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getUserTypeColor(
                        userData!['userType'],
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${_getUserTypeText(userData!['userType'])} Account',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getUserTypeColor(userData!['userType']),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getUserTypeColor(String? userType) {
    switch (userType?.toLowerCase()) {
      case 'seller':
        return Colors.green;
      case 'buyer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getUserTypeText(String? userType) {
    switch (userType?.toLowerCase()) {
      case 'seller':
        return 'Seller';
      case 'buyer':
        return 'Buyer';
      default:
        return 'User';
    }
  }
}

// Separate widget for Selling History Card
class _SellingHistoryCard extends StatelessWidget {
  const _SellingHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selling History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('You Sold', style: TextStyle(fontSize: 16)),
                Text(
                  '₹1234',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('This Month', style: TextStyle(fontSize: 16)),
                Text(
                  '₹567',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Collect Your Earnings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Optimized Categories Grid
class _CategoriesGrid extends StatelessWidget {
  static const List<_CategoryData> _categories = [
    _CategoryData('Plastic', Icons.local_drink, Colors.blue),
    _CategoryData('Glass', Icons.wine_bar, Colors.green),
    _CategoryData('Can', Icons.local_drink_outlined, Colors.orange),
    _CategoryData('Paper', Icons.description, Colors.brown),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _categories.length,
      // Add this for better performance
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return RepaintBoundary(
          // Wrap each item
          child: _CategoryCard(
            category: category,
            onTap: () => _navigateToCategory(context, category),
          ),
        );
      },
    );
  }

  void _navigateToCategory(BuildContext context, _CategoryData category) {
    Widget screen;
    switch (category.title) {
      case 'Plastic':
        screen = PlasticCategoryScreen();
        break;
      case 'Glass':
        screen = GlassCategoryScreen();
        break;
      case 'Can':
        screen = CanCategoryScreen();
        break;
      case 'Paper':
        screen = PaperCategoryScreen();
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}

// Category data model
class _CategoryData {
  final String title;
  final IconData icon;
  final Color color;

  const _CategoryData(this.title, this.icon, this.color);
}

// Optimized Category Card
class _CategoryCard extends StatelessWidget {
  final _CategoryData category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color, size: 32),
              ),
              const SizedBox(height: 8),
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Optimized Bottom Navigation Bar
class _OptimizedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _OptimizedBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
