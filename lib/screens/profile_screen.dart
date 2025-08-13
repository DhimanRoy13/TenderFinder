import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:provider/provider.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../providers/auth_provider.dart';
import 'activity_insights_screen.dart';
import 'profile_details_screen.dart';
import 'preference_details_screen.dart';
import 'settings_support_screen.dart';
import 'subscription_screen.dart';
import '../shared/subscription_provider.dart';
import 'edit_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../utils/back_button_handler.dart';

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
  bool hasUnreadNotifications = true;
  Timer? _notificationTimer;

  // Check if there are unread notifications
  Future<bool> _checkUnreadNotifications() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false; // Default to false if error occurs
    }
  }

  void _updateNotificationStatus() async {
    final hasUnread = await _checkUnreadNotifications();
    if (mounted) {
      setState(() {
        hasUnreadNotifications = hasUnread;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    username = "John Doe";
    email = widget.userEmail;
    _updateNotificationStatus(); // Check for unread notifications on init
    _notificationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _updateNotificationStatus();
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => BackButtonHandler.handleMainPageBackPress(context),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
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
                        icon: Icon(
                          hasUnreadNotifications
                              ? Icons
                                    .notifications // filled icon
                              : Icons.notifications_none, // outlined icon
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NotificationScreen(),
                            ),
                          );
                          // Update notification status when returning from notification screen
                          _updateNotificationStatus();
                        },
                      ),
                      if (hasUnreadNotifications)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
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
                      Consumer<SubscriptionProvider>(
                        builder: (context, subscriptionProvider, _) {
                          Color tickColor = Colors.blue;
                          bool showTick = false;
                          if (subscriptionProvider.isSubscribed) {
                            showTick = true;
                            tickColor = subscriptionProvider.remainingDays > 0
                                ? Colors.blue
                                : Colors.red;
                          }
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final authProvider =
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                        userName: authProvider.userName,
                                        userEmail: authProvider.userEmail,
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    size: 46,
                                    color: Color(0xFF007074),
                                  ),
                                ),
                              ),
                              if (showTick)
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: tickColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authProvider.userName.isNotEmpty
                            ? authProvider.userName
                            : "John Doe",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authProvider.userEmail.isNotEmpty
                            ? authProvider.userEmail
                            : widget.userEmail,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Uplifted white card with menu items (full width, attached to sides and bottom)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
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
                          subtitle: 'Edit User information',
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileDetailsScreen(
                                  userName: authProvider.userName.isNotEmpty
                                      ? authProvider.userName
                                      : "John Doe",
                                  userEmail: authProvider.userEmail.isNotEmpty
                                      ? authProvider.userEmail
                                      : widget.userEmail,
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
                                    builder: (context) =>
                                        const SubscriptionScreen(),
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
                                builder: (context) =>
                                    const PreferenceDetailsScreen(),
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
            bottomNavigationBar: CustomBottomNavBar(
              onFilterPressed: () {},
              currentIndex: 3, // Profile screen is index 3
            ),
          );
        },
      ),
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
              onPressed: () async {
                Navigator.pop(context); // Close dialog

                // Logout using AuthProvider
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();

                if (!mounted) return;
                // Navigate to login screen
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
