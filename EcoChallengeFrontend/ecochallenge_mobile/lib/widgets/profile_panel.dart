import 'package:ecochallenge_mobile/pages/leaderboard_page.dart';
import 'package:ecochallenge_mobile/pages/my_events_page.dart';
import 'package:ecochallenge_mobile/pages/user_profile_page.dart';
import 'package:ecochallenge_mobile/pages/history_page.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecochallenge_mobile/providers/auth_provider.dart';
import 'package:ecochallenge_mobile/models/user.dart';

class ProfilePanel extends StatelessWidget {
  final VoidCallback onClose;

  const ProfilePanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final user = AuthProvider.userData;

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // Profile Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Profile Picture
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: user?.profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user!.profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar(user);
                                },
                              ),
                            )
                          : _buildDefaultAvatar(user),
                    ),
                    const SizedBox(height: 16),
                    // User Name
                    Text(
                      user != null
                          ? '${user.firstName} ${user.lastName}'
                          : AuthProvider.username ?? 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      user?.email ?? 'user@example.com',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      onTap: () {
                        // Check if user data and userId are available
                        final userId = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).currentUserId;

                        if (userId != null) {
                          onClose();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => UserProfilePage(userId: userId),
                            ),
                          );
                        } else {
                          // Handle case where user ID is not available
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Unable to load profile. Please try logging in again.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.event_outlined,
                      title: 'My events',
                      subtitle: user != null
                          ? '${user.totalEventsParticipated} participated'
                          : null,
                      onTap: () {
                        onClose();
                         Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MyEventsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.history,
                      title: 'My event/request history',
                      subtitle: user != null
                          ? '${user.totalCleanups} cleanups completed'
                          : null,
                      onTap: () {
                        onClose(); // Close the profile panel first
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HistoryPage(), // Navigate to HistoryPage
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.leaderboard_outlined,
                      title: 'Leaderboard',
                      subtitle: user != null
                          ? '${user.totalPoints} points'
                          : null,
                      onTap: () {
                        onClose();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LeaderboardPage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.assignment_outlined,
                      title: 'Requests',
                      onTap: () {
                        onClose();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Requests page coming soon!'),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {
                        onClose();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notifications page coming soon!'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).logout();
                              Navigator.pushReplacementNamed(context, '/login');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Logout failed: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD2691E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Log out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(UserResponse? user) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF4CAF50),
      ),
      child: Center(
        child: Text(
          user != null
              ? '${user.firstName[0]}${user.lastName[0]}'.toUpperCase()
              : (AuthProvider.username?.isNotEmpty == true
                    ? AuthProvider.username![0].toUpperCase()
                    : 'U'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}