import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_scan/ui/screens/user_account/account_security.dart';
import 'package:safe_scan/ui/screens/user_account/feedback.dart';
import 'package:safe_scan/ui/screens/user_account/subscriptions.dart';
import 'package:safe_scan/ui/screens/user_account/terms_of_service.dart';

User? user = FirebaseAuth.instance.currentUser;
var email = user?.email;

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

              // Billing and Subscriptions
              _buildSectionHeader('Billing and Subscriptions'),
              _buildBillingSubscriptions(context),

              // Security and Privacy
              _buildSectionHeader('Security and Privacy'),
              _buildSecurityPrivacy(context),

              // Feedback and Suggestions
              _buildSectionHeader('Feedback and Support'),
              _buildFeedbackSupport(context),

              // Legal and Compliance
              _buildSectionHeader('Legal and Compliance'),
              _buildLegalCompliance(context),

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
        title: Text('Display Name' ,style: TextStyle(
          fontFamily: 'SF Pro Text',
          ),
        ),
        subtitle: Text('Logged in as $email', style: TextStyle(
          color: Colors.green,
          fontFamily: 'SF Pro Text',
        ),
        ),
        ),
      );
  }


  Widget _buildSecurityPrivacy(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).pushNamed(AccountSettingsWidget.path);
        },
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


  Widget _buildFeedbackSupport(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.feedback),
        title: Text('Feedback and Support'),
        subtitle: Text('Submit feedback, suggestions'),
        onTap: () {
          Navigator.of(context).pushNamed(FeedbackForm.path);
        },
        trailing: IconButton(
          icon: Icon(Icons.chat),
          onPressed: () {
            // Implement feedback and suggestions actions
          },
        ),
      ),
    );
  }

  Widget _buildLegalCompliance(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).pushNamed(TermsOfServicePage.path);
        },
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

}