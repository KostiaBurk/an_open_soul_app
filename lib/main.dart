import 'package:an_open_soul_app/screens/explore_yourself_screen.dart';
import 'package:an_open_soul_app/screens/search_user_screen.dart';
import 'package:an_open_soul_app/screens/subscription_screen.dart';
import 'package:an_open_soul_app/screens/tests/depression_result_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:an_open_soul_app/services/subscription_checker.dart';
import 'package:an_open_soul_app/services/subscription_service.dart';
import 'package:an_open_soul_app/providers/subscription_provider.dart';
import 'package:an_open_soul_app/services/trial_service.dart';



import 'package:an_open_soul_app/screens/splash_loading_screen.dart';
import 'package:an_open_soul_app/screens/welcome_screen.dart';
import 'package:an_open_soul_app/screens/auth_selection_screen.dart';
import 'package:an_open_soul_app/screens/home_screen.dart';
import 'package:an_open_soul_app/screens/my_chats_screen.dart';
import 'package:an_open_soul_app/screens/edit_profile_screen.dart';
import 'package:an_open_soul_app/screens/chat_screen.dart';
import 'package:an_open_soul_app/screens/chat_requests_screen.dart';

import 'package:an_open_soul_app/screens/privacy_security_screen.dart';
import 'package:an_open_soul_app/screens/about_app_screen.dart';
import 'package:an_open_soul_app/screens/help_support_screen.dart';
import 'package:an_open_soul_app/screens/email_verification_screen.dart';
import 'package:an_open_soul_app/screens/privacy_policy_screen.dart';
import 'package:an_open_soul_app/screens/delete_account_screen.dart';
import 'package:an_open_soul_app/screens/forgot_password_screen.dart';
import 'package:an_open_soul_app/screens/login_screen.dart';
import 'package:an_open_soul_app/screens/nova_chat_screen.dart';
import 'package:an_open_soul_app/screens/register_screen.dart';
import 'package:an_open_soul_app/screens/reset_password_screen.dart';
import 'package:an_open_soul_app/screens/manage_blocked_users_screen.dart';
import 'package:an_open_soul_app/screens/friends_screen.dart';

import 'package:an_open_soul_app/providers/theme_provider.dart';
import 'package:an_open_soul_app/providers/unread_provider.dart'; // 👈 добавь этот импорт

import 'package:an_open_soul_app/themes/dark_theme.dart';
import 'package:an_open_soul_app/providers/chat_provider.dart';
import 'package:an_open_soul_app/screens/tests/beck_depression_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final Logger _logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool hasNavigated = false;
String? pendingOobCodeFromLink;

class AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final isNowOnline = state == AppLifecycleState.resumed;

    // 1. Обновляем основной профиль пользователя
    await userDoc.set({
      'isOnline': isNowOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _logger.i(isNowOnline ? '🟢 User came online' : '🔴 User went offline');

    // 2. Обновляем статус isOnline в userChats у других пользователей
    final userChatsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('userChats')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (final chatDoc in userChatsSnapshot.docs) {
      await chatDoc.reference.update({
        'isOnline': isNowOnline,
      });
    }

    _logger.i('🔁 isOnline обновлён в ${userChatsSnapshot.docs.length} userChats');
  }
}


void waitAndNavigateToReset(String oobCode) {
  int attempts = 0;

  void tryNavigate() {
    if (!hasNavigated && navigatorKey.currentState != null) {
      hasNavigated = true;
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        '/resetPassword',
        (route) => false,
        arguments: {'oobCode': oobCode},
      );
      _logger.i('✅ Navigated immediately to /resetPassword with oobCode: $oobCode');
    } else {
      attempts++;
      if (attempts < 10) {
        Future.delayed(const Duration(milliseconds: 200), tryNavigate);
      } else {
        _logger.w('⏱️ Failed to navigate after 10 attempts');
      }
    }
  }

  tryNavigate();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  _logger.i('📲 onMessage СРАБОТАЛ');


  await Firebase.initializeApp();
  _logger.i('📩 Push из фона: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

 FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  _logger.i('📲 Push при открытом приложении: ${message.notification?.title}');

  final notification = message.notification;
  final android = message.notification?.android;

  if (notification != null && android != null) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // channel ID
      'High Importance Notifications', // channel name
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      
    );
  }
});


