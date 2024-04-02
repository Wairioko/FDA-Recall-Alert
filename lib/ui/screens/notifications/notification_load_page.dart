import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:safe_scan/ui/screens/notifications/notifications_widget.dart';
import '../../../model/detail_data_model.dart';
import '../detail/detail.dart';


class SelectionScreen extends StatelessWidget {
  final List<DetailDataModel> matches;


  const SelectionScreen({Key? key, required this.matches}) : super(key: key);

  Color _getColorForClassification(String classification) {
    switch (classification.toUpperCase()) { // Normalize for comparison
      case 'CLASS I':
        return Colors.redAccent;
      case 'CLASS II':
        return Colors.orangeAccent;
      case 'CLASS III':
        return Colors.yellow;
      default:
        return Colors.grey; // Neutral color for unknown classification
    }
  }

  String cleanText(String inputText) {
    return inputText.replaceAll('\n', ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Potential Match Found'),
      ),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Material(
              elevation: 4, // Add elevation for shadow
              shadowColor: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12), // Add border radius
              child: InkWell(
                onTap: () {
                  // Navigate to detail screen for the selected match
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
                      SizedBox(height: 4.0),
                      Text(
                        cleanText(NotificationMessage.getNotification() ?? ''),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        cleanText(matches[index].product_description),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        cleanText(matches[index].classification),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900,
                          color: _getColorForClassification(matches[index].classification),
                        ),
                      ),
                      SizedBox(height: 8.0), // Add some space between items
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
