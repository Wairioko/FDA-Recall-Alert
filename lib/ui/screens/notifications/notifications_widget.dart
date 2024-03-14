import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  static const String path = '/notifications';

  // Define your notifications data
  final List<Notification> notifications = [
    Notification(
      icon: Icons.notification_important,
      color: Colors.red,
      title: 'Urgent Notification',
      message: 'This is an urgent notification.',
    ),
    Notification(
      icon: Icons.notifications,
      color: Colors.blue,
      title: 'General Notification',
      message: 'This is a general notification.',
    ),
    // Add more notifications as needed
  ];

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
          Icon(notification.icon, color: notification.color),
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
  final Color color;
  final String title;
  final String message;

  Notification({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });
}
