import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportBottomSheet extends StatefulWidget {
  final String userId;
  const ReportBottomSheet({super.key, required this.userId});

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final List<String> _selectedReasons = [];
  final TextEditingController _otherController = TextEditingController();
  final int _maxSelections = 3;

  final List<Map<String, dynamic>> _reasons = [
    {"icon": Icons.warning_amber_rounded, "text": "Inappropriate Content"},
    {"icon": Icons.bug_report, "text": "Harassment or Bullying"},
    {"icon": Icons.person_off, "text": "Fake Profile"},
    {"icon": Icons.gavel, "text": "Hate Speech or Discrimination"},
    {"icon": Icons.explicit, "text": "Sexual Content or Nudity"},
    {"icon": Icons.link, "text": "Spam or Scams"},
    {"icon": Icons.health_and_safety, "text": "Self-harm or Suicide concerns"},
    {"icon": Icons.child_care, "text": "Underage User"},
    {"icon": Icons.edit, "text": "Other"},
  ];

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_selectedReasons.isEmpty || _selectedReasons.length > _maxSelections) return false;
    if (_selectedReasons.contains("Other") && _otherController.text.trim().isEmpty) return false;
    return true;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
    ? const Color(0xDD1E1E1E) // Тёмная полупрозрачная подложка
    : const Color(0xEBFFFFFF), // Прежний светлый

                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SafeArea(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                     Center(
  child: Text(
    "Report User",
    style: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withAlpha((0.95 * 255).toInt())
          : Colors.black,
    ),
  ),
),

                      const SizedBox(height: 12),
                     Center(
  child: Text(
    "You can select up to 3 reasons:",
    style: TextStyle(
      fontSize: 16,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white70
          : Colors.black54,
    ),
  ),
),

                      const SizedBox(height: 16),
                      ..._reasons.map((reason) {
                        final text = reason['text'];
                        final icon = reason['icon'];
                        final isSelected = _selectedReasons.contains(text);
                        final isDisabled = !isSelected && _selectedReasons.length >= _maxSelections;

                        return GestureDetector(
                          onTap: isDisabled
                              ? null
                              : () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedReasons.remove(text);
                                    } else {
                                      _selectedReasons.add(text);
                                    }
                                  });
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
    ? (Theme.of(context).brightness == Brightness.dark
        ? const Color(0x33FF5252)
        : const Color(0x1AFF5252))
    : (Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2C2C2E)
        : Colors.grey.shade100),

                              border: Border.all(
                                color: isSelected ? Colors.redAccent : Colors.transparent,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(icon, color: Colors.redAccent),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    text,
                                   style: TextStyle(
  fontSize: 16,
  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  color: isDisabled
      ? Colors.grey
      : Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black87,
),


                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Colors.redAccent),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (_selectedReasons.contains("Other"))
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: TextField(
                            controller: _otherController,
                            maxLines: null,
                            minLines: 3,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: "Please describe the issue...",
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF2C2C2C)
    : Colors.white,

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 248, 95, 95)),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _canSubmit ? Colors.redAccent : Colors.grey.shade400,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _canSubmit
                                ? () async {
                                    final ctx = context;
                                    _showCustomSuccessMessage(ctx, "User reported. Thank you!");

                                    final currentUser = FirebaseAuth.instance.currentUser;
                                    final reporterId = currentUser?.uid ?? 'guest';

                                    final reporterSnapshot = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(reporterId)
                                        .get();
                                    final reporterUsername =
                                        reporterSnapshot.data()?['username'] ?? 'Unknown';

                                    final reportedSnapshot = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.userId)
                                        .get();
                                    final reportedUsername =
                                        reportedSnapshot.data()?['username'] ?? 'Unknown';

                                    await FirebaseFirestore.instance.collection('reports').add({
                                      'reporterId': reporterId,
                                      'reporterUsername': reporterUsername,
                                      'reportedUserId': widget.userId,
                                      'reportedUsername': reportedUsername,
                                      'reasons': _selectedReasons,
                                      'otherText': _selectedReasons.contains("Other")
                                          ? _otherController.text.trim()
                                          : null,
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });

                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (mounted) Navigator.pop(ctx);
                                    });
                                  }
                                : null,
                            child: const Text("Report",
                                style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}