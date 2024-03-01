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
  const LogInPage({Key? key});

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
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formkey, // Assign the GlobalKey<FormState> to the Form widget
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo
                  Container(
                      height: 250,
                      child: Image.asset('assets/image/login.png')
                  ),
                  //Hello Again
                  Text(
                    'Hello Again! ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Welcome back, you\'ve been missed! ',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  //email textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: TextFormField( // Use TextFormField instead of TextField
                          controller: email, // Provide the TextEditingController
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: 'Email',
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  //password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: TextFormField( // Use TextFormField instead of TextField
                          controller: password, // Provide the TextEditingController
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.password),
                              hintText: 'Password',
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  //signin button
                  //TODO: Replace with MaterialButton
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(300, 69),
                        primary: Colors.lightBlueAccent,
                        //padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        textStyle: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onPressed: () {moveToHome(context);},
                    child: Text('Sign In'),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Not a member?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Register Now',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),

                      )
                    ],
                  )

                  //not a member? register button
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
