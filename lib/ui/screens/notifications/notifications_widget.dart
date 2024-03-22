import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


class NotificationsPage extends StatefulWidget {
  static const String path = '/notifications';

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Define a list to hold incoming notifications
  List<Notification> notifications = [];

  // Initialize Firebase messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // Configure Firebase messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.title}");
      // Process the received message
      setState(() {
        notifications.add(Notification(
          icon: Icons.notifications,
          title: message.notification?.title ?? "Notification",
          message: message.notification?.body ?? "New notification",
        ));
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationItem(notification: notifications[index]);
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final Notification notification;

  NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [BoxShadow(color: Colors.grey.shade300)],
      ),
      child: Row(
        children: [
          Icon(notification.icon),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(notification.message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sample Notification Model
class Notification {
  final IconData icon;
  final String title;
  final String message;

  Notification({
    required this.icon,
    required this.title,
    required this.message,
  });
}
