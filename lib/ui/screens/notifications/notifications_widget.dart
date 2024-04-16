import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../data/network/current_weather_api.dart';
import '../../../model/detail_data_model.dart';
import '../detail/detail.dart';


class NotificationsPage extends StatefulWidget {
  static const String path = '/notifications';

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> notifications = [];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.title}");
      _processMessage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _processMessage(message);
    });
    FirebaseMessaging.onBackgroundMessage(_processBackgroundMessage);
    _initializeNotifications();
  }

  Future<void> _processBackgroundMessage(RemoteMessage message) async {
    print("Handling a background message: ${message.notification?.title}");
    _processMessage(message);
  }

  void _processMessage(RemoteMessage message) {
    setState(() {
      notifications.insert(
        0,
        NotificationModel(
          icon: Icons.notifications,
          title: message.notification?.title ?? "Notification",
          message: message.notification?.body ?? "New notification",
          remoteMessage: message,
        ),
      );
    });
  }

  void _initializeNotifications() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _processMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _processMessage(message);
    });
  }


  @override
  void dispose() {
    FirebaseMessaging.onMessage.listen(null).cancel();
    FirebaseMessaging.onMessageOpenedApp.listen(null).cancel();
    super.dispose();
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
    return GestureDetector(
      onTap: () {
        if (notification.message.contains("POTENTIAL MATCH FOUND FOR:")) {
          Navigator.of(context).pushNamed(
            NotificationDisplay.path,
            arguments: notification.remoteMessage,
          );
        }
      },
      child: Container(
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
            leading: Icon(notification.icon),
            title: Text(notification.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(notification.message),
          ),
        ),
      ),
    );
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
    print("Type of responseJson: ${responseJson.runtimeType}");
    print("Content of responseJson: $responseJson");


    String itemName = message.notification?.body?.replaceFirst("POTENTIAL MATCH FOUND FOR: ", "") ?? "";

    // Iterate over each key in responseJson
    for (var key in ['DRUG', 'FOOD', 'DEVICE']) {
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
