class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;

  MessageModel(
      {required this.messageid,
      required sender,
      required this.text,
      required this.seen,
      required this.createdon});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map['messageid'];
    sender = map['sender'];
    text = map['text'];
    seen = map['seen'];
    createdon = map['createdon'].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'messageid': messageid,
      'sender': sender,
      'text': text,
      'seen': seen,
      'createdon': createdon
    };
  }
}
