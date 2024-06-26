import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String? id;
  List<String>? participants;
  List<Message>? messages;

  String? lastMessage;
  Timestamp? lastMessageDate;
  String? lastMessageSenderID;

  Chat({
    required this.id,
    required this.participants,
    required this.messages,
    required this.lastMessage,
    required this.lastMessageDate,
    required this.lastMessageSenderID,
  });

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    participants = List<String>.from(json['participants']);
    messages =
        List.from(json['messages']).map((m) => Message.fromJson(m)).toList();
    lastMessage = json['lastMessage'];
    lastMessageDate = json['lastMessageDate'];
    lastMessageSenderID = json['lastMessageSenderID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['participants'] = participants;
    data['messages'] = messages?.map((m) => m.toJson()).toList() ?? [];
    data['lastMessage'] = lastMessage;
    data['lastMessageDate'] = lastMessageDate;
    data['lastMessageSenderID'] = lastMessageSenderID;
    return data;
  }
}
