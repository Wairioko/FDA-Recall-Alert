import 'package:flutter/material.dart';

class AccountSettingsWidget extends StatefulWidget {
  @override
  _AccountSettingsWidgetState createState() => _AccountSettingsWidgetState();
  static const String path = '/account_security';
}

class _AccountSettingsWidgetState extends State<AccountSettingsWidget> {
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        backgroundColor: Colors.blue, // Use your preferred color scheme
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
              child: Text('Change Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Use your preferred color scheme
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Implement account deletion logic here
              },
              child: Text('Delete Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Use your preferred color scheme
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
