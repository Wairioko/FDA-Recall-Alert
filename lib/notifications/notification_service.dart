import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Subscribe to a topic to receive messages for all users
    await _firebaseMessaging.subscribeToTopic('recall_match');
    await _firebaseMessaging.subscribeToTopic('new_data');

    // Listen for incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notification
      showNotification(message);
    });

    // Listen for incoming messages when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle background notification
      navigateToNotificationPage(message);
    });
  }

  void showNotification(RemoteMessage message) {
    // Implement your notification display logic here
    // You can use a notification package or a custom solution to display notifications
    // Example using 'flutter_local_notifications' package:
    // _displayLocalNotification(message.notification?.title, message.notification?.body);
  }

  void navigateToNotificationPage(RemoteMessage message) {
    // Implement navigation to the notification page
    // For example, you can use the Navigator to navigate to a specific page
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => NotificationsPage()),
    // );
  }

  // Optional: Add a method to handle the device token retrieval
  Future<String?> getDeviceToken() async {
    // Get the device token and handle it as needed (e.g., send it to your server).
    return await _firebaseMessaging.getToken();
  }
}

