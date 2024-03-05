import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe_scan/ui/screens/user_auth/login.dart';
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




String shoppingFrequencyHintText = "";
class SignUpPage extends StatefulWidget {
  static const String path = '/signup';

  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController defaultStateController = TextEditingController();
  String shoppingFrequency = '';

  MoveToLog() async {
    if (formkey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text,
          password: password.text.trim(),
        ).then((value) async {
          await FirebaseFirestore.instance.collection('user-registration-data').doc(value.user?.uid).set({
            'email': email.text,
            'defaultState': defaultStateController.text,
            'shoppingFrequency': shoppingFrequency,
          });

          Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInPage()));
        });
      } on FirebaseAuthException catch (e) {
        // Handle authentication exceptions
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    List<String> shoppingFrequencyOptions = [
      '1-3 times per month',
      '4-6 times per month',
      '7+ times per month'
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 10.0),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          suffixIcon: const Icon(Icons.mail),
                          hintText: "username@gmail.com",
                          labelText: "Enter Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
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
                          suffixIcon: const Icon(Icons.lock),
                          hintText: "Abcd@54#87",
                          labelText: "Enter Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
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
                        controller: defaultStateController,
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.location_on),
                          hintText: "Your Default State",
                          labelText: "Enter Default State",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "To Enable Notifications For Your State";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButton<String>(
                        // ... other properties

                        value: shoppingFrequency.isEmpty
                            ? null // Assign null if shoppingFrequency is empty
                            : shoppingFrequency,
                        items: shoppingFrequencyOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value, // Ensure values are unique
                            child: Text(value, ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              shoppingFrequency = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    FractionallySizedBox(
                      widthFactor: 0.87,
                      child: ElevatedButton(
                        onPressed: () {
                          MoveToLog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'SF Pro Text',
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          "Create Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Space above the "OR" line
                    Center(
                      child: Text(
                        '--------------------OR--------------------',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible( // Wrap the entire Row with Flexible
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () {},
                              icon: FaIcon(FontAwesomeIcons.google),
                              label: Text(
                                'Sign up Google',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'SF Pro Text',
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10), // Add space between buttons
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () {},
                              icon: FaIcon(
                                FontAwesomeIcons.apple,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Sign up Apple',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SF Pro Text',
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),


                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
