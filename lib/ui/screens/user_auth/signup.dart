import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../home/home.dart';
import 'login.dart';


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


  // void _showSnackBar(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //     ),
  //   );
  // }

  void _handleGoogleSignUp(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      // Sign out the current user to allow selecting from other accounts
      await googleSignIn.signOut();
      // Proceed with sign-in
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // No active Google accounts found
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No active Google accounts found'),
        ));
      } else {
        final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
        final AuthCredential google_credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        // Check if the user account already exists
        final userCredential = await FirebaseAuth.instance.signInWithCredential(google_credential);
        if (userCredential.additionalUserInfo?.isNewUser ?? true) {
          // If the user is a new user, save details to Firestore
          _saveUserDetailsToFirestore();
        } else {
          // If the user already exists, show account dialog
          final List<GoogleSignInAccount> accounts = [googleUser];
          _showGoogleAccountsDialog(context, googleSignIn, accounts);
        }
      }
    } catch (e) {
      // Handle Google sign-in errors
      print('Error signing in with Google: $e');
    }
  }



  void _saveUserDetailsToFirestore() {
    // Call the method to collect additional information
    _collectAdditionalInformation();
  }


  void _showGoogleAccountsDialog(BuildContext context, GoogleSignIn googleSignIn, List<GoogleSignInAccount> accounts) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue with:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ...accounts.map((account) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: ListTile(
                          onTap: () {
                            context.read<UserProviderLogin>().signInWithGoogle();
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => Home()));
                          },
                          title: Text(
                            '${account.email}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                          leading: Icon(Icons.account_circle),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            height: 36,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'OR',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            height: 36,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleGoogleSignUp(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: const Text(
                            'Register With Another Account',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
      // Save user details to Firestore
      _saveUserDetailsToFirestore();
    } catch (e) {
      // Handle Apple sign-in errors
      print("Apple sign-in error: $e");
    }
  }


  void _collectAdditionalInformation() {
    BuildContext parentContext = context; // Store the context

    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        final GlobalKey<FormState> secondFormKey = GlobalKey<FormState>();

        return AlertDialog(
          title: Text('Additional Information'),
          content: Form(
            key: secondFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: shoppingFrequency,
                  onChanged: (String? newValue) {
                    setState(() {
                      shoppingFrequency = newValue!;
                    });
                  },
                  items: const [
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
              onPressed: () async {
                if (secondFormKey.currentState!.validate()) {
                  final user = FirebaseAuth.instance.currentUser;
                  final token = await _getFCMToken();

                  // Use the stored parentContext here
                  FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
                    'email': user?.email,
                    'defaultState': defaultStateController.text,
                    'shoppingFrequency': shoppingFrequency,
                    'token': token,
                  }).then((_) {
                    Navigator.of(parentContext).pop(); // Use parentContext to close dialog
                    Navigator.push(parentContext, MaterialPageRoute(builder: (context) => const Home()));
                  }).catchError((error) {
                    print('Error saving data to Firestore: $error');
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                      child: Container(
                        child: Text(
                          "Safe Recall",
                          style: GoogleFonts.lato(fontSize: 50.0, color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Keeping you and your family safe',
                      style: TextStyle(fontSize: 20, fontFamily: 'San Francisco'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'One Scan at a time!',
                      style: TextStyle(fontSize: 20, fontFamily: 'San Francisco'),
                    ),
                    SizedBox(height: 50), // Reduced the height
                    SizedBox(
                      width: double.infinity, // Make the button as wide as possible
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          _handleGoogleSignUp(context);
                        },
                        icon: FaIcon(FontAwesomeIcons.google),
                        label: Text(
                          'Sign up with Google',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'San Francisco',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'OR',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 20), // Adjusted gap between buttons
                    SizedBox(
                      width: double.infinity,
                      // Make the button as wide as possible
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          _handleAppleSignUp();
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.apple,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Sign up with Apple',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'San Francisco',
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 20),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: TextFormField(
                    //     controller: defaultStateController,
                    //     decoration: InputDecoration(
                    //       suffixIcon: const Icon(Icons.location_on),
                    //       labelText: "Enter Home State",
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(30),
                    //       ),
                    //     ),
                    //     validator: (value) {
                    //       if (value!.isEmpty) {
                    //         return "To Enable Notifications For Your State";
                    //       }
                    //       return null;
                    //     },
                    //   ),
                    // ),
                    // const SizedBox(height: 16),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: DropdownButton<String>(
                    //     // ... other properties
                    //
                    //     value: shoppingFrequency.isEmpty
                    //         ? null // Assign null if shoppingFrequency is empty
                    //         : shoppingFrequency,
                    //     items: shoppingFrequencyOptions.map((String value) {
                    //       return DropdownMenuItem<String>(
                    //         value: value, // Ensure values are unique
                    //         child: Text(value, ),
                    //       );
                    //     }).toList(),
                    //     onChanged: (String? newValue) {
                    //       if (newValue != null) {
                    //         setState(() {
                    //           shoppingFrequency = newValue;
                    //         });
                    //       }
                    //     },
                    //   ),
                    // ),
                    const SizedBox(height: 40), // Space above the "OR" line
                    const Center(
                      child: Text(
                        '------------------Login------------------',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 40), // Adjusted gap
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already a member?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'San Francisco',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child:const Text(
                            ' Sign In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontFamily: 'San Francisco',
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
