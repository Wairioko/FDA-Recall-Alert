import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      if (authResult.additionalUserInfo?.isNewUser ?? true) {
        Navigator.pushNamed(context, '/signup');
      } else {
        setUser(authResult.user);
        Navigator.pushNamed(context, '/home');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error signing in with Google: $e');
    }
  }

  Future<void> signInWithEmailAndPassword(BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      setUser(FirebaseAuth.instance.currentUser);
      Navigator.pushNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, e.message ?? 'Unknown error occurred');
    }
  }

  Future<bool> checkIfUserIsRegistered(GoogleSignInAccount googleUser) async {
    String userUid = googleUser.id;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: userUid)
        .get();

    bool userExists = querySnapshot.docs.isNotEmpty;

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
        scopes: [AppleIDAuthorizationScopes.email],
      );

      final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
      final AuthCredential authCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(authCredential);

      setUser(FirebaseAuth.instance.currentUser);
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSuccessDialog(context, 'Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, e.message ?? 'Unknown error occurred');
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    setUser(null);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Enter your email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  resetPassword(context, emailController.text.trim());
                } else {
                  _showErrorDialog(context, 'Please enter your email to reset password');
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
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
  bool showLoginForm = false;

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
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Text(
                          "FDA Recall Alert",
                          style: GoogleFonts.lato(fontSize: 40.0, color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Keeping you and your family safe',
                      style: TextStyle(fontSize: 20, fontFamily: 'SF Pro Text'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'One Scan at a time!',
                      style: TextStyle(fontSize: 20, fontFamily: 'San Francisco'),
                    ),
                    const SizedBox(height: 20),
                    if (showLoginForm) ...[
                      TextFormField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: password,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formkey.currentState!.validate()) {
                              context.read<UserProviderLogin>().signInWithEmailAndPassword(
                                context,
                                email.text.trim(),
                                password.text.trim(),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.envelope),
                              SizedBox(width: 10),
                              Text('Sign in'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          context.read<UserProviderLogin>()._showForgotPasswordDialog(context);
                        },
                        child: Text('Forgot Password?'),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showLoginForm = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.envelope),
                              SizedBox(width: 10),
                              Text('Sign in with Email',
                                style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'San Francisco',
                              ),),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'OR',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                    ],
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        '----------------Register----------------',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 30),
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
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: 16,
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




// SizedBox(height: 20), // Adjusted gap between buttons
// SizedBox(
// width: double.infinity,
// // Make the button as wide as possible
// child: ElevatedButton.icon(
// style: ElevatedButton.styleFrom(
// backgroundColor: Colors.black,
// padding: const EdgeInsets.symmetric(
// horizontal: 20, vertical: 12),
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(30.0),
// ),
// ),
// onPressed: () {
// context.read<UserProviderLogin>().signInWithApple(
// context);
// Navigator.push(context, MaterialPageRoute(
// builder: (context) => Home()));
// },
// icon: const FaIcon(
// FontAwesomeIcons.apple,
// color: Colors.white,
// ),
// label: const Text(
// 'Sign in with Apple',
// style: TextStyle(
// color: Colors.white,
// fontFamily: 'San Francisco',
// ),
// ),
// ),
// ),