import 'package:flutter/material.dart';
import 'package:an_open_soul_app/widgets/custom_drawer.dart';
import 'package:an_open_soul_app/widgets/title_widget.dart';
import 'package:an_open_soul_app/widgets/chat_buttons.dart';
import 'package:an_open_soul_app/screens/nova_chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:an_open_soul_app/screens/people_chat_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedMood = -1;

  final List<String> moods = ["Very Bad", "Bad", "Neutral", "Okay", "Excellent"];
  final List<LinearGradient> moodGradients = [
    const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFFF7043)]),
    const LinearGradient(colors: [Color(0xFFFFA726), Color(0xFFFFD54F)]),
    const LinearGradient(colors: [Color(0xFF26A69A), Color(0xFF80CBC4)]),
    const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF90CAF9)]),
    const LinearGradient(colors: [Color(0xFFAB47BC), Color(0xFFCE93D8)]),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E24AA),
                  Color(0xFFF3D9FF),
                  Color(0xFF80DEEA),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
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
                child: const Text(
                  "❮",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Color.fromRGBO(211, 207, 207, 0.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
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
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.08),
                Image.asset(
                  'assets/images/logo.png',
                  width: 230,
                  height: 230,
                ),
                const SizedBox(height: 1),
                const TitleWidget(),
                Text(
                  "Find peace and support",
                  style: GoogleFonts.caveat(
                    fontSize: 36,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "How are you feeling today?",
                  style: GoogleFonts.irishGrover(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: screenWidth * 0.85,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: _selectedMood != -1 ? moodGradients[_selectedMood] : null,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Select an emoji",
                        style: GoogleFonts.caveat(
                          fontSize: 36,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMood = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _selectedMood == index ? Colors.white : Colors.transparent,
                                boxShadow: _selectedMood == index
                                    ? [
                                        const BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Image.asset(
                                _getAnimatedEmoji(index),
                                width: 50,
                                height: 50,
                              ),
                            ),
                          );
                        }),
                      ),
                      if (_selectedMood != -1)
                        Text(
                          "You selected: ${moods[_selectedMood]}",
                          style: GoogleFonts.caveat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedRoundButton(
                      text: 'Chat\nwith\nNova',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NovaChatScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 30),
                    AnimatedRoundButton(
  text: 'Chat\nwith\nPeople',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PeopleChatScreen(),
      ),
    );
  },
),


                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAnimatedEmoji(int index) {
    const List<String> emojiPaths = [
      'assets/emojis/very_bad.gif',
      'assets/emojis/bad.gif',
      'assets/emojis/neutral.gif',
      'assets/emojis/okay.gif',
      'assets/emojis/excellent.gif',
    ];
    return emojiPaths[index];
  }
}
