import 'package:an_open_soul_app/widgets/report_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:an_open_soul_app/screens/chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLiked = false;
  int _likeCount = 0;
  final bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final likeDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('likes')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _likeCount = userDoc.data()!['likes'] ?? 0;
        _isLiked = likeDoc.exists;
      });
    }
  }

  Future<void> _toggleLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final likeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('likes')
        .doc(currentUser.uid);

    final likeSnapshot = await likeRef.get();

    if (!likeSnapshot.exists) {
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'likes': FieldValue.increment(1),
      });
      setState(() {
        _isLiked = true;
        _likeCount++;
      });
    } else {
      await likeRef.delete();
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'likes': FieldValue.increment(-1),
      });
      setState(() {
        _isLiked = false;
        _likeCount--;
      });
    }
  }

  void _showReportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportBottomSheet(userId: widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data();
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text("User not found", style: TextStyle(color: Colors.white))),
            backgroundColor: Colors.deepPurple,
          );
        }

        final userMap = data as Map<String, dynamic>;
        final username = userMap['username'] ?? 'Unknown';
        final bio = userMap['bio'] ?? '';
        final story = userMap['story'] ?? '';
        final showStory = userMap['showStory'] ?? false;
        final imageUrl = userMap['profileImageUrl'];

        return Stack(
          children: [
            Container(
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
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.flag_outlined, color: Colors.white),
                      onPressed: _showReportDialog,
                    )
                  ],
                ),
                extendBodyBehindAppBar: true,
                body: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                            ? NetworkImage(imageUrl)
                            : null,
                        backgroundColor: Colors.white,
                        child: (imageUrl == null || imageUrl.isEmpty)
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        username,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      if (bio.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("About me:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[900] : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                bio,
                                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87, height: 1.4),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 30),
                      if (showStory && story.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "My Story",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onDoubleTap: _toggleLike,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[900] : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  story,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark ? Colors.white : Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: _toggleLike,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(25),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _isLiked ? Icons.favorite : Icons.favorite_border,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$_likeCount',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
                          final chatId = '${currentUserId}_${widget.userId}';

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                userName: username,
                                userId: widget.userId,
                                mediaPath: "",
                                chatId: chatId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Send Message", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showSuccess)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade100.withAlpha((0.95 * 255).toInt()),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 26),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "User reported. Thank you!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}