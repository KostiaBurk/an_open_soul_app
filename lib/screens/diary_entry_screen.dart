import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? existingEntry;
  final DateTime selectedDate;

  const DiaryEntryScreen({
    super.key,
    this.existingEntry,
    required this.selectedDate,
  });

  @override
  DiaryEntryScreenState createState() => DiaryEntryScreenState();
}

class DiaryEntryScreenState extends State<DiaryEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingEntry?['title'] ?? '');
    _contentController = TextEditingController(text: widget.existingEntry?['content'] ?? '');
  }

  Future<void> _saveEntry() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      final entryData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'date': widget.existingEntry?['date'] ??
            DateFormat('MMMM d, yyyy').format(widget.selectedDate),
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.existingEntry != null && widget.existingEntry!['entryId'] != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('diaryEntries')
            .doc(widget.existingEntry!['entryId'])
            .update(entryData);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('diaryEntries')
            .add(entryData);
      }

      if (!mounted) return;
      Navigator.pop(context, entryData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
            Column(
              children: [
                // ✅ Custom AppBar
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: 10,
                    left: 8,
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.transparent,
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
                          widget.existingEntry != null ? 'Edit Entry' : 'New Entry',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                // ✅ Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black.withAlpha(76),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.white60),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            labelText: 'Title',
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: TextField(
                            controller: _contentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black.withAlpha(76),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: Colors.white60),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              labelText: 'Content',
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            maxLines: 6,
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _saveEntry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E24AA),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Save Entry',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
