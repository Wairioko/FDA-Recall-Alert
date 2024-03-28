import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<void> signInWithGoogle() async {

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      await googleSignIn.signOut();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        setUser(FirebaseAuth.instance.currentUser);
      }
    } catch (e) {
      print(e.toString());
    }
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

  Future<void> signInWithEmail(BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      setUser(FirebaseAuth.instance.currentUser);
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text("Please Enter A Valid Email"),
            );
          },
        );
      } else if (e.code == "wrong-password") {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text("Wrong Password"),
            );
          },
        );
      }
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
  bool _obscurePassword = true;

  // void moveToHome(BuildContext context) async {
  //   if (formkey.currentState!.validate()) {
  //     try {
  //       await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: email.text,
  //         password: password.text,
  //       );
  //       context.read<UserProviderLogin>().setUser(FirebaseAuth.instance.currentUser);
  //       Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == "invalid-email") {
  //         return showDialog(
  //           context: context,
  //           builder: (context) {
  //             return const AlertDialog(
  //               content: Text("Please Enter A Valid Email"),
  //             );
  //           },
  //         );
  //       } else if (e.code == "wrong-password") {
  //         return showDialog(
  //           context: context,
  //           builder: (context) {
  //             return const AlertDialog(
  //               content: Text("Wrong Password"),
  //             );
  //           },
  //         );
  //       }
  //     }
  //   }
  // }

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
                          "Safe Recall",
                          style: GoogleFonts.lato(fontSize: 50.0, color: Colors.blue),
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
                          context.read<UserProviderLogin>().signInWithGoogle();
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Home()));
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
                            Navigator.pushNamed(context, '/signup');
                          },
                          child:const Text(
                            ' Sign up',
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

