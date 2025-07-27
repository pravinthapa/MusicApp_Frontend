import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  // wrong email message popup
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  Future resetpassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      print('Email reset sent');
    }  on FirebaseAuthException catch(e) {
      showErrorMessage(e.message.toString());
    }
  }

  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your email to reset!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),

              // username textfield
              MyTextField(
                controller: _emailController,
                hintText: 'Email',
                obscureText: false,
                autofill: AutofillHints.email,
              ),
              const SizedBox(height: 55),
              MyButton(onTap: resetpassword, name: "Reset Password", color: Colors.deepPurple.shade400),
            ],
          ),
        ));
  }
}
