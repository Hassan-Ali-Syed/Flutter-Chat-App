import 'dart:io';

import 'package:chat_app/Pages/home_page.dart';
import 'package:chat_app/models/UIheelper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfilePage extends StatefulWidget {
  final UserModel usermodel;
  final User userprofile;

  const CompleteProfilePage(
      {super.key, required this.usermodel, required this.userprofile});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  File? imagefile;
  TextEditingController fullnameController = TextEditingController();

  void showPhotooptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: const Icon(Icons.photo_album),
                title: const Text('Select From Gallery'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                leading: const Icon(Icons.camera_alt_sharp),
                title: const Text('Take a Photo'),
              )
            ],
          ),
        );
      },
    );
  }

  void selectImage(ImageSource source) async {
    XFile? pickedfile = await ImagePicker().pickImage(source: source);
    if (pickedfile != null) {
      cropImage(pickedfile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedimage = (await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 25));

    File image = File(croppedimage!.path);
    if (croppedimage != null) {
      setState(() {
        imagefile = image;
      });
    }
  }

  void checkValues() {
    String fullname = fullnameController.text.trim();
    if (fullname == '' || imagefile == null) {
      UiHelper.showAlertDialogue(
          context, 'Incomplete Data', 'please fill all the fields');
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UiHelper.showLoadingDialogue(context, ' uploading Image...');
    UploadTask uploadtask = FirebaseStorage.instance
        .ref('profile picture')
        .child(widget.usermodel.uid.toString())
        .putFile(imagefile!);
    TaskSnapshot snapshot = await uploadtask;
    String? imageurl = await snapshot.ref.getDownloadURL();
    String? fullname = fullnameController.text.trim();
    widget.usermodel.fullname = fullname;
    widget.usermodel.profilepic = imageurl;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.usermodel.uid)
        .set(widget.usermodel.toMap()!)
        .then((value) => print('Data uploaded succefully'));
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                usermodel: widget.usermodel,
                firebaseuser: widget.userprofile)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Complete Profile',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            CupertinoButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                showPhotooptions();
              },
              child: imagefile == null
                  ? CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 60,
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.black,
                      ))
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: FileImage(imagefile!),
                      radius: 60,
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: fullnameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(
              height: 20,
            ),
            CupertinoButton(
                color: Theme.of(context).primaryColor,
                child: const Text('Submit'),
                onPressed: () {
                  checkValues();
                })
          ],
        ),
      )),
    );
  }
}
