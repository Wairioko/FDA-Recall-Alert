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
        .collection('user-registration-data')
        .doc(loggedInUser.uid)
        .collection('receipts-data')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: receiptsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No receipts available.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var receiptData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              var receiptId = snapshot.data!.docs[index].id;

              return ListTile(
                title: Text(receiptData['receipt']),
                onTap: () {
                  _navigateToEditScreen(receiptId, receiptData['receipt']);
                },
                onLongPress: () {
                  _showDeleteConfirmationDialog(receiptId);
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
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String receiptId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Receipt"),
          content: const Text("Are you sure you want to delete this receipt?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteReceipt(receiptId);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _deleteReceipt(String receiptId) {
    FirebaseFirestore.instance
        .collection('user-registration-data')
        .doc(loggedInUser.uid)
        .collection('receipts-data')
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

  const ReceiptEditScreen({super.key, required this.receiptId, required this.initialText});

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
        title: const Text('Edit Receipt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textEditingController,
              onChanged: (value) {
                // You can add any additional logic when the text changes
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateReceipt();
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateReceipt() {
    String updatedText = _textEditingController.text;
    FirebaseFirestore.instance
        .collection('user-registration-data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('receipts-data')
        .doc(widget.receiptId)
        .update({'receipt': updatedText})
        .then((_) {
      print("Receipt updated successfully");
      Navigator.pop(context); // Pop back to the receipts list screen
    }).catchError((error) {
      print("Error updating receipt: $error");
    });
  }
}
