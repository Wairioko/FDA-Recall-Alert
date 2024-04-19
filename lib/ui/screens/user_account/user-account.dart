import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_scan/ui/screens/home/widgets/landing_page.dart';
import 'package:safe_scan/ui/screens/user_account/account_security.dart';
import 'package:safe_scan/ui/screens/user_account/feedback.dart';
import 'package:safe_scan/ui/screens/user_account/subscriptions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';


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

              // Feedback and Suggestions
              _buildSectionHeader('Feedback and Support'),
              // Implement feedback and support widgets here
              _buildFeedbackSupport(context),

              // Legal and Compliance
              _buildSectionHeader('Legal and Compliance'),
              // Implement legal and compliance widgets here
              _buildLegalCompliance(context),

              // Security and Privacy
              _buildSectionHeader('Account and Data Deletion'),
              // Implement security and privacy widgets here
              _buildSecurityPrivacy(context),

              // _buildSectionHeader('Landing Page'),
              // _buildLanding(context),

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
            return const Card(
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


  Widget _buildBillingSubscriptions(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).pushNamed(SubscriptionPage.path);
        },
        leading: Icon(Icons.credit_card),
        title: Text('Subscription'),
        subtitle: Text('Access all features'),
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

  Widget _buildSecurityPrivacy(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).pushNamed(AccountSettingsWidget.path);
        },
        leading: const Icon(Icons.security),
        title: const Text('Account Security'),
        subtitle: const Text('Delete Account'),
        trailing: IconButton(
          icon: const Icon(Icons.lock),
          onPressed: () {
            // Implement security settings
          },
        ),
      ),
    );
  }
  // Widget _buildLanding(BuildContext context) {
  //   return Card(
  //     child: ListTile(
  //       onTap: () {
  //         Navigator.of(context).pushNamed(LandingPage.path);
  //       },
  //       leading: const Icon(Icons.security),
  //       title: const Text('Landing Page'),
  //       subtitle: const Text('Kulandi'),
  //       trailing: IconButton(
  //         icon: const Icon(Icons.lock),
  //         onPressed: () {
  //           // Implement security settings
  //         },
  //       ),
  //     ),
  //   );
  // }


  Widget _buildLegalCompliance(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          launchUrlString('https://www.termsfeed.com/live/dc8eb1b0-e905-46b7-85b0-408a1dbb8604');
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
