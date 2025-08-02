import 'activity_insights_screen.dart';
import 'settings_support_screen.dart';
import 'profile_details_screen.dart';
// lib/screens/profile_screen.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;
  final String? userName;
  const ProfileScreen({super.key, required this.userEmail, this.userName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DateTime? _lastBackPressed;
  void _logout(BuildContext context) {
    // Clear login fields before going back
    LoginScreen.clearFields();
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C989C), Color(0xFF007074)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          onFilterPressed: () {}, // No filter functionality on profile screen
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1C989C), Color(0xFF007074)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.account_circle,
                            size: 96,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "TenderFinder",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1C989C),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: const Text('Profile'),
                    subtitle: Text(
                      '${widget.userName ?? "User"} • ${widget.userEmail}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileDetailsScreen(
                            userName: widget.userName ?? "User",
                            userEmail: widget.userEmail,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 8,
                    endIndent: 8,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.insights,
                      color: Color(0xFF1C989C),
                    ),
                    title: const Text('Activity & Insights'),
                    subtitle: const Text(
                      'History, saved tenders, subscription',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActivityInsightsScreen(
                            userName: widget.userName ?? "User",
                            userEmail: widget.userEmail,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 8,
                    endIndent: 8,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: Color(0xFF1C989C),
                    ),
                    title: const Text('Settings & Support'),
                    subtitle: const Text('Notifications, help & support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsSupportScreen(
                            userName: widget.userName ?? "User",
                            userEmail: widget.userEmail,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C989C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            // ...existing code...
          ],
        ),
      ),
    );
  }
}
