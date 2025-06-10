import 'package:an_open_soul_app/widgets/stars_background.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:an_open_soul_app/screens/change_password_screen.dart'; // ✅ Импортируем экран смены пароля

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
     appBar: PreferredSize(
  preferredSize: const Size.fromHeight(59),
  child: Stack(
    children: [
      // 🎨 Фон AppBar'а
      Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : const Color(0xFF8E24AA),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      // ✨ Звёзды поверх фона (только в тёмной теме)
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
              "Privacy & Security", // 👈 Заменяй на нужный заголовок
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSettingOption(
                  context,
                  icon: Icons.lock,
                  title: "Change Password",
                  subtitle: "Update your account password",
                  onTap: () {
                    debugPrint("Change Password tapped");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingOption(
                  context,
                  icon: Icons.visibility_off,
                  title: "Manage Blocked Users",
                  subtitle: "See who you have blocked",
                  onTap: () {
                    Navigator.pushNamed(context, "/manageBlockedUsers");
                  },
                ),
                _buildSettingOption(
                  context,
                  icon: Icons.delete_forever,
                  title: "Delete Account",
                  subtitle: "Permanently delete your account",
                  onTap: () {
                    Navigator.pushNamed(context, "/deleteAccount");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  }

 Widget _buildSettingOption(BuildContext context,
    {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
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
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
        ],
      ),
    ),
  );
}
