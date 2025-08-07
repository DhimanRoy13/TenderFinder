import 'package:flutter/material.dart';

class ActivityInsightsScreen extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  const ActivityInsightsScreen({super.key, this.userName, this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Activity & Insights'),
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
              leading: const Icon(Icons.history, color: Color(0xFF1C989C)),
              title: const Text('Tenders Applied For'),
              subtitle: const Text('View your application history'),
              onTap: () {
                // TODO: Navigate to applied tenders history
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
              leading: const Icon(Icons.bookmark, color: Color(0xFF1C989C)),
              title: const Text('Shortlisted / Saved Tenders'),
              subtitle: const Text('See your saved tenders'),
              onTap: () {
                // TODO: Navigate to saved/shortlisted tenders
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
              leading: const Icon(
                Icons.workspace_premium,
                color: Color(0xFF1C989C),
              ),
              title: const Text('Subscription / Plan Status'),
              subtitle: const Text('Check your premium plan status'),
              onTap: () {
                // TODO: Navigate to subscription/plan status
              },
            ),
          ),
        ],
      ),
    );
  }
}
