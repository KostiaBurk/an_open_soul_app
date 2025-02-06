import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:an_open_soul_app/widgets/custom_drawer.dart';
import 'package:an_open_soul_app/screens/chat_screen.dart';

class PeopleChatScreen extends StatefulWidget {
  const PeopleChatScreen({super.key});

  @override
  State<PeopleChatScreen> createState() => _PeopleChatScreenState();
}

class _PeopleChatScreenState extends State<PeopleChatScreen> {
  bool _showOnlyOnline = false;
  final List<Map<String, String>> _users = [
    {'name': 'Alice', 'status': 'Online'},
    {'name': 'Bob', 'status': 'Offline'},
    {'name': 'Charlie', 'status': 'Online'},
    {'name': 'Daisy', 'status': 'Offline'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          // Фон
          Container(
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
          // Кнопка назад
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
                ),
                alignment: Alignment.center,
                child: const Text(
                  "❮",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Кнопка меню
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
          // Заголовок
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 20,
            right: 20,
            child: Center(
              child: Stack(
                children: [
                  Text(
                    "Chat with People",
                    style: GoogleFonts.pacifico(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.black,
                    ),
                  ),
                  Text(
                    "Chat with People",
                    style: GoogleFonts.pacifico(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Тумблер "Online only"
          Positioned(
            top: MediaQuery.of(context).padding.top + 100,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Online only",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Switch(
                  value: _showOnlyOnline,
                  onChanged: (value) {
                    setState(() {
                      _showOnlyOnline = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          // Список пользователей
          Positioned(
            top: MediaQuery.of(context).padding.top + 150,
            left: 20,
            right: 20,
            bottom: 20,
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                if (_showOnlyOnline && _users[index]['status'] != 'Online') {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage('assets/images/avatar_placeholder.png'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _users[index]['name']!,
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _users[index]['status']!,
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: _users[index]['status'] == 'Online'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Looking for support",
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Иконка лайка (сердечко)
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                onPressed: () {
                                  // Добавить в избранное
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          // Кнопка отправки сообщения
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      userName: _users[index]['name']!,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Send Message',
                                style: GoogleFonts.roboto(fontSize: 14),
                              ),
                            ),
                          ),
                          // Кнопка блокировки
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.block, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Block User"),
                                    content: const Text("Are you sure you want to block this user?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          // Логика блокировки пользователя
                                        },
                                        child: const Text("Yes"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
