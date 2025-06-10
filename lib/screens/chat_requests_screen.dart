import 'package:an_open_soul_app/widgets/stars_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatRequestsScreen extends StatelessWidget {
  const ChatRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(59),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black : const Color(0xFF8E24AA),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
            ),
            if (isDark)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: const AnimatedStarField(starCount: 40),
                ),
              ),
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
                    "Chat Requests",
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
      extendBodyBehindAppBar: true,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('friend_requests')
                .where('toUserId', isEqualTo: currentUser?.uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No requests yet', style: TextStyle(color: Colors.white70)));
              }
              final requests = snapshot.data!.docs;
              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final data = requests[index].data() as Map<String, dynamic>;
                  final docId = requests[index].id;
                  final fromUserName = data['fromUsername'] ?? 'Unknown';

                  return _buildRequestCard(
                    context,
                    name: fromUserName,
                    requestMessage: "wants to be your friend",
                    onAccept: () async {
                      debugPrint("✅ Accepted $fromUserName");
                      await FirebaseFirestore.instance.collection('friend_requests').doc(docId).delete();
                    },
                    onDecline: () async {
                      debugPrint("❌ Declined $fromUserName");
                      await FirebaseFirestore.instance.collection('friend_requests').doc(docId).delete();
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context, {
    required String name,
    required String requestMessage,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
                  color: const Color(0xFFB388FF).withAlpha((0.3 * 255).toInt()),
                  blurRadius: 12,
                  spreadRadius: 2,
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white12 : Colors.white24,
            ),
            child: const Icon(Icons.person, size: 30, color: Colors.white),
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
                  requestMessage,
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
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                onPressed: onAccept,
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                onPressed: onDecline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}