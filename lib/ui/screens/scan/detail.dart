import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_scan/ui/screens/home/widgets/query_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_scan/data/network/current_weather_api.dart';
import 'package:flutter/services.dart';
import '../../../model/detail_data_model.dart';
import '../../../model/new_item_model.dart';
import '../detail/detail.dart';


User? loggedInUser = FirebaseAuth.instance.currentUser;


class SelectionScreen extends StatelessWidget {
  final List<DetailDataModel> matches;

  const SelectionScreen({Key? key, required this.matches}) : super(key: key);

  String cleanText(String inputText) {
    return inputText.replaceAll('\n', ' ').trim();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Match'),
      ),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              // Navigate to detail screen for the selected match
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detail(detailDataModel: matches[index]),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      color: Colors.black
                    ),
                  ),
                  Divider(color: Colors.grey[400]), // Divider between items
                ],
              ),
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
  String cleanText(String inputText) {
    return inputText.replaceAll('\n', ' ').trim();
  }


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


  // Define a map to store line index and its matches
  Map<int, List<DetailDataModel>> lineMatchesMap = {};

  Future<void> _checkItems() async {
    setState(() {
      _isSearching = true;
    });

    // Clear previous search results and lineMatchesMap
    _searchResults.clear();
    lineMatchesMap.clear();

    List<String> updatedLines = List<String>.from(unfilteredLines); // Create a copy

    for (int i = 0; i < updatedLines.length - 1; i++) {
      String line = updatedLines[i];
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

      // Update lineMatchesMap with matches
      lineMatchesMap[i] = matches;

      // Update line item labels and color
      if (matches.isNotEmpty) {
        updatedLines[i] = "$line - Potential Matches Found (${matches.length}), Click to see Details";
      } else {
        updatedLines[i] = "$line - Item Cleared";
        clearedIndices.add(i);
      }
    }

    // Update unfilteredLines with the modified lines
    setState(() {
      unfilteredLines = updatedLines;
    });

    // Convert lineMatchesMap to _searchResults
    _searchResults = lineMatchesMap.entries
        .map((entry) => {unfilteredLines[entry.key]: entry.value})
        .toList();

    setState(() {
      _isSearching = false;
    });

    // Synchronize lineMatchesMap indices with unfilteredLines indices
    for (int key in lineMatchesMap.keys.toList()) {
      if (key >= updatedLines.length) {
        lineMatchesMap.remove(key);
      }
    }
  }


  Widget _buildNotebookList() {
    final filteredLines = unfilteredLines.where((line) {
      return !nonProductPatterns.any((pattern) => pattern.hasMatch(line.trim()));
    }).toList();

    return Material(
      child: RawKeyboardListener(
        focusNode: _keyboardListenerFocusNode,
        onKey: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            for (int index = 1; index < filteredLines.length; index++) {
              if (_isEditing && index == _editingLineIndex && _focusNode.hasFocus) {
                setState(() {
                  // Calculate the original index based on the current state of the list
                  final originalIndex = unfilteredLines.indexOf(filteredLines[index]);
                  final insertionIndex = originalIndex + 1;
                  unfilteredLines.insert(insertionIndex, ''); // Insert into original data
                  filteredLines.insert(index + 1, ''); // Insert into filtered data
                  _editingLineIndex = originalIndex + 1;
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
                final isSelected = lineMatchesMap.containsKey(index);
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
                        lineMatchesMap.remove(originalIndex);

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

