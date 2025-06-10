import 'dart:io';
import 'package:an_open_soul_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../utils/chat_actions.dart';

var logger = Logger();

class ChatScreen extends StatefulWidget {
  final String userName;
  final String? mediaPath;
  final String userId;
  final String? chatId;


  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.mediaPath = "",
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  int? _longPressIndex;
  int? _editingMessageIndex;
  final FocusNode _editFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  File? _pendingImage;

 @override
  void initState() {
  super.initState();
  final chatProvider = Provider.of<ChatProvider>(context, listen: false);

  logger.i('📩 ChatScreen initState:');
  logger.i('👤 userId: ${widget.userId}');
  logger.i('💬 chatId: ${widget.chatId}');
  logger.i('👤 userName: ${widget.userName}');
  final currentUser = FirebaseAuth.instance.currentUser;
  logger.i('✅ Logged in as (currentUser.uid): ${currentUser?.uid}');


  if (widget.chatId != null && widget.chatId!.isNotEmpty) {
    chatProvider.listenToMessages(widget.chatId);
  } else {
    debugPrint('⚠️ ChatScreen: chatId is null or empty. Skipping listener.');
  }
  ensureChatMetadata();

}
Future<void> ensureChatMetadata() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final myDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
  final myName = myDoc.data()?['username'] ?? 'Unknown';
  final myImage = myDoc.data()?['profileImageUrl'] ?? '';
  final myOnline = myDoc.data()?['isOnline'] ?? false;

  final otherUserId = widget.userId;
  final chatId = widget.chatId;

  final chatRef = FirebaseFirestore.instance
      .collection('users')
      .doc(otherUserId)
      .collection('userChats')
      .doc(chatId);

  await chatRef.set({
    'userId': currentUser.uid,
    'userName': myName,
    'profileImageUrl': myImage,
    'isOnline': myOnline,
    'timestamp': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}




  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatProvider = Provider.of<ChatProvider>(context);
  chatProvider.addListener(() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    markMessagesAsRead();
  });
});


  }

  void _closeMenu() => setState(() => _longPressIndex = null);

  void _sendMessage() {
    final isEditing = _editingMessageIndex != null;

    if (isEditing) {
      ChatActions.editMessage(context, _editingMessageIndex!, _messageController.text.trim());
      setState(() {
        _editingMessageIndex = null;
        _messageController.clear();
      });
      FocusScope.of(context).unfocus();
    } else {
      final text = _messageController.text.trim();
      final provider = Provider.of<ChatProvider>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (_pendingImage != null || text.isNotEmpty) {
     if (widget.chatId != null && widget.chatId!.isNotEmpty) {
  provider.sendCombinedMessage(
    chatId: widget.chatId!,
    senderId: currentUser!.uid,
    receiverId: widget.userId,
    userName: widget.userName,
    text: text,
    imageFile: _pendingImage,
  );

  setState(() {
    _pendingImage = null;
    _messageController.clear();
  });
} else {
  debugPrint('⚠️ Cannot send message: chatId is null or empty');
}



        setState(() {
          _pendingImage = null;
          _messageController.clear();
        });
      }
    }
  }
void markMessagesAsRead() {
  if (!mounted) return; // 🛡 Защита от ошибки

  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final chatId = widget.chatId;

  if (chatId != null && currentUserId.isNotEmpty) {
    chatProvider.markMessagesAsRead(chatId, currentUserId);
  }
}




  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messages = Provider.of<ChatProvider>(context).messages;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

   WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;

  if (_scrollController.hasClients) {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }
});


    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        _closeMenu();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(colors: [Color(0xFF1C1C1C), Color(0xFF2A2A2A)])
                    : const LinearGradient(colors: [
                        Color(0xFFB39DDB),
                        Color(0xFFCE93D8),
                        Color(0xFFB2EBF2),
                      ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black54 : Colors.white24,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.userName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pacifico(
                            fontSize: 24,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final isMe = messages[index].sender == currentUserId;

                        return MessageBubble(
                          message: messages[index],
                          index: index,
                          isMe: isMe,
                          longPressIndex: _longPressIndex,
                          onLongPress: () => setState(() => _longPressIndex = index),
                          onDoubleTap: () {
                            HapticFeedback.lightImpact();
                            final currentReaction = messages[index].reaction;
                            final newReaction = currentReaction == "❤️" ? null : "❤️";

                            setState(() {
                              messages[index] = messages[index].copyWith(reaction: newReaction);
                            });

                            ChatActions.addReaction(
                              context,
                              index,
                              newReaction ?? '',
                            );
                          },
                          onReaction: (reaction) {
                            ChatActions.addReaction(context, index, reaction);
                            _closeMenu();
                          },
                          onEdit: () {
                            setState(() {
                              _editingMessageIndex = index;
                              _messageController.text = messages[index].text ?? '';
                              _editFocusNode.requestFocus();
                              _longPressIndex = null;
                            });
                          },
                          onDelete: () => ChatActions.deleteMessage(context, index),
                          onCopy: () => ChatActions.copyMessage(context, index),
                        );
                      },
                    ),
                  ),
                ),
                if (_pendingImage != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _pendingImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _pendingImage = null),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.image, color: Theme.of(context).iconTheme.color),
                        onPressed: () async {
                          final file = await ChatActions.pickImageFile();
                          if (file != null) {
                            setState(() => _pendingImage = file);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.camera, color: Theme.of(context).iconTheme.color),
                        onPressed: () => ChatActions.takePhoto(
  context,
  widget.chatId!,
  widget.userId,
  widget.userName,
),

                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _editFocusNode,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark ? Colors.grey[800] : Colors.white70,
                            hintText: "Type a message...",
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF8E24AA), Color(0xFF80DEEA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}