import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'package:logger/logger.dart';
import 'dart:developer'; // ← ДОБАВЬ наверху, если ещё не добавлено


class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  List<Message> get messages => _messages;
  final logger = Logger();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  void listenToMessages(String? chatId) {
    if (chatId == null || chatId.isEmpty) {
      debugPrint('⚠️ listenToMessages: chatId is null or empty. Skipping listener.');
      return;
    }

    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final newMessage = Message.fromJson({
          ...doc.data(),
          'chatId': chatId,
        }, doc.id);

        final existingIndex = _messages.indexWhere((msg) => msg.id == newMessage.id);
        if (existingIndex != -1) {
          _messages[existingIndex] = newMessage;
        } else {
          _messages.add(newMessage);
        }
      }

      final seen = <String>{};
      _messages.retainWhere((msg) => seen.add(msg.id ?? msg.timestamp.toString()));

      notifyListeners();
    });
  }

 Future<void> sendTextMessage(String chatId, String senderId, String receiverId, String text, {String? userName}) async {
  final now = DateTime.now();

  final message = Message(
    sender: senderId,
    receiverId: receiverId,
    chatId: chatId,
    userName: userName,
    text: text,
    timestamp: now,
    isRead: false, // ✅ добавлено
  );

  await _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .add(message.toJson());

  await _firestore.collection('users').doc(senderId).collection('userChats').doc(chatId).set({
    'userId': receiverId,
    'userName': userName ?? '',
    'lastMessage': text,
    'isOnline': true,
    'timestamp': Timestamp.fromDate(now),
  });

  final senderDoc = await _firestore.collection('users').doc(senderId).get();
  final senderName = senderDoc.data()?['fullName'] ?? '';

  // 🔴 добавлено: увеличиваем unreadCount у получателя
  final userChatsRef = _firestore.collection('users').doc(receiverId).collection('userChats').doc(chatId);
 // Получаем количество непрочитанных сообщений для receiver
final unreadSnapshot = await _firestore
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .where('receiverId', isEqualTo: receiverId)
    .where('isRead', isEqualTo: false)
    .get();

await userChatsRef.set({
  'userId': senderId,
  'userName': senderName,
  'lastMessage': text.isNotEmpty ? text : '📷 Photo',
  'isOnline': true,
  'timestamp': Timestamp.fromDate(now),
  'unreadCount': unreadSnapshot.docs.length,
});

  
}


  Future<void> sendImageMessage(String chatId, String senderId, String receiverId, File imageFile, {String? userName}) async {
    final now = DateTime.now();

    final ref = _storage
        .ref()
        .child('chat_images')
        .child('${now.millisecondsSinceEpoch}.jpg');

    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();

   final message = Message(
  sender: senderId,
  receiverId: receiverId,
  chatId: chatId,
  userName: userName,
  imagePath: url,
  timestamp: now,
  isRead: false, // 👈 Добавлено
);


    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());

    await _firestore.collection('users').doc(senderId).collection('userChats').doc(chatId).set({
      'userId': receiverId,
      'userName': userName ?? '',
      'lastMessage': '📷 Photo',
      'isOnline': true,
      'timestamp': Timestamp.fromDate(now),
    });

    final senderDoc = await _firestore.collection('users').doc(senderId).get();
    final senderName = senderDoc.data()?['fullName'] ?? '';


  final userChatsRef = _firestore.collection('users').doc(receiverId).collection('userChats').doc(chatId);
final unreadSnapshot = await _firestore
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .where('receiverId', isEqualTo: receiverId)
    .where('isRead', isEqualTo: false)
    .get();

