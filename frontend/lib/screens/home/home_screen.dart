import 'package:flutter/material.dart';
import '../home/profile_screen.dart';
import '../waste_detection/camera_screen.dart';
import '../home/plastic_category.dart';
import '../home/glass_category.dart';
import '../home/can_category.dart';
import '../home/paper_category.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi, Guys!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selling History Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selling History',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    // Add your selling history table here
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Waste Category Section
            Text(
              'Waste Category',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategoryItem(
                  context,
                  'Plastic',
                  Icons.local_drink,
                  Colors.blue,
                ),
                _buildCategoryItem(
                  context,
                  'Glass',
                  Icons.wine_bar,
                  Colors.red,
                ),
                _buildCategoryItem(context, 'Can', Icons.archive, Colors.green),
                _buildCategoryItem(
                  context,
                  'Paper',
                  Icons.description,
                  Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pie Chart Section
            Text(
              'Type of selling trash',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            // Add your pie chart here
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanScreen()),
            );
          } else if (index == 3) {
            // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        if (title == 'Plastic') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlasticCategoryScreen()),
          );
        } else if (title == 'Glass') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GlassCategoryScreen()),
          );
        } else if (title == 'Can') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CanCategoryScreen()),
          );
        } else if (title == 'Paper') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaperCategoryScreen()),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}
