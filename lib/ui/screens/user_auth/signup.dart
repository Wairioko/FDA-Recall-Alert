import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_news/ui/screens/user_auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserModel {
  String defaultState;
  String shoppingFrequency;

  UserModel({required this.defaultState, required this.shoppingFrequency});

  // Convert UserModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      'defaultState': defaultState,
      'shoppingFrequency': shoppingFrequency,
    };
  }
}




String shoppingFrequencyHintText = "How often do you shop";
class SignUpPage extends StatelessWidget {
  static const String path = '/signup';

  const SignUpPage({Key? key});
  //

  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>();
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    TextEditingController defaultStateController = TextEditingController();
    String shoppingFrequency = ''; // Added variable to store shopping frequency

    MoveToLog() async {
      if (formkey.currentState!.validate()) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.text,
            password: password.text.trim(),
          ).then((value) async {
            await FirebaseFirestore.instance.collection('users').doc(value.user?.uid).set({
              'email': email.text,
              'defaultState': defaultStateController.text,
              'shoppingFrequency': shoppingFrequency,
            });

          //   Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInPage()));
          // });
            // // Save user's default state and shopping frequency to database or other storage
            // UserModel newUser = UserModel(
            //   defaultState: defaultStateController.text,
            //   shoppingFrequency: shoppingFrequency,
            // );
            // // TODO: Save newUser to your storage mechanism (e.g., Firebase Firestore)
            // // Save additional data to Firestore
            // await FirebaseFirestore.instance.collection('user_registration_data').doc
            //   (value.user?.uid).set(newUser.toMap());

            Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInPage()));
          });
        } on FirebaseAuthException catch (e) {
          // Handle authentication exceptions
        }
      }
    }

    // List of shopping frequency options
    List<String> shoppingFrequencyOptions = [
      'Multiple times each week',
      'Every 2 weeks',
      'After 3 weeks',
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 10.0),
          child: Form(
            key: formkey,
            child: Column(
              children: [
                SvgPicture.asset(
                  "assets/Images/referal.svg",
                  height: 300.0,
                  width: 300.0,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                  child: Container(
                    child: Text(
                      "Register",
                      style: GoogleFonts.lato(fontSize: 50.0, color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(CupertinoIcons.mail),
                      hintText: "username@gmail.com",
                      labelText: "Enter Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Email Can Not Be Empty";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: TextFormField(
                    obscureText: true,
                    controller: password,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(CupertinoIcons.padlock),
                      hintText: "Abcd@54#87",
                      labelText: "Enter Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password Can Not Be Empty";
                      } else if (value.length < 6) {
                        return "Password Should Be Greater Than 6 Digits";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: TextFormField(
                    obscureText: true,
                    controller: defaultStateController,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(CupertinoIcons.location),
                      hintText: "Your Default State",
                      labelText: "Enter Default State",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Setting Your Home State Helps In Curating Recalls Based on You State";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Dropdown for shopping frequency
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButton<String>(
                    dropdownColor: Colors.grey[300],
                    underline: const SizedBox(),
                    hint: Text(
                      shoppingFrequencyHintText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    items: shoppingFrequencyOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // Update shopping frequency when selected
                        shoppingFrequency = newValue;
                      }
                    },
                  ),
                ),

                // ... (existing code)

                ElevatedButton(
                  onPressed: () {
                    MoveToLog();
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInPage())),
                  child: const Text("Log In"),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




// import 'dart:developer';
// import 'package:daily_news/ui/screens/user_auth/login.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// class SignUpPage extends StatelessWidget {
//   static const String path = '/signup';
//   const SignUpPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final formkey = GlobalKey<FormState>();
//     TextEditingController email = TextEditingController();
//     TextEditingController password = TextEditingController();
//     MoveToLog() async {
//       if (formkey.currentState!.validate()) {
//         try {
//           await FirebaseAuth.instance
//               .createUserWithEmailAndPassword(
//               email: email.text, password: password.text.trim())
//               .then((value) => Navigator.push(context,
//               MaterialPageRoute(builder: (context) => const LogInPage())));
//         } on FirebaseAuthException catch (e) {
//           if (e.code == "invalid-email") {
//             showDialog(
//               context: context,
//               builder: (context) {
//                 return const AlertDialog(
//                   content: Text("Please Enter A Valid Email"),
//                 );
//               },
//             );
//           } else if (e.code == "weak-password") {
//             showDialog(
//               context: context,
//               builder: (context) {
//                 return const AlertDialog(
//                   content: Text("PLease Enter A Strong Password"),
//                 );
//               },
//             );
//           }
//           log(e.code);
//         }
//       }
//     }
//
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Form(
//             key: formkey,
//             child: Column(children: [
//               SvgPicture.asset(
//                 "assets/Images/referal.svg",
//                 height: 300.0,
//                 width: 300.0,
//                 fit: BoxFit.cover,
//               ),
//               const SizedBox(
//                 height: 30,
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
//                 child: Container(
//                   // alignment: Alignment.center,
//                   child: Text(
//                     "Register",
//                     style: GoogleFonts.lato(fontSize: 50.0, color: Colors.blue),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//                 child: TextFormField(
//                   controller: email,
//                   decoration: InputDecoration(
//                       suffixIcon: const Icon(CupertinoIcons.mail),
//                       hintText: "username@gmail.com",
//                       labelText: "Enter Email",
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10))),
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return "Email Can Not Be Empty";
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//                 child: TextFormField(
//                   obscureText: true,
//                   controller: password,
//                   decoration: InputDecoration(
//                       suffixIcon: const Icon(CupertinoIcons.padlock),
//                       hintText: "Abcd@54#87",
//                       labelText: "Enter Password",
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10))),
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return "Password Can Not Be Empty";
//                     } else if (value.length < 6) {
//                       return "Password Should Be Greater Then 6 Digits";
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
//                 child: TextFormField(
//                   obscureText: true,
//                   decoration: InputDecoration(
//                       suffixIcon: const Icon(CupertinoIcons.lock),
//                       hintText: "Abcd@54#87",
//                       labelText: "Confirm Password",
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10))),
//                   validator: (value) {
//                     if (value != password.text) {
//                       return "Confirm Password Is Not Same As Password";
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(
//                 height: 10.0,
//               ),
//               ElevatedButton(
//                   onPressed: () {
//                     MoveToLog();
//                   },
//                   child: const Text(
//                     "Sign Up",
//                     style: TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold),
//                   )),
//               TextButton(
//                   onPressed: () => Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => const LogInPage())),
//                   child: const Text("Log In")),
//               const SizedBox(
//                 height: 10.0,
//               )
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
// }