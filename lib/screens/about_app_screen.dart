import 'package:an_open_soul_app/widgets/stars_background.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final dividerColor = isDark ? Colors.grey[700] : Colors.grey[300];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(59),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          child: Stack(
            children: [
              Container(
                color: isDark ? Colors.black : const Color(0xFF8E24AA),
              ),
              if (isDark)
                const Positioned.fill(
                  child: AnimatedStarField(starCount: 40),
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
                      "About App",
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  "An Open Soul",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Version 1.0.0",
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 30),
                _section("🧭 Our Mission", "An Open Soul is a safe space to open your heart. Whether you're looking for understanding, support, or just someone to talk to — you're not alone."),
                _section("🧑‍🤝‍🧑 Who It's For", "• Anyone feeling overwhelmed\n• Those struggling with loneliness\n• People who need a kind word or motivation\n• Users who want to write or record their thoughts\n• Those who believe in human kindness"),
                _section("✨ What You Can Do", "• 💬 Chat with AI — when no one's around\n• 🧑‍🤝‍🧑 Chat with real people — you're not alone\n• 📖 Write or record in your personal diary\n• 🤍 Read & share personal stories\n• 🔐 Stay anonymous and safe"),
                _section("💫 Philosophy", "We don’t offer instant fixes. We provide space to breathe, to feel, to grow. A place where it’s okay not to be okay."),
                _section("👨‍💻 Creator", "Made with heart by Kostia Burkaltsev — for those who once felt they needed this too."),
                const SizedBox(height: 20),
                Divider(color: dividerColor),
                const SizedBox(height: 20),
                Text(
                  "Contact: team.anopensoul@gmail.com",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: isDark ? Colors.blue[200] : Colors.blue,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.3 * 255).toInt()), // 🌙 Полупрозрачная подложка
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: GoogleFonts.roboto(
                fontSize: 17,
                height: 1.6,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
