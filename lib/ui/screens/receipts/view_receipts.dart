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
        title: const Text('Receipts List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: receiptsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No receipts available.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var receiptData = snapshot.data!.docs[index].data()
                as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    _navigateToEditScreen(snapshot.data!.docs[index].id,
                        receiptData['cleared_items']);
                  },
                  onLongPress: () {
                    _showDeleteConfirmationDialog(snapshot.data!.docs[index].id);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 4), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _truncateText(receiptData['cleared_items'], 30),// Adjust the number of characters for preview
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            // Add additional receipt information here if needed
                            'Date: ${receiptData['date']}',
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _showDeleteConfirmationDialog(snapshot.data!.docs[index].id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return text.substring(0, maxLength) + '...';
    }
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
    }).catchError((error) {

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
        title: const Text('Edit Receipt'),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateReceipt(_textEditingController.text);
              },
              child: const Text('Save Changes'),
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

      Navigator.pop(context); // Pop back to the receipts list screen
    }).catchError((error) {
    });
  }
}
