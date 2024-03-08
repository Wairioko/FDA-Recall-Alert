import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_scan/ui/screens/home/widgets/query_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_scan/data/network/current_weather_api.dart';
import 'package:flutter/services.dart';
import '../../../model/detail_data_model.dart';
import '../detail/detail.dart';


User? loggedInUser = FirebaseAuth.instance.currentUser;


class SelectionScreen extends StatelessWidget {
  final List<DetailDataModel> matches;

  const SelectionScreen({Key? key, required this.matches}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Match'),
      ),
      body: ListView.separated( // Using separated for visual dividers
        itemCount: matches.length,
        separatorBuilder: (context, index) => const Divider(height: 1), // Divider
        itemBuilder: (context, index) {
          return Padding(  // Added padding
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              title: Text(
                matches[index].product_description,
                style: TextStyle(fontWeight: FontWeight.w500), // Slightly bolder title
              ),
              subtitle: Text(matches[index].classification),
              onTap: () {
                // Navigate to detail screen for the selected match
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Detail(detailDataModel: matches[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }


}


class ResultScreen extends StatefulWidget {
  final String text;
  const ResultScreen({Key? key, required this.text}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _textEditingController;
  late FocusNode _keyboardListenerFocusNode;
  late String _editedText;
  // Define validIndices list
  List<int> validIndices = [];
  late FocusNode _focusNode;
  int _editingLineIndex = -1;
  bool _isEditing = false;
  bool _isUploading = false;
  late List<dynamic> _searchResults = [];
  bool _allItemsChecked = false;
  bool _isSearching = false;
  bool _textEdited = false; // Flag to track text edits
  List<String> unfilteredLines = []; // List to store lines of text
  List<dynamic>? responseJson;
  // New property to keep track of selected lines
  Set<int> _selectedLines = Set<int>();
  List<int> clearedIndices = [];



  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.text);
    _editedText = widget.text;
    unfilteredLines = _editedText.split('\n'); // Split the text into lines
    _focusNode = FocusNode();
    validIndices = List<int>.generate(unfilteredLines.length, (index) => index);
    _keyboardListenerFocusNode = FocusNode();

    // Add focus listener
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Hide keyboard and show search button
        setState(() {
          _isEditing = false;
        });
      }
    });

    // Load responseJson as a list of dynamic objects
    responseJson = ApiData.responseJson;
  }


  // Declare a Completer
  Completer<void> _uploadCompleter = Completer<void>();


  Future<void> _upLoad(User? loggedInUser) async {
    if (_isUploading) {
      // Upload only if editing, text has been edited, and not already uploading
      return;
    }

    setState(() {
      _isUploading = true;
    });

    if (loggedInUser != null) {
      try {
        // Filter out items marked as "Item cleared" and without "Potential Matches Found", and upload the rest
        List<String> itemsToUpload = [];
        for (int i = 0; i < unfilteredLines.length; i++) {
          String item = unfilteredLines[i];
          if (!clearedIndices.contains(i) && !item.contains('Potential Matches Found')) {
            // Remove " - Item Cleared" substring
            item = item.replaceAll(' - Item Cleared', '');
            itemsToUpload.add(item);
          }
        }
        print(itemsToUpload);

        if (itemsToUpload.isNotEmpty) {
          // Reference to the user's document in "user-registration-data" collection
          DocumentReference userDoc = FirebaseFirestore.instance
              .collection('receipts-data')
              .doc(loggedInUser.uid);
          // Reference to the "receipts" subcollection under the user's document
          CollectionReference receiptsCollection =
          userDoc.collection('cleared_items');
          // Call the user's CollectionReference to add a new receipt
          await receiptsCollection.add({
            'items_category': CategoryData.category,
            'cleared_items': itemsToUpload.join('\n'), // Join the items into a single string
          });
          // Show successful upload pop-up
          _showUploadSuccessDialog();
          print("Receipt Added");
        } else {
          print("No items to upload. All items marked as 'Item cleared' or contain 'Potential Matches Found'.");
        }
      } catch (error) {
        print("Failed to add receipt: $error");
      } finally {
        setState(() {
          _isUploading = false;
          _textEdited = false; // Reset text edited flag after upload
          _isSearching = false; // Stop searching
        });
      }
    }
  }


  void _showUploadSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Upload Successful"),
          content: const Text("The receipt has been successfully uploaded."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
    _keyboardListenerFocusNode.dispose();
  }


  Future<void> _checkItems() async {
    setState(() {
      _isSearching = true;
    });

    // Clear previous search results
    _searchResults.clear();

    // Initialize a map to store item matches
    Map<String, List<DetailDataModel>> itemMatchesMap = {};

    for (String line in unfilteredLines) {
      // Check if the line is empty
      if (line.trim().isEmpty) {
        continue;
      }

      List<DetailDataModel> matches = [];

      // Loop through each entry in responseJson to check for matches
      for (dynamic item in responseJson ?? []) {
        if (item['product_description'] != null &&
            item['product_description']
                .toString()
                .toLowerCase()
                .contains(line.toLowerCase())) {

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

      // Update line item labels and color
      if (matches.isNotEmpty) {
        // If a match is found, update the line text to include matches
        unfilteredLines[unfilteredLines.indexOf(line)] = "$line - Potential Matches Found (${matches.length}), Click to see Details";
      } else {
        // If no match is found, update the line text to indicate that the item is cleared
        unfilteredLines[unfilteredLines.indexOf(line)] = "$line - Item Cleared";
        clearedIndices.add(unfilteredLines.indexOf(line));
      }

      // Add matches to the itemMatchesMap
      itemMatchesMap[line] = matches;
    }

    // Convert itemMatchesMap to the desired format and assign it to _searchResults
    _searchResults = itemMatchesMap.entries
        .map((entry) => {entry.key: entry.value})
        .toList();

    setState(() {
      _isSearching = false;
    });
  }


  // Update _handleLineTap method to correctly handle line taps and navigation
  void _handleLineTap(int index) {
    if (!_isEditing) {
      if (index < _searchResults.length) {
        List<DetailDataModel> matches = _searchResults[index].values.first;
        if (matches == null || clearedIndices.contains(index)) {
          print('Item cleared. No matches found.');
        } else if (matches.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectionScreen(matches: matches),
            ),
          );
        }
      }
    } else {
      setState(() {
        _editingLineIndex = index;
        _isEditing = false;
        _textEditingController.text = unfilteredLines[index];
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
  }



  // Define a list of patterns and keywords indicating non-product lines
  final nonProductPatterns = [
    RegExp(r'^\d+\.$'), // Matches lines containing a number followed by a period
    RegExp(r'^[a-zA-Z]$', caseSensitive: false), // Matches lines containing only a single letter
    RegExp(r'^\d+$'),//filter for numbers only
    RegExp(r'\b\d{2,12}\b'), // Barcode numbers (at least 12 digits)
    RegExp(r'\b\d+\.\d+\b'), // Amounts (decimal numbers)
    RegExp(r'\b\d+\s*(PCS|pack|pieces|amount|kgs|gms)\b', caseSensitive: false), // Quantities like "1.00PCS"
    // Add more patterns as needed
  ];

  List<int> selectedIndices = [];

  Widget _buildNotebookList() {
    final filteredLines = unfilteredLines.where((line) {
      return !nonProductPatterns.any((pattern) => pattern.hasMatch(line.trim()));
    }).toList();

    return Material(
      child: RawKeyboardListener(
        focusNode: _keyboardListenerFocusNode,
        onKey: (event) {
          if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            for (int index = 0; index < filteredLines.length; index++) {
              if (_isEditing && index == _editingLineIndex && _focusNode.hasFocus) {
                setState(() {
                  // Calculate the insertion index based on the current state of the list
                  final insertionIndex = unfilteredLines.indexOf(filteredLines[index]);
                  filteredLines.insert(insertionIndex + 1, '');
                  unfilteredLines.insert(insertionIndex + 1, ''); // Insert into original data
                  _editingLineIndex = insertionIndex + 1;
                  _focusNode.requestFocus();
                });
                break;
              }
            }
          }
        },
        child: Container(
          color: Colors.black,
          child: SizedBox(
            height: 400, // Set a finite height here
            child: ListView.builder(
              itemCount: filteredLines.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndices.contains(index);
                if (!nonProductPatterns.any((pattern) => pattern.hasMatch(filteredLines[index]))) {
                  return _isEditing && index == _editingLineIndex
                      ? Material(
                    color: Colors.black,
                    child: TextFormField(
                      controller: _textEditingController,
                      focusNode: _focusNode,
                      style: TextStyle(color: Colors.white), // Set text color to white
                      onEditingComplete: () {
                        setState(() {
                          // Calculate the original index based on the current state of the list
                          final originalIndex = unfilteredLines.indexOf(filteredLines[index]);
                          unfilteredLines[originalIndex] = _textEditingController.text;
                          _isEditing = false;
                        });
                      },
                    ),
                  )
                      : Dismissible(
                    key: Key(filteredLines[index]), // Unique key for each item
                    onDismissed: (direction) {
                      setState(() {
                        // Calculate the original index based on the current state of the list
                        final originalIndex = unfilteredLines.indexOf(filteredLines[index]);
                        unfilteredLines.removeAt(originalIndex);
                        // If the item is dismissed, clear any selection
                        selectedIndices.remove(originalIndex);

                        // Update valid indices for navigation
                        validIndices.remove(originalIndex);

                      });
                    },
                    background: Container(color: Colors.red),
                    child: Material(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.5) : Colors.black,
                          border: Border(
                            top: BorderSide(color: Colors.amber),
                            bottom: BorderSide(color: Colors.amber),
                          ),
                        ),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              filteredLines[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          onTap: () {
                            if (!_isEditing) {
                              _handleLineTap(validIndices[index]); // Use valid indices for navigation
                            }
                          },
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [

          if (!_isUploading)
            IconButton(
              onPressed: () async {
                // Call _updateText function passing the current user and await its completion
                await _upLoad(FirebaseAuth.instance.currentUser);
                // Complete the _uploadCompleter only if it hasn't been completed already
                if (!_uploadCompleter.isCompleted) {
                  _uploadCompleter.complete();
                }
              },
              icon: const Icon(Icons.cloud_upload),
            ),
          if (_isUploading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildNotebookList(),
          ),

        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // _updateText(FirebaseAuth.instance.currentUser);
                // Call _checkItems directly when the search button is pressed
                await _checkItems();
              },
              child: const Text('Search All Items'),
            ),
          ],
        ),
      ),
    );
  }
}



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Result'),
//         actions: [
//           if (_isUploading)
//             const Center(child: CircularProgressIndicator()),
//           if (!_isUploading)
//             IconButton(
//               onPressed: () async {
//                 // Call _updateText function passing the current user and await its completion
//                 await _updateText(FirebaseAuth.instance.currentUser);
//                 // Complete the _uploadCompleter only if it hasn't been completed already
//                 if (!_uploadCompleter.isCompleted) {
//                   _uploadCompleter.complete();
//                 }
//               },
//               icon: const Icon(Icons.cloud_upload),
//             ),
//         ],
//       ),
//       body: _buildNotebookList(),
//       bottomNavigationBar: BottomAppBar(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 // _updateText(FirebaseAuth.instance.currentUser);
//                 // Call _checkItems directly when the search button is pressed
//                 await _checkItems();
//               },
//               child: const Text('Search All Items'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//



// Widget _buildNotebookList() {
//   // Ensure at least 20 empty lines are available
//   while (_lines.length < 20) {
//     _lines.add('');
//   }
//
//   return RawKeyboardListener(
//     focusNode: _keyboardListenerFocusNode,
//     onKey: (event) {
//       if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
//         print("Key pressed: ${event.logicalKey}");
//         print("TextField has focus: ${_focusNode.hasFocus}");
//         print("Return key pressed");
//         // Loop through your Listview to find the TextField that's in focus
//         for (int index = 0; index < _lines.length; index++) {
//           if (_isEditing && index == _editingLineIndex && _focusNode.hasFocus) {
//             setState(() {
//               _lines.insert(_editingLineIndex + 1, '');
//               _editingLineIndex++;
//
//               // Explicitly request focus on the new TextField
//               _focusNode.requestFocus();
//             });
//             break; // Exit the loop once you've found the TextField
//           }
//         }
//       }
//     },
//     child: Container(
//       color: Colors.black,
//       child: ListView.builder(
//         itemCount: _lines.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               if (_lines[index].contains('Potential Matches Found')) {
//                 try {
//
//                   var isolatedSearchTerm = _lines[index].split('-')[0].trim().toLowerCase(); // Ensure lowercase
//
//                   var matchesForLineItem = _searchResults.firstWhere(
//                         (resultDict) => resultDict.keys.any((key) => key.toLowerCase() == isolatedSearchTerm),
//                   );
//
//                   if (matchesForLineItem.containsKey(isolatedSearchTerm)) {
//                     List<DetailDataModel> selectedMatches = matchesForLineItem[isolatedSearchTerm]!;
//
//                     if (selectedMatches.isNotEmpty) {
//                       // Navigate to SelectionScreen with the list of matches
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SelectionScreen(matches: selectedMatches),
//                         ),
//                       );
//                     }
//                   }
//                 } catch (e) {
//                   print("Error: $e");
//                 }
//               } else {
//                 _editLine(index);
//               }
//             },
//
//
//
//
//             child: Column(
//               children: [
//                 _isEditing && index == _editingLineIndex
//                     ? TextField(
//                   style: TextStyle(color: Colors.white),
//                   keyboardType: TextInputType.multiline,
//                   maxLines: null, // Allow indefinite lines
//                   autofocus: true,
//                   controller: _textEditingController,
//                   focusNode: _focusNode,
//                   onChanged: (value) {
//                     setState(() {
//                       _lines[index] = value;
//                       _textEdited = true;
//                     });
//                   },
//                 )
//                     : ListTile(
//                   title: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       _lines[index],
//                       style: TextStyle(
//                         color: _lines[index].contains('Potential Match - Click to See Details')
//                             ? Colors.red
//                             : _lines[index].contains('Item cleared')
//                             ? Colors.green
//                             : Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   height: 1,
//                   color: Colors.amber, // Adjust color as needed
//                 ), // Add Container here
//               ],
//             ),
//           );
//         },
//       ),
//     ),
//   );
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// User? loggedInUser = FirebaseAuth.instance.currentUser;
//
// class ResultScreen extends StatefulWidget {
//   final String text;
//   const ResultScreen({Key? key, required this.text}) : super(key: key);
//
//   @override
//   _ResultScreenState createState() => _ResultScreenState();
// }
//
// class _ResultScreenState extends State<ResultScreen> {
//   late TextEditingController _textEditingController;
//   late String _editedText;
//   late FocusNode _focusNode;
//   bool _isEditing = false;
//   bool _isUploading = false;
//   late List<dynamic> _searchResults = [];
//   late List<dynamic> _selectedItems = [];
//   bool _allItemsChecked = false;
//   bool _isSearching = false;
//   bool _textEdited = false; // Flag to track text edits
//   List<String> _lines = []; // List to store lines of text
//
//   @override
//   void initState() {
//     super.initState();
//     _textEditingController = TextEditingController(text: widget.text);
//     _editedText = widget.text;
//     _lines = _editedText.split('\n'); // Split the text into lines
//     _checkItems(); // Initial check
//     _focusNode = FocusNode();
//
//     // Add focus listener
//     _focusNode.addListener(() {
//       if (!_focusNode.hasFocus) {
//         // Hide keyboard and show search button
//         setState(() {
//           _isEditing = false;
//         });
//       }
//     });
//   }
//
//   Future<void> _checkItems() async {
//     setState(() {
//       _isSearching = true; // Start searching
//     });
//
//     // Clear previous search results
//     _searchResults.clear();
//
//     // Loop through every line and search for items
//     for (String line in _lines) {
//       List<dynamic>? responseJson = ApiData.responseJson;
//       if (responseJson != null && responseJson.isNotEmpty) {
//         List<dynamic> lineItems = responseJson.where((item) =>
//             item['product_description']
//                 .toString()
//                 .toLowerCase()
//                 .contains(line.toLowerCase())).toList();
//         _searchResults.addAll(lineItems);
//       }
//     }
//
//     setState(() {
//       _isSearching = false; // Stop searching
//     });
//   }
//
//   Future<void> _updateText(User? loggedInUser) async {
//     if (_isUploading || !_textEdited) {
//       // Upload only if editing, text has been edited, and not already uploading
//       return;
//     }
//
//     setState(() {
//       _isUploading = true;
//       _isSearching = true; // Start searching
//     });
//
//     if (loggedInUser != null) {
//       try {
//         // **Perform search before upload**
//         await _checkItems();
//
//         // If no matches found, upload the edited text
//         if (_searchResults.isEmpty) {
//           // Combine lines into one string
//           _editedText = _lines.join('\n');
//           // Reference to the user's document in "user-registration-data" collection
//           DocumentReference userDoc = FirebaseFirestore.instance
//               .collection('receipts-data')
//               .doc(loggedInUser.uid);
//           // Reference to the "receipts" subcollection under the user's document
//           CollectionReference receiptsCollection =
//           userDoc.collection('user_receipts');
//           // Call the user's CollectionReference to add a new receipt
//           await receiptsCollection.add({
//             'receipt': _editedText,
//           });
//           // Show successful upload pop-up
//           _showUploadSuccessDialog();
//           print("Receipt Added");
//         } else {
//           // Notify the user or take appropriate action if matches are found
//           // You may choose to display a message or perform a specific action here
//           print("Matches found, not uploading the edited text.");
//         }
//       } catch (error) {
//         print("Failed to add receipt: $error");
//       } finally {
//         setState(() {
//           _isUploading = false;
//           _textEdited = false; // Reset text edited flag after upload
//           _isSearching = false; // Stop searching
//         });
//       }
//     } else {
//       print("User not logged in");
//     }
//   }
//
//   void _showUploadSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Upload Successful"),
//           content: const Text("The receipt has been successfully uploaded."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context); // Pop twice to return to the home screen
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _onCheckboxChanged(bool? value) {
//     setState(() {
//       _allItemsChecked = value ?? false;
//     });
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   void _editLine(int lineIndex) {
//     setState(() {
//       _isEditing = true;
//     });
//     _textEditingController.text = _lines[lineIndex]; // Set initial text
//     // Focus on the TextField
//     FocusScope.of(context).requestFocus(_focusNode);
//   }
//
//   void _enableTextEditing() {
//     setState(() {
//       _isEditing = !_isEditing;
//       _textEdited = false; // Reset _textEdited when editing starts
//     });
//
//     if (_isEditing) {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return GestureDetector(
//             onTap: () {}, // Prevent dismissing bottom sheet on tap
//             child: Container(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: _textEditingController,
//                     focusNode: _focusNode,
//                     onChanged: (value) {
//                       setState(() {
//                         _editedText = value;
//                         _textEdited = true; // Set _textEdited to true when text is changed
//                         // Update the lines when text is edited
//                         _lines = _editedText.split('\n');
//                       });
//                     },
//                     textInputAction: TextInputAction.newline,
//                     keyboardType: TextInputType.multiline,
//                     maxLines: null,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//       FocusScope.of(context).requestFocus(_focusNode); // Focus on text field when editing starts
//     }
//   }
//
//   Widget _buildNotebookList() {
//     return Container(
//       color: Colors.black,
//       child: ListView.builder(
//         itemCount: _lines.length,
//         itemBuilder: (context, index) {
//           String line = _lines[index];
//           bool isMatchFound = _searchResults.any((item) =>
//               item['product_description'].toString().toLowerCase().contains(line.toLowerCase()));
//
//           return Column(
//             children: [
//               ListTile(
//                 title: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     line,
//                     style: TextStyle(
//                       color: isMatchFound ? Colors.red : Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               Container(
//                 height: 1,
//                 width: double.infinity,
//                 color: isMatchFound ? Colors.red : Colors.amber, // Adjust color for the line separator
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Result'),
//         actions: [
//           if (_isSearching || _isEditing) // Show upload button only when searching or editing
//             IconButton(
//               onPressed: () {
//                 _updateText(FirebaseAuth.instance.currentUser);
//               },
//               icon: const Icon(Icons.cloud_upload),
//             ),
//           IconButton(
//             onPressed: () {
//               _enableTextEditing();
//             },
//             icon: const Icon(Icons.edit),
//           ),
//         ],
//       ),
//       body: _buildNotebookList(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _updateText(FirebaseAuth.instance.currentUser);
//         },
//         child: const Icon(Icons.cloud_upload),
//         backgroundColor: Colors.greenAccent,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: BottomAppBar(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 _updateText(FirebaseAuth.instance.currentUser);
//               },
//               child: const Text('Search All Items'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ApiData {
//   static List<dynamic>? responseJson;
// }





// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:daily_news/data/network/current_weather_api.dart';
//
// User? loggedInUser = FirebaseAuth.instance.currentUser;
//
// class ResultScreen extends StatefulWidget {
//   final String text;
//   const ResultScreen({Key? key, required this.text}) : super(key: key);
//
//   @override
//   _ResultScreenState createState() => _ResultScreenState();
// }
//
// class _ResultScreenState extends State<ResultScreen> {
//   late TextEditingController _textEditingController;
//   late String _editedText;
//   bool _isEditing = false;
//   bool _isUploading = false;
//   late List<dynamic> _searchResults = [];
//   late List<dynamic> _selectedItems = [];
//   bool _allItemsChecked = false;
//   bool _isSearching = false;
//   bool _textEdited = false; // Flag to track text edits
//
//   @override
//   void initState() {
//     super.initState();
//     _textEditingController = TextEditingController(text: widget.text);
//     _editedText = widget.text;
//     _checkItems(); // Initial check
//   }
//
//   Future<void> _checkItems() async {
//     setState(() {
//       _isSearching = true; // Start searching
//     });
//
//     List<dynamic>? responseJson = ApiData.responseJson;
//     if (responseJson != null && responseJson.isNotEmpty) {
//       _selectedItems = responseJson
//           .where((item) => item['product_description'].toString().toLowerCase().contains(_editedText.toLowerCase()))
//           .toList();
//       _allItemsChecked = _selectedItems.length == responseJson.length;
//     }
//
//     setState(() {
//       _isSearching = false; // Stop searching
//     });
//   }
//
//   Future<void> _updateText(User? loggedInUser) async {
//     if (_isUploading || !_textEdited) {
//       // Upload only if editing, text has been edited, and not already uploading
//       return;
//     }
//
//     setState(() {
//       _isUploading = true;
//       _isSearching = true; // Start searching
//     });
//
//     if (loggedInUser != null) {
//       try {
//         // **Perform search before upload**
//         await _checkItems();
//
//         // If no matches found, upload the edited text
//         if (_selectedItems.isEmpty) {
//           // Reference to the user's document in "user-registration-data" collection
//           DocumentReference userDoc = FirebaseFirestore.instance.collection('receipts-data').doc(loggedInUser.uid);
//           // Reference to the "receipts" subcollection under the user's document
//           CollectionReference receiptsCollection = userDoc.collection('user_receipts');
//           // Call the user's CollectionReference to add a new receipt
//           await receiptsCollection.add({
//             'receipt': _editedText,
//           });
//           // Show successful upload pop-up
//           _showUploadSuccessDialog();
//           print("Receipt Added");
//         } else {
//           // Notify the user or take appropriate action if matches are found
//           // You may choose to display a message or perform a specific action here
//           print("Matches found, not uploading the edited text.");
//         }
//       } catch (error) {
//         print("Failed to add receipt: $error");
//       } finally {
//         setState(() {
//           _isUploading = false;
//           _textEdited = false; // Reset text edited flag after upload
//           _isSearching = false; // Stop searching
//         });
//       }
//     } else {
//       print("User not logged in");
//     }
//   }
//
//   void _showUploadSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Upload Successful"),
//           content: const Text("The receipt has been successfully uploaded."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context); // Pop twice to return to the home screen
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _onCheckboxChanged(bool? value) {
//     setState(() {
//       _allItemsChecked = value ?? false;
//     });
//   }
//
//   void _enableTextEditing() {
//     setState(() {
//       _editedText = widget.text;
//       _isEditing = !_isEditing;
//       _textEdited = false; // Reset _textEdited when editing starts
//     });
//
//     if (_isEditing) {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _textEditingController,
//                   onChanged: (value) {
//                     setState(() {
//                       _editedText = value;
//                       _textEdited = true; // Set _textEdited to true when text is changed
//                     });
//                     _checkItems(); // Check items again when text is changed
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     _updateText(FirebaseAuth.instance.currentUser);
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.greenAccent,
//                   ),
//                   child: const Text('Search'),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Result'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               _enableTextEditing();
//             },
//             icon: const Icon(Icons.edit),
//           ),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           if (_isEditing) {
//             _enableTextEditing();
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _editedText,
//                 style: const TextStyle(
//                   fontSize: 18.0,
//                 ),
//               ),
//               if (_isSearching) // Render "Searching for matches" if searching
//                 Text(
//                   'Searching for matches...',
//                   style: TextStyle(
//                     fontSize: 16.0,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               Checkbox(
//                 value: _allItemsChecked,
//                 onChanged: _onCheckboxChanged,
//               ),
//               // Other UI elements...
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _updateText(FirebaseAuth.instance.currentUser);
//         },
//         child: const Icon(Icons.cloud_upload),
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:daily_news/data/network/current_weather_api.dart';
//
// User? loggedInUser = FirebaseAuth.instance.currentUser;
//
// class ResultScreen extends StatefulWidget {
//   final String text;
//   const ResultScreen({Key? key, required this.text}) : super(key: key);
//
//   @override
//   _ResultScreenState createState() => _ResultScreenState();
// }
//
// class _ResultScreenState extends State<ResultScreen> {
//   late TextEditingController _textEditingController;
//   late String _editedText;
//   bool _isEditing = false;
//   bool _isUploading = false;
//   late List<dynamic> _searchResults = [];
//   late List<dynamic> _selectedItems = [];
//   bool _allItemsChecked = false;
//   bool _isSearching = false;
//   bool _textEdited = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _textEditingController = TextEditingController(text: widget.text);
//     _editedText = widget.text;
//     _checkItems(); // Initial check
//   }
//
//   void _updateText(User? loggedInUser) async {
//     if (_isUploading || !_textEdited) {
//       // Upload only if editing, text has been edited, and not already uploading
//       return;
//     }
//
//     setState(() {
//       _isUploading = true;
//     });
//
//     if (loggedInUser != null) {
//       try {
//         // Reference to the user's document in "user-registration-data" collection
//         DocumentReference userDoc = FirebaseFirestore.instance.collection('receipts-data').doc(loggedInUser.uid);
//         // Reference to the "receipts" subcollection under the user's document
//         CollectionReference receiptsCollection = userDoc.collection('user_receipts');
//         // Call the user's CollectionReference to add a new receipt
//         await receiptsCollection.add({
//           'receipt': _editedText,
//         });
//         // Show successful upload pop-up
//         _showUploadSuccessDialog();
//         print("Receipt Added");
//
//         // Perform search against responseJson entries
//         _checkItems();
//       } catch (error) {
//         print("Failed to add receipt: $error");
//       } finally {
//         setState(() {
//           _isUploading = false;
//           _textEdited = false; // Reset text edited flag after upload
//         });
//       }
//     } else {
//       print("User not logged in");
//     }
//   }
//
//
//   void _showUploadSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Upload Successful"),
//           content: const Text("The receipt has been successfully uploaded."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context); // Pop twice to return to the home screen
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _checkItems() async {
//     setState(() {
//       _isSearching = true; // Start searching
//     });
//     List<dynamic>? responseJson = ApiData.responseJson;
//     if (responseJson != null && responseJson.isNotEmpty) {
//       _selectedItems = responseJson
//           .where((item) => _editedText.contains(item['product_description']))
//           .toList();
//
//       _allItemsChecked = _selectedItems.length == responseJson.length;
//     }
//     setState(() {
//       _isSearching = false; // Stop searching
//     });
//   }
//
//   void _onCheckboxChanged(bool? value) {
//     setState(() {
//       _allItemsChecked = value ?? false;
//       if (_allItemsChecked) {
//         print("Your items are safe, we will continue keeping an eye out");
//         // Upload the text only if all items are checked
//         if (_allItemsChecked) {
//           _updateText(FirebaseAuth.instance.currentUser);
//         }
//       }
//     });
//   }
//
//   void _enableTextEditing() {
//     setState(() {
//       _editedText = widget.text;
//       _isEditing = !_isEditing;
//       _textEdited = false; // Reset _textEdited when editing starts
//     });
//
//     if (_isEditing) {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _textEditingController,
//                   onChanged: (value) {
//                     setState(() {
//                       _editedText = value;
//                       _textEdited = true; // Set _textEdited to true when text is changed
//                     });
//                     _checkItems(); // Check items again when text is changed
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     _updateText(FirebaseAuth.instance.currentUser);
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.greenAccent,
//                   ),
//                   child: const Text('Save'),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Result'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               _enableTextEditing();
//             },
//             icon: const Icon(Icons.edit),
//           ),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           if (_isEditing) {
//             _enableTextEditing();
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _editedText,
//                 style: const TextStyle(
//                   fontSize: 18.0,
//                 ),
//               ),
//               if (_isSearching) // Render "Searching for matches" if searching
//                 Text(
//                   'Searching for matches...',
//                   style: TextStyle(
//                     fontSize: 16.0,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               Checkbox(
//                 value: _allItemsChecked,
//                 onChanged: _onCheckboxChanged,
//               ),
//               // Other UI elements...
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if (_isEditing) {
//             _updateText(FirebaseAuth.instance.currentUser);
//           }
//         },
//         child: const Icon(Icons.cloud_upload),
//       ),
//     );
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:daily_news/data/network/current_weather_api.dart';
//
// User? loggedInUser = FirebaseAuth.instance.currentUser;
//
// class ResultScreen extends StatefulWidget {
//   final String text;
//   const ResultScreen({Key? key, required this.text}) : super(key: key);
//
//   @override
//   _ResultScreenState createState() => _ResultScreenState();
// }
//
// class _ResultScreenState extends State<ResultScreen> {
//   late TextEditingController _textEditingController;
//   late String _editedText;
//   bool _isEditing = false;
//   bool _isUploading = false;
//   late List<dynamic> _searchResults = [];
//   late List<dynamic> _selectedItems = [];
//   bool _allItemsChecked = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _textEditingController = TextEditingController(text: widget.text);
//     _editedText = widget.text;
//     _checkItems();
//   }
//
//   void _updateText(User? loggedInUser) async {
//     if (_isUploading) {
//       // If already uploading, do nothing
//       return;
//     }
//
//     setState(() {
//       _isUploading = true;
//     });
//
//     if (loggedInUser != null) {
//       try {
//         // Check if all edited items exist in responseJson
//         bool allItemsExist = _selectedItems.every((item) => _editedText.contains(item['product_description']));
//
//         if (allItemsExist) {
//           // Reference to the user's document in "user-registration-data" collection
//           DocumentReference userDoc = FirebaseFirestore.instance.collection('receipts-data').doc(loggedInUser.uid);
//           // Reference to the "receipts" subcollection under the user's document
//           CollectionReference receiptsCollection = userDoc.collection('user_receipts');
//           // Call the user's CollectionReference to add a new receipt
//           await receiptsCollection.add({
//             'receipt': _editedText,
//           });
//           // Show successful upload pop-up
//           _showUploadSuccessDialog();
//           print("Receipt Added");
//         } else {
//           // Handle case where not all items exist in responseJson
//           print("Not all items exist in responseJson");
//         }
//       } catch (error) {
//         print("Failed to add receipt: $error");
//       } finally {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     } else {
//       print("User not logged in");
//     }
//   }
//
//   void _showUploadSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Upload Successful"),
//           content: const Text("The receipt has been successfully uploaded."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context); // Pop twice to return to the home screen
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // void _checkItems() {
//   //   List<dynamic>? responseJson = ApiData.responseJson;
//   //   print("my user $responseJson");
//   //   if (responseJson != null && responseJson.isNotEmpty) {
//   //     _selectedItems = responseJson
//   //         .where((item) => _editedText.contains(item['product_description']))
//   //         .toList();
//   //
//   //     _allItemsChecked = _selectedItems.length == responseJson.length;
//   //   }
//   // }
//
//   void _checkItems() {
//     List<dynamic>? responseJson = ApiData.responseJson;
//     if (responseJson != null && responseJson.isNotEmpty) {
//       _selectedItems = responseJson
//           .where((item) =>
//           item['product_description'].toString().toLowerCase().contains(_editedText.toLowerCase()))
//           .toList();
//
//       _allItemsChecked = _selectedItems.length == responseJson.length;
//     }
//   }
//
//   void _onCheckboxChanged(bool? value) {
//     setState(() {
//       _allItemsChecked = value ?? false;
//       if (_allItemsChecked) {
//         print("Your items are safe, we will continue keeping an eye out");
//         // Upload the text only if all items are checked
//         if (_allItemsChecked) {
//           _updateText(FirebaseAuth.instance.currentUser);
//         }
//       }
//     });
//   }
//
//   void _enableTextEditing() {
//     setState(() {
//       _editedText = widget.text;
//       _isEditing = !_isEditing;
//     });
//
//     if (_isEditing) {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _textEditingController,
//                   onChanged: (value) {
//                     setState(() {
//                       _editedText = value;
//                     });
//                     _checkItems(); // Check items again when text is changed
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     _updateText(FirebaseAuth.instance.currentUser);
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.greenAccent,
//                   ),
//                   child: const Text('Save'),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Result'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               _enableTextEditing();
//             },
//             icon: const Icon(Icons.edit),
//           ),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           if (_isEditing) {
//             _enableTextEditing();
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _editedText,
//                 style: const TextStyle(
//                   fontSize: 18.0,
//                 ),
//               ),
//               Checkbox(
//                 value: _allItemsChecked,
//                 onChanged: _onCheckboxChanged,
//               ),
//               // Other UI elements...
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if (_isEditing) {
//             _updateText(FirebaseAuth.instance.currentUser);
//           }
//         },
//         child: const Icon(Icons.cloud_upload),
//       ),
//     );
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:daily_news/data/network/current_weather_api.dart';
//
// User? loggedInUser = FirebaseAuth.instance.currentUser;
//
// Map<String, dynamic>? responseJson = ApiData.responseJson;
// List<dynamic> ongoingItems = responseJson?['results']
//     .where((item) => item['status'] == "Ongoing")
//     .toList();
//
//
// class ResultScreen extends StatefulWidget {
//   final String text;
//   const ResultScreen({Key? key, required this.text}) : super(key: key);
//
//   @override
//   _ResultScreenState createState() => _ResultScreenState();
// }
//
// class _ResultScreenState extends State<ResultScreen> {
//   late TextEditingController _textEditingController;
//   late String _editedText;
//   bool _isEditing = false;
//   bool _isUploading = false;
//   late List<dynamic> _searchResults = [];
//   late List<dynamic> _selectedItems = [];
//   bool _allItemsChecked = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _textEditingController = TextEditingController(text: widget.text);
//     _editedText = widget.text;
//     _checkItems();
//   }
//
//   void _updateText(User? loggedInUser) async {
//     if (_isUploading) {
//       // If already uploading, do nothing
//       return;
//     }
//
//     setState(() {
//       _isUploading = true;
//     });
//
//     if (loggedInUser != null) {
//       try {
//         // Check if all edited items exist in responseJson
//         bool allItemsExist = _selectedItems.every((item) => _editedText.contains(item['product_description']));
//
//         if (allItemsExist) {
//           // Reference to the user's document in "user-registration-data" collection
//           DocumentReference userDoc = FirebaseFirestore.instance.collection('receipts-data').doc(loggedInUser.uid);
//           // Reference to the "receipts" subcollection under the user's document
//           CollectionReference receiptsCollection = userDoc.collection('user_receipts');
//           // Call the user's CollectionReference to add a new receipt
//           await receiptsCollection.add({
//             'receipt': _editedText,
//           });
//           // Show successful upload pop-up
//           _showUploadSuccessDialog();
//           print("Receipt Added");
//         } else {
//           // Handle case where not all items exist in responseJson
//           print("Not all items exist in responseJson");
//         }
//       } catch (error) {
//         print("Failed to add receipt: $error");
//       } finally {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     } else {
//       print("User not logged in");
//     }
//   }
//
//   void _showUploadSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Upload Successful"),
//           content: const Text("The receipt has been successfully uploaded."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context); // Pop twice to return to the home screen
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _checkItems() {
//     if (responseJson != null) {
//       List<dynamic> results = responseJson!['results'];
//       print("from detail: $results");
//       _selectedItems = results
//           .where((item) => _editedText.contains(item['product_description']))
//           .toList();
//
//       _allItemsChecked = _selectedItems.length == results.length;
//     }
//   }
//
//   void _onCheckboxChanged(bool? value) {
//     setState(() {
//       _allItemsChecked = value ?? false;
//       if (_allItemsChecked) {
//         print("Your items are safe, we will continue keeping an eye out");
//         // Upload the text only if all items are checked
//         if (_allItemsChecked) {
//           _updateText(FirebaseAuth.instance.currentUser);
//         }
//       }
//     });
//   }
//
//   void _enableTextEditing() {
//     setState(() {
//       _editedText = widget.text;
//       _isEditing = !_isEditing;
//     });
//
//     if (_isEditing) {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _textEditingController,
//                   onChanged: (value) {
//                     setState(() {
//                       _editedText = value;
//                     });
//                     _checkItems(); // Check items again when text is changed
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     _updateText(FirebaseAuth.instance.currentUser);
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.greenAccent,
//                   ),
//                   child: const Text('Save'),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Result'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               _enableTextEditing();
//             },
//             icon: const Icon(Icons.edit),
//           ),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           if (_isEditing) {
//             _enableTextEditing();
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _editedText,
//                 style: const TextStyle(
//                   fontSize: 18.0,
//                 ),
//               ),
//               Checkbox(
//                 value: _allItemsChecked,
//                 onChanged: _onCheckboxChanged,
//               ),
//               // Other UI elements...
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if (_isEditing) {
//             _updateText(FirebaseAuth.instance.currentUser);
//           }
//         },
//         child: const Icon(Icons.cloud_upload),
//       ),
//     );
//   }
// }
//

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:daily_news/data/network/current_weather_api.dart';
//
// User? loggedInUser = FirebaseAuth.instance.currentUser;
//
//
// Map<String, dynamic>? responseJson = ApiData.responseJson;
// List<dynamic> ongoingItems = responseJson?['results']
//     .where((item) => item['status'] == "Ongoing")
//     .toList();
//
//
//
// class ResultScreen extends StatefulWidget {
//   final String text;
//   const ResultScreen({super.key, required this.text});
//
//   @override
//   _ResultScreenState createState() => _ResultScreenState();
// }
//
// class _ResultScreenState extends State<ResultScreen> {
//   late TextEditingController _textEditingController;
//   late String _editedText;
//   bool _isEditing = false;
//   bool _isUploading = false;
//   late List<dynamic> _searchResults = [];
//   late List<dynamic> _selectedItems = [];
//
//
//   @override
//   void initState() {
//     super.initState();
//     _textEditingController = TextEditingController(text: widget.text);
//     _editedText = widget.text;
//   }
//
//   void _updateText(User? loggedInUser) async {
//     if (_isUploading) {
//       // If already uploading, do nothing
//       return;
//     }
//
//     setState(() {
//       _isUploading = true;
//     });
//
//     if (loggedInUser != null) {
//       try {
//         // Reference to the user's document in "user-registration-data" collection
//         DocumentReference userDoc = FirebaseFirestore.instance.collection('receipts-data').doc(loggedInUser.uid);
//         // Reference to the "receipts" subcollection under the user's document
//         CollectionReference receiptsCollection = userDoc.collection('user_receipts');
//         // Call the user's CollectionReference to add a new receipt
//         await receiptsCollection.add({
//           'receipt': _editedText,
//         });
//         // Show successful upload pop-up
//         _showUploadSuccessDialog();
//         print("Receipt Added");
//       } catch (error) {
//         print("Failed to add receipt: $error");
//       } finally {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     } else {
//       print("User not logged in");
//     }
//   }
//
//
//   void _showUploadSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Upload Successful"),
//           content: const Text("The receipt has been successfully uploaded."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context); // Pop twice to return to the home screen
//               },
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Result'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               _enableTextEditing();
//             },
//             icon: const Icon(Icons.edit),
//           ),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: () {
//           if (_isEditing) {
//             _enableTextEditing();
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.all(30.0),
//           child: Text(
//             _editedText,
//             style: const TextStyle(
//               fontSize: 18.0,
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if (_isEditing) {
//             _updateText(FirebaseAuth.instance.currentUser);
//           }
//         },
//         child: const Icon(Icons.cloud_upload),
//       ),
//     );
//   }
//
//   void _enableTextEditing() {
//     setState(() {
//       _editedText = widget.text;
//       _isEditing = !_isEditing;
//     });
//
//     if (_isEditing) {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _textEditingController,
//                   onChanged: (value) {
//                     setState(() {
//                       _editedText = value;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     _updateText(FirebaseAuth.instance.currentUser);
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.greenAccent, // Set the button color to blue
//                   ),
//                   child: const Text('Save'),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
// }
