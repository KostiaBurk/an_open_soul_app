import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionProvider extends ChangeNotifier {
  String? _currentPlan;

  String? get currentPlan => _currentPlan;

  bool get isFree => _currentPlan == null || _currentPlan == 'Echo';
  bool get isPulse => _currentPlan == 'plan_pulse';
  bool get isNovaLink => _currentPlan == 'plan_novalink';

  SubscriptionProvider() {
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    _currentPlan = prefs.getString('activeSubscription');
    notifyListeners();
  }

  Future<void> updatePlan(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeSubscription', planId);
    _currentPlan = planId;
    notifyListeners();
  }

  Future<void> clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('activeSubscription');
    _currentPlan = null;
    notifyListeners();
  }
}
