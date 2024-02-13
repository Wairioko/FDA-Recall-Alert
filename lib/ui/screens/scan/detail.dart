import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

User? loggedInUser = FirebaseAuth.instance.currentUser;

class ResultScreen extends StatefulWidget {
  final String text;

  const ResultScreen({super.key, required this.text});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _textEditingController;
  late String _editedText;
  bool _isEditing = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.text);
    _editedText = widget.text;
  }

  void _updateText(User? loggedInUser) async {
    if (_isUploading) {
      // If already uploading, do nothing
      return;
    }

    setState(() {
      _isUploading = true;
    });

    if (loggedInUser != null) {
      try {
        // Reference to the user's document in "user-registration-data" collection
        DocumentReference userDoc = FirebaseFirestore.instance.collection('user-registration-data').doc(loggedInUser.uid);

        // Reference to the "receipts" subcollection under the user's document
        CollectionReference receiptsCollection = userDoc.collection('user_receipts');

        // Call the user's CollectionReference to add a new receipt
        await receiptsCollection.add({
          'receipt': _editedText,
        });

        // Show successful upload pop-up
        _showUploadSuccessDialog();

        print("Receipt Added");
      } catch (error) {
        print("Failed to add receipt: $error");
      } finally {
        setState(() {
          _isUploading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            onPressed: () {
              _enableTextEditing();
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_isEditing) {
            _enableTextEditing();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Text(
            _editedText,
            style: const TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isEditing) {
            _updateText(FirebaseAuth.instance.currentUser);
          }
        },
        child: const Icon(Icons.cloud_upload),
      ),
    );
  }

  void _enableTextEditing() {
    setState(() {
      _editedText = widget.text;
      _isEditing = !_isEditing;
    });

    if (_isEditing) {
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
                    setState(() {
                      _editedText = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _updateText(FirebaseAuth.instance.currentUser);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent, // Set the button color to blue
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
