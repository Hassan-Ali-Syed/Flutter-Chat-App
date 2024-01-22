import 'dart:developer';

import 'package:chat_app/Pages/chat_room_page.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';

class SearchPage extends StatefulWidget {
  final UserModel usermodel;
  final User firebaseuser;

  const SearchPage(
      {super.key, required this.usermodel, required this.firebaseuser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchcontroller = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetuser) async {
    ChatRoomModel? chatroom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.usermodel.uid}', isEqualTo: true)
        .where('participants.${targetuser.uid}', isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      //fetch the existed chatroom
      log('chatroom already creaed');

      var docData = snapshot.docs[0].data();
      ChatRoomModel existingchatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatroom = existingchatroom;
    } else {
      //create a new chatroom
      ChatRoomModel? newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastmessage: '',
          participants: {
            widget.usermodel.uid.toString(): true,
            targetuser.uid.toString(): true,
          },
          users: [
            widget.usermodel.uid.toString(),
            targetuser.uid.toString(),
          ],
          createdon: DateTime.now());

      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap()!);
      log('new chatroom created');
      chatroom = newChatroom;
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              TextField(
                controller: searchcontroller,
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                  color: Colors.blue,
                  child: const Text('Search'),
                  onPressed: () {
                    setState(() {});
                  }),
              const SizedBox(height: 20),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: searchcontroller.text)
                      .where('email', isNotEqualTo: widget.usermodel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot datasnapshot =
                            snapshot.data as QuerySnapshot;
                        if (datasnapshot.docs.length > 0) {
                          Map<String, dynamic>? Usermap = datasnapshot.docs[0]
                              .data() as Map<String, dynamic>;

                          UserModel searchuser = UserModel.fromMap(Usermap);
                          return ListTile(
                            onTap: () async {
                              ChatRoomModel? chatroommodel =
                                  await getChatroomModel(searchuser);
                              if (chatroommodel != null) {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatRoomPage(
                                              targetuser: searchuser,
                                              usermodel: widget.usermodel,
                                              firebaseuser: widget.firebaseuser,
                                              chatroom: chatroommodel,
                                            )));
                              }
                            },
                            leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(searchuser.profilepic!)),
                            title: Text(searchuser.fullname!),
                            subtitle: Text(searchuser.email!),
                            trailing: const Icon(Icons.keyboard_arrow_right),
                          );
                        } else {
                          return const Text('No Data Found');
                        }
                      } else if (snapshot.hasError) {
                        return const Text('An Error Occured');
                      } else {
                        return const Text('No Data Found');
                      }
                    } else {
                      return const CircularProgressIndicator();
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
