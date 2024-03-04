import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_scan/ui/screens/user_account/subscriptions.dart';

User? user = FirebaseAuth.instance.currentUser;

class UserAccountPage extends StatelessWidget {

  static const String path = '/user-account';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Information
              _buildSectionHeader('Profile Information'),
              _buildProfileInfo(),

              // Security and Privacy
              _buildSectionHeader('Security and Privacy'),
              _buildSecurityPrivacy(),

              // Billing and Subscriptions
              _buildSectionHeader('Billing and Subscriptions'),
              _buildBillingSubscriptions(context),


              // Help and Support
              _buildSectionHeader('Help and Support'),
              _buildHelpAndSupport(),

              // Feedback and Suggestions
              _buildSectionHeader('Feedback and Suggestions'),
              _buildFeedbackSuggestions(),

              // Legal and Compliance
              _buildSectionHeader('Legal and Compliance'),
              _buildLegalCompliance(),

              // Data Management
              _buildSectionHeader('Data Management'),
              _buildDataManagement(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.person),
        title: Text('Display Name'),
        subtitle: Text('Logged in as $user'),
        ),
      );
  }


  Widget _buildSecurityPrivacy() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.security),
        title: Text('Account Security'),
        subtitle: Text('Password strength: Strong'),
        trailing: IconButton(
          icon: Icon(Icons.lock),
          onPressed: () {
            // Implement security settings
          },
        ),
      ),
    );
  }

  Widget _buildBillingSubscriptions(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).pushNamed(SubscriptionPage.path);
        },
        leading: Icon(Icons.credit_card),
        title: Text('Subscription'),
        subtitle: Text('Active'),
        trailing: IconButton(
          icon: Icon(Icons.payment),
          onPressed: () {
            // Implement billing and subscription settings
          },
        ),
      ),
    );
  }


  Widget _buildHelpAndSupport() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.help),
        title: Text('Help and Support'),
        subtitle: Text('FAQs, contact support'),
        trailing: IconButton(
          icon: Icon(Icons.chat),
          onPressed: () {
            // Implement help and support actions
          },
        ),
      ),
    );
  }

  Widget _buildFeedbackSuggestions() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.feedback),
        title: Text('Feedback and Suggestions'),
        subtitle: Text('Submit feedback, suggestions'),
        trailing: IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            // Implement feedback and suggestions actions
          },
        ),
      ),
    );
  }

  Widget _buildLegalCompliance() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.gavel),
        title: Text('Legal and Compliance'),
        subtitle: Text('Terms of Service, Privacy Policy'),
        trailing: IconButton(
          icon: Icon(Icons.info),
          onPressed: () {
            // Implement legal and compliance actions
          },
        ),
      ),
    );
  }

  Widget _buildDataManagement() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.data_usage),
        title: Text('Data Management'),
        subtitle: Text('Export options, data deletion request'),
        trailing: IconButton(
          icon: Icon(Icons.storage),
          onPressed: () {
            // Implement data management actions
          },
        ),
      ),
    );
  }
}