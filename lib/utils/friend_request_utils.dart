import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestUtils {
  static Future<void> sendFriendRequest({
    required String toUserId,
    required String toUsername,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final fromUserId = currentUser.uid;

   final currentUserDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(fromUserId)
    .get();

final fromUsername = currentUserDoc.data()?['username'] ?? 'Anonymous';


    final requestDoc = FirebaseFirestore.instance
        .collection('friend_requests')
        .doc('${fromUserId}_$toUserId');

    final requestData = {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromUsername': fromUsername,
      'toUsername': toUsername,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    };

    await requestDoc.set(requestData);
  }
}
