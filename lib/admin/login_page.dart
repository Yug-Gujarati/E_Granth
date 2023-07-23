// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'componet/button.dart';
import 'componet/text_field.dart';


class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key , required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void signIn() async{
    showDialog(
      context: context,  
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      )
    );


    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      if(context.mounted){
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const AdminPage()));
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  void displayMessage(String message){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 31, 36, 45),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal : 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(
                Icons.lock,
                size: 100,
                color: Colors.white,
              ),
        
              Text("Only for Admin login",
              style: TextStyle(color: Colors.grey[100] , fontSize: 16),
              
              ),
        
              SizedBox(height: 25,),

              MyTextField(
                controller: emailTextController,
                hintText: 'Email',
                obscureText: false,
              ),

              SizedBox(height: 25,),

              MyTextField(
                controller: passwordTextController,
                hintText: 'Password',
                obscureText: true,
              ),

              SizedBox(height: 25),

              Mybutton(
                onTap: signIn, 
                text: 'Sign In',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//   void _login() async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: _email, password: _password);
//       Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//               builder: (context) => AdminPage()));
//     } catch (e) {
//       print(e);
//     }
//   }
// }