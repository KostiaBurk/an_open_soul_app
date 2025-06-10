import 'package:cloud_firestore/cloud_firestore.dart';

class TrialService {
  static Future<bool> isUserInTrial(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;

    final isTrial = userDoc.data()?['isTrial'] as bool? ?? false;
    return isTrial;
  }

  static Future<int> daysLeftInTrial(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!userDoc.exists) return 0;

    final trialStart = userDoc.data()?['trialStart'] as Timestamp?;
    if (trialStart == null) return 0;

    final now = DateTime.now();
    final start = trialStart.toDate();
    final daysPassed = now.difference(start).inDays;
    final daysLeft = 7 - daysPassed;
    return daysLeft > 0 ? daysLeft : 0;
  }

  static Future<void> checkTrialStatus(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    final data = userDoc.data();
    final Timestamp? startTimestamp = data?['trialStart'];
    final bool isTrial = data?['isTrial'] ?? false;

    if (startTimestamp != null && isTrial) {
      final DateTime start = startTimestamp.toDate();
      final DateTime now = DateTime.now();
      final difference = now.difference(start).inDays;

      if (difference >= 7) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isTrial': false,
        });
      }
    }
  }
}
