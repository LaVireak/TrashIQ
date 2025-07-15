import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as custom_auth;

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<custom_auth.AuthProvider>(
        builder: (context, authProvider, child) {
          final currentUserPoints = authProvider.userPoints;
          final currentUserName = authProvider.userName;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Current user rank card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        currentUserName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$currentUserPoints Points',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Current Rank: #4',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Top users
                const Text(
                  'Top EcoWarriors',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Mock leaderboard data
                _buildLeaderboardItem(1, 'Sarah Green', 1250, true),
                _buildLeaderboardItem(2, 'Mike Johnson', 1180, false),
                _buildLeaderboardItem(3, 'Emma Wilson', 980, false),
                _buildLeaderboardItem(
                  4,
                  currentUserName,
                  currentUserPoints,
                  false,
                  isCurrentUser: true,
                ),
                _buildLeaderboardItem(5, 'Alex Brown', 720, false),
                _buildLeaderboardItem(6, 'Lisa Davis', 650, false),
                _buildLeaderboardItem(7, 'Tom Miller', 590, false),
                _buildLeaderboardItem(8, 'Anna Lee', 540, false),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(
    int rank,
    String name,
    int points,
    bool showCrown, {
    bool isCurrentUser = false,
  }) {
    Color backgroundColor =
        isCurrentUser ? Colors.green.withOpacity(0.1) : Colors.white;
    Color borderColor = isCurrentUser ? Colors.green : Colors.grey.shade200;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow:
            rank <= 3
                ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  showCrown
                      ? const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 20,
                      )
                      : Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color:
                        isCurrentUser ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
                Text(
                  '$points points',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

          // Badge for top 3
          if (rank <= 3) Icon(Icons.star, color: _getRankColor(rank), size: 24),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
