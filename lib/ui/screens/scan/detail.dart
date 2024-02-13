import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

User? loggedInUser = FirebaseAuth.instance.currentUser;

class ResultScreen extends StatefulWidget {
  final String text;
  const ResultScreen({Key? key, required this.text}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _textEditingController;
  late String _editedText;
  bool _isEditing = false;
  bool _isUploading = false;
  late List<dynamic> _searchResults = [];
  late List<dynamic> _selectedItems = [];
  bool _allItemsChecked = false;
  bool _isSearching = false;
  bool _textEdited = false; // Flag to track text edits
  List<String> _lines = []; // List to store lines of text

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.text);
    _editedText = widget.text;
    _lines = _editedText.split('\n'); // Split the text into lines
    _checkItems(); // Initial check
  }

  Future<void> _checkItems() async {
    setState(() {
      _isSearching = true; // Start searching
    });

    // Clear previous search results
    _searchResults.clear();

    // Loop through every line and search for items
    for (String line in _lines) {
      List<dynamic>? responseJson = ApiData.responseJson;
      if (responseJson != null && responseJson.isNotEmpty) {
        List<dynamic> lineItems = responseJson.where((item) =>
            item['product_description']
                .toString()
                .toLowerCase()
                .contains(line.toLowerCase())).toList();
        _searchResults.addAll(lineItems);
      }
    }

    setState(() {
      _isSearching = false; // Stop searching
    });
  }

  Future<void> _updateText(User? loggedInUser) async {
    if (_isUploading || !_textEdited) {
      // Upload only if editing, text has been edited, and not already uploading
      return;
    }

    setState(() {
      _isUploading = true;
      _isSearching = true; // Start searching
    });

    if (loggedInUser != null) {
      try {
        // **Perform search before upload**
        await _checkItems();

        // If no matches found, upload the edited text
        if (_searchResults.isEmpty) {
          // Combine lines into one string
          _editedText = _lines.join('\n');
          // Reference to the user's document in "user-registration-data" collection
          DocumentReference userDoc = FirebaseFirestore.instance
              .collection('receipts-data')
              .doc(loggedInUser.uid);
          // Reference to the "receipts" subcollection under the user's document
          CollectionReference receiptsCollection =
          userDoc.collection('user_receipts');
          // Call the user's CollectionReference to add a new receipt
          await receiptsCollection.add({
            'receipt': _editedText,
          });
          // Show successful upload pop-up
          _showUploadSuccessDialog();
          print("Receipt Added");
        } else {
          // Notify the user or take appropriate action if matches are found
          // You may choose to display a message or perform a specific action here
          print("Matches found, not uploading the edited text.");
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
    } else {
      print("User not logged in");
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
                Navigator.pop(context); // Pop twice to return to the home screen
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _onCheckboxChanged(bool? value) {
    setState(() {
      _allItemsChecked = value ?? false;
    });
  }

  void _enableTextEditing() {
    setState(() {
      _isEditing = !_isEditing;
      _textEdited = false; // Reset _textEdited when editing starts
    });

    if (_isEditing) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {}, // Prevent dismissing bottom sheet on tap
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textEditingController,
                    onChanged: (value) {
                      setState(() {
                        _editedText = value;
                        _textEdited = true; // Set _textEdited to true when text is changed
                        // Update the lines when text is edited
                        _lines = _editedText.split('\n');
                      });
                    },
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.text, // Set keyboardType to TextInputType.text
                    maxLines: null,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          if (_isSearching || _isEditing) // Show upload button only when searching or editing
            IconButton(
              onPressed: () {
                _updateText(FirebaseAuth.instance.currentUser);
              },
              icon: const Icon(Icons.cloud_upload),
            ),
          IconButton(
            onPressed: () {
              _enableTextEditing();
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _buildNotebookList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _updateText(FirebaseAuth.instance.currentUser);
        },
        child: const Icon(Icons.cloud_upload),
        backgroundColor: Colors.greenAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _updateText(FirebaseAuth.instance.currentUser);
              },
              child: const Text('Search All Items'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotebookList() {
    return Container(
      color: Colors.black,
      child: ListView(
        children: _lines
            .map((line) => GestureDetector(
          onTap: () => _editLine(_lines.indexOf(line)),
          child: Column(
            children: [
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    line,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.amber,
              ),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }

  void _editLine(int lineIndex) {
    setState(() {
      _isEditing = true;
    });
    _textEditingController.text = _lines[lineIndex]; // Set initial text

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textEditingController,
                onChanged: (value) {
                  // Update the line directly
                  _lines[lineIndex] = value;
                },
                textInputAction: TextInputAction.newline, // Create new line on return
                keyboardType: TextInputType.multiline, // Allow multiple lines
                maxLines: null,
              ),
            ],
          ),
        );
      },
    );
  }

}

class ApiData {
  static List<dynamic>? responseJson;
}




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
