// ignore_for_file: unused_element, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_test_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final CollectionReference _notificationCollection = FirebaseFirestore.instance
      .collection('notifications');

  void _addNotification(RemoteMessage message) {
    final notificationData = {
      'title': message.notification?.title ?? 'No Title',
      'body': message.notification?.body ?? 'No Body',
      'time': DateTime.now().toIso8601String(),
      'isRead': false,
    };
    setState(() {
      notifications.insert(0, {...notificationData, 'time': DateTime.now()});
    });
    // Save to Firestore
    _notificationCollection.add(notificationData);
  }

  void _listenToFirebaseMessages() {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.data}');
      _addNotification(message);
      _fetchNotificationsFromFirestore();
    });

    // Listen for background message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened: ${message.data}');
      _addNotification(message);
      _fetchNotificationsFromFirestore();
    });
  }

  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();

    // Load notifications from Firestore
    _fetchNotificationsFromFirestore();

    // Listen for new Firebase messages
    _listenToFirebaseMessages();

    // Get and display FCM token
    _displayToken();
  }

  Future<void> _fetchNotificationsFromFirestore() async {
    final snapshot = await _notificationCollection
        .orderBy('time', descending: true)
        .get();
    setState(() {
      notifications = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'title': data['title'] ?? 'No Title',
          'body': data['body'] ?? 'No Body',
          'time': DateTime.tryParse(data['time'] ?? '') ?? DateTime.now(),
          'isRead': data['isRead'] ?? false,
        };
      }).toList();
    });
  }

  void _displayToken() async {
    String? token = await NotificationService().getToken();
    print('FCM Token: $token');
    // You can copy this token for testing with Firebase Console
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('FCM Token logged to console'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLocalNotification(RemoteMessage message) {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      platformChannelSpecifics,
      payload: 'data',
    );
  }

  void _markAsRead(int index) {
    final notification = notifications[index];
    setState(() {
      notification['isRead'] = true;
    });
    // Update Firestore
    _notificationCollection
        .where(
          'time',
          isEqualTo: (notification['time'] as DateTime).toIso8601String(),
        )
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({'isRead': true});
          }
        });
  }

  void _deleteNotification(int index) {
    final notification = notifications[index];
    setState(() {
      notifications.removeAt(index);
    });
    // Delete from Firestore
    _notificationCollection
        .where(
          'time',
          isEqualTo: (notification['time'] as DateTime).toIso8601String(),
        )
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in notifications) {
        n['isRead'] = true;
      }
    });
    // Update all in Firestore
    for (var n in notifications) {
      _notificationCollection
          .where('time', isEqualTo: (n['time'] as DateTime).toIso8601String())
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.update({'isRead': true});
            }
          });
    }
  }

  void _clearAll() {
    setState(() {
      notifications.clear();
    });
  }

  String _groupLabel(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Map<String, List<Map<String, dynamic>>> _groupNotifications() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var n in notifications) {
      String label = _groupLabel(n['time']);
      grouped.putIfAbsent(label, () => []).add(n);
    }
    return grouped;
  }

  /// Simulate refreshing (could also fetch from API or Firebase here)
  Future<void> _refreshNotifications() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulated delay
    await _fetchNotificationsFromFirestore(); // Reload from Firestore
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotifications();

    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            tooltip: "Test Notifications",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationTestScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.done_all),
            tooltip: "Mark all as read",
            onPressed: _markAllAsRead,
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep),
            tooltip: "Clear all",
            onPressed: _clearAll,
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(child: Text("No notifications yet"))
          : RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: ListView(
                children: groupedNotifications.entries.map((entry) {
                  String dateLabel = entry.key;
                  List<Map<String, dynamic>> group = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...group.asMap().entries.map((e) {
                        int index = notifications.indexOf(e.value);
                        final notification = e.value;
                        return Dismissible(
                          key: Key(
                            notification['time'].toString() + index.toString(),
                          ),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => _deleteNotification(index),
                          child: Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: Icon(
                                notification['isRead']
                                    ? Icons.notifications_none
                                    : Icons.notifications_active,
                                color: notification['isRead']
                                    ? Colors.grey
                                    : Colors.blueAccent,
                              ),
                              title: Text(
                                notification['title'],
                                style: TextStyle(
                                  fontWeight: notification['isRead']
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(notification['body']),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.check_circle,
                                  color: notification['isRead']
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () => _markAsRead(index),
                                tooltip: "Mark as Read",
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
