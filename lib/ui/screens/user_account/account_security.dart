import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountSettingsWidget extends StatefulWidget {
  @override
  _AccountSettingsWidgetState createState() => _AccountSettingsWidgetState();
  static const String path = '/account_security';
}

class _AccountSettingsWidgetState extends State<AccountSettingsWidget> {
  bool _isSocialSignIn = true; // Set this value based on your authentication method
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Account Deletion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete your account?'
                    'This will permanently delete all associated data.'), // Emphasize data loss
                Text('Thank you for choosing Safe Recall'),
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
                var current = FirebaseAuth.instance.currentUser;
                var uid = current?.uid;

                if (uid != null) { // Ensure user is logged in
                  try {
                    // Step 1: Delete user info in 'users'
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .delete();

                    // Step 2: Delete data in other collections
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
                  }
                }
              },
            ),
          ],
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
            if (!_isSocialSignIn)
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'San Francisco',
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Current Password',
              ),
              onChanged: (value) {
                setState(() {
                  _currentPassword = value;
                });
              },
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
              onChanged: (value) {
                setState(() {
                  _newPassword = value;
                });
              },
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
              ),
              onChanged: (value) {
                setState(() {
                  _confirmPassword = value;
                });
              },
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement password change logic here
                // Check if current password matches
                // Check if new password and confirm password match
                // Perform password change action
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'San Francisco',
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Use your preferred color scheme
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
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
            ),

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
