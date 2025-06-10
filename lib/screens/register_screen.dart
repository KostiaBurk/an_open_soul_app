import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _soulnameController = TextEditingController();
  final RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~]).{6,}$');


  final Logger _logger = Logger();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isEmailValid = true;
  bool _isPasswordMismatch = false;
bool _isSoulnameEmpty = false;
bool _isSoulnameTaken = false;
bool _isWeakPassword = false;






   Future<bool> _showPrivacyAndTermsDialog() async {
    bool accepted = false;
    bool showCheckbox = false;
    final ScrollController scrollController = ScrollController();

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            scrollController.addListener(() {
              if (scrollController.offset >= scrollController.position.maxScrollExtent && !showCheckbox) {
                setState(() => showCheckbox = true);
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xFF1E1E2C),
              title: const Text(
                "Privacy Policy & Terms of Use",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                width: double.maxFinite,
                child: Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: scrollController,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: const Text(
                            "Welcome to An Open Soul.\n\nWe value your privacy and are committed to protecting your personal data.\n\nInformation We Collect:\n- Email Address\n- Full Name (optional)\n- Messages sent within the app\n- Diary entries (text, audio, video)\n- Uploaded media files (photos/videos)\n\nHow We Use Your Data:\n- To provide a personalized experience\n- To secure communication and prevent abuse\n- To enable synchronization across devices\n- To analyze app performance and improve quality\n\nData Storage & Security:\n- All user data is securely stored using Firebase services.\n- We use authentication, encryption, and secure transfer protocols.\n- Your data is never shared with third parties without your explicit consent.\n\nData Retention:\n- Data is retained as long as your account is active.\n- You can request data deletion by emailing team.anopensoul@gmail.com.\n\nYour Rights:\n- You may access, update, or delete your personal data.\n- You may withdraw consent at any time.\n\nAge Restriction:\n- Use of the app is limited to users aged 16 or older.\n\nCookies and Tracking:\n- We do not use cookies or track users outside the app.\n\nDisclaimer:\n- While we strive to protect your data, no system is 100% secure. Use the app at your own discretion.\n\nBy tapping Continue, you confirm you have read, understood, and agree to our Privacy Policy and Terms of Use.\n\nThis agreement is governed by the laws of the Province of Ontario, Canada.",
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                    if (showCheckbox)
                      Row(
                        children: [
                          Checkbox(
                            value: accepted,
                            onChanged: (value) => setState(() => accepted = value ?? false),
                            checkColor: Colors.white,
                            activeColor: Colors.blueAccent,
                          ),
                          const Expanded(
                            child: Text(
                              "I have read and agree to the Privacy Policy & Terms of Use",
                              style: TextStyle(fontSize: 13, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: accepted ? () => Navigator.pop(context, true) : null,
                  child: const Text("Continue", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    ).then((value) => value ?? false);
   }

   Future<void> _handleRegistration() async {
  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();
  final soulname = _soulnameController.text.trim().toLowerCase();

  final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
 
  


  // Валидация полей
  setState(() {
    _isEmailValid = emailRegex.hasMatch(email);
      _isPasswordMismatch = password != confirmPassword;

  _isWeakPassword = !passwordRegex.hasMatch(password);


    _isSoulnameEmpty = soulname.isEmpty;
    _isSoulnameTaken = false;
  });

  if (!_isEmailValid || _isPasswordMismatch || _isWeakPassword || _isSoulnameEmpty || name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {

    return;
  }

  try {
    final exists = await FirebaseFirestore.instance
        .collection('users')
        .where('soulname', isEqualTo: soulname)
        .get();

    if (exists.docs.isNotEmpty) {
      setState(() {
        _isSoulnameTaken = true;
      });
      return;
    }
  } catch (e) {
    _logger.e("❌ Error checking soulname uniqueness", error: e);
    return;
  }

  final accepted = await _showPrivacyAndTermsDialog();
  if (!accepted) return;

  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    _logger.i("✅ Registered as: ${userCredential.user?.email}");

    await userCredential.user?.sendEmailVerification(
  ActionCodeSettings(
    url: 'https://an-open-soul.web.app/verify-email-success',



    handleCodeInApp: false,
    iOSBundleId: 'com.anopensoul.app',
    androidPackageName: 'com.anopensoul.app',
    androidInstallApp: true,
    androidMinimumVersion: '1',
  ),
);


await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
  'email': email,
  'fullName': name,
  'soulname': soulname,
  'createdAt': FieldValue.serverTimestamp(),
  'isOnline': true,
  'lastSeen': FieldValue.serverTimestamp(),
  'trialStartedAt': FieldValue.serverTimestamp(), // ✅ заменили trialStart на правильное имя
  'isTrial': true,
  'messagesToday': {
    'gpt3': 0,
    'gpt35': 0,
    'gpt4': 0,
  },
  'lastMessageReset': FieldValue.serverTimestamp(),
});




    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/verifyEmail',
      arguments: {'email': email},
    );
} on FirebaseAuthException catch (e) {
  if (e.code == 'weak-password') {
    setState(() {
      _isWeakPassword = true;
    });
  } else if (e.code == 'email-already-in-use') {
    setState(() {
      _isEmailValid = false;
    });
    if (!mounted) return;
   
  }

  _logger.w("⚠️ FirebaseAuthException: ${e.code}");
}
 catch (e, stackTrace) {
    _logger.e("⚠ Unexpected error during registration", error: e, stackTrace: stackTrace);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFFE1BEE7), Color(0xFF4DD0E1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 5.0, color: Colors.black87, offset: Offset(2, 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign up to get started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(blurRadius: 3.0, color: Colors.black45, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField("Full Name", _nameController, false),
                  const SizedBox(height: 20),
                  _buildEmailField(),

                  const SizedBox(height: 20),
 Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _buildTextField("Soulname (e.g. openheart)", _soulnameController, false),
    if (_isSoulnameEmpty)
      _buildErrorText("Please enter a soulname"),
    if (_isSoulnameTaken)
      _buildErrorText("This soulname is already taken"),
  ],
 ),


                  const SizedBox(height: 20),
                 Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _buildPasswordField("Password", _passwordController, _isPasswordVisible, () {
      setState(() {
        _isPasswordVisible = !_isPasswordVisible;
      });
    }),
    if (_isWeakPassword)
      _buildErrorText("Password must be at least 6 characters, include one uppercase letter and one special symbol (!@#\$&*~)")

  ],
),

                  const SizedBox(height: 20),
                 Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _buildPasswordField("Confirm Password", _confirmPasswordController, _isConfirmPasswordVisible, () {
      setState(() {
        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
      });
    }),
    if (_isPasswordMismatch)
      _buildErrorText("Passwords do not match"),
  ],
 ),

                  const SizedBox(height: 30),
                  _buildButton("Sign Up", const Color(0xFF007AFF), _handleRegistration),
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
 Widget _buildErrorText(String message) {
  return Padding(
    padding: const EdgeInsets.only(top: 6, left: 4),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 0, 0, 1).withAlpha((0.85 * 255).toInt()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

 Widget _buildEmailField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 60,
        child: TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            final isValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value.trim());
            setState(() {
              _isEmailValid = isValid || value.trim().isEmpty;
            });
          },
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            labelText: "Email",
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Color.fromRGBO(0, 0, 0, 0.35), // Чёрный полупрозрачный фон

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: _isEmailValid
                  ? BorderSide.none
                  : const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            suffixIcon: !_isEmailValid
                ? const Icon(Icons.error_outline, color: Colors.redAccent)
                : null,
          ),
        ),
      ),
      if (!_isEmailValid)
  Padding(
    padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 247, 0, 0).withAlpha((0.6 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.25 * 255).toInt()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Text(
        "Please enter a valid email address",
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),

    ],
  );
 }



  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
    return SizedBox(
      height: 60,
      child: TextField(
  controller: controller,
  obscureText: isPassword,
  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
  decoration: InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70, fontSize: 16),
    hintStyle: const TextStyle(color: Colors.white38),
    filled: true,
    fillColor: Color.fromRGBO(0, 0, 0, 0.35), // Чёрный полупрозрачный фон

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),
 )

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isVisible, VoidCallback toggleVisibility) {
  return SizedBox(
    height: 60,
    child: TextField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: (_) {
  setState(() {
    _isPasswordMismatch = _passwordController.text != _confirmPasswordController.text;
    _isWeakPassword = !passwordRegex.hasMatch(_passwordController.text);

  });
},

      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
        ),
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        filled: true,
        fillColor: Color.fromRGBO(0, 0, 0, 0.35), // Чёрный полупрозрачный фон

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
            size: 20,
          ),
          onPressed: toggleVisibility,
        ),
      ),
    ),
  );
 }



  @override
 void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  _soulnameController.dispose(); // 👈 ДОБАВЬ ЭТО
  super.dispose();
}

}
