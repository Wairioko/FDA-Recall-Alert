import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:safe_scan/ui/screens/home/widgets/query_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_scan/data/network/current_weather_api.dart';
import 'package:flutter/services.dart';
import 'package:safe_scan/ui/screens/receipts/view_receipts.dart';
import '../../../model/detail_data_model.dart';
import '../detail/detail.dart';
import '../home/home.dart';


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

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _textEditingController;
  late FocusNode _keyboardListenerFocusNode;
  late String _editedText;
  List<int> validIndices = [];
  late FocusNode _focusNode;
  int _editingLineIndex = 1;
  bool _isEditing = false;
  bool _isUploading = false;
  late List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _textEdited = false;
  List<String> unfilteredLines = [];
  List<dynamic>? responseJson;
  final Set<int> _selectedLines = <int>{};
  List<int> clearedIndices = [];
  // Replace lineMatchesMap with this dictionary
  late Map<String, List<DetailDataModel>> lineMatchesMap = {};
  // Move filteredLines here as a class-level variable
  late List<String> checkedLines = [];
  late List<String> filteredLines = [];
  bool _searched = false; // Flag to keep track of whether search has been performed


  final nonProductPatterns = [
    RegExp(r'^\d+\.$'),
    RegExp(r'^[a-zA-Z]$', caseSensitive: false),
    RegExp(r'^\d+$'),
    RegExp(r'\b\d{2,12}\b'),
    RegExp(r'\b\d+\.\d+\b'),
    RegExp(r'\b\d+\s*(PCS|pack|pieces|amount|kgs|gms)\b', caseSensitive: false),
  ];


  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.text);
    _editedText = widget.text;
    unfilteredLines = _editedText.split('\n');
    _focusNode = FocusNode();
    validIndices = List<int>.generate(unfilteredLines.length, (index) => index);
    _keyboardListenerFocusNode = FocusNode();
    responseJson = ApiData.responseJson;
    lineMatchesMap = {};
    filteredLines = _filterLines(unfilteredLines);


  }

  List<String> _filterLines(List<String> lines) {
    return lines.where((line) {
      final trimmedLine = line.trim();
      final startsWithNonAlphanumeric = RegExp(r'^\W').hasMatch(trimmedLine);
      final containsNonProductPattern = nonProductPatterns.any((pattern) => pattern.hasMatch(trimmedLine));
      return !startsWithNonAlphanumeric && !containsNonProductPattern;
    }).toList();
  }

  Completer<void> _uploadCompleter = Completer<void>();


  void _handleLineTap(int index) {
    if (!_isEditing && index >= 0 && index < filteredLines.length) {
      setState(() {
        _editingLineIndex = index;
        _isEditing = true;
        _textEditingController.text = filteredLines[index];
        FocusScope.of(context).requestFocus(_focusNode);
      });
      final line = filteredLines[index].trim(); // Get the line item text and trim any whitespace
      print("the line $line");
      final matches = _getMatchesForLine(index); // Retrieve matches based on the line item text
      print("the matches for line $matches");
      if (matches == null || clearedIndices.contains(index)) {
        print('Item cleared. No matches found.');
      } else if (matches.isNotEmpty) {
        setState(() {
          _editingLineIndex = index;
          _isEditing = false;
          _textEditingController.text = filteredLines[index];
          FocusScope.of(context).requestFocus(_focusNode);
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectionScreen(matches: matches),
          ),
        );
      }
    } else if (_isEditing && index >= 0 && index < filteredLines.length) {
      setState(() {
        _editingLineIndex = index;
        _isEditing = false;
        _textEditingController.text = filteredLines[index];
        FocusScope.of(context).requestFocus(_focusNode);
      }
      );
    }
  }

  // Method to show dialog with message
  void _showAlreadySearchedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Search Already Conducted"),
          content: Text("You have already conducted the search."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  List<DetailDataModel>? _getMatchesForLine(int index) {
    final line = filteredLines[index].trim();
    String lineContent = line;
    String? tag;

    // Check for tags and separate them from the actual line content
    if (line.contains('- Potential Matches Found')) {
      lineContent = line.replaceAll(RegExp(r'\s*-\s*Potential Matches Found \(\d+\), Click to see Details$'), '');
      tag = 'Potential Matches Found';
    } else if (line.contains('- Item Cleared')) {
      lineContent = line.replaceAll(RegExp(r'\s*-\s*Item Cleared$'), '');
      tag = 'Item Cleared';
    }
    // Retrieve matches based on the cleaned line content
    final matches = lineMatchesMap[lineContent];
    // Optionally, you can handle the tag here as well
    // For example, you might want to use the tag to customize the UI display
    return matches;
  }

  Future<void> _upLoad(User? loggedInUser) async {
    if (_isUploading) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    if (loggedInUser != null) {
      try {
        List<String> itemsToUpload = [];
        for (int i = 0; i < filteredLines.length; i++) {
          String item = filteredLines[i];
          if (!clearedIndices.contains(i) &&
              !item.contains('Potential Matches Found') &&
              !_matchesNonProductPatterns(item)) {
            // Check if item contains 'Item Cleared' and remove it if present
            if (item.contains(' - Item Cleared')) {
              item = item.replaceAll(' - Item Cleared', '');
            }
            itemsToUpload.add(item);
          }
        }

        if (itemsToUpload.isNotEmpty) {
          // Add timestamp to the data
          DateTime currentDate = DateTime.now();
          // Get today's date
          final timestamp = Timestamp.fromDate(DateTime.utc(currentDate.year, currentDate.month, currentDate.day));
          // Convert the Timestamp to a DateTime
          final dateTime = timestamp.toDate();
          // Format the DateTime as a string
          final dateString = DateFormat('yyyy-MM-dd').format(dateTime);

          DocumentReference userDoc = FirebaseFirestore.instance
              .collection('receipts-data')
              .doc(loggedInUser.uid);
          CollectionReference receiptsCollection =
          userDoc.collection('cleared_items');
          await receiptsCollection.add({
            'items_category': CategoryData.category,
            'cleared_items': itemsToUpload.join('\n'),
            'date': dateString,
          });
          _showUploadSuccessDialog();
          Navigator.of(context).pushNamed(ReceiptListScreen.path);
        } else {
          print(
              "No items to upload. All items marked as 'Item cleared', contain 'Potential Matches Found', or match non-product patterns.");
        }
      } catch (error) {
        print("Failed to add receipt: $error");
      } finally {
        setState(() {
          _isUploading = false;
          _textEdited = false;
          _isSearching = false;
        });
      }
    }
  }

  bool _matchesNonProductPatterns(String item) {
    return nonProductPatterns.any((pattern) => pattern.hasMatch(item));
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
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
    _textEditingController.dispose(); // Dispose text controller
    super.dispose();
    _keyboardListenerFocusNode.dispose();
  }

  void _handleDismiss(int index) {
    setState(() {
      if (index >= 0 && index < filteredLines.length) {
        final removedLine = filteredLines.removeAt(index);
        unfilteredLines.remove(removedLine);
        // Ensure _isEditing is set to false if an item is dismissed while in editing mode
        if (_isEditing && index == _editingLineIndex) {
          _isEditing = false;
        }
      }
    });
  }



  Future<void> _checkItems() async {
    setState(() {
      _isSearching = true;
    });

    // Clear the lineMatchesMap before updating it
    lineMatchesMap.clear();
    filteredLines.clear(); // Clear the filtered lines

    for (int i = 0; i < unfilteredLines.length; i++) {
      String line = unfilteredLines[i];
      if (line.trim().isEmpty) {
        continue;
      }

      List<DetailDataModel> matches = [];

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

      // Update lineMatchesMap and filteredLines
      lineMatchesMap[line] = matches;

      if (matches.isNotEmpty) {
        filteredLines.add("$line - Potential Matches Found (${matches.length}), Click to see Details");
      } else {
        filteredLines.add("$line - Item Cleared");
      }
    }

    // Update the state after updating lineMatchesMap and filteredLines
    setState(() {
      _isSearching = false;
      _searchResults = lineMatchesMap.entries.map((entry) => {entry.key: entry.value}).toList();
    });
  }



  Widget _buildNotebookList() {
    return Material(
      child: RawKeyboardListener(
        focusNode: _keyboardListenerFocusNode,
        onKey: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            for (int index = 0; index < filteredLines.length; index++) {
              if (_isEditing && index == _editingLineIndex && _focusNode.hasFocus) {
                setState(() {
                  final originalIndex = filteredLines.indexOf(filteredLines[index]);
                  final insertionIndex = originalIndex + 1;
                  filteredLines.insert(insertionIndex, '');
                  filteredLines.insert(index + 1, '');
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
            height: 400,
            child: ListView.builder(
              itemCount: filteredLines.length,
              itemBuilder: (context, index) {
                final isSelected = lineMatchesMap.containsKey(filteredLines[index]);
                if (!nonProductPatterns.any((pattern) => pattern.hasMatch(filteredLines[index]))) {
                  Color textColor = Colors.white; // Default color is white
                  if (filteredLines[index].contains('Potential Matches Found')) {
                    textColor = Colors.red; // Change color to red if potential matches found
                  } else if (filteredLines[index].contains('Item Cleared')) {
                    textColor = Colors.green; // Change color to green if item is cleared
                  }
                  return _isEditing && index == _editingLineIndex
                      ? Material(
                      child: Container(
                          color: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller: _textEditingController,
                            focusNode: _focusNode,
                            style: const TextStyle(color: Colors.white),

                            onEditingComplete: () {
                              setState(() {
                                filteredLines[index] = _textEditingController.text;
                                _isEditing = false;
                                }
                              );
                              _focusNode.unfocus(); // Ensure focus is removed from the TextFormField
                            },

                          ),
                    ),
                  )
                      : Dismissible(
                    key: Key(filteredLines[index]), // Ensure the key uniquely identifies the item
                    onDismissed: (direction) {
                      _handleDismiss(index);
                    },
                    background: Container(color: Colors.red),
                    child: Material(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black,
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
                                color: textColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          onTap: () {
                            if (!_isEditing) {
                              _handleLineTap(validIndices[index]);
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
                await _upLoad(FirebaseAuth.instance.currentUser);
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
                // Check if search has already been performed
                if (!_searched) {
                  await _checkItems();
                  setState(() {
                    _searched = true; // Mark search as performed
                  });
                } else {
                  _showAlreadySearchedDialog(); // Show dialog if search already conducted
                }
              },
              child: const Text('Search All Items'),
            ),
          ],
        ),
      ),
    );
  }
}
