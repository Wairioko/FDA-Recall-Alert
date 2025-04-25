import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import '../../../data/network/current_weather_api.dart';
import '../../../model/detail_data_model.dart';
import '../detail/detail.dart';

GlobalKey<NotificationsPageState> notificationsPageKey = GlobalKey();

// Update the NotificationsPage class
class NotificationsPage extends StatefulWidget {
  static const String path = '/notifications';

  const NotificationsPage({Key? key}) : super(key: key);

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  final GlobalKey<NotificationsPageState> _key = GlobalKey();
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    key: notificationsPageKey;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            debugPrint("No notifications yet"); // Check if this is printed
            return Center(
              child: Text('No notifications yet'),
            );
          } else {
            return ListView.builder(
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                return NotificationItem(
                  notification: provider.notifications[index],
                  onClear: () {
                    provider.removeNotification(provider.notifications[index]);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}



class NotificationProvider extends ChangeNotifier {
  late List<NotificationModel> _notifications = [];
  final StreamController<List<NotificationModel>> _notificationStreamController =
  StreamController<List<NotificationModel>>.broadcast();

  Stream<List<NotificationModel>> get notificationStream =>
      _notificationStreamController.stream;

  List<NotificationModel> get notifications => _notifications;

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners(); // Notify listeners whenever a new notification is added

  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationProvider() {
    print("NotificationProvider initialized");
    _initializeMessaging();
  }

  void _initializeMessaging() {

    print("_initializeMessaging called");
    _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.title}");
      _processMessage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.title}");
      _processMessage(message);
    });
    // FlutterLocalNotificationsPlugin();
    _initLocalNotifications();
    _initializeNotifications();
  }


  void _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create the notification channel
    const String channelId = 'fcm_default_channel';
    const String channelName = 'Default Notifications';
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.high,
    );

    // Register the channel with the system
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('Notification channel created: $channelId');
  }






  // Method to remove a notification
  void removeNotification(NotificationModel notification) {
    _notifications.remove(notification);
    notifyListeners(); // Notify listeners whenever a notification is removed

  }



  // void _processMessage(RemoteMessage message) async {
  //   NotificationModel notification = NotificationModel(
  //     icon: Icons.notifications,
  //     title: message.notification?.title ?? "",
  //     message: message.notification?.body ?? "",
  //     remoteMessage: message,
  //   );
  //
  //   // Add the notification
  //   addNotification(notification);
  //
  //   // Show the notification
  //   await _showNotification(
  //     message.notification?.title ?? "",
  //     message.notification?.body ?? "",
  //   );
  //
  //   // Update the NotificationsPage with the new notification
  //   notificationsPageKey.currentState?.refresh();
  // }

  void _processMessage(RemoteMessage message) async {

    NotificationModel notification = NotificationModel(
      icon: Icons.notifications,
      title: message.notification?.title ?? "",
      message: message.notification?.body ?? "",
      remoteMessage: message,
    );

    // Add the notification
    addNotification(notification);

    // Show the notification
    await _showNotification(
      message.notification?.title ?? "",
      message.notification?.body ?? "",
    );

    // Update the NotificationsPage with the new notification
    if (notificationsPageKey.currentState != null) {
      notificationsPageKey.currentState!.refresh();
    }
  }



  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'default_notification_channel_id', 'default_notification_channel_id',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
        payload: 'item x');
  }

  void _initializeNotifications() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _processMessage(initialMessage);
    }
  }

}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onClear;

  NotificationItem({required this.notification, required this.onClear});

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
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          onTap: () {
            _handleNotificationClick(context);
          },
          leading: Icon(notification.icon),
          title: Text(notification.title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(notification.message),
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: onClear,
          ),
        ),
      ),
    );
  }

  void _handleNotificationClick(BuildContext context) {
    if (notification.message.contains("POTENTIAL MATCH FOUND FOR:")) {
      Navigator.of(context).pushNamed(
        NotificationDisplay.path,
        arguments: notification.remoteMessage,
      );
    } else {
      Navigator.of(context).pushNamed(
        NotificationsPage.path,
      );
    }
  }
}


class NotificationModel {
  final IconData icon;
  final String title;
  final String message;
  final RemoteMessage remoteMessage;

  NotificationModel({
    required this.icon,
    required this.title,
    required this.message,
    required this.remoteMessage,
  });
}

class NotificationDisplay extends StatelessWidget {
  static const String path = '/notification_selection';

  final RemoteMessage message;

  const NotificationDisplay({Key? key, required this.message}) : super(key: key);

  Color _getColorForClassification(String classification) {
    switch (classification.toUpperCase()) {
      case 'CLASS I':
        return Colors.redAccent;
      case 'CLASS II':
        return Colors.orangeAccent;
      case 'CLASS III':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  String cleanText(String inputText) {
    return inputText.replaceAll('\n', ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    List<DetailDataModel> matches = [];
    var responseJson = AllApiData.getAllResponseJson();

    String itemName = message.notification?.body?.replaceFirst("POTENTIAL MATCH FOUND FOR: ", "") ?? "";

    // Iterate over each key in responseJson
    for (var key in ['FOOD','DRUG','DEVICE']) {
      if (responseJson[key] != null && responseJson[key] is List) {
        for (var item in responseJson[key]!) {
          if (item['product_description'] != null &&
              item['product_description'].toString().toLowerCase().contains(itemName.toLowerCase())) {
            matches.add(
              DetailDataModel(
                product_description: item['product_description'],
                reason_for_recall: item['reason_for_recall'],
                status: item['status'],
                classification: item['classification'],
                recalling_firm: item['recalling_firm'],
                voluntary_mandated: item['voluntary_mandated'],
                recall_number: item['recall_number']
              ),
            );
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Potential Match Found'),
      ),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Material(
              elevation: 4,
              shadowColor: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Detail(detailDataModel: matches[index]),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4.0),
                      Text(
                        cleanText(message.notification?.title ?? ''),
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        cleanText(matches[index].product_description),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        cleanText(matches[index].classification),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900,
                          color: _getColorForClassification(matches[index].classification),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
