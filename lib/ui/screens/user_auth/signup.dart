import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe_scan/ui/screens/user_auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../home/home.dart';


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
// Define a variable to track the authentication method
enum AuthMethod { EmailPassword, Google, Apple }

class _SignUpPageState extends State<SignUpPage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController defaultStateController = TextEditingController();
  String shoppingFrequency = '1-3 times per month';

  // Initialize it with the default method
  AuthMethod authMethod = AuthMethod.EmailPassword;

  Future<String?> _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token;
  }


  void _handleGoogleSignUp() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        authMethod = AuthMethod.Google;
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential google_credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(google_credential);
        // Call the method to collect additional information
        _collectAdditionalInformation(); // Added this line
      } else {
        // Handle Google sign-in cancellation
      }
    } catch (e) {
      // Handle Google sign-in errors
      print("Google sign-in error: $e");
    }
  }

  void _handleAppleSignUp() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'your_client_id',
          redirectUri: Uri.parse('https://your-redirect-url.com'),
        ),
      );
      authMethod = AuthMethod.Apple;
      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential apple_credential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      await FirebaseAuth.instance.signInWithCredential(apple_credential);
      // Call the method to collect additional information
      _collectAdditionalInformation(); // Added this line
    } catch (e) {
      // Handle Apple sign-in errors
      print("Apple sign-in error: $e");
    }
  }

  void _collectAdditionalInformation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Additional Information'),
          content: Form(
            key: formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add other form fields here
                TextFormField(
                  controller: defaultStateController,
                  decoration: const InputDecoration(
                    hintText: "Your Default State",
                    labelText: "Enter Default State",
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "State cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: shoppingFrequency,
                  onChanged: (String? newValue) {
                    setState(() {
                      shoppingFrequency = newValue!;
                    });
                  },
                  items: const [
                    // Dropdown menu items
                    DropdownMenuItem(
                      value: '1-3 times per month',
                      child: Text('1-3 times per month'),
                    ),
                    DropdownMenuItem(
                      value: '4-6 times per month',
                      child: Text('4-6 times per month'),
                    ),
                    DropdownMenuItem(
                      value: '7+ times per month',
                      child: Text('7+ times per month'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Shopping Frequency',
                    hintText: 'Select Shopping Frequency',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select shopping frequency';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formkey.currentState!.validate()) {
                  // Save the additional information to Firebase or any other storage
                  // For example:
                  final user = FirebaseAuth.instance.currentUser;

                  FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
                    'email':user.email,
                    'defaultState': defaultStateController.text,
                    'shoppingFrequency': shoppingFrequency,
                    'token': _getFCMToken,
                  });
                  // Close the dialog
                  Navigator.of(context).pop();
                  // Proceed with other actions
                  // For example, navigate to another screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  const Home()
                  )
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }




  MoveToLog() async {
    if (formkey.currentState!.validate()) {
      if (authMethod == AuthMethod.EmailPassword && (email.text.isEmpty || password.text.isEmpty)) {
        // Email and password fields are required for traditional sign-up method
        return;
      }

      try {
        if (authMethod == AuthMethod.EmailPassword) {
          // Perform email/password sign-up
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.text,
            password: password.text.trim(),
          );
        }

        // Save additional information to Firebase or any other storage
        final user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'email': user.email,
          'defaultState': defaultStateController.text,
          'shoppingFrequency': shoppingFrequency,
        });

        // Navigate to the login page
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInPage()));
      } catch (e) {
        // Handle authentication exceptions
        print(e.toString());
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

    // Boolean variables to track if email and password fields should be visible
    bool showEmailAndPassword = true;

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
                    // Conditional rendering of email and password fields
                    if (showEmailAndPassword)
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
                              onPressed: _handleGoogleSignUp,
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
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: _handleAppleSignUp,
                              icon: const FaIcon(
                                FontAwesomeIcons.apple,
                                color: Colors.white,
                              ),
                              label: const Text(
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
