import 'package:an_open_soul_app/widgets/stars_background.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Logger _logger = Logger();

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, // 👈 Важно!
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
              "Help & Support", // 👈 Заменяй на нужный заголовок
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
                const SizedBox(height: 10),
                Text(
                  "How can we help you?",
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(0x66),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "If you have any questions, issues, or need assistance, feel free to contact our support team.",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 30),
                _buildSupportItem(" How to use the app?", "Learn how to navigate and use all features effectively."),
                _buildSupportItem(" Reporting a problem", "Found a bug? Let us know and we'll fix it!"),
                _buildSupportItem(" Contact support", "Need direct assistance? Reach out to our team."),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showContactForm(context);
                    },
                    icon: const Icon(Icons.email, color: Colors.white),
                    label: Text(
                      "Contact Us",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      backgroundColor: isDark ? const Color(0xFF610159) : Color(0xFF8E24AA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.help_outline, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(0x66),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  return SingleChildScrollView(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      left: 20,
      right: 20,
      top: 20,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Contact Us",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: subjectController,
          decoration: InputDecoration(
            labelText: "Subject",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: messageController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: "Message",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            String subject = subjectController.text.trim();
            String message = messageController.text.trim();

            if (subject.isEmpty || message.isEmpty) {
              if (context.mounted) _showErrorDialog(context);
              return;
            }

            final user = FirebaseAuth.instance.currentUser;

            final data = {
              'subject': subject,
              'message': message,
              'timestamp': FieldValue.serverTimestamp(),
              'email': user?.email ?? 'guest',
              'uid': user?.uid ?? 'guest',
            };

            try {
              await FirebaseFirestore.instance.collection('support_messages').add(data);
              _logger.i("✅ Support message sent from ${data['email']}");
              if (context.mounted) {
                Navigator.pop(context);
                _showCustomSuccessMessage(context, "Your message has been sent!");
              }
            } catch (e) {
              _logger.e("❌ Failed to send message: $e");
              if (context.mounted) _showErrorDialog(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: const Text("Send", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
},

    );
  }

  void _showCustomSuccessMessage(BuildContext ctx, String message) {
    final overlay = Navigator.of(ctx, rootNavigator: true).overlay!;
    final overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(ctx).size.height * 0.4,
        left: MediaQuery.of(ctx).size.width * 0.1,
        right: MediaQuery.of(ctx).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.green.shade100.withAlpha((0.95 * 255).toInt()),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 26),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
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
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: const Text("Please fill in all fields"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
