import 'package:flutter/cupertino.dart';
import 'package:safe_scan/data/network/current_weather_api.dart';
import 'package:safe_scan/model/request_query.dart';
import 'package:safe_scan/ui/screens/scan/scan_detail.dart';
import 'package:safe_scan/ui/shared/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utility/news_texts.dart';
import '../cubit/home_cubit.dart';
import 'package:share_plus/share_plus.dart';



class QueryWidget extends StatefulWidget {
  final HomeCubit homeCubit;

  const QueryWidget({Key? key, required this.homeCubit}) : super(key: key);

  @override
  State<QueryWidget> createState() => _QueryWidgetState();
}

class CategoryData {
  static String? category;
}

String? state_value;



class _QueryWidgetState extends State<QueryWidget> {
  RequestQuery requestQuery = RequestQuery("", "", "", "", "");
  String classificationHintText = "Classification";
  String stateHintText = "State";
  String itemHintText = "Recall Category";
  final  uid = loggedInUser?.uid;
  List<String> categories = ['DRUG', 'DEVICE', 'FOOD'];

  final TextEditingController _controller = TextEditingController();
  bool shouldSearch = false;
  bool showClearButton = false;
  bool showSearchParameters = true;

  void clearState() {
    setState(() {
      stateHintText = "State";
      requestQuery.state = "";
    });
  }

  void clearItem() {
    setState(() {
      itemHintText = "Recall Category";
      requestQuery.item = "FOOD";
    });
  }


  void clearClassification() {
    setState(() {
      classificationHintText = "Classification";
      requestQuery.classification = ""; // Set classification to an empty string
    });
  }

  void reloadData() {
    setState(() {
      showClearButton = requestQuery
          .isNotEmpty; // Show the clear button only if there's any query
    });

    // Only fetch data if there's a non-empty query
    if (requestQuery.isNotEmpty) {
      widget.homeCubit.getTopHeadlines(requestQuery: requestQuery);
    }
  }

  void clearAllParameters() {
    setState(() {
      showClearButton = false;
      _controller.clear();
      clearState();
      clearClassification();
      clearItem();
      requestQuery.query = ""; // Set query to an empty string
    });

    // Trigger data reload
    widget.homeCubit.getTopHeadlines(requestQuery: requestQuery);
  }

  // Method to handle submission event when "Done" or "Enter" key is pressed
  void _filterItems(String query) {
    // Your existing logic for filtering items goes here
    setState(() {
      // Update the requestQuery's query field
      requestQuery.query = query;
      // If the query is empty, clear state, category, and classification
      if (query.isEmpty) {
        clearState();
        clearClassification();
        clearItem();
      }

      // Show/hide search elements and reset search button based on query
      if (query.isNotEmpty) {
        // Hide search elements and show reset search button
        showSearchParameters = false;
        reloadData();
      } else {
        // Show search elements and hide reset search button
        showSearchParameters = true;
      }
    });
  }



  void _onSearchTextChanged() {
    if (shouldSearch) {
      shouldSearch = false; // Reset the flag
      _filterItems(_controller.text); // Call _filterItems when the search should be performed
    }
  }

  void resetSearchParameters() {
    setState(() {
      // Clear the text field
      _controller.clear();
      // Reset all search parameters
      clearState();
      clearClassification();
      clearItem();
      requestQuery.query = ""; // Reset query
    });
    // Trigger data reload with empty query
    reloadData();
  }


  @override
  void initState() {
    super.initState();
    fetchAllCategoriesData();
    _controller.addListener(_onSearchTextChanged);
  }

