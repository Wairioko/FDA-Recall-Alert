import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_scan/provider/user_provider.dart';
import 'package:provider/provider.dart';

class LoggedInPage extends StatelessWidget {
  const LoggedInPage({Key? key, user});
  static const String path = '/loggedin';

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('SAFE SCAN - Logged In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user?.email ?? 'User'}!',
              style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.bold,

              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // Clear user data from the provider
                context.read<UserProvider>().setUser(null);
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
// class LoggedInPage extends StatelessWidget {
//   const LoggedInPage({super.key, user});
//   static const String path = '/loggedin';
//
//   @override
//   Widget build(BuildContext context) {
//     User? user = FirebaseAuth.instance.currentUser;
//
//     // Check if user is already logged in
//     if (user != null) {
//       // User is logged in, navigate to home page
//       Navigator.pushReplacementNamed(context, Home.path);
//       return Container(); // This is just a placeholder; it won't be built
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('SAFE SCAN - Logged In'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Welcome, ${user?.email ?? 'User'}!',
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 await FirebaseAuth.instance.signOut();
//                 // Clear user data from the provider
//                 context.read<UserProvider>().setUser(null);
//                 Navigator.popUntil(context, ModalRoute.withName('/home'));
//               },
//               child: const Text('Log Out'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }
