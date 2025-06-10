import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:an_open_soul_app/models/user_plan.dart'; // ← используем основной enum

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;

  bool _available = false;
  List<ProductDetails> _products = [];
  final List<String> _productIds = ['plan_pulse', 'plan_novalink'];

  List<ProductDetails> get products => _products;

  Future<void> init() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('In-app purchases not available');
      return;
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds.toSet());
    if (response.error != null) {
      debugPrint('Error loading products: ${response.error}');
      return;
    }

    _products = response.productDetails;
    debugPrint('Loaded products: $_products');
  }

  Future<void> buy(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void listenToPurchaseUpdates({
    required void Function(String productId) onPlanRestored,
    required void Function(PurchaseDetails purchase) onError,
  }) {
    _iap.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
          onPlanRestored(purchase.productID);
        } else if (purchase.status == PurchaseStatus.error) {
          onError(purchase);
        }
      }
    });
  }

  Future<UserPlan> getUserPlan(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('subscriptions').doc(uid).get();

    if (!doc.exists) return UserPlan.echo;

    final data = doc.data();
    final plan = data?['plan'] ?? 'echo';

    switch (plan) {
      case 'pulse':
        return UserPlan.pulse;
      case 'novaLink':
        return UserPlan.novaLink;
      default:
        return UserPlan.echo;
    }
  }
}
