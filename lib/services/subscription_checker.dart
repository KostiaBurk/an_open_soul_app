import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionChecker {
  Future<void> restoreUserPurchases() async {
    final iap = InAppPurchase.instance;

    final isStoreAvailable = await iap.isAvailable();
    if (!isStoreAvailable) return;

    await iap.restorePurchases();
  }

  Future<bool> isTrialActive(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final trialStart = doc.data()?['trialStartedAt']?.toDate();

    if (trialStart == null) return false;

    final now = DateTime.now();
    final difference = now.difference(trialStart).inDays;

    return difference < 7;
  }

  Future<bool> canSendMessage(String uid, String model, {bool isTrial = false}) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();

    if (data == null) return false;

    final messagesToday = Map<String, dynamic>.from(data['messagesToday'] ?? {});

    // Лимиты на сообщения в пробный период
    final trialLimits = {
      'gpt3': 30,    // Echo
      'gpt35': 20,   // Pulse
      'gpt4': 10,    // NovaLink
    };

    // Лимиты после покупки
    final paidLimits = {
      'pulse_gpt35': 1500,   // Pulse план
      'novalink_gpt4': 900,  // NovaLink план
    };

    final used = messagesToday[model] ?? 0;

    if (isTrial) {
      final limit = trialLimits[model];
      if (limit == null) return false;
      return used < limit;
    } else {
      final limit = paidLimits[model];
      if (limit == null) return false;
      return used < limit;
    }
  }

  Future<void> incrementMessageCount(String uid, String model) async {
    final field = 'messagesToday.$model';
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      field: FieldValue.increment(1),
    });
  }

  Future<void> resetDailyCountersIfNeeded(String uid) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final doc = await docRef.get();
    final data = doc.data();

    if (data == null) return;

    final lastReset = data['lastMessageReset']?.toDate();
    final now = DateTime.now();

    if (lastReset == null || now.difference(lastReset).inHours >= 24) {
      await docRef.update({
        'messagesToday': {
          'gpt3': 0,
          'gpt35': 0,
          'gpt4': 0,
        },
        'lastMessageReset': now,
      });
    }
  }
}
