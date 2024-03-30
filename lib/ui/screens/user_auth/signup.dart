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
enum AuthMethod {Google, Apple }

class _SignUpPageState extends State<SignUpPage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController defaultStateController = TextEditingController();
  String shoppingFrequency = '1-3 times per month';
  bool additionalInfoCollected = false; // Define this variable in your stateful widget


  // Initialize it with the default method
  AuthMethod authMethod = AuthMethod.Google;

  @override
  void initState() {
    super.initState();
    // Reset text controllers and other state variables when the sign-up page is initialized
  }

  Future<String?> _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token;
  }


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
        final AuthCredential googleCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );


        // Check if the user account already exists
        final userCredential = await FirebaseAuth.instance.signInWithCredential(googleCredential);
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? true;
        var current = FirebaseAuth.instance.currentUser;
        current?.reload();

        // Check if additional information has been collected
        final userId = userCredential.user?.uid;
        final additionalInfoCollected = await isAdditionalInfoCollected(userId);

        if (isNewUser && !additionalInfoCollected) {
          String email = googleUser.email;
          // If the user is new and additional information has not been collected,
          // prompt the user to provide additional information
          _collectAdditionalInformation(userId, context, email);
        } else {
          // If the user already exists or additional information has been collected,
          // proceed with the regular sign-in flow
          final List<GoogleSignInAccount> accounts = [googleUser];
          _showGoogleAccountsDialog(context, googleSignIn, accounts);
        }
      }
    } catch (e) {
      // Handle Google sign-in errors
      print('Error signing in with Google: $e');
    }
  }


// Function to check if additional information is collected for the user
  Future<bool> isAdditionalInfoCollected(String? userId) async {
    if (userId == null) return false;

    try {
      // Get a reference to the user document in Firestore
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final userData = await userDoc.get();

      // Check if the user document exists and if additional information is present
      return userData.exists && userData['shoppingFrequency'] != null && userData['defaultState'] != null;
    } catch (e) {
      print('Error checking additional information: $e');
      return false;
    }
  }



// Function to handle the selection of shopping frequency
  void _onShoppingFrequencyChanged(String? newValue) {
    setState(() {
      shoppingFrequency = newValue!;
    });
  }

  void _collectAdditionalInformation(String? userId, BuildContext context, String? email) {
    if (userId == null) return;

    // Show a dialog to collect additional information
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Variables to store collected information
        String defaultState = '';

        // GlobalKey to access the form state
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();

        return AlertDialog(
          title:const Text('Additional Information'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown to select shopping frequency
                  DropdownButtonFormField<String>(
                    value: shoppingFrequency,
                    onChanged: _onShoppingFrequencyChanged,
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
                  // Text field to enter default state
                  TextFormField(
                    onChanged: (value) {
                      defaultState = value;
                    },
                    decoration:const InputDecoration(
                      hintText: 'Your Default State',
                      labelText: 'Enter Default State',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'State cannot be empty';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // Get FCM token
                    String? fcmToken = await _getFCMToken();

                    // Store additional information in Firestore
                    await FirebaseFirestore.instance.collection('users').doc(userId).set({
                      'shoppingFrequency': shoppingFrequency,
                      'defaultState': defaultState,
                      'token': fcmToken,
                      'email': email,
                    }, SetOptions(merge: true)); // Merge with existing data if present

                    // Update the state to indicate that additional information has been collected
                    setState(() {
                      additionalInfoCollected = true;
                    });

                    // Close the dialog
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/home');
                  } catch (e) {
                    print('Error saving additional information: $e');
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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
                padding:const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Continue with:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...accounts.map((account) {
                      return Container(
                        margin:const EdgeInsets.symmetric(vertical: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: ListTile(
                          onTap: () {
                            context.read<UserProviderLogin>().signInWithGoogle(context);
                            Navigator.pop(context);
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
                    const SizedBox(height: 20),
                    const Row(
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
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleGoogleSignUp(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: const Text(
                            'Register Another Account',
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
    } catch (e) {
      // Handle Apple sign-in errors
      print("Apple sign-in error: $e");
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
                          'Register with Google',
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
                          'Register with Apple',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'San Francisco',
                          ),
                        ),
                      ),
                    ),

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
