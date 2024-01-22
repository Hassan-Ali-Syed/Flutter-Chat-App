import 'package:chat_app/Pages/complete_profile_page.dart';
import 'package:chat_app/Pages/home_page.dart';
import 'package:chat_app/Pages/login_page.dart';
import 'package:chat_app/Pages/signup_page.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  User? currentuser = FirebaseAuth.instance.currentUser;
  if (currentuser != null) {
    UserModel? helperusermodel =
        await FirebaseHelper.getUsermodelbyId(currentuser.uid);
    if (helperusermodel != null) {
      runApp(LoggedIn(
        usermodel: helperusermodel!,
        firebaseuser: currentuser,
      ));
    } else {
      runApp(const MyApp());
    }
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: LoginPage());
  }
}

class LoggedIn extends StatelessWidget {
  final UserModel usermodel;
  final User firebaseuser;

  const LoggedIn(
      {super.key, required this.usermodel, required this.firebaseuser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(usermodel: usermodel, firebaseuser: firebaseuser));
  }
}