final token = await FirebaseMessaging.instance.getToken();
_logger.i('🎯 FCM Token: $token');

final user = FirebaseAuth.instance.currentUser;
if (user != null && token != null) {
  // Удаляем токен у других пользователей
  final query = await FirebaseFirestore.instance
      .collection('users')
      .where('fcmToken', isEqualTo: token)
      .get();

  for (final doc in query.docs) {
    if (doc.id != user.uid) {
      await doc.reference.update({'fcmToken': FieldValue.delete()});
      _logger.w('🧹 FCM Token удалён у другого пользователя: ${doc.id}');
    }
  }

  // Сохраняем токен у текущего пользователя
  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    'fcmToken': token,
  }, SetOptions(merge: true));
  _logger.i('✅ FCM Token saved to Firestore for ${user.uid}');
}


  final lifecycleObserver = AppLifecycleObserver();
  WidgetsBinding.instance.addObserver(lifecycleObserver);
  final subscriptionService = SubscriptionService();
subscriptionService.listenToPurchaseUpdates(
onPlanRestored: (productId) async {
  _logger.i('🔁 Restored subscription: $productId');

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('activeSubscription', productId);

  // 🔒 Безопасный способ использовать context
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final provider = Provider.of<SubscriptionProvider>(context, listen: false);
      provider.updatePlan(productId);
    } else {
      _logger.w('⚠️ Context is null when trying to update subscription plan.');
    }
  });
},

  onError: (purchase) {
    _logger.e('❌ Error during subscription restore: ${purchase.error}');
  },
);

// Восстанавливаем покупки (это вызовет стрим)
await SubscriptionChecker().restoreUserPurchases();
FirebaseAuth.instance.authStateChanges().listen((user) async {
  if (user != null) {
    await TrialService.checkTrialStatus(user.uid);
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (_) => false);
  }
});



  const MethodChannel channel = MethodChannel('universal_link_channel');
  _logger.i('👂 Listening for universal links');
  String? initialOobCode;

  channel.setMethodCallHandler((call) async {
    if (call.method == 'handleUniversalLink') {
      final String link = call.arguments as String;
      final Uri uri = Uri.parse(link);
      final oobCode = uri.queryParameters['oobCode'];
      final mode = uri.queryParameters['mode'];

      _logger.i('🌐 Received link: $link');
      _logger.i('🔎 Extracted mode: $mode');
      _logger.i('🔑 Extracted oobCode: $oobCode');

      if (oobCode != null && oobCode.isNotEmpty) {
        pendingOobCodeFromLink = link;

        if (mode == 'resetPassword') {
          _logger.i('🔄 Mode is resetPassword. Navigating to reset password screen.');
          waitAndNavigateToReset(oobCode);
        } else if (mode == 'verifyEmail') {
          _logger.i('📬 Mode is verifyEmail. Attempting to verify email.');
          try {
            await FirebaseAuth.instance.applyActionCode(oobCode);
            _logger.i('✅ Email verification successful. Reloading user state.');
            await FirebaseAuth.instance.currentUser?.reload();
            final user = FirebaseAuth.instance.currentUser;

            if (user != null && user.emailVerified) {
              _logger.i('✅ User email is verified. Navigating to login screen.');
              navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
            } else {
              _logger.w('⚠️ User email is not verified after reload. Showing error screen.');
              navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (_) => const ErrorScreen(message: 'Email verification failed. Please try again.'),
              ));
            }
          } on FirebaseAuthException catch (e) {
            _logger.e('❌ FirebaseAuthException during email verification: ${e.code} | ${e.message}');
            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (_) => const ErrorScreen(message: 'Email verification failed. Try again later.'),
            ));
          } catch (e) {
            _logger.e('🔥 Unexpected error during email verification: $e');
            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (_) => const ErrorScreen(message: 'An unexpected error occurred. Please try again later.'),
            ));
          }
        } else {
          _logger.w('⚠️ Unsupported mode received: $mode');
        }
      } else {
        _logger.w('⚠️ Link received, but oobCode is missing or empty.');
      }
    }
  });

  try {
    final String? pendingLink = await channel.invokeMethod<String>('getInitialLink');
    _logger.i('🔥 Initial link on launch: $pendingLink');

    if (pendingLink != null) {
      final uri = Uri.parse(pendingLink);
      final oobCode = uri.queryParameters['oobCode'];
      final mode = uri.queryParameters['mode'];

      if (oobCode != null && oobCode.isNotEmpty) {
        pendingOobCodeFromLink = pendingLink;

        if (mode == 'resetPassword') {
          waitAndNavigateToReset(oobCode);
        } else if (mode == 'verifyEmail') {
          _logger.i('📬 Email verification mode detected via link');
          try {
            await FirebaseAuth.instance.applyActionCode(oobCode);
            await FirebaseAuth.instance.currentUser?.reload(); // Обновляем состояние пользователя
            final user = FirebaseAuth.instance.currentUser;

            if (user != null && user.emailVerified) {
              _logger.i('✅ Email verified successfully');
              navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
            } else {
              _logger.w('❌ Email verification failed: User not verified after reload');
              navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (_) => const ErrorScreen(message: 'Email verification failed. Please try again.'),
              ));
            }
          } on FirebaseAuthException catch (e) {
            _logger.w('❌ Failed to verify email: ${e.code}');
            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (_) => const ErrorScreen(message: 'Email verification failed. Please try again.'),
            ));
          }
        }
      }
    }
  } catch (e) {
    _logger.w('⚠️ Failed to get initial link: $e');
  }
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();

const InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsIOS,
);

const AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(androidNotificationChannel);


await flutterLocalNotificationsPlugin
  .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.createNotificationChannel(androidNotificationChannel); // ✅




await flutterLocalNotificationsPlugin.initialize(initializationSettings);

FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  final data = message.data;
  final context = navigatorKey.currentContext;

  // Пример: если ты хочешь перейти на ChatScreen
  if (data.containsKey('chatId') && context != null) {
    final chatId = data['chatId'];
    final userId = data['userId'];
    final userName = data['userName'];
    final mediaPath = data['mediaPath'] ?? '';

    navigatorKey.currentState?.pushNamed('/chatScreen', arguments: {
      'chatId': chatId,
      'userId': userId,
      'userName': userName,
      'mediaPath': mediaPath,
    });
  }

  // Пример: если это запрос в друзья
  if (data['type'] == 'friend_request' && context != null) {
    navigatorKey.currentState?.pushNamed('/chatRequests');
  }

  // Можно добавлять другие типы
});


  runApp(
    MultiProvider(
     providers: [
  ChangeNotifierProvider(create: (_) => ChatProvider()),
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ChangeNotifierProvider(create: (_) => UnreadProvider()..startListening()), // 👈 добавили
  ChangeNotifierProvider(create: (_) => SubscriptionProvider()),

],

      child: MyApp(initialOobCode: initialOobCode),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (pendingOobCodeFromLink != null && !hasNavigated && navigatorKey.currentState != null) {
      final uri = Uri.parse(pendingOobCodeFromLink!);
      final mode = uri.queryParameters['mode'];
      final oobCode = uri.queryParameters['oobCode'];

      if (mode == 'resetPassword') {
        hasNavigated = true;
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          '/resetPassword',
          (route) => false,
          arguments: {'oobCode': oobCode},
        );
        pendingOobCodeFromLink = null;
      }
    }
  });
}

class MyApp extends StatelessWidget {
  final String? initialOobCode;
  const MyApp({super.key, this.initialOobCode});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'An Open Soul',
          debugShowCheckedModeBanner: false,
          theme: darkTheme,
themeMode: ThemeMode.dark,

          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashLoadingScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/authSelection': (context) => const AuthSelectionScreen(),
            '/auth': (context) => const AuthSelectionScreen(),
            '/myChats': (context) => const MyChatsScreen(),
            '/chatRequests': (context) => const ChatRequestsScreen(),
            '/explore': (context) => const ExploreYourselfScreen(),

