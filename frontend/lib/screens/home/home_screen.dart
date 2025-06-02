import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    return Column(
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
    );
  }
}
