import 'package:an_open_soul_app/widgets/stars_background.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
              "Privacy Policy", // 👈 Заменяй на нужный заголовок
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
                      colors: [Color(0xFF7B1FA2), Color(0xFF4DD0E1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 140, left: 16, right: 16, bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha((0.05 * 255).toInt())
                        : const Color.fromRGBO(255, 255, 255, 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.deepPurpleAccent.withAlpha((0.6 * 255).toInt()) : Colors.white30,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "An Open Soul — Privacy Policy",
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Last updated: March 31, 2025",
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle("1. Information We Collect", "📦"),
                          _sectionBody("• Email address\n• Full name (optional)\n• Messages sent within the app\n• Diary entries (text, audio, video)\n• Uploaded media files (photos/videos)\n• Technical info (device, OS version, logs)"),
                          _sectionTitle("2. How We Use Your Data", "🔧"),
                          _sectionBody("• Secure login\n• Chat and diary functionality\n• Analytics\n• App improvement\nWe never sell or share your data without consent."),
                          _sectionTitle("3. Data Storage & Security", "🔐"),
                          _sectionBody("Stored in Google Firebase with encryption and strict access control."),
                          _sectionTitle("4. Retention & Deletion", "🗑️"),
                          _sectionBody("You can request deletion any time: team.anopensoul@gmail.com"),
                          _sectionTitle("5. Your Rights", "⚖️"),
                          _sectionBody("• View / edit / delete\n• Withdraw consent\n• Request data export"),
                          _sectionTitle("6. Age Restriction", "🔞"),
                          _sectionBody("Only for users 16+. By using app, you confirm compliance."),
                          _sectionTitle("7. Legal Jurisdiction", "📍"),
                          _sectionBody("Province of Ontario, Canada governs this agreement."),
                          _sectionTitle("8. Changes to Policy", "🔄"),
                          _sectionBody("You'll be notified in-app or via email about significant changes."),
                          const SizedBox(height: 24),
                          Text(
                            "By using An Open Soul, you agree to this Privacy Policy & Terms of Use.",
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 6),
      child: Text(
        "$icon  $title",
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _sectionBody(String content) {
    return Text(
      content,
      style: GoogleFonts.roboto(
        fontSize: 15.5,
        height: 1.6,
        color: const Color.fromRGBO(255, 255, 255, 0.9),
      ),
    );
  }
}
