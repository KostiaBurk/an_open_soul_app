import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'welcome_screen.dart';

class SplashLoadingScreen extends StatefulWidget {
  const SplashLoadingScreen({super.key});

  @override
  State<SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<SplashLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _handleInitialUniversalLink();

    Timer(const Duration(seconds: 4), _navigateToNextScreen);
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const WelcomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        var tween =
            Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);

        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    );
  }

  Future<void> _handleInitialUniversalLink() async {
    const channel = MethodChannel('universal_link_channel');

    try {
      final String? pendingLink =
          await channel.invokeMethod<String>('getInitialLink');
      if (pendingLink != null) {
        final uri = Uri.parse(pendingLink);
        final oobCode = uri.queryParameters['oobCode'];

        if (oobCode != null && oobCode.isNotEmpty && mounted) {
          Navigator.pushNamed(context, '/resetPassword',
              arguments: {'oobCode': oobCode});
          _hasNavigated = true;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error handling initial link: $e');
    }

    channel.setMethodCallHandler((call) async {
      if (call.method == 'handleUniversalLink') {
        final String link = call.arguments as String;
        final Uri uri = Uri.parse(link);
        final oobCode = uri.queryParameters['oobCode'];

        if (oobCode != null && oobCode.isNotEmpty && mounted) {
          Navigator.pushNamed(context, '/resetPassword',
              arguments: {'oobCode': oobCode});
          _hasNavigated = true;
        }
      }
    });
  }

  void _navigateToNextScreen() async {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacement(_createRoute());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1D1F21),
              Color(0xFF2C2C54),
              Color(0xFF1D1F21),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  height: 180,
                ),
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  "We’re opening the doors for you...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black26,
                        offset: Offset(0.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: Color.fromARGB(153, 255, 255, 255),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
