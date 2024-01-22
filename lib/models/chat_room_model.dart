class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastmessage;
  List<dynamic>? users;
  DateTime? createdon;

  ChatRoomModel(
      {this.chatroomid,
      this.participants,
      this.lastmessage,
      required this.users,
      this.createdon});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map['chatroomid'];
    participants = map['participants'];
    lastmessage = map['lastmessage'];
    users = map['users'];
    // createdon = map['createdon'];
  }

  Map<String, dynamic>? toMap() {
    return {
      'chatroomid': chatroomid,
      'participants': participants,
      'lastmessage': lastmessage,
      'users': users,
      'createdon': createdon
    };
  }
}
