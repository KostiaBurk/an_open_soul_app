import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_plan.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получаем текущий план
  Future<UserPlan> getUserPlan() async {
    final user = _auth.currentUser;
    if (user == null) return UserPlan.echo;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    final planString = doc.data()?['plan'] ?? 'echo';
    return UserPlanExtension.fromString(planString);
  }

  // Обновляем план (например, после покупки подписки)
  Future<void> setUserPlan(UserPlan plan) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'plan': plan.firestoreValue,
    });
  }
}
