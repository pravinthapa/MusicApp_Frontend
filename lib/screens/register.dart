
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/square_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_services.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers

  final emailController = TextEditingController();
  final _firstNameContoller = TextEditingController();
  final _lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  // sign user in method
  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try sign up
    if (passwordController.text != confirmpasswordController.text) {
      Navigator.pop(context);
      showErrorMessage("Passwords do not match");
      return;
    }
    try {
      //create user
      UserCredential result =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      String uid = result.user!.uid;

      //add userdetails
      addUserDetails(_firstNameContoller.text.trim(), _lastNameController.text.trim(), emailController.text.trim(), uid);

      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);
      // WRONG EMAIL
      showErrorMessage(e.code);
    }
  }

  Future addUserDetails(String firstname, String lastname, String email, String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'first name': firstname,
      'last name' : lastname,
      'email' : email,
      'uid': uid,
    });
  }

  // wrong email message popup
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.pink,
          title: Center(
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: AutofillGroup(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  // logo
                  const Icon(
                    Icons.app_registration,
                    color: Colors.deepPurple,
                    size: 50,
                  ),

                  const SizedBox(height: 50),

                  // welcome back, you've been missed!
                  Text(
                    'Time to sign you up!',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // username textfield
                  MyTextField(
                    controller: _firstNameContoller,
                    hintText: 'First Name',
                    obscureText: false,
                    autofill: AutofillHints.givenName,
                  ),
                  const SizedBox(height: 10),
                  // username textfield
                  MyTextField(
                    controller: _lastNameController,
                    hintText: 'Last name',
                    obscureText: false,
                    autofill: AutofillHints.familyName,
                  ),
                  const SizedBox(height: 10),
                  // username textfield
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    autofill: AutofillHints.email,

                  ),

                  const SizedBox(height: 10),

                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    autofill: AutofillHints.password,

                  ),
                  const SizedBox(height: 10),

                  // password textfield
                  MyTextField(
                    controller: confirmpasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                    autofill: AutofillHints.password,

                  ),

                  const SizedBox(height: 25),

                  // sign in button
                  MyButton(
                      onTap: signUserUp,
                      name: "Sign Up",
                      color: Colors.deepPurple.shade400),

                  const SizedBox(height: 50),

                  // or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // google + apple sign in buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // google button
                      GestureDetector(
                          onTap: () => AuthService().signInWithGoogle(),
                          child: SquareTile(imagePath: 'images/google.png')),
                      //
                      // SizedBox(width: 25),
                      //
                      // // apple button
                      // SquareTile(imagePath: 'images/apple.png')
                    ],
                  ),

                  const SizedBox(height: 30),

                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
