import 'package:firebase_auth/firebase_auth.dart';

class GuestUtils {
  static bool get isGuest {
    final user = FirebaseAuth.instance.currentUser;
    return user == null;
  }
}
