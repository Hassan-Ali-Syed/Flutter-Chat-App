import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetuser;
  final ChatRoomModel chatroom;
  final UserModel usermodel;
  final User firebaseuser;

  const ChatRoomPage(
      {super.key,
      required this.targetuser,
      required this.chatroom,
      required this.usermodel,
      required this.firebaseuser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messagecontroller = TextEditingController();

  void sendMessage() async {
    String msg = messagecontroller.text.trim();
    messagecontroller.clear();
    print(widget.usermodel.uid);
    if (msg != '') {
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: "${widget.usermodel.uid}",
          createdon: DateTime.now(),
          text: msg,
          seen: false);
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatroom.chatroomid)
          .collection('messages')
          .doc(newMessage.messageid)
          .set(newMessage.toMap());
      log('msg sent');
      widget.chatroom.lastmessage = msg;
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap()!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              backgroundImage:
                  NetworkImage(widget.targetuser.profilepic.toString()),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.targetuser.fullname.toString())
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(widget.chatroom.chatroomid)
                        .collection('messages')
                        .orderBy('createdon', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot datasnapshot =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                              reverse: true,
                              itemCount: datasnapshot.docs.length,
                              itemBuilder: ((context, index) {
                                MessageModel currentmessage =
                                    MessageModel.fromMap(
                                        datasnapshot.docs[index].data()
                                            as Map<String, dynamic>);
                                log(currentmessage.sender.toString());
                                return Row(
                                  mainAxisAlignment: (currentmessage.sender ==
                                          widget.usermodel.uid
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end),
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 3),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: (currentmessage.sender ==
                                                  widget.usermodel.uid)
                                              ? Colors.grey
                                              : Colors.yellow,
                                        ),
                                        child: Text(
                                          currentmessage.text.toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                );
                              }));
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                                'an error has occured,please check your internet connection'),
                          );
                        } else {
                          return const Center(
                            child: Text('say hi to your new friend'),
                          );
                        }
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                    maxLines: null,
                    controller: messagecontroller,
                    decoration: const InputDecoration(
                        hintText: 'Enter a Message', border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.blue,
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
