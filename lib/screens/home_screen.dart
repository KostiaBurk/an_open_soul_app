import 'dart:async';

import 'package:flutter/material.dart';
import 'package:an_open_soul_app/widgets/custom_drawer.dart';
import 'package:an_open_soul_app/widgets/title_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:an_open_soul_app/screens/people_chat_screen.dart' as people_screen;
import 'package:provider/provider.dart';
import 'package:an_open_soul_app/widgets/stars_background.dart';
import 'package:an_open_soul_app/providers/unread_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

 List<String> quotes = [
  "You are stronger than you think. You have gotten through every bad day in your life, and you are undefeated.",
  "Healing takes time, and asking for help is a courageous step.",
  "Even the darkest night will end, and the sun will rise.",
  "You don’t have to control your thoughts. You just have to stop letting them control you.",
  "Self-care is how you take your power back.",
  "You are not a drop in the ocean. You are the entire ocean in a drop.",
  "Fall seven times, stand up eight.",
  "It's okay to not be okay.",
  "You are enough just as you are.",
  "This too shall pass.",
  "Your present circumstances don’t determine where you go; they merely determine where you start.",
  "Be kind to yourself.",
  "You are not alone.",
  "Progress, not perfection.",
  "Take it one day at a time.",
  "Your mental health is a priority.",
  "You are more than your struggles.",
  "It's okay to ask for help.",
  "You are worthy of love and respect.",
  "Every day is a second chance.",
  "You have the power to change your story.",
  "You are not your thoughts.",
  "You are capable of amazing things.",
  "Believe in yourself.",
  "You matter.",
  "Your feelings are valid.",
  "You are doing the best you can.",
  "It's okay to take a break.",
  "You are not a burden.",
  "You are resilient.",
  "You are not defined by your mistakes.",
  "You are growing every day.",
  "You deserve happiness.",
  "You are not broken.",
  "You are healing.",
  "You are brave.",
  "You are not your anxiety.",
  "You are not your depression.",
  "You are not your trauma.",
  "You are not alone in this.",
  "You are not your past.",
  "You are not your illness.",
  "You are not your diagnosis.",
  "You are not your fears.",
  "You are not your insecurities.",
  "You are not your failures.",
  "You are not your emotions.",
  "You are not your pain.",
  "You are not your struggles.",
];

String currentQuote = "";
Timer? quoteTimer;

@override
void initState() {
  super.initState();
  quotes.shuffle();
  currentQuote = quotes.first;
  // Вызовем обновление интерфейса
  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {}); // заставит экран перерисоваться с currentQuote
  });

  quoteTimer = Timer.periodic(const Duration(minutes: 1), (_) => _setRandomQuote());
}
 

void _setRandomQuote() {
  setState(() {
    quotes.shuffle();
    currentQuote = quotes.first;
  });
}

@override
void dispose() {
  quoteTimer?.cancel();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = context.watch<UnreadProvider>().totalUnread;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: const CustomDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF12002E), Color(0xFF1D003A), Color(0xFF12002E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFE3C2FF), Color(0xFFFCE4FF), Color(0xFFE3C2FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
            child: Stack(
              children: [
                if (isDark) const Positioned.fill(child: _AppBarStarField()),
              ],
            ),
          ),
          title: const SizedBox(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(128, 0, 128, 0.9),
                            Color.fromRGBO(255, 255, 255, 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.menu, color: Colors.white, size: 24),
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
    body: Stack(
  children: [
    // Фон
    Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF12002E), Color(0xFF1D003A), Color(0xFF12002E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [Color(0xFFE3C2FF), Color(0xFFFCE4FF), Color(0xFFE3C2FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
    ),
    if (isDark) const AnimatedStarField(),

    // Основной контент
   // Основной контент
SafeArea(
  child: SingleChildScrollView(
    child: Column(
      children: [
        const SizedBox(height: 20),
        Image.asset('assets/images/logo.png', width: 230, height: 230),
        const SizedBox(height: 10),
        const TitleWidget(),
        Text(
          "Find peace and support",
          style: GoogleFonts.caveat(
            fontSize: 36,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 20),

        // Цитата
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.3 * 255).toInt()),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              currentQuote,
              style: GoogleFonts.mukta(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Кнопки
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _buildChatButton(
                  text: "Chat with Nova",
                  icon: Icons.android,
                  onTap: () => Navigator.pushNamed(context, '/nova'),
                ),
              ),
              const SizedBox(width: 15),
              Flexible(
                child: _buildChatButton(
                  text: "Chat with People",
                  icon: Icons.people,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const people_screen.PeopleChatScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),

  ],
),

      ),
    );
  }

Widget _buildChatButton({required String text, required IconData icon, required VoidCallback onTap}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 65,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF9400D3), Color(0xFF00FFFF)]
              : [Color(0xFF00B4DB), Color(0xFF8E2DE2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: isDark ? Color(0xFF9400D3).withAlpha((0.6 * 255).toInt()) : Color(0xFF00B4DB).withAlpha((0.4 * 255).toInt()),
            blurRadius: 20,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  }

class _AppBarStarField extends StatelessWidget {
  const _AppBarStarField();

  @override
  Widget build(BuildContext context) {
    final stars = List.generate(90, (_) => Star.random());

    return CustomPaint(
      painter: StarPainter(stars, const [], 0.0),
      size: Size.infinite,
    );
  }
}
