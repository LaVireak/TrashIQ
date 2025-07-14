import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart' as custom_auth;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return Consumer<custom_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        final userData = authProvider.userData;
        // Fix: Use 'name' instead of 'username' and add fallbacks
        final username =
            (userData?['name'] ?? authProvider.user?.displayName ?? 'User')
                .toString()
                .trim();
        final userEmail = authProvider.userEmail ?? 'No email';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture Section
                const SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // User Info
                Text(
                  username.isNotEmpty ? username : 'Username',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (userData != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'User Type: ${userData['userType'] ?? 'Not specified'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
                const SizedBox(height: 32),

                // Menu Items
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.history,
                  title: 'History',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help and Support',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Terms and Conditions',
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Log Out',
                  onTap: () => _showLogoutDialog(context),
                  showDivider: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first

                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                  );

                  // Use AuthProvider for logout
                  final authProvider = Provider.of<custom_auth.AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout();

                  // Close loading dialog
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }

                  // Navigate to login screen and clear navigation stack
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                } catch (e) {
                  // Close loading dialog if it's still open
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.grey[700]),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        ),
        if (showDivider) Divider(color: Colors.grey[300], height: 1),
      ],
    );
  }
}