  Future<void> fetchAllCategoriesData() async {
    Map<String, List<dynamic>> allData = {};

    for (String category in categories) {
      CategoryData.category = category;
      await widget.homeCubit.getTopHeadlines(requestQuery: requestQuery);
      // Wait for some time between each category fetch if needed
      // await Future.delayed(Duration(seconds: 1));

      // Collect data for the current category
      Map<String, dynamic> categoryData = AllApiData.getAllResponseJson();
      List<dynamic> categoryDataList = categoryData[category] ?? [];
      allData[category] = categoryDataList;
    }

    allData.forEach((category, data) {
    });
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10.0, width: 10,),
              // Recall Category Widget
              if (showSearchParameters)
                Container(
                  decoration:
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0), // Softer border
                    color: Colors.grey.shade200,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 0.8, horizontal: 8.0),
                  child: DropdownButton<String>(
                    dropdownColor: Colors.grey.shade200,
                    underline: const SizedBox(),
                    isExpanded: true,
                    hint: Text(
                      itemHintText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: Colors.grey.shade600 // Placeholder text less bold
                      ),
                    ),
                    items: InformationTexts.itemList().map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        itemHintText = newValue ?? 'Recall Category';
                        requestQuery.item = newValue ?? InformationTexts.itemList()[0];
                        CategoryData.category = newValue;
                        reloadData();
                      });
                    },
                  ),
                ),
              const SizedBox(height: 10.0, width: 10,),  // Adding padding between elements
              // Search Bar
              if (showSearchParameters)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 8.0),
                  child: // TextField widget
                  // Modify the TextField widget to set the flag when the "Enter" key is pressed
                  TextField(
                    controller: _controller,
                    onSubmitted: (String value) {
                      shouldSearch = true; // Set the flag to trigger search on submission
                      _onSearchTextChanged(); // Call _onSearchTextChanged manually after submission
                    },
                    onChanged: (String value) {
                      shouldSearch = false;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter Query',
                      contentPadding: EdgeInsets.all(8.0),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              const SizedBox(height: 10.0, width: 10,), // Adding padding between elements
              // Dropdowns
              if (showSearchParameters)
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.grey[200],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: DropdownButton<String>(
                          dropdownColor: Colors.grey[300],
                          underline: const SizedBox(),
                          isExpanded: true,
                          hint: Text(
                            stateHintText,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          items: InformationTexts.stateList().map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              stateHintText = newValue ?? 'State';
                              requestQuery.state = newValue ?? InformationTexts.stateList()[0];
                              state_value = requestQuery.state;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10, width: 10.0),
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.grey[200],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButton<String>(
                          dropdownColor: Colors.grey[300],
                          underline: const SizedBox(),
                          isExpanded: true,
                          hint: Text(
                            classificationHintText,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          items: InformationTexts.classificationList().map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              classificationHintText = newValue ?? 'Class';
                              requestQuery.classification =
                                  newValue ?? InformationTexts.classificationList()[0];
                            });
                          },
                        ),
                      ),
                    ),

                  ],
                ),
              if (showSearchParameters)
                Padding(
                  padding: const EdgeInsets.only(top: 8), // Adjust the padding values as needed
                  child: CupertinoButton(
                    onPressed: () async {
                      shouldSearch = true; // Set the flag to trigger search
                      reloadData();
                      _onSearchTextChanged();
                      setState(() {
                        showSearchParameters = false;
                      });
                    },
                    color: CupertinoColors.activeBlue, // Standard Apple color
                    padding: const EdgeInsets.all(10.0), // More padding within the button
                    borderRadius: BorderRadius.circular(30), // Adjust the border radius
                    child: Text(
                      InformationTexts.get()['search']!,
                      style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'SanFrancisco'
                      ),
                    ),
                  ),
                ),
              // Buttons

              // Inside your build method, where you want to place the reset button

              if (!showSearchParameters)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {

                        setState(() {
                          clearAllParameters();
                          showSearchParameters = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.8), backgroundColor: Colors.orange, // Use primary instead of backgroundColor
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        shadowColor: Colors.grey,
                        elevation: 3,
                      ),
                      child: Text('Clear Filters'),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          clearAllParameters();
                          showSearchParameters = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.8), backgroundColor: Colors.blue, // Use primary instead of backgroundColor
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        shadowColor: Colors.grey,
                        elevation: 3,
                      ),
                      child: const Text('Search Again'),
                    ),
                  ],
                ),

              const SizedBox(height: 10),
              if (!showSearchParameters)// Add some spacing between the buttons and the share button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Align the share button to the center
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Add border radius
                        ),
                      ),
                      icon: Icon(Icons.share_outlined),
                      label: Text("Share data with Loved Ones"), // Adjust button label
                      onPressed: () {
                        // var data = ApiData.responseJson;
                        var data = StateApiData.stateresponseJson;

                        // Extract product descriptions
                        List<String> descriptions = [];
                        for (var item in data!) {
                          String? description = item['product_description'];
                          if (description != null && description.isNotEmpty) {
                            descriptions.add(description);
                          }
                        }
                        // Display as numbered list in a dialog
                        if (descriptions.isNotEmpty) {
                          String message = '';
                          for (int i = 0; i <  5 && i < descriptions.length; i++) { // Ensure descriptions.length bounds
                            message += '${i + 1}. ${descriptions[i]}\n';
                          }
                          String title = '5 Most Recently Recalled Items in $state_value';
                          String referral = 'Download our app to see more recalled items in your state, check your shopping against the recalled list nationwide, and access other features!';
                          String referralLink = 'https://play.google.com/store/apps/details?id=com.saferecall.com';

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(title),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text(message),
                                      const SizedBox(height: 10),
                                      InkWell(
                                        onTap: () {
                                          // Open the app store with referral link
                                          // You can customize this based on the platform (iOS or Android)
                                          launch(referralLink);
                                        },
                                        child: const Text(
                                          'Download the app now!',
                                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text('Close'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Share the message
                                      Share.share('$title\n$message\n$referral\n$referralLink');// This will share the message to other apps
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text('Share'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // Show a message if there are no descriptions
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('No Descriptions Found'),
                                content: Text('There are no product descriptions to share.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),

            ],
          ),

        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}

