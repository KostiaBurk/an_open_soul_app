import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:an_open_soul_app/widgets/stars_background.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  late TabController _tabController;

 @override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);
  WidgetsBinding.instance.addObserver(this);
}


  Future<List<Map<String, dynamic>>> _getFriends() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final sent = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'accepted')
        .get();

    final received = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('toUserId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'accepted')
        .get();

    return [...sent.docs.map((doc) => doc.data()), ...received.docs.map((doc) => doc.data())];
  }

  Future<List<Map<String, dynamic>>> _getIncomingRequests() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('toUserId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> _getSentRequests() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _acceptRequest(String fromUserId, String toUserId) async {
    final batch = FirebaseFirestore.instance.batch();
    final doc = FirebaseFirestore.instance.collection('friend_requests').doc('${fromUserId}_$toUserId');
    batch.update(doc, {'status': 'accepted'});
    await batch.commit();
    setState(() {});
  }

  Future<void> _rejectRequest(String fromUserId, String toUserId) async {
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc('${fromUserId}_$toUserId')
        .update({'status': 'rejected'});
    setState(() {});
  }
Future<int> getUnreadCount(String chatId, String currentUserId) async {
  
  final snapshot = await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .where('receiverId', isEqualTo: currentUserId)
      .where('isRead', isEqualTo: false)
      .get();

  return snapshot.docs.length;
}

Widget _buildFriendTile(Map<String, dynamic> user, {bool isIncoming = false}) {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final otherUserId = user['fromUserId'] == currentUserId ? user['toUserId'] : user['fromUserId'];
  final isOnline = user['isOnline'] ?? false;

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
       return const Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: SizedBox(
    height: 70,
    child: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
        strokeWidth: 3,
      ),
    ),
  ),
);

      }

      final profileData = snapshot.data!.data() as Map<String, dynamic>;
      final name = profileData['username'] ?? 'Anonymous';
      final photoUrl = profileData['profileImageUrl'];

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.deepPurple.withAlpha((0.6 * 255).toInt()), Colors.purple.withAlpha((0.3 * 255).toInt())],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha((0.2 * 255).toInt()), blurRadius: 6, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  backgroundColor: Colors.deepPurple,
                  child: photoUrl == null
                      ? Text(name[0], style: const TextStyle(color: Colors.white))
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
   Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
      const SizedBox(height: 2),
      Row(
        children: [
          Icon(
            isOnline ? Icons.circle : Icons.circle_outlined,
            color: isOnline ? Colors.greenAccent : Colors.white38,
            size: 10,
          ),
          const SizedBox(width: 6),
          Builder(builder: (context) {
            String statusText;

            if (isOnline) {
              statusText = 'Online';
            } else {
              final lastSeen = profileData['lastSeen'];
              if (lastSeen != null && lastSeen is Timestamp) {
                final lastSeenDate = lastSeen.toDate();
                final difference = DateTime.now().difference(lastSeenDate);

                if (difference.inMinutes < 1) {
                  statusText = 'Last seen just now';
                } else if (difference.inMinutes < 60) {
                  statusText = 'Last seen ${difference.inMinutes} min ago';
                } else if (difference.inHours < 24) {
                  statusText = 'Last seen ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
                } else {
                  statusText = 'Last seen ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
                }
              } else {
                statusText = 'Offline';
              }
            }

            return Text(
              statusText,
              style: GoogleFonts.poppins(
                color: isOnline ? Colors.greenAccent : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            );
          }),
        ],
      ),
    ],
  ),
),



            isIncoming
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _acceptRequest(user['fromUserId'], user['toUserId']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectRequest(user['fromUserId'], user['toUserId']),
                      ),
                    ],
                  )
               : FutureBuilder<int>(
    future: getUnreadCount(
      ([currentUserId, otherUserId]..sort()).join("_"),
      currentUserId,
    ),
    builder: (context, snapshot) {
      final unreadCount = snapshot.data ?? 0;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              final sortedIds = [currentUserId, otherUserId]..sort();
              final chatId = '${sortedIds[0]}_${sortedIds[1]}';

              Navigator.pushNamed(context, '/chatScreen', arguments: {
                'userId': otherUserId,
                'userName': name,
                'mediaPath': '',
                'chatId': chatId,
              });
            },
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text("Chat"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 3,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    },
  ),

          ],
        ),
      );
    },
  );
}


Widget _buildEmptyState(IconData icon, String title, String subtitle) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: isDark ? Colors.white24 : Colors.black26),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
            SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    "Friends",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54)],
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
              ? const LinearGradient(colors: [Color(0xFF1D1F21), Color(0xFF2C2C54), Color(0xFF1D1F21)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
              : const LinearGradient(colors: [Color(0xFF8E24AA), Color(0xFFF3D9FF), Color(0xFF80DEEA)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          children: [
            const SizedBox(height: 120),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / 3;
                  return Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _tabController.animation!,
                        builder: (context, child) {
                          return Positioned(
                            left: _tabController.animation!.value * tabWidth,
                            top: 0,
                            bottom: 0,
                            width: tabWidth,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.withAlpha((0.2 * 255).toInt()),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _tabController.animation!,
                        builder: (context, child) {
                          return Row(
                            children: List.generate(3, (index) {
                              final labels = ['Friends', 'Requests', 'Pending'];
                              final animationValue = _tabController.animation!.value;
                              final isSelected = (animationValue - index).abs() < 0.5;

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => _tabController.animateTo(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    alignment: Alignment.center,
                                    child: Text(
                                      labels[index],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: isSelected ? Colors.white : Colors.white60,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
           Text(
  "Tap or swipe to switch between categories.",
  style: GoogleFonts.poppins(
    color: isDark ? Colors.white38 : Colors.black54,
    fontSize: 15,
  ),
),

            const SizedBox(height: 0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  FutureBuilder(
                    future: _getFriends(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final data = snapshot.data!;
                      if (data.isEmpty) return _buildEmptyState(Icons.group_outlined, "No friends yet", "Connect with others by sending requests.");
                   return RefreshIndicator(
  onRefresh: () async {
    setState(() {});
  },
  child: ListView(
    padding: const EdgeInsets.only(top: 10), // 👈 уменьшаешь или увеличиваешь это число
    physics: const AlwaysScrollableScrollPhysics(),
    children: data.map((user) => _buildFriendTile(user)).toList(),
  ),
);


                    },
                  ),
                  FutureBuilder(
                    future: _getIncomingRequests(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final data = snapshot.data!;
                      if (data.isEmpty) return _buildEmptyState(Icons.mail_outline, "No requests yet", "When someone sends you a request, it will appear here.");
                     return RefreshIndicator(
  onRefresh: () async {
    setState(() {}); // просто перезапускает FutureBuilder
  },
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: data.map((user) => _buildFriendTile(user)).toList(),
  ),
);

                    },
                  ),
                  FutureBuilder(
                    future: _getSentRequests(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final data = snapshot.data!;
                      if (data.isEmpty) return _buildEmptyState(Icons.pending_outlined, "No pending requests", "Requests you send will show up here until accepted.");
                      return RefreshIndicator(
  onRefresh: () async {
    setState(() {}); // просто перезапускает FutureBuilder
  },
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: data.map((user) => _buildFriendTile(user)).toList(),
  ),
);

                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  @override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
}
@override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

  if (state == AppLifecycleState.paused ||
      state == AppLifecycleState.inactive ||
      state == AppLifecycleState.detached) {
    await userDoc.update({
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': false,
    });
  } else if (state == AppLifecycleState.resumed) {
    await userDoc.update({'isOnline': true});
  }
}

}
