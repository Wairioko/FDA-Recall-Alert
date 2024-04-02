import 'package:flutter/material.dart';
import 'package:safe_scan/data/network/current_weather_api.dart';
import 'package:safe_scan/ui/screens/detail/detail.dart';
import '../../../model/detail_data_model.dart';
import 'notifications_widget.dart';

class SelectionScreen extends StatelessWidget {
  final List<DetailDataModel> matches;

  const SelectionScreen({Key? key, required this.matches}) : super(key: key);


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
    String message = NotificationMessage.getNotification() ?? '';
    List<DetailDataModel> matches = [];
    var responseJson = ApiData.getResponseJson();

    for (dynamic item in responseJson ?? []) {
      if (item['product_description'] != null &&
          item['product_description']
              .toString()
              .toLowerCase()
              .contains(message.toLowerCase())) {
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
                      SizedBox(height: 4.0),
                      Text(
                        cleanText(message),
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
                      SizedBox(height: 8.0),
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
