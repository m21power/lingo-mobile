import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lingo/features/About/presentation/pages/about_page.dart';
import 'package:lingo/features/About/presentation/pages/rules_page.dart';
import 'package:lingo/features/chat/presentation/pages/chat_page.dart';
import 'package:lingo/features/notifications/presentation/pages/notification_page.dart';
import 'package:lingo/features/profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [ProfilePage(), ChatPage(), NotificationPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF121212), // Telegram dark background

      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color.fromARGB(255, 30, 35, 45), // dark background
            onSelected: (value) {
              if (value == 'rules') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RulesPage()),
                );
              } else if (value == 'about') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'rules',
                child: Row(
                  children: const [
                    Icon(Icons.rule, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text('Rules', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'about',
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text('About', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Lingo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: GNav(
                backgroundColor: Colors.transparent,
                color: Colors.grey[400],
                activeColor: Colors.white,
                iconSize: 24,
                tabBorderRadius: 16,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                tabBackgroundColor: Colors.blueAccent.withOpacity(0.5),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                gap: 8,
                selectedIndex: _selectedIndex,
                onTabChange: (index) => setState(() => _selectedIndex = index),
                tabs: const [
                  GButton(icon: Icons.person, text: 'Profile'),
                  GButton(icon: Icons.chat, text: 'Chat'),
                  GButton(icon: Icons.notifications_active, text: 'Alerts'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
