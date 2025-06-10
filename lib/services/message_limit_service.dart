import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/user_plan.dart';

class MessageLimitService {
  static Future<int> getDailyLimit(UserPlan plan, {required String model}) async {
    if (plan == UserPlan.novaLink) return 150;
    if (plan == UserPlan.pulse) return 50;

    // Echo (бесплатный план)
    switch (model) {
      case 'gpt-4o':
        return 5;  // жёсткий лимит
      case 'gpt-3.5':
        return 10;
      default: // gpt-3.0
        return 20;
    }
  }

  static String _keyForModel(String model) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return 'messages_sent_${model}_$today';
  }

  static Future<int> getMessagesSentToday(String model) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForModel(model);
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> incrementMessagesSent(String model) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyForModel(model);
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // если нужно сбросить всё
  }
}
