import 'package:cloud_firestore/cloud_firestore.dart';

class NovaMessage {
  final String text;
  final String sender; // 'user' или 'nova'
  final DateTime timestamp;
  final String model;

  NovaMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.model,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'sender': sender,
        'timestamp': Timestamp.fromDate(timestamp),
        'model': model,
      };

  static NovaMessage fromJson(Map<String, dynamic> json) => NovaMessage(
        text: json['text'],
        sender: json['sender'],
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        model: json['model'],
      );
}
