import 'package:flutter/material.dart';

class SettingsSupportScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  const SettingsSupportScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Settings & Support'),
        backgroundColor: const Color(0xFF1C989C),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            child: ListTile(
              leading: const Icon(
                Icons.notifications,
                color: Color(0xFF1C989C),
              ),
              title: const Text('Notification Preferences'),
              subtitle: const Text('Email/SMS alerts for new tenders'),
              onTap: () {
                // TODO: Navigate to notification preferences
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.help, color: Color(0xFF1C989C)),
              title: const Text('Help & Support'),
              subtitle: const Text('Contact, FAQs'),
              onTap: () {
                // TODO: Navigate to help & support
              },
            ),
          ),
        ],
      ),
    );
  }
}
