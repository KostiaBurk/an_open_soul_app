import 'package:an_open_soul_app/widgets/guest_access_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StorySection extends StatelessWidget {
  final TextEditingController controller;
  final bool showToOthers;
  final bool isGuest;
  final ValueChanged<bool> onSwitchChanged;

  const StorySection({
    super.key,
    required this.controller,
    required this.showToOthers,
    required this.isGuest,
    required this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Your Story"),
        const SizedBox(height: 8),
        _buildTextField(context, controller, "Share your journey...", maxLines: 6, isGuest: isGuest),
        const SizedBox(height: 19),
        Row(
          children: [
            Switch(
              value: showToOthers,
              onChanged: isGuest ? null : onSwitchChanged,
              activeColor: Colors.white,
              activeTrackColor: Colors.purpleAccent,
            ),
            const SizedBox(width: 8),
            Text(
              "Show my story to others",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        shadows: const [
          Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26),
        ],
      ),
    );
  }

Widget _buildTextField(BuildContext context, TextEditingController controller, String hint,
    {int maxLines = 1, required bool isGuest}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return TextField(
    controller: controller,
    maxLines: maxLines,
    onTap: () {
      if (isGuest) {
        FocusScope.of(context).unfocus();
        showGuestAccessDialog(context);
      }
    },
    readOnly: isGuest,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark
          ? const Color.fromARGB(180, 40, 40, 50)
          : const Color.fromRGBO(255, 255, 255, 0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      hintStyle: TextStyle(
        color: isDark ? Colors.white70 : const Color.fromRGBO(0, 0, 0, 0.6),
      ),
    ),
    style: TextStyle(
      color: isDark ? Colors.white : Colors.black87,
    ),
  );
}

}