await userChatsRef.set({
  'userId': senderId,
  'userName': senderName,
  'lastMessage': '📷 Photo',
  'isOnline': true,
  'timestamp': Timestamp.fromDate(now),
  'unreadCount': unreadSnapshot.docs.length,
});


  }

  Future<void> sendCombinedMessage({
  required String chatId,
  required String senderId,
  required String receiverId,
  required String text,
  File? imageFile,
  String? userName,
}) async {
  final now = DateTime.now();
  String? imageUrl;

  if (imageFile != null) {
    final ref = _storage
        .ref()
        .child('chat_images')
        .child('${now.millisecondsSinceEpoch}.jpg');

    await ref.putFile(imageFile);
    imageUrl = await ref.getDownloadURL();
    log("📷 Image uploaded: $imageUrl");
  }

  final message = Message(
  sender: senderId,
  receiverId: receiverId,
  chatId: chatId,
  userName: userName,
  text: text,
  imagePath: imageUrl,
  timestamp: now,
  isRead: false, // 👈 Добавлено
);


  log("💬 Saving message to chats/$chatId/messages...");
  await _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .add(message.toJson());
  log("✅ Message saved!");

  // ➕ userChats для sender
  log("📌 Creating userChats for sender $senderId...");
  await _firestore
      .collection('users')
      .doc(senderId)
      .collection('userChats')
      .doc(chatId)
      .set({
    'userId': receiverId,
    'userName': userName ?? '',
    'lastMessage': text.isNotEmpty ? text : '📷 Photo',
    'isOnline': true,
    'timestamp': Timestamp.fromDate(now),
  });
  log("✅ userChats for sender saved");

  // ➕ userChats для receiver
  log("📥 Getting sender's full name for receiver $receiverId...");
  final senderDoc = await _firestore.collection('users').doc(senderId).get();
  final senderName = senderDoc.data()?['fullName'] ?? '';
  log("👤 Sender full name: $senderName");

  log("📌 Creating userChats for receiver $receiverId...");
  final userChatsRef = _firestore
    .collection('users')
    .doc(receiverId)
    .collection('userChats')
    .doc(chatId);

final chatSnapshot = await userChatsRef.get();
final previousUnread = chatSnapshot.data()?['unreadCount'] ?? 0;

await userChatsRef.set({
  'userId': senderId,
  'userName': senderName,
  'lastMessage': text.isNotEmpty ? text : '📷 Photo',
  'isOnline': true,
  'timestamp': Timestamp.fromDate(now),
  'unreadCount': previousUnread + 1,
});

  log("✅ userChats for receiver saved");
}



  Future<void> sendVideoMessage(String chatId, String senderId, String receiverId, File videoFile, {String? userName}) async {
    final now = DateTime.now();

    final ref = _storage
        .ref()
        .child('chat_videos')
        .child('${now.millisecondsSinceEpoch}.mp4');

    final uploadTask = ref.putFile(videoFile);
    await uploadTask.whenComplete(() => null);
    final url = await ref.getDownloadURL();

   final message = Message(
  sender: senderId,
  receiverId: receiverId,
  chatId: chatId,
  userName: userName,
  videoPath: url,
  timestamp: now,
  isRead: false, // 👈 Добавлено
);


    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());

    await _firestore.collection('users').doc(senderId).collection('userChats').doc(chatId).set({
      'userId': receiverId,
      'userName': userName ?? '',
      'lastMessage': '🎥 Video',
      'isOnline': true,
      'timestamp': Timestamp.fromDate(now),
    });

    final senderDoc = await _firestore.collection('users').doc(senderId).get();
    final senderName = senderDoc.data()?['fullName'] ?? '';


   final userChatsRef = _firestore.collection('users').doc(receiverId).collection('userChats').doc(chatId);
final chatSnapshot = await userChatsRef.get();
final previousUnread = chatSnapshot.data()?['unreadCount'] ?? 0;

await userChatsRef.set({
  'userId': senderId,
  'userName': senderName,
  'lastMessage': '🎥 Video', // ✅ правильно
  'isOnline': true,
  'timestamp': Timestamp.fromDate(now),
  'unreadCount': previousUnread + 1,
});


  }

  Future<void> editMessage(String chatId, String messageId, String newText) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'text': newText,
      'edited': true,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> updateReaction(String chatId, String messageId, int index, String? reaction) async {
    if (index < 0 || index >= _messages.length) return;

    _messages[index] = _messages[index].copyWith(reaction: reaction);
    notifyListeners();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reaction': reaction,
    });
  }
Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('userChats')
        .doc(chatId)
        .update({'unreadCount': 0});
  } catch (e) {
    debugPrint('markMessagesAsRead error: $e');
  }
}



}
