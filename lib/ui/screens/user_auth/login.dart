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
import 'package:safe_scan/ui/screens/user_auth/signup.dart';

class UserProviderLogin extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
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

  void moveToHome(BuildContext context) async {
    if (formkey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text,
          password: password.text,
        );
        context.read<UserProviderLogin>().setUser(FirebaseAuth.instance.currentUser);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
      } on FirebaseAuthException catch (e) {
        if (e.code == "invalid-email") {
          return showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: Text("Please Enter A Valid Email"),
              );
            },
          );
        } else if (e.code == "wrong-password") {
          return showDialog(
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
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProviderLogin(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 50),
                        Text(
                          'Safe Recall',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.blue,
                            fontSize: 50,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Keeping you and your family safe',
                          style: TextStyle(fontSize: 20, fontFamily: 'SF Pro Text'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'One Scan at a time!',
                          style: TextStyle(fontSize: 20, fontFamily: 'SF Pro Text'),
                        ),
                        SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: TextFormField(
                                controller: email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  hintText: 'Email',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: TextFormField(
                                controller: password,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.password),
                                  hintText: 'Password',
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        FractionallySizedBox(
                          widthFactor: 0.87,
                          child: ElevatedButton(
                            onPressed: () {
                              moveToHome(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                fontFamily: 'SF Pro Text',
                              ),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              "Login",
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
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    context.read<UserProviderLogin>().signInWithGoogle();
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                                  },
                                  icon: FaIcon(FontAwesomeIcons.google),
                                  label: Text(
                                    'Sign in Google',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'SF Pro Text',
                                    ),
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    context.read<UserProviderLogin>().signInWithApple(context);
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                                  },
                                  icon: FaIcon(
                                    FontAwesomeIcons.apple,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Sign in Apple',
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
                        SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Not a member?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'SF Pro Text',
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(
                                'Register Now',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontFamily: 'SF Pro Text',
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
            ],
          ),
        ),
      ),
    );
  }
}
