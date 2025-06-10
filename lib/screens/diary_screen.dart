import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:an_open_soul_app/utils/audio_recorder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'diary_entry_screen.dart';
import 'package:an_open_soul_app/widgets/guest_access_dialog.dart';



import 'package:an_open_soul_app/widgets/show_audio_player_dialog.dart';



class DiaryScreen extends StatefulWidget {
  final bool isGuest;

  const DiaryScreen({super.key, this.isGuest = false});


  @override
  DiaryScreenState createState() => DiaryScreenState();
}

class DiaryScreenState extends State<DiaryScreen> with SingleTickerProviderStateMixin {
  late Map<DateTime, List<Map<String, dynamic>>> _diaryEntries;
  late DateTime _selectedDate;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _diaryEntries = {};

    _audioPlayer.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playAndRecord,
        options: {AVAudioSessionOptions.defaultToSpeaker},
      ),
    ));

    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loadDiaryEntries(_selectedDate);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final time = timestamp.toDate();
      return DateFormat.jm().format(time);
    }
    return '';
  }

  Future<void> _loadDiaryEntries(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dateFormatted = DateFormat('MMMM d, yyyy').format(date);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('diaryEntries')
        .where('date', isEqualTo: dateFormatted)
        .orderBy('createdAt', descending: true)
        .get();

    final entries = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'entryId': doc.id,
        'type': data['type'] ?? 'text',
        'title': data.containsKey('title') ? data['title'] : '',
        'content': data['content'],
        'date': data['date'],
        'createdAt': data['createdAt'],
      };
    }).toList();

    if (!mounted) return;
    setState(() {
      _diaryEntries[date] = entries;
    });
  }



  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDate = day;
    });
    _loadDiaryEntries(day);
  }

 void _addNewEntry() {
  if (widget.isGuest) {
  showGuestAccessDialog(context);
  return;
}


  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DiaryEntryScreen(
        selectedDate: _selectedDate,
      ),
    ),
  ).then((newEntry) {
    if (newEntry != null) {
      _loadDiaryEntries(_selectedDate);
    }
  });
}





  Future<void> _toggleRecording() async {
   if (widget.isGuest) {
  showGuestAccessDialog(context);
  return;
}


    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_isRecording) {
      String? audioUrl = await _audioRecorder.stopRecording();
      setState(() => _isRecording = false);
      _animationController.stop();

      final dateFormatted = DateFormat('MMMM d, yyyy').format(_selectedDate);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('diaryEntries')
          .add({
        'type': 'audio',
        'content': audioUrl,
        'date': dateFormatted,
        'createdAt': Timestamp.now(),
      });

      _loadDiaryEntries(_selectedDate);
        } else {
      await _audioRecorder.startRecording();
      setState(() => _isRecording = true);
      _animationController.repeat(reverse: true);
    }
  }

Future<void> _deleteEntry(String entryId) async {
  if (widget.isGuest) {
  showGuestAccessDialog(context);
  return;
}


  final confirm = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Delete Entry',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_forever, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text(
                  'Delete Entry?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to delete this diary entry?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: child,
      );
    },
  );

  if (confirm == true) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('diaryEntries')
        .doc(entryId)
        .delete();

    if (!mounted) return; // Проверяем, монтирован ли виджет
    _loadDiaryEntries(_selectedDate);
  }
}




 void _showEditDialog(Map<String, dynamic> entry) async {
  if (widget.isGuest) {
  showGuestAccessDialog(context);
  return;
}


  final titleController = TextEditingController(text: entry['title'] ?? '');
  final contentController = TextEditingController(text: entry['content']);

  final navigator = Navigator.of(context); // сохранён ДО await

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Edit Entry',
    barrierColor: Colors.black.withAlpha(128)
, // затемнение
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(51, 0, 0, 0)
,
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Entry',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => navigator.pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final newTitle = titleController.text.trim();
                          final newContent = contentController.text.trim();

                          if (newContent.isNotEmpty) {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('diaryEntries')
                                .doc(entry['entryId'])
                                .update({
                              'title': newTitle,
                              'content': newContent,
                            });

                            if (!mounted) return;
                            navigator.pop(); // безопасно
                            _loadDiaryEntries(_selectedDate);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E24AA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text('Save'),
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
    transitionBuilder: (context, animation, _, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: child,
      );
    },
  );
}



 @override
Widget build(BuildContext context) {
  return Scaffold(
   appBar: PreferredSize(
  preferredSize: const Size.fromHeight(60),
  child: Container(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top,
      bottom: 10,
      left: 8,
      right: 8,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark ? Colors.black : const Color(0xFF8E24AA),
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
            "My Diary",
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
),

    resizeToAvoidBottomInset: false,
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
  gradient: Theme.of(context).brightness == Brightness.dark
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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "fab_add",
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _addNewEntry,
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1 + _animationController.value * 0.15,
                          child: FloatingActionButton(
                            heroTag: "fab_record",
                            backgroundColor: _isRecording ? Colors.red : Colors.blue,
                            onPressed: _toggleRecording,
                            child: Icon(_isRecording ? Icons.stop : Icons.mic),
                          ),
                        );
                      },
                    ),
                    if (_isRecording)
                      const Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: Text("Recording...", style: TextStyle(color: Colors.redAccent)),
                      )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color.fromARGB(255, 22, 167, 155).withAlpha(60),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _selectedDate,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                onDaySelected: _onDaySelected,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _diaryEntries[_selectedDate]?.isEmpty ?? true
                  ? const Center(child: Text('No entries for this day'))
                  : ListView.builder(
                      itemCount: _diaryEntries[_selectedDate]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final entry = _diaryEntries[_selectedDate]![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: entry['type'] == 'audio'
                                ? const Icon(Icons.audiotrack, color: Colors.deepPurple)
                                : null,
                            title: entry['type'] == 'audio'
                                ? const Text("Audio Entry")
                                : Text(entry['title']),
                            subtitle: Text("${entry['date']} • ${_formatTime(entry['createdAt'])}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (entry['type'] == 'audio')
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () {
  final url = entry['content'];
  showAudioPlayerDialog(
    context: context,
    audioPlayer: _audioPlayer,
    url: url,
  );
},

                                  )
                                else if (entry['type'] == 'text')
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                                    onPressed: () => _showEditDialog(entry),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteEntry(entry['entryId']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}





}