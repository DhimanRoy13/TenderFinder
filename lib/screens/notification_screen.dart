import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart'; // For date formatting

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];

  Future<void> _requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    print('Notification permission status: \\${settings.authorizationStatus}');
  }

  @override
  void initState() {
    super.initState();

    // Request notification permission (Android 13+)
    _requestNotificationPermission();

    // Initialize local notifications
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Print FCM token for debugging
    FirebaseMessaging.instance.getToken().then((token) {
      print('FCM Token: \\${token}');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: \\${message.data}');
      _addNotification(message);
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened: \\${message.data}');
      _addNotification(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('App launched from notification: \\${message.data}');
        _addNotification(message);
      }
    });
  }

  void _addNotification(RemoteMessage message) {
    setState(() {
      notifications.insert(0, {
        'title': message.notification?.title ?? 'No Title',
        'body': message.notification?.body ?? 'No Body',
        'time': DateTime.now(),
        'isRead': false,
      });
    });
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
    setState(() {
      notifications[index]['isRead'] = true;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in notifications) {
        n['isRead'] = true;
      }
    });
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
    await Future.delayed(Duration(seconds: 1)); // Simulated delay
    setState(() {
      // In real-world, you'd fetch from server or re-sync with Firebase
      notifications.insert(0, {
        'title': 'Refreshed Notification',
        'body': 'This is a newly fetched notification',
        'time': DateTime.now(),
        'isRead': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotifications();

    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        actions: [
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
