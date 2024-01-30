// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:project1/models/user_data.dart';
//
// class AuthMethods{
//   final FirebaseAuth _auth= FirebaseAuth.instance;
//   final FirebaseFirestore _fireStore=FirebaseFirestore.instance;
//   Future<String> registerUser({
//     required String email,
//     required String password,
//
//
//   })async{
//     String resp="Some Error occurred";
//     try{
//       UserCredential credential=await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       await sendEmailVerification();
//       UserData userData=UserData(
//         name: name,
//         uid: credential.user!.uid,
//         lastName: lastName,
//         email: email,
//         accountType: accountType,
//       );
//       await _fireStore.collection('Users').doc(credential.user!.uid).set(
//           userData.toJson()
//       );
//       resp='success';
//
//     }catch(err){
//       resp=err.toString();
//     }
//     return resp;
//   }
//   Future<void> sendEmailVerification() async {
//     User? user = FirebaseAuth.instance.currentUser;
//
//     if (user != null && !user.emailVerified) {
//       await user.sendEmailVerification();
//     }
//   }
//
//   Future<String> loginUser({
//     required String email,
//     required String password,
//   })async{
//     String res="some error occurred";
//     try{
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       if (!userCredential.user!.emailVerified) {
//         // User's email is not verified, handle it accordingly
//         // You might want to show a message or navigate to a screen prompting the user to verify their email
//         res = "Email not verified";
//       } else {
//         res = "success";
//       }
//     }catch(e){
//       res=e.toString();
//     }
//     return res;
//   }
//
//   Future<UserData> getUserDetails()async{
//     User currentUser=_auth.currentUser!;
//     DocumentSnapshot snap=
//     await _fireStore
//         .collection('Users')
//         .doc(currentUser.uid)
//         .get();
//     return UserData.fromSnap(snap);
//   }
//
// }