import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:an_open_soul_app/widgets/custom_drawer.dart';
import 'package:an_open_soul_app/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:an_open_soul_app/screens/user_profile_screen.dart';

class PeopleChatScreen extends StatefulWidget {
  const PeopleChatScreen({super.key});

  @override
  State<PeopleChatScreen> createState() => _PeopleChatScreenState();
}

class _PeopleChatScreenState extends State<PeopleChatScreen> {
  bool _showOnlyOnline = false;

  final List<Map<String, String>> _users = [
    {'id': 'uid_1', 'name': 'Alice', 'status': 'Online'},
    {'id': 'uid_2', 'name': 'Bob', 'status': 'Offline'},
    {'id': 'uid_3', 'name': 'Charlie', 'status': 'Online'},
    {'id': 'uid_4', 'name': 'Daisy', 'status': 'Offline'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      endDrawer: const CustomDrawer(),
      body: Stack(
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
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: _buildIcon(isDark, Icons.arrow_back, () => Navigator.pop(context)),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Builder(
              builder: (context) => _buildIcon(isDark, Icons.menu, () => Scaffold.of(context).openEndDrawer()),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  "Chat with People",
                  style: GoogleFonts.pacifico(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black.withAlpha(153), offset: const Offset(2, 2), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
             Align(
  alignment: Alignment.centerLeft,

  child: TextButton.icon(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.purple.withAlpha((0.2 * 255).toInt()),
    ),
    icon: const Icon(Icons.person_add_alt_1, size: 20, color: Colors.white),
    label: const Text("Add Friend", style: TextStyle(color: Colors.white)),
    onPressed: () {
      Navigator.pushNamed(context, '/searchUser');
    },
  ),
),

              ],
            ),
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 130,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Online only", style: TextStyle(color: Colors.white, fontSize: 18)),
                Switch(
                  value: _showOnlyOnline,
                  onChanged: (value) => setState(() => _showOnlyOnline = value),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 180,
            left: 20,
            right: 20,
            bottom: 20,
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                if (_showOnlyOnline && _users[index]['status'] != 'Online') {
                  return const SizedBox.shrink();
                }

                final user = _users[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(userId: user['id'] ?? 'default_id'),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isDark
                          ? Border.all(
                              color: const Color(0xFF8E24AA).withAlpha((0.6 * 255).toInt()),
                              width: 1.5,
                            )
                          : null,
                      boxShadow: [
                        if (isDark)
                          BoxShadow(
                            color: const Color(0xFF8E24AA).withAlpha((0.4 * 255).toInt()),
                            blurRadius: 12,
                            spreadRadius: 0.5,
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withAlpha((0.1 * 255).toInt()),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 30),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                user['status']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: user['status'] == 'Online' ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Looking for support",
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          color: isDark ? Colors.white70 : Colors.black87,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  userId: user['id']!,
                                  userName: user['name']!,
                                  chatId: '${FirebaseAuth.instance.currentUser?.uid}_${user['id']}',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(bool isDark, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(128, 0, 128, 0.9),
              Color.fromRGBO(255, 255, 255, 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
