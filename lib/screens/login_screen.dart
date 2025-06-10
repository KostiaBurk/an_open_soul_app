import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger _logger = Logger();
  bool _isPasswordVisible = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password.');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(
  ActionCodeSettings(
    url: 'https://an-open-soul.web.app/verifyEmail.html',
    handleCodeInApp: false, // 👈 ОЧЕНЬ ВАЖНО: false!
    androidPackageName: 'com.anopensoul.app',
    androidMinimumVersion: '1',
    androidInstallApp: true,
    iOSBundleId: 'com.anopensoul.app',
  ),
);


        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Email Not Verified"),
            content: const Text("We’ve sent a verification email to your address. Please verify before continuing."),
            actions: [
            TextButton(
  onPressed: () async {
    await user.sendEmailVerification(
      ActionCodeSettings(
        url: 'https://an-open-soul.web.app/verifyEmail.html',
        handleCodeInApp: false, // обязательно false!
        androidPackageName: 'com.anopensoul.app',
        androidMinimumVersion: '1',
        androidInstallApp: true,
        iOSBundleId: 'com.anopensoul.app',
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
      _showError("Verification email sent again.");
    }
  },
  child: const Text("Resend"),
),

              TextButton(
                onPressed: () async {
                  await user.reload();
                  final refreshedUser = FirebaseAuth.instance.currentUser;
                  if (refreshedUser != null && refreshedUser.emailVerified) {
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/home', arguments: {'userName': refreshedUser.email});
                  } else {
                    if (!mounted) return;
                    _showError("Email still not verified.");
                  }
                },
                child: const Text("I've Verified"),
              ),
            ],
          ),
        );

        return;
      }

      _logger.i('✅ Logged in as: ${user?.email}');

// 🔥 Сохраняем FCM токен в Firestore
try {
  final messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    final fcmToken = await messaging.getToken();
    if (user != null && fcmToken != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': fcmToken});
      _logger.i('✅ FCM token saved: $fcmToken');
    }
  } else {
    _logger.w('⚠️ User declined or has not accepted permission');
  }
} catch (e) {
  _logger.w('⚠️ Failed to save FCM token: $e');
}


if (!mounted) return;
Navigator.pushReplacementNamed(context, '/home', arguments: {'userName': user?.email});

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      }

      _showError(errorMessage);
    } catch (e) {
      _showError('An unexpected error occurred.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7B1FA2),
              Color(0xFFE1BEE7),
              Color(0xFF4DD0E1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 5.0, color: Colors.black87, offset: Offset(2, 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(blurRadius: 3.0, color: Colors.black45, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField("Email", _emailController, false),
                  const SizedBox(height: 20),
                  _buildPasswordField("Password", _passwordController, _isPasswordVisible, () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  }),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgotPassword');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildButton("Sign In", const Color(0xFF007AFF), _handleLogin),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don’t have an account?', style: TextStyle(color: Colors.white, fontSize: 16)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
  return SizedBox(
    height: 56,
    child: TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 2.5,
            color: Colors.black87,
            offset: Offset(0, 1),
          ),
        ],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Color.fromRGBO(0, 0, 0, 0.35), // тёмный прозрачный фон

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}
Widget _buildPasswordField(String label, TextEditingController controller, bool isVisible, VoidCallback toggleVisibility) {
  return SizedBox(
    height: 56,
    child: TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 2.5,
            color: Colors.black87,
            offset: Offset(0, 1),
          ),
        ],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Color.fromRGBO(0, 0, 0, 0.35), // тёмный прозрачный фон

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: toggleVisibility,
        ),
      ),
    ),
  );
}




  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}