import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatefulWidget {
  final bool isGuest;
  const CustomDrawer({super.key, this.isGuest = false});

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer> {
  String username = "Username";
  String avatarUrl = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

 Future<void> _loadUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!mounted) return;
    if (doc.exists) {
      setState(() {
        username = doc.data()?['username'] ?? "Username";
        avatarUrl = doc.data()?['profileImageUrl'] ?? "";
      });
    }
  }
}


  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Log Out",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("No", style: TextStyle(color: Colors.grey)),
            ),
          TextButton(
  onPressed: () async {
    Navigator.pop(dialogContext);
    await FirebaseAuth.instance.signOut();
if (!mounted) return;
if (context.mounted) {
  Navigator.pushReplacementNamed(context, '/authSelection');
}

  },
  child: const Text("Yes", style: TextStyle(color: Colors.purple)),
),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1D1F21), Color(0xFF2C2C54), Color(0xFF1D1F21)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF8E24AA), Color(0xFFF3D9FF), Color(0xFF80DEEA)],
                    ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amber, width: 2.0),
                              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(2, 2))],
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.transparent,
                              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl.isEmpty
                                  ? const Icon(Icons.person, size: 64, color: Colors.white)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                  context,
                                  '/editProfile',
                                  arguments: {
                                    'initialUsername': username,
                                    'initialBio': 'Your current bio',
                                    'isGuest': widget.isGuest,
                                  },
                                )
                                .then((_) {
  if (!mounted) return;
  _loadUserData();
});

                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.edit, size: 14, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        username,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.amberAccent,
                          shadows: const [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black)],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildDrawerItem(Icons.home, "Home", context, "/home", widget.isGuest),
                _buildDrawerItem(Icons.message, "My Chats", context, "/myChats", widget.isGuest),
                //_buildDrawerItem(Icons.person_add, "Requests", context, "/chatRequests", widget.isGuest),
_buildDrawerItem(Icons.group, "Friends", context, "/friends", widget.isGuest),

                _buildDrawerItem(Icons.self_improvement, "Explore Yourself", context, "/explore", widget.isGuest),

                _buildDrawerItem(Icons.privacy_tip, "Privacy & Security", context, "/privacy", widget.isGuest),
                _buildDrawerItem(Icons.workspace_premium, "Subscribe / Plan", context, "/subscription", widget.isGuest),

                const Spacer(),
                const Divider(color: Colors.white70, thickness: 1, indent: 20, endIndent: 20),
                _buildDrawerItem(Icons.info, "About App", context, "/aboutApp", widget.isGuest),
                _buildDrawerItem(Icons.help, "Help & Support", context, "/helpSupport", widget.isGuest),
                _buildDrawerItem(Icons.policy, "Privacy Policy & Terms", context, "/privacyPolicy", widget.isGuest),
                
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white, size: 28),
                  title: Text(
                    "Log Out",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [Shadow(offset: Offset(1, 2), blurRadius: 2, color: Colors.black)],
                    ),
                  ),
                  onTap: () => _showLogoutConfirmationDialog(context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildDrawerItem(IconData icon, String title, BuildContext context, String route, bool isGuest) {
  final user = FirebaseAuth.instance.currentUser;

 if (route == "/myChats" && user != null) {
  final userChatsRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('userChats');

  return StreamBuilder<QuerySnapshot>(
    stream: userChatsRef.snapshots(),
    builder: (context, snapshot) {
      int totalUnreadUsers = 0;

      if (snapshot.hasData) {
        for (final doc in snapshot.data!.docs) {
          final unreadCount = doc['unreadCount'] ?? 0;
          if (unreadCount > 0) {
            totalUnreadUsers++;
          }
        }
      }

      return Stack(
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.white, size: 28),
            title: Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [Shadow(offset: Offset(1, 2), blurRadius: 2, color: Colors.black)],
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, route, arguments: {"isGuest": isGuest});
            },
          ),
          if (totalUnreadUsers > 0)
            Positioned(
              right: 20,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  totalUnreadUsers.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      );
    },
  );
}


  // обычный пункт меню
  return ListTile(
    leading: Icon(icon, color: Colors.white, size: 28),
    title: Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: const [Shadow(offset: Offset(1, 2), blurRadius: 2, color: Colors.black)],
      ),
    ),
    onTap: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, route, arguments: {"isGuest": isGuest});
    },
  );
}

}