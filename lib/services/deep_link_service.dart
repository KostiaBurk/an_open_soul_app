import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final MethodChannel _channel = const MethodChannel('universal_link_channel');
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  String? _pendingOobCode;
  bool _hasNavigated = false;

  Future<void> init() async {
    _channel.setMethodCallHandler(_handleMethodCall);

    try {
      final String? initialLink = await _channel.invokeMethod<String>('getInitialLink');
      if (initialLink != null) {
        final Uri uri = Uri.parse(initialLink);
        final code = uri.queryParameters['oobCode'];
        if (code != null && code.isNotEmpty) {
          _pendingOobCode = code;
        }
      }
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryNavigate();
    });
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'handleUniversalLink') {
      final String link = call.arguments;
      final Uri uri = Uri.parse(link);
      final code = uri.queryParameters['oobCode'];
      if (code != null && code.isNotEmpty) {
        _pendingOobCode = code;
        _tryNavigate();
      }
    }
  }

  void _tryNavigate() {
    if (_pendingOobCode != null && !_hasNavigated && navigatorKey.currentState != null) {
      _hasNavigated = true;
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        '/resetPassword',
        (route) => false,
        arguments: {'oobCode': _pendingOobCode},
      );
      _pendingOobCode = null;
    }
  }
}
