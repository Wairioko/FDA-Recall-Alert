import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReceiptListScreen extends StatefulWidget {
  static const String path = '/receipts';
  const ReceiptListScreen({super.key});

  @override
  _ReceiptListScreenState createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends State<ReceiptListScreen> {
  late User loggedInUser;
  late Stream<QuerySnapshot> receiptsStream;

  @override
  void initState() {
    super.initState();
    loggedInUser = FirebaseAuth.instance.currentUser!;
    receiptsStream = FirebaseFirestore.instance
        .collection('receipts-data')
        .doc(loggedInUser.uid)
        .collection('cleared_items')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipts List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: receiptsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No receipts available.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var receiptData =
              snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(receiptData['cleared_items']),
                onTap: () {
                  _navigateToEditScreen(snapshot.data!.docs[index].id,
                      receiptData['cleared_items']);
                },
                onLongPress: () {
                  _showDeleteConfirmationDialog(snapshot.data!.docs[index].id);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToEditScreen(String receiptId, String receiptText) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptEditScreen(
          receiptId: receiptId,
          initialText: receiptText,
          initialItems: [],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String receiptId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Receipt"),
          content: Text("Are you sure you want to delete this receipt?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteReceipt(receiptId);
                Navigator.pop(context);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteReceipt(String receiptId) {
    FirebaseFirestore.instance
        .collection('receipts-data')
        .doc(loggedInUser.uid)
        .collection('cleared_items')
        .doc(receiptId)
        .delete()
        .then((_) {
      print("Receipt deleted successfully");
    }).catchError((error) {
      print("Error deleting receipt: $error");
    });
  }
}

class ReceiptEditScreen extends StatefulWidget {
  final String receiptId;
  final String initialText;
  final List<String> initialItems;

  const ReceiptEditScreen({
    Key? key,
    required this.receiptId,
    required this.initialText,
    required this.initialItems,
  }) : super(key: key);

  @override
  _ReceiptEditScreenState createState() => _ReceiptEditScreenState();
}

class _ReceiptEditScreenState extends State<ReceiptEditScreen> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Receipt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                maxLines: null, // Allow unlimited lines
                onChanged: (value) {
                  // You can add any additional logic when the text changes
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateReceipt(_textEditingController.text);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateReceipt(String updatedText) {
    FirebaseFirestore.instance
        .collection('receipts-data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cleared_items')
        .doc(widget.receiptId)
        .update({'cleared_items': updatedText})
        .then((_) {
      print("Receipt updated successfully");
      Navigator.pop(context); // Pop back to the receipts list screen
    }).catchError((error) {
      print("Error updating receipt: $error");
    });
  }
}
