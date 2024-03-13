import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_scan/ui/screens/user_account/account_security.dart';
import 'package:safe_scan/ui/screens/user_account/feedback.dart';
import 'package:safe_scan/ui/screens/user_account/subscriptions.dart';
import 'package:safe_scan/ui/screens/user_account/terms_of_service.dart';


class UserAccountPage extends StatelessWidget {
  static const String path = '/user-account';

  const UserAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Information
              _buildSectionHeader('Profile Information'),
              _buildProfileInfo(),

              // Billing and Subscriptions
              _buildSectionHeader('Billing and Subscriptions'),
              // Implement billing and subscription widgets here
              _buildBillingSubscriptions(context),

              // Security and Privacy
              _buildSectionHeader('Security and Privacy'),
              // Implement security and privacy widgets here
              _buildSecurityPrivacy(context),

              // Feedback and Suggestions
              _buildSectionHeader('Feedback and Support'),
              // Implement feedback and support widgets here
              _buildFeedbackSupport(context),

              // Legal and Compliance
              _buildSectionHeader('Legal and Compliance'),
              // Implement legal and compliance widgets here
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
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while waiting for the user data
            return CircularProgressIndicator();
          }

          // Check if the user is logged in
          if (snapshot.hasData) {
            // User is logged in, display user information
            User? user = snapshot.data;
            String? email = user?.email;

            return Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  'Display Name',
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                subtitle: Text(
                  'Logged in as ${email ?? 'Unknown'}',
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),
            );
          } else {
            // User is not logged in
            return Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  'Display Name',
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                subtitle: Text(
                  'Not logged in',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),
            );
          }
        }
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
          // Navigator.of(context).pushNamed(SubscriptionPage.path);
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
