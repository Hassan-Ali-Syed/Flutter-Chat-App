import 'dart:developer';

import 'package:chat_app/Pages/chat_room_page.dart';
import 'package:chat_app/Pages/login_page.dart';
import 'package:chat_app/Pages/signup_page.dart';
import 'package:chat_app/models/UIheelper.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/Pages/searchpage.dart';

class HomePage extends StatefulWidget {
  final UserModel usermodel;
  final User firebaseuser;

  const HomePage(
      {super.key, required this.usermodel, required this.firebaseuser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat App',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColorDark,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const LoginPage();
                }));
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: SafeArea(
          child: Container(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where('users', arrayContains: widget.usermodel.uid)
                .orderBy('createdon')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatroomsnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatroomsnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatroommodel = ChatRoomModel.fromMap(
                          chatroomsnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      Map<String, dynamic>? participants =
                          chatroommodel.participants;
                      List<String> partcipantskeys =
                          participants!.keys.toList();
                      partcipantskeys.remove(widget.usermodel.uid);

                      return FutureBuilder(
                          future: FirebaseHelper.getUsermodelbyId(
                              partcipantskeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              if (userData.data != null) {
                                UserModel targetuser =
                                    userData.data as UserModel;
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                          targetuser: targetuser,
                                          chatroom: chatroommodel,
                                          usermodel: widget.usermodel,
                                          firebaseuser: widget.firebaseuser);
                                    }));
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        targetuser.profilepic.toString()),
                                  ),
                                  title: Text(targetuser.fullname.toString()),
                                  subtitle: (chatroommodel.lastmessage != '')
                                      ? Text(
                                          chatroommodel.lastmessage.toString(),
                                        )
                                      : Text(
                                          'say hi to youe new friend',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          });
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return const Center(
                    child: Text('no chatroom available'),
                  );
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColorDark,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(
                  usermodel: widget.usermodel,
                  firebaseuser: widget.firebaseuser),
            ),
          );
        },
        child: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}
