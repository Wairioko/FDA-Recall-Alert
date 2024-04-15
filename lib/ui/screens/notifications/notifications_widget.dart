import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationMessage {
  static String? notificationMessage;

  static void setNotification(String message) {
    notificationMessage = message;
  }

  static String? getNotification() {
    return notificationMessage;
  }
}

class NotificationsPage extends StatefulWidget {
  static const String path = '/notifications';

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Define a list to hold incoming notifications
  List<NotificationModel> notifications = [];

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
        notifications.add(NotificationModel(
          icon: Icons.notifications,
          title: message.notification?.title ?? "Notification",
          message: message.notification?.body ?? "New notification",
        ));
        NotificationMessage.setNotification(message.notification?.body ?? "New notification");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? Center(
        child: Text('No notifications yet'),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationItem(notification: notifications[index]);
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Card(
        elevation: 0, // to remove the default card elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          leading: Icon(notification.icon),
          title: Text(notification.title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(notification.message),
        ),
      ),
    );
  }
}

// Sample Notification Model
class NotificationModel {
  final IconData icon;
  final String title;
  final String message;

  NotificationModel({
    required this.icon,
    required this.title,
    required this.message,
  });
}
