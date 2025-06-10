import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import 'package:logger/logger.dart';

var logger = Logger();

/// 🔁 Редактирование: Firestore + локально
Future<void> editMessage(int index, List<Message> messages, String newText) async {
  if (index < 0 || index >= messages.length) return;
  final message = messages[index];

  if (message.id == null || message.id!.isEmpty) {
    logger.e("❌ Невозможно отредактировать сообщение: отсутствует message.id");
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .doc(message.id)
        .update({
      'text': newText,
      'edited': true,
      'timestamp': Timestamp.now(),
    });

    messages[index] = message.copyWith(text: newText, edited: true);
    logger.i("✅ Сообщение обновлено в Firestore.");
  } catch (e) {
    logger.e("Ошибка при редактировании: $e");
  }
}

/// 🗑️ Удаление: Firestore + локально
Future<void> deleteMessage(int index, List<Message> messages) async {
  if (index < 0 || index >= messages.length) return;
  final message = messages[index];

  if (message.id == null || message.id!.isEmpty) {
    logger.e("❌ Невозможно удалить сообщение: отсутствует message.id");
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .doc(message.id)
        .delete();

    messages.removeAt(index);
    logger.i("🗑️ Сообщение удалено из Firestore.");
  } catch (e) {
    logger.e("Ошибка при удалении: $e");
  }
}

/// ❤️ Реакция — только локально
void addReaction(int index, List<Message> messages, String reaction) {
  if (index >= 0 && index < messages.length) {
    messages[index] = messages[index].copyWith(reaction: reaction);
  }
}
