import 'package:chat_app/Pages/complete_profile_page.dart';
import 'package:chat_app/Pages/login_page.dart';
import 'package:chat_app/models/UIheelper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController cpasswordcontroller = TextEditingController();

  void checkValues() {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();
    String confirmPassword = cpasswordcontroller.text.trim();
    if (email == '' || password == '' || confirmPassword == '') {
      UiHelper.showAlertDialogue(
          context, 'Incomplete Data', 'Please Fill All The Fields');
    } else if (password != confirmPassword) {
      UiHelper.showAlertDialogue(context, 'Passwords Mismatched',
          'Passwords You Entered Do Not Match');
    } else {
      signUp(email, password);
    }
  }

  void signUp(String emailstring, String passwordstring) async {
    UserCredential? credential;
    UiHelper.showLoadingDialogue(context, 'Creating A New Account..');
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailstring, password: passwordstring);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UiHelper.showAlertDialogue(
          context, 'An Error Has Occured', ex.code.toString());

      print(ex.code.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: emailstring, fullname: '', profilepic: '');
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .set(newUser.toMap()!)
          .then(
            (value) => print('New User Created'),
          );
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteProfilePage(
              usermodel: newUser, userprofile: credential!.user!),
        ),
      );
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
                  controller: emailcontroller,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  controller: passwordcontroller,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cpasswordcontroller,
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password'),
                ),
                const SizedBox(height: 20),
                CupertinoButton(
                    color: Theme.of(context).colorScheme.primary,
                    child: const Text('Sign Up'),
                    onPressed: () {
                      checkValues();
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
            "already have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
              child: const Text('Log in'),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      )),
    );
  }
}
