import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:an_open_soul_app/widgets/stars_background.dart';

class MyChatsScreen extends StatelessWidget {
  const MyChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentUser == null) {
      log("User is not logged in.");
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
     appBar: PreferredSize(
  preferredSize: const Size.fromHeight(59),
  child: Stack(
    children: [
      // ⬛ Чёрный фон AppBar'а
     Container(
  decoration: BoxDecoration(
    color: isDark ? Colors.black : const Color(0xFF8E24AA),
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
  ),
),


      // ✨ Звёзды поверх чёрного
      if (isDark)
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: const AnimatedStarField(starCount: 40),
          ),
        ),

      // 📦 Контент AppBar'а
      Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 2),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
            Text(
              "My Chats",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [
                  Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
                ],
              ),
            ),
            const Spacer(),
            const SizedBox(width: 48),
          ],
        ),
      ),
    ],
  ),
),


      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF1D1F21), Color(0xFF2C2C54), Color(0xFF1D1F21)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFF8E24AA), Color(0xFFF3D9FF), Color(0xFF80DEEA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('userChats')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error loading chats.",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No chats yet.",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                ),
              );
            }

            final chatDocs = snapshot.data!.docs;

           return ListView.builder(
  itemCount: chatDocs.length,
 itemBuilder: (context, index) {
  final chat = chatDocs[index];
  final data = chat.data() as Map<String, dynamic>;
  final userId = data['userId'];

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
    builder: (context, userSnapshot) {
      if (!userSnapshot.hasData) {
        return const SizedBox.shrink();
      }

      final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
      final name = userData['username'] ?? 'Unknown';
      final isOnline = userData['isOnline'] ?? false;
      final imageUrl = userData['profileImageUrl'] ?? '';
      final lastMessage = data['lastMessage'] ?? '';
      final unreadCount = data['unreadCount'] ?? 0;

    return _buildChatCard(
  context,
  name: name,
  lastMessage: lastMessage,
  isOnline: isOnline,
  imageUrl: imageUrl,
  unreadCount: unreadCount,
 onTap: () async {
  // 1. Получи текущего пользователя
  final currentUser = FirebaseAuth.instance.currentUser;

  // 2. Обнули счётчик непрочитанных сообщений
await FirebaseFirestore.instance
    .collection('users')
    .doc(currentUser?.uid)
    .collection('userChats')
    .doc(chat.id)
    .update({'unreadCount': 0});

if (!context.mounted) return;

Navigator.pushNamed(
  context,
  '/chatScreen',
  arguments: {
    'chatId': chat.id,
    'userId': userId,
    'userName': name,
    'mediaPath': '',
  },
);

},

);

    },
  );
},


);

          },
        ),
      ),
    );
  }

Widget _buildChatCard(
  BuildContext context, {
  required String name,
  required String lastMessage,
  required bool isOnline,
  required String imageUrl,
  required int unreadCount,
  required VoidCallback onTap,
}) {


    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF2A2A2A), Color(0xFF3D2C4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFFAB47BC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.purpleAccent.withAlpha((0.4 * 255).toInt()),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
           Stack(
  children: [
    Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white12 : Colors.white24,
        image: imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl.isEmpty
          ? const Icon(Icons.person, size: 30, color: Colors.white)
          : null,
    ),
    Positioned(
      bottom: 3,
      right: 3,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: isOnline ? Colors.green : Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    ),
  ],
),

            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lastMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            unreadCount > 0
    ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$unreadCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    : const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),

          ],
        ),
      ),
    );
  }
}
