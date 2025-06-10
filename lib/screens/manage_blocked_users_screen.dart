import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageBlockedUsersScreen extends StatefulWidget {
  const ManageBlockedUsersScreen({super.key});

  @override
  ManageBlockedUsersScreenState createState() => ManageBlockedUsersScreenState();
}

class ManageBlockedUsersScreenState extends State<ManageBlockedUsersScreen> {
  List<String> blockedUsers = [
    "User 1",
    "User 2",
    "User 3",
    "User 4",
  ]; //  Заглушка, позже подключим базу данных

  void _unblockUser(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2C2C54) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Unblock \${blockedUsers[index]}?",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            "Are you sure you want to unblock this user?",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  blockedUsers.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text(
                "Unblock",
                style: GoogleFonts.poppins(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: 10,
            left: 8,
            right: 8,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : const Color(0xFF8E24AA),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Blocked Users",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Column(
            children: [
              Expanded(
                child: blockedUsers.isNotEmpty
                    ? ListView.builder(
                        itemCount: blockedUsers.length,
                        itemBuilder: (context, index) {
                          return _buildBlockedCard(context, index);
                        },
                      )
                    : Center(
                        child: Text(
                          "No blocked users",
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedCard(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = blockedUsers[index];

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
                  "Blocked user",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
            onPressed: () => _unblockUser(index),
          ),
        ],
      ),
    );
  }
}