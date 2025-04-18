import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountSettingsWidget extends StatefulWidget {
  @override
  _AccountSettingsWidgetState createState() => _AccountSettingsWidgetState();
  static const String path = '/account_security';
}

class _AccountSettingsWidgetState extends State<AccountSettingsWidget> {
  bool _isLoading = false;

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Confirm Account Deletion'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Are you sure you want to delete your account?'),
                    Text('This will permanently delete all associated data and your account'), // Emphasize data loss
                    Text('Thank you for choosing FDA Recall Alert'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child: Text('Delete'),
                  onPressed: () async {
                    setState(() {
                      _isLoading = true; // Show loading indicator
                    });

                    var current = FirebaseAuth.instance.currentUser;
                    var uid = current?.uid;

                    if (uid != null) {
                      try {
                        // Step 2: Delete data in collections
                        await deleteDataFromCollection('users', uid);
                        await deleteDataFromCollection('receipts-data', uid);
                        await deleteDataFromCollection('notifications', uid);
                        await deleteDataFromCollection('watchlist', uid);
                        await deleteDataFromCollection('feedback', uid);

                        // Step 3: Delete user from Authentication
                        await current!.delete();

                        // Step 4: Sign out and navigate
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                      } catch (e) {
                        // Handle any potential errors during the deletion process
                        print('Error deleting user data: $e');
                      } finally {
                        setState(() {
                          _isLoading = false; // Hide loading indicator
                        });
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper function to delete data from a collection
  Future<void> deleteDataFromCollection(String collectionName, String uid) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .where('userId', isEqualTo: uid)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        backgroundColor: Colors.blue, // Use your preferred color scheme
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'San Francisco',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Implement account deletion logic here
                _showDeleteConfirmationDialog();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'San Francisco',
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Use your preferred color scheme
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ), // Loading indicator
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AccountSettingsWidget(),
  ));
}

