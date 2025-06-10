// lib/utils/chat_actions.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../providers/chat_provider.dart';
import '../utils/message_handler.dart' as handler;
import '../image_handler.dart' as image_utils;
import '../camera_screen.dart';

class ChatActions {
  static Future<void> pickImages(BuildContext context, String chatId, String receiverId, String userName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final List<File>? imageFiles = await image_utils.pickImages();
    if (!context.mounted) return;

    if (imageFiles != null && imageFiles.isNotEmpty) {
      for (File file in imageFiles) {
        Provider.of<ChatProvider>(context, listen: false).sendImageMessage(
          chatId,
          currentUser.uid,
          receiverId,
          file,
          userName: userName,
        );
      }
    } else {
      debugPrint("No images selected");
    }
  }

  static Future<void> takePhoto(BuildContext context, String chatId, String receiverId, String userName) async {
    final cameras = await availableCameras();
    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          cameras: cameras,
          userName: userName,
          onMediaCaptured: (XFile file) {
            if (!context.mounted) return;

            String mediaPath = file.path;
            debugPrint("📸 Медиафайл получен в ChatScreen: $mediaPath");

            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null) return;

            final chatProvider = Provider.of<ChatProvider>(context, listen: false);

            if (mediaPath.endsWith('.jpg')) {
              chatProvider.sendImageMessage(
                chatId,
                currentUser.uid,
                receiverId,
                File(mediaPath),
                userName: userName,
              );
            } else if (mediaPath.endsWith('.mp4')) {
              chatProvider.sendVideoMessage(
                chatId,
                currentUser.uid,
                receiverId,
                File(mediaPath),
                userName: userName,
              );
            }
          },
        ),
      ),
    );
  }

  static Future<void> sendTextMessage(BuildContext context, String chatId, String receiverId, String text, String userName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (text.trim().isEmpty || currentUser == null) return;

    Provider.of<ChatProvider>(context, listen: false).sendTextMessage(
      chatId,
      currentUser.uid,
      receiverId,
      text.trim(),
      userName: userName,
    );

    // Локальное уведомление
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'New message from $userName',
      text.trim(),
      notificationDetails,
    );
  }

  static Future<void> editMessage(BuildContext context, int index, String newText) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final messages = chatProvider.messages;
    final message = messages[index];

    final chatId = message.chatId;
    final messageId = message.id;

    if (chatId.isEmpty || messageId == null || messageId.isEmpty) {
      debugPrint("❌ Ошибка: chatId или id пустой. chatId=$chatId, id=$messageId");
      return;
    }

    handler.editMessage(index, messages, newText);

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'text': newText,
        'edited': true,
        'timestamp': Timestamp.now(),
          'isRead': false, // 👈 Добавь это
      });
      debugPrint('✔️ Message updated in Firestore');
    } catch (e) {
      debugPrint('❌ Failed to update message in Firestore: $e');
    }
  }

  static Future<void> addReaction(BuildContext context, int index, String? reaction) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final message = chatProvider.messages[index];

    final chatId = message.chatId;
    final messageId = message.id;

    if (chatId.isEmpty || messageId == null || messageId.isEmpty) {
      debugPrint("❌ Ошибка: chatId или id пустой. chatId=$chatId, id=$messageId");
      return;
    }

    await chatProvider.updateReaction(chatId, messageId, index, reaction);
  }

  static void deleteMessage(BuildContext context, int index) {
    final messages = Provider.of<ChatProvider>(context, listen: false).messages;
    handler.deleteMessage(index, messages);
  }

  static void copyMessage(BuildContext context, int index) {
    final messages = Provider.of<ChatProvider>(context, listen: false).messages;
    Clipboard.setData(ClipboardData(text: messages[index].text ?? ''));
  }

  static void scrollToBottom(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  static void jumpToBottom(ScrollController scrollController) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  static Future<List<File>> pickImageFiles() async {
    final List<File>? images = await image_utils.pickImages();
    return images ?? [];
  }

  static Future<File?> pickImageFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}