            '/privacy': (context) => const PrivacySecurityScreen(),
            '/aboutApp': (context) => const AboutAppScreen(),
            '/helpSupport': (context) => const HelpSupportScreen(),
            '/privacyPolicy': (context) => const PrivacyPolicyScreen(),
            '/verifyEmail': (context) => const EmailVerificationScreen(),
            '/register': (context) => const RegisterScreen(),
            '/manageBlockedUsers': (context) => const ManageBlockedUsersScreen(),
            '/deleteAccount': (context) => const DeleteAccountScreen(),
            '/forgotPassword': (context) => const ForgotPasswordScreen(),
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/nova': (context) => const NovaChatScreen(),
            '/searchUser': (_) => const SearchUserScreen(),
            '/friends': (context) => const FriendsScreen(),
            '/stressInsight': (context) => const BeckDepressionScreen(),
            '/subscription': (context) => const SubscriptionScreen(),


            '/depressionResult': (context) {
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  final int score = args?['score'] ?? 0;

  return DepressionResultScreen(score: score);
},



            '/resetPassword': (context) {
              try {
                final args = ModalRoute.of(context)?.settings.arguments as Map?;
                final oobCode = args?['oobCode'] ?? initialOobCode;
                if (oobCode == null || oobCode.toString().trim().isEmpty) {
                  debugPrint("❌ No oobCode received");
                  return const Scaffold(
                    body: Center(child: Text('Invalid or missing reset link')),
                  );
                }
                debugPrint("✅ Received oobCode: $oobCode");
                return ResetPasswordScreen(oobCode: oobCode);
              } catch (e) {
                debugPrint("🔥 Error in /resetPassword route: $e");
                return const Scaffold(
                  body: Center(child: Text('Error loading reset screen')),
                );
              }
            },
          },
          onGenerateRoute: (settings) {
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            switch (settings.name) {
              case '/editProfile':
                return MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    initialUsername: args['initialUsername'] ?? '',
                    initialBio: args['initialBio'] ?? '',
                  ),
                );
          case '/chatScreen':
  if (!args.containsKey('userId')) {
    return MaterialPageRoute(
      builder: (context) => const ErrorScreen(message: 'Missing userId argument'),
    );
  }

  final String userId = args['userId'] ?? '';
  final String userName = args['userName'] ?? 'Anonymous';
  final String mediaPath = args['mediaPath'] ?? '';
  final String? chatId = args['chatId'];

  // 👇 ДОБАВЬ ЭТО
  debugPrint('🧭 Navigating to ChatScreen:');
  debugPrint('   userId: $userId');
  debugPrint('   userName: $userName');
  debugPrint('   mediaPath: $mediaPath');
  debugPrint('   chatId: $chatId');

  return MaterialPageRoute(
    builder: (context) => ChatScreen(
      userId: userId,
      userName: userName,
      mediaPath: mediaPath,
      chatId: chatId,
    ),
  );


              default:
                return MaterialPageRoute(
                  builder: (context) => ErrorScreen(message: 'Route not found: ${settings.name}'),
                );
            }
          },
        );
      },
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;
  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(message, style: const TextStyle(fontSize: 18, color: Colors.red)),
      ),
    );
  }
}

void logDebug(String message) {
  if (!const bool.fromEnvironment('dart.vm.product')) {
    _logger.d(message);
  }
}

Future<void> sendVerificationEmail() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://an-open-soul.web.app/verifyEmail.html',

          handleCodeInApp: false, // 👈 обязательно false
          androidPackageName: 'com.anopensoul.app',
          androidMinimumVersion: '1',
          androidInstallApp: true,
          iOSBundleId: 'com.anopensoul.app',
        ),
      );
      _logger.i('✅ Verification email sent to ${user.email}');
    } else {
      _logger.w('⚠️ No user is currently signed in.');
    }
  } catch (e) {
    _logger.e('❌ Failed to send verification email: $e');
  }
}


Future<void> sendPasswordResetEmail(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: 'https://an-open-soul.web.app/resetPassword',
        handleCodeInApp: true,
        androidPackageName: 'com.anopensoul.app',
        androidMinimumVersion: '1',
        androidInstallApp: true,
        iOSBundleId: 'com.anopensoul.app',
      ),
    );
    _logger.i('✅ Password reset email sent to $email');
  } catch (e) {
    _logger.e('❌ Failed to send password reset email: $e');
  }
}
