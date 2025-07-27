
import 'package:finalmicrophone/screens/login_page.dart';
import 'package:finalmicrophone/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/homePage.dart';

//this is genius.
//if the user is not logged in, then, we are directed here, and since the showLoginPage is true,
//it directs to login page first, and when we press the register now, the onTap function is activated
//and the showLoginPage is false, and then, since the user is still not logged in, it directs to register
//page.
//this widget acts as the function provider (togglePage ) which acts as the inbuilt required stuff
// for login and register page both.

//in summary, when the user not logged in, eta direct huncha, so depending on pressing on onTap fnction,
//the return is varied depending on the state of showLoginPage here. so
//yei widget maa hune kura ho.

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({Key? key}) : super(key: key);

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {


  bool showLoginPage =true;
  //method to toggle between login and register page
  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
if(showLoginPage){
return LoginPage(onTap: togglePages);}
else{
  return RegisterPage(onTap: togglePages);
}
  }
}
