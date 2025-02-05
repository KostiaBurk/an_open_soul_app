// Боковое меню, иконки, текст и т.д.

import 'package:flutter/material.dart';
import 'package:an_open_soul_app/screens/home_screen.dart';

 // Импортируем HomeScreen

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height,
        child: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
          ),
          elevation: 8,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8E24AA),
                  Color(0xFFF3D9FF),
                  Color(0xFF80DEEA),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amber,
                            width: 2.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person, size: 64, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Username",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 24,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(Icons.dashboard, "Home", context, () {
                  Navigator.pop(context); // Закрыть меню
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()), // Переход на HomeScreen
                  );
                }),
                _buildDrawerItem(Icons.message, "Chat", context, () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(Icons.tune, "Settings", context, () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(Icons.power_settings_new, "Log Out", context, () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 36,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.amber,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.black54,
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
