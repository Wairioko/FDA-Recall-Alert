import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safe_scan/ui/screens/user_auth/signup.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safe_scan/ui/screens/home/home.dart';


class UserProviderLogin extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in process
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the Google credential
      final authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      final isNewUser = authResult.additionalUserInfo?.isNewUser ?? true;

      if (isNewUser) {
        // Redirect to the signup page if the user is new
        Navigator.pushNamed(context, '/signup');
      } else {
        // Update authentication state
        setUser(authResult.user);

        // Redirect to the home page upon successful authentication
        Navigator.pushNamed(context, '/home'); // Replace '/home' with your home page route
      }
    } catch (e) {
      // Handle sign-in errors
      if (e.toString().contains('Bad state: User is no longer signed in')) {
        // Handle token expiration or user no longer signed in
        print('User is no longer signed in. Please try signing in again.');
        // You may want to show a snackbar or dialog to inform the user
      } else {
        // For other errors, log the error and handle it accordingly
        print('Error signing in with Google: $e');
      }
    }
  }


  Future<bool> checkIfUserIsRegistered(GoogleSignInAccount googleUser) async {
    // Get the UID (unique identifier) of the Google user
    String userUid = googleUser.id;

    // Query Firestore to check if the user's UID exists in the 'users' collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: userUid)
        .get();

    // Check if any documents match the query
    bool userExists = querySnapshot.docs.isNotEmpty;

    // Print statement based on whether matches were found or not
    if (userExists) {
      print('Matches found');
    } else {
      print('No matches found');
    }

    return userExists;
  }


  Future<void> signInWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
      final AuthCredential authCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(authCredential);

      setUser(FirebaseAuth.instance.currentUser);
    } catch (e) {
      print(e.toString());
    }
  }


  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    setUser(null);
  }
}





class LogInPage extends StatefulWidget {
  static const String path = '/login';
  const LogInPage({Key? key}) : super(key: key);

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                          "FDA Recall Alert",
                          style: GoogleFonts.lato(fontSize: 40.0, color: Colors.blue),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Keeping you and your family safe',
                      style: TextStyle(fontSize: 20, fontFamily: 'SF Pro Text'),
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
                          context.read<UserProviderLogin>().signInWithGoogle(context);


                        },
                        icon: FaIcon(FontAwesomeIcons.google),
                        label: Text(
                          'Sign in with Google',
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
                          context.read<UserProviderLogin>().signInWithApple(
                              context);
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Home()));
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.apple,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Sign in with Apple',
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
                        '----------------Register----------------',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 40), // Adjusted gap
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Not a member?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'San Francisco',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, 'signup');
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0), // Adjust padding here
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontFamily: 'San Francisco',
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

