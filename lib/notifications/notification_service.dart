import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _firebaseMessaging.subscribeToTopic('all_users');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notification
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle background notification
      navigateToNotificationPage(message);
    });
  }

  void showNotification(RemoteMessage message) {
    // Implement your notification display logic here
  }

  void navigateToNotificationPage(RemoteMessage message) {
    // Implement navigation to the notification page
    // Navigator.push(
    //   // Use your navigation logic here
    //   // Example: MaterialPageRoute(builder: (context) => NotificationsPage()),
    // );
  }

}
