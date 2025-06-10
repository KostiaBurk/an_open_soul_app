import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UnreadProvider extends ChangeNotifier {
  int _totalUnread = 0;
  int get totalUnread => _totalUnread;

  void startListening() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('userChats')
        .snapshots()
        .listen((snapshot) {
      int count = 0;
  for (final doc in snapshot.docs) {
  final data = doc.data();
  count = count + ((data['unreadCount'] ?? 0) as num).toInt();
}


      _totalUnread = count;
      notifyListeners();
    });
  }
}
