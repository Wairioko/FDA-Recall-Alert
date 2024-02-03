import 'package:daily_news/model/request_query.dart';
import 'package:daily_news/ui/shared/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utility/news_texts.dart';
import '../cubit/home_cubit.dart';

class QueryWidget extends StatefulWidget {
  final HomeCubit homeCubit;

  const QueryWidget({Key? key, required this.homeCubit}) : super(key: key);

  @override
  State<QueryWidget> createState() => _QueryWidgetState();
}

class _QueryWidgetState extends State<QueryWidget> {
  RequestQuery requestQuery = RequestQuery("", "", "", "");
  String categoryHintText = "Classification";
  String stateHintText = "State";
  String itemHintText = "Category";
  final TextEditingController _controller = TextEditingController();
  bool showClearButton = false;

  void clearState() {
    setState(() {
      stateHintText = "State";
      requestQuery.state = "";
    });
  }

  void clearCategory() {
    setState(() {
      categoryHintText = "Classification";
      requestQuery.category = ""; // Set category to an empty string
    });
  }

  void clearClassification() {
    setState(() {
      categoryHintText = "Classification";
      requestQuery.classification = ""; // Set classification to an empty string
    });
  }

  void reloadData() {
    setState(() {
      showClearButton = requestQuery.isNotEmpty; // Show the clear button only if there's any query
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
      clearCategory();
      clearClassification();
      requestQuery.query = ""; // Set query to an empty string
    });

    // Trigger data reload
    widget.homeCubit.getTopHeadlines(requestQuery: requestQuery);
  }

  void _filterItems(String query) {
    setState(() {
      // Update the requestQuery's query field
      requestQuery.query = query;

      // If the query is empty, clear state, category, and classification
      if (query.isEmpty) {
        clearState();
        clearCategory();
        clearClassification();
      }

      // Trigger data reload
      reloadData();
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey[200],
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: _filterItems, // Call _filterItems when the text changes
                  decoration: const InputDecoration(
                    hintText: 'Enter Query',
                    contentPadding: EdgeInsets.all(16.0),
                    border: InputBorder.none,
                  ),
                ),
              ),
              // const SizedBox(width: 10.0),
              // Flexible(
              //   child: Container(
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(10.0),
              //       color: Colors.grey[200],
              //     ),
              //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //     child: DropdownButton<String>(
              //       dropdownColor: Colors.grey[300],
              //       underline: const SizedBox(),
              //       isExpanded: true,
              //       hint: Text(
              //         itemHintText,
              //         overflow: TextOverflow.ellipsis,
              //         maxLines: 1,
              //       ),
              //       items: NewsTexts.itemList().map((String value) {
              //         return DropdownMenuItem<String>(
              //           value: value,
              //           child: Text(value),
              //         );
              //       }).toList(),
              //       onChanged: (String? newValue) {
              //         setState(() {
              //           itemHintText = newValue ?? 'Recall Item';
              //           requestQuery.category = newValue ?? NewsTexts.itemList()[0];
              //         });
              //       },
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 12.0),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[200],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey[300],
                        underline: const SizedBox(),
                        isExpanded: true,
                        hint: Text(
                          stateHintText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        items: NewsTexts.stateList().map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            stateHintText = newValue ?? 'State';
                            requestQuery.state = newValue ?? NewsTexts.stateList()[0];
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[200],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey[300],
                        underline: const SizedBox(),
                        isExpanded: true,
                        hint: Text(
                          categoryHintText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        items: NewsTexts.classificationList().map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            categoryHintText = newValue ?? 'Classification';
                            requestQuery.classification =
                                newValue ?? NewsTexts.classificationList()[0];
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(
              //   height: 8,
              // ),
              TextButton(
                onPressed: () async {
                  // Remove the redundant line
                  reloadData();
                },
                child: Text(
                  NewsTexts.get()['search']!,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showClearButton)
                ElevatedButton(
                  onPressed: () {
                    clearAllParameters();
                  },
                  child: Text('Clear All Parameters'),
                ),
            ],
          ),
        );
      },
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return BlocBuilder<ThemeCubit, ThemeState>(
  //     builder: (context, state) {
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 10),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             // ... other widgets
  //
  //             /// Enclose the filter row in a SingleChildScrollView for horizontal scrolling
  //             SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               child: Row(
  //                 children: [
  //                   /// Wrap each widget in a Flexible to ensure proportional space allocation
  //                   Flexible(
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10.0),
  //                         color: Colors.grey[200],
  //                       ),
  //                       padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //                       child: DropdownButton<String>(
  //                         dropdownColor: Colors.grey[300],
  //                         underline: const SizedBox(),
  //                         isExpanded: false,
  //                         hint: Text(
  //                           stateHintText,
  //                           overflow: TextOverflow.ellipsis,
  //                           maxLines: 1,
  //                         ),
  //                         items: NewsTexts.stateList().map((String value) {
  //                           return DropdownMenuItem<String>(
  //                             value: value,
  //                             child: Text(value),
  //                           );
  //                         }).toList(),
  //                         onChanged: (String? newValue) {
  //                           setState(() {
  //                             stateHintText = newValue ?? 'State';
  //                             requestQuery.state = newValue ?? NewsTexts.stateList()[0];
  //                           });
  //                         },
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 5.0),
  //                   Flexible(
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10.0),
  //                         color: Colors.grey[200],
  //                       ),
  //                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                       child: DropdownButton<String>(
  //                         dropdownColor: Colors.grey[300],
  //                         underline: const SizedBox(),
  //                         isExpanded: false,
  //                         hint: Text(
  //                           categoryHintText,
  //                           overflow: TextOverflow.ellipsis,
  //                           maxLines: 1,
  //                         ),
  //                         items: NewsTexts.classificationList().map((String value) {
  //                           return DropdownMenuItem<String>(
  //                             value: value,
  //                             child: Text(value),
  //                           );
  //                         }).toList(),
  //                         onChanged: (String? newValue) {
  //                           setState(() {
  //                             categoryHintText = newValue ?? 'Classification';
  //                             requestQuery.classification =
  //                                 newValue ?? NewsTexts.classificationList()[0];
  //                           });
  //                         },
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 10.0),
  //                   Flexible(
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(10.0),
  //                         color: Colors.grey[200],
  //                       ),
  //                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                       child: TextButton(
  //                         onPressed: () async {
  //                           // Remove the redundant line
  //                           reloadData();
  //                         },
  //                         child: Text(
  //                           NewsTexts.get()['search']!,
  //                           style: const TextStyle(
  //                             color: Colors.green,
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //
  //             // ... other widgets
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


// import 'package:daily_news/model/request_query.dart';
// import 'package:daily_news/ui/shared/theme/theme_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../utility/news_texts.dart';
// import '../cubit/home_cubit.dart';
//
//
// class QueryWidget extends StatefulWidget {
//   final HomeCubit homeCubit;
//
//   const QueryWidget({Key? key, required this.homeCubit}) : super(key: key);
//
//   @override
//   State<QueryWidget> createState() => _QueryWidgetState();
// }
//
// class _QueryWidgetState extends State<QueryWidget> {
//   RequestQuery requestQuery = RequestQuery("", "", "", "");
//   String categoryHintText = "Classification";
//   String stateHintText = "State";
//   String itemHintText = "Category";
//   final TextEditingController _controller = TextEditingController();
//   bool showClearButton = false;
//
//   void clearState() {
//     setState(() {
//       stateHintText = "State";
//       requestQuery.state = "";
//     });
//   }
//
//   void clearCategory() {
//     setState(() {
//       categoryHintText = "Classification";
//       requestQuery.category = ""; // Set category to an empty string
//     });
//   }
//
//   void clearClassification() {
//     setState(() {
//       categoryHintText = "Classification";
//       requestQuery.classification = ""; // Set category to an empty string
//     });
//   }
//
//
//   void reloadData() {
//     setState(() {
//       showClearButton = requestQuery.isNotEmpty; // Show the clear button only if there's any query
//     });
//
//     // Only fetch data if there's a non-empty query
//     if (requestQuery.isNotEmpty) {
//       widget.homeCubit.getTopHeadlines(requestQuery: requestQuery);
//     }
//   }
//
//
//   void clearAllParameters() {
//     setState(() {
//       showClearButton = false;
//       _controller.clear();
//       clearState();
//       clearCategory();
//       clearClassification();
//       requestQuery.query = "";  // Set query to an empty string
//     });
//
//     // Trigger data reload
//     widget.homeCubit.getTopHeadlines(requestQuery: requestQuery);
//   }
//
//
//   void _filterItems(String query) {
//     setState(() {
//       // Update the requestQuery's query field
//       requestQuery.query = query;
//
//       // If the query is empty, clear state and category
//       if (query.isEmpty) {
//         clearState();
//         clearCategory();
//         clearClassification();
//       }
//
//       // Trigger data reload
//       reloadData();
//     });
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ThemeCubit, ThemeState>(
//       builder: (context, state) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.0),
//                   color: Colors.grey[200],
//                 ),
//                 child:
//                 TextField(
//                   controller: _controller,
//                   onChanged: _filterItems, // Call _filterItems when the text changes
//                   decoration: const InputDecoration(
//                     hintText: 'Enter Query',
//                     contentPadding: EdgeInsets.all(16.0),
//                     border: InputBorder.none,
//                   ),
//                 ),
//
//               ),
//               const SizedBox(width: 10.0),
//               Expanded(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: Colors.grey[200],
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: DropdownButton<String>(
//                     dropdownColor: Colors.grey[300],
//                     underline: const SizedBox(),
//                     isExpanded: true,
//                     hint: Text(
//                       itemHintText,
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                     items: NewsTexts.itemList().map((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         itemHintText = newValue ?? 'Recall Item';
//                         requestQuery.category =
//                             newValue ?? NewsTexts.itemList()[0];
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12.0),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.0),
//                         color: Colors.grey[200],
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: DropdownButton<String>(
//                         dropdownColor: Colors.grey[300],
//                         underline: const SizedBox(),
//                         isExpanded: true,
//                         hint: Text(
//                           stateHintText,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         items: NewsTexts.stateList().map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             stateHintText = newValue ?? 'State';
//                             requestQuery.state =
//                                 newValue ?? NewsTexts.stateList()[0];
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10.0),
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.0),
//                         color: Colors.grey[200],
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: DropdownButton<String>(
//                         dropdownColor: Colors.grey[300],
//                         underline: const SizedBox(),
//                         isExpanded: true,
//                         hint: Text(
//                           categoryHintText,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         items: NewsTexts.classificationList().map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             categoryHintText = newValue ?? 'Classification';
//                             requestQuery.category =
//                                 newValue ?? NewsTexts.classificationList()[0];
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//
//                 ],
//               ),
//               const SizedBox(
//                 height: 8,
//               ),
//               TextButton(
//                 onPressed: () async {
//                   requestQuery.query = _controller.text;
//                   reloadData();
//                 },
//                 child: Text(
//                   NewsTexts.get()['search']!,
//                   style: const TextStyle(
//                     color: Colors.green,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               if (showClearButton)
//                 ElevatedButton(
//                   onPressed: () {
//                     clearAllParameters();
//                   },
//                   child: Text('Clear All Parameters'),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }


//
// class QueryWidget extends StatefulWidget {
//   final HomeCubit homeCubit;
//
//   const QueryWidget({super.key, required this.homeCubit});
//
//   @override
//   State<QueryWidget> createState() => _QueryWidgetState();
// }
//
// class _QueryWidgetState extends State<QueryWidget> {
//   RequestQuery requestQuery = RequestQuery("", "", "");
//   String categoryHintText = "Category";
//   String stateHintText = "State";
//
//
//   final TextEditingController _controller = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ThemeCubit, ThemeState>(
//       builder: (context, state) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10.0),
//                   color:
//                       state.themeData.colorScheme.surface, // Background color
//                 ),
//                 child: TextField(
//                   controller: _controller,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter Query',
//                     contentPadding: EdgeInsets.all(16.0),
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12.0), // Spacer between EditText and Row
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.0),
//                         color: state
//                             .themeData.colorScheme.surface, // Background color
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: DropdownButton<String>(
//                         dropdownColor: state.themeData.colorScheme.secondary,
//                         underline: const SizedBox(),
//                         isExpanded: true,
//                         hint: Text(
//                           stateHintText,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         items: NewsTexts.stateList().map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             stateHintText =
//                                 newValue ?? 'STATE'; // Update hint text
//                           });
//                           requestQuery.state =
//                               newValue ?? NewsTexts.stateList()[50];
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10.0), // Spacer between Dropdowns
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.0),
//                         color: state
//                             .themeData.colorScheme.surface, // Background color
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: DropdownButton<String>(
//                         dropdownColor: state.themeData.colorScheme.secondary,
//                         underline: const SizedBox(),
//                         isExpanded: true,
//                         hint: Text(
//                           categoryHintText,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                         items: NewsTexts.categoryList().map((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             categoryHintText =
//                                 newValue ?? 'Category'; // Update hint text
//                           });
//                           requestQuery.category =
//                               newValue ?? NewsTexts.categoryList()[0];
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 8,
//               ),
//               TextButton(
//                 style: TextButton.styleFrom(
//                   shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10))),
//                   backgroundColor: Colors.green.shade100.withAlpha(100),
//                 ),
//                 onPressed: () async {
//                   requestQuery.query = _controller.text;
//                   widget.homeCubit.getTopHeadlines(requestQuery: requestQuery);
//                   // topHeadlinesApi.lastrequestQuery = requestQuery;
//                 },
//                 child: Text(
//                   NewsTexts.get()['search'],
//                   style: const TextStyle(
//                       color: Colors.green,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600),
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

