import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String? id; // ✅ Firestore document ID
  final String sender;
  final String? userName;
  final String chatId;
  final String? text;
  final String? imagePath;
  final String? videoPath;
  final String? reaction;
  final bool edited;
  final DateTime? timestamp;
  final String? receiverId; // ✅ добавлено для push
  final bool? isRead;


  Message({
  required this.sender,
  required this.receiverId,
  required this.chatId,
  this.text,
  this.imagePath,
  this.videoPath,
  this.userName,
  this.timestamp,
  this.reaction,
  this.edited = false,
  this.id,
  this.isRead, // ← добавь это
});


  Message copyWith({
    String? id,
    String? chatId,
    String? text,
    String? imagePath,
    String? videoPath,
    String? reaction,
    bool? edited,
    DateTime? timestamp,
    String? receiverId, // ✅
    bool? isRead, // ← ✅ Добавь ЭТО
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender,
      userName: userName,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      videoPath: videoPath ?? this.videoPath,
      reaction: reaction ?? this.reaction,
      edited: edited ?? this.edited,
      timestamp: timestamp ?? this.timestamp,
      receiverId: receiverId ?? this.receiverId, // ✅
    );
  }

Map<String, dynamic> toJson() {
  return {
    'sender': sender,
    'userName': userName,
    'chatId': chatId,
    'text': text,
    'imagePath': imagePath,
    'videoPath': videoPath,
    'mediaPath': imagePath ?? videoPath ?? '',
    'reaction': reaction,
    'edited': edited,
    'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    'receiverId': receiverId,
    'isRead': isRead, // ← ✅ ДОБАВЬ ЭТУ СТРОКУ
  };
}



  factory Message.fromJson(Map<String, dynamic> json, String id) {
    DateTime? parsedTimestamp;

    if (json['timestamp'] != null) {
      if (json['timestamp'] is Timestamp) {
        parsedTimestamp = (json['timestamp'] as Timestamp).toDate();
      } else if (json['timestamp'] is String) {
        parsedTimestamp = DateTime.tryParse(json['timestamp']);
      }
    }

   return Message(
  id: id,
  sender: json['sender'],
  userName: json['userName'],
  chatId: json['chatId'] ?? '',
  text: json['text'],
  imagePath: json['imagePath'],
  videoPath: json['videoPath'],
  reaction: json['reaction'],
  edited: json['edited'] ?? false,
  timestamp: parsedTimestamp,
  receiverId: json['receiverId'],
  isRead: json['isRead'] ?? false, // ← ✅ ДОБАВЬ ЭТУ СТРОКУ
);

  }
}
