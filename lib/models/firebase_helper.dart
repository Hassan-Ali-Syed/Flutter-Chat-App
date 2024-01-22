import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FirebaseHelper {
  static Future<UserModel?> getUsermodelbyId(String id) async {
    UserModel? usermodel;

    DocumentSnapshot docsnapshot =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    if (docsnapshot.data() != null) {
      usermodel = UserModel.fromMap(docsnapshot.data() as Map<String, dynamic>);
    }

    return usermodel;
  }
}
