import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:provider/provider.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'activity_insights_screen.dart';
import 'profile_details_screen.dart';
import 'preference_details_screen.dart';
import 'settings_support_screen.dart';
import 'subscription_screen.dart';
import '../shared/subscription_provider.dart';

import 'notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userEmail});

  final String userEmail;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String username;
  late String email;

  @override
  void initState() {
    super.initState();
    username = "John Doe";
    email = widget.userEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007074),
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF007074),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 6),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Avatar/username/email group
          Container(
            width: double.infinity,
            color: const Color(0xFF007074),
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 46,
                      color: Color(0xFF007074),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Uplifted white card with menu items (full width, attached to sides and bottom)
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'User information',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileDetailsScreen(
                            userName: username,
                            userEmail: email,
                          ),
                        ),
                      );
                      if (result is Map<String, String>) {
                        setState(() {
                          username = result['userName'] ?? username;
                          email = result['userEmail'] ?? email;
                        });
                      }
                    },
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  Consumer<SubscriptionProvider>(
                    builder: (context, subscriptionProvider, _) {
                      return _buildListTile(
                        context,
                        icon: Icons.workspace_premium,
                        title: subscriptionProvider.isSubscribed
                            ? 'Premium Plan'
                            : 'Go Premium',
                        subtitle: subscriptionProvider.isSubscribed
                            ? '${subscriptionProvider.remainingDays} days remaining'
                            : 'Unlock unlimited tender access',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  _buildListTile(
                    context,
                    icon: Icons.analytics_outlined,
                    title: 'Activity & Insights',
                    subtitle: 'History, saved tenders, subscription',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityInsightsScreen(
                            userName: '',
                            userEmail: '',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  _buildListTile(
                    context,
                    icon: Icons.tune,
                    title: 'Preference',
                    subtitle: 'Your preferred Tender filter',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PreferenceDetailsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  _buildListTile(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings & Support',
                    subtitle: 'Notifications, help & support',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsSupportScreen(
                            userName: username,
                            userEmail: email,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007074),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(onFilterPressed: () {}),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF007074).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF007074), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007074),
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
