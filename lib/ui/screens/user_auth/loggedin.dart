import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_scan/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:safe_scan/ui/screens/home/home.dart';
// import '../models/user_data.dart';
//
// class LoggedInWidget extends StatefulWidget {
//   static const String path = '/login';
//   const LoggedInWidget({Key? key}) : super(key: key);
//   @override
//   State<LoggedInWidget> createState() => _LoggedInWidgetState();
// }
// class _LoggedInWidgetState extends State<LoggedInWidget> {
//   final FirebaseAuth firebaseAuth=FirebaseAuth.instance;
//   updateData()async{
//     UserProvider userProvider=Provider.of(context,listen: false);
//     await userProvider.refreshUser();
//   }
//   String? accountType;
//   @override
//   void initState() {
//     super.initState();
//     updateData();
//   }
//   @override
//   Widget build(BuildContext context) {
//     UserData? userData=Provider.of<UserProvider>(context).getUser;
//     final user=FirebaseAuth.instance.currentUser!;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Logged In',style: TextStyle(color: Colors.white),),
//         centerTitle: true,
//         backgroundColor: Colors.black87,
//         actions: [
//           TextButton(onPressed: (){
//             final provider= Provider.of<GoogleSignInProvider>(context,listen:false);
//             provider.logout();
//           }, child: const Text('Logout'))
//         ],
//       ),
//       body: Container(
//         alignment: Alignment.center,
//         color: Colors.blueGrey.shade900,
//         child:  Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('Profile',
//               style: TextStyle(fontSize: 24,color: Colors.white),
//             ),
//             const SizedBox(height: 32,),
//             CircleAvatar(
//               radius: 40,
//               backgroundImage: NetworkImage(user.photoURL??""),
//             ),
//             const SizedBox(height: 8,),
//             const SizedBox(height: 8,),
//             Text(
//               user.displayName==null?
//               'Name: ${userData?.name}' :'Name: ${user.displayName}',
//               style:const TextStyle(color: Colors.white,fontSize: 16),
//             ),
//             const SizedBox(height: 8,),
//             Text(
//               'Email: ${user.email}',
//               style:const TextStyle(color:Colors.white,fontSize: 16),
//             ),
//             Text(
//               'uid: ${user.uid}',
//               style:const TextStyle(color:Colors.white,fontSize: 16),
//             ),
//             Text(
//               'account type: ${userData?.accountType}',
//               style:const TextStyle(color:Colors.white,fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//
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
