import 'package:safe_scan/ui/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safe_scan/ui/screens/user_auth/signup.dart';
import 'package:safe_scan/provider/user_provider.dart';

class LogInPage extends StatelessWidget {
  static const String path = '/login';
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>();
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();

    void moveToHome(BuildContext context) async {
      if (formkey.currentState!.validate()) {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email.text, password: password.text);
          context.read<UserProvider>().setUser(FirebaseAuth.instance.currentUser);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('SAFE SCAN'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              children: [
                const SizedBox(
                  height: 50.0,
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                  child: SvgPicture.asset(
                    "assets/Images/LogIn.svg",
                    height: 200.0,
                    width: 200.0,
                    // fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                  child: Container(
                    child: Text(
                      "Log In",
                      style: GoogleFonts.lato(fontSize: 50.0, color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                        suffixIcon: const Icon(CupertinoIcons.mail),
                        hintText: "username@gmail.com",
                        labelText: "Enter Email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Email Can Not Be Empty";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: TextFormField(
                    obscureText: true,
                    controller: password,
                    decoration: InputDecoration(
                        suffixIcon: const Icon(CupertinoIcons.lock),
                        hintText: "Abcd@54#87",
                        labelText: "Enter Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Password Can Not Be Empty";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    moveToHome(context);
                  },
                  child: const Text(
                    "Log In",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const SignUpPage())),
                  child: const Text("Create An Account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}