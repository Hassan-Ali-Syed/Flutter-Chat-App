import 'dart:developer';

import 'package:chat_app/Pages/home_page.dart';
import 'package:chat_app/Pages/signup_page.dart';
import 'package:chat_app/models/UIheelper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailcontrollerr = TextEditingController();
  TextEditingController passwordcontrollerr = TextEditingController();

  void checkvalues() {
    String email = emailcontrollerr.text.trim();
    String password = passwordcontrollerr.text.trim();
    if (email == '' || password == '') {
      UiHelper.showAlertDialogue(
          context, 'Incomplete Data', 'Please Fill All The Fields');
    } else {
      lognin(email, password);
    }
  }

  void lognin(String emailcont, String passcont) async {
    UserCredential? credential;
    UiHelper.showLoadingDialogue(context, 'Loading....');

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailcont, password: passcont);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UiHelper.showAlertDialogue(
          context, 'An Error Has Occured', ex.message.toString());
    }
    if (credential != null) {
      String? uid = credential.user!.uid;
      DocumentSnapshot userdata =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      UserModel usermodel =
          UserModel.fromMap(userdata.data() as Map<String, dynamic>);
      print('log in succenssfull');
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(usermodel: usermodel, firebaseuser: credential!.user!),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Center(
            child: SingleChildScrollView(
              child: Column(children: [
                Text(
                  'Chat App',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailcontrollerr,
                  decoration: InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordcontrollerr,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),
                CupertinoButton(
                    color: Theme.of(context).colorScheme.primary,
                    child: const Text('Login'),
                    onPressed: () {
                      checkvalues();
                    })
              ]),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
              child: const Text('Sign Up'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpPage()));
              })
        ],
      )),
    );
  }
}
