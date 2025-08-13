import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';
import 'package:flutter/services.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String _token = '';
  String _lastMessage = '';

  @override
  void initState() {
    super.initState();
    _getToken();
    _setupMessageHandling();
  }

  void _getToken() async {
    final token = await NotificationService().getToken();
    setState(() {
      _token = token ?? 'No token';
    });
  }

  void _setupMessageHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _lastMessage =
            'Title: ${message.notification?.title}\nBody: ${message.notification?.body}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FCM Token:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(_token, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _token));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Token copied to clipboard')),
                );
                print('FCM Token for testing: $_token');
              },
              child: const Text('Copy Token'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Last Received Message:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_lastMessage.isEmpty ? 'No messages yet' : _lastMessage),
            const SizedBox(height: 24),
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Copy the FCM token above\n'
              '2. Go to Firebase Console > Your Project > Cloud Messaging\n'
              '3. Click "Send your first message"\n'
              '4. Enter title and message text\n'
              '5. Click "Send test message"\n'
              '6. Paste your FCM token\n'
              '7. Click "Test" to send notification',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
