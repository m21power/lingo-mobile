import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lingo/features/About/presentation/pages/about_page.dart';
import 'package:lingo/features/About/presentation/pages/rules_page.dart';
import 'package:lingo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lingo/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:lingo/features/chat/presentation/pages/chat_page.dart';
import 'package:lingo/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:lingo/features/notifications/presentation/pages/notification_page.dart';
import 'package:lingo/features/profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({Key? key, this.initialIndex = 1})
    : super(key: key); // default to Chat

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [ProfilePage(), ChatPage(), NotificationPage()];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccessState) {
          context.read<AuthBloc>().add(IsLoggedInEvent());
        }
      },
      builder: (context, state) {
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
                      MaterialPageRoute(
                        builder: (context) => const RulesPage(),
                      ),
                    );
                  } else if (value == 'about') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  } else if (value == 'log out') {
                    context.read<AuthBloc>().add(const LogoutEvent());
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
                  PopupMenuItem(
                    value: 'log out',
                    child: Row(
                      children: const [
                        Icon(Icons.logout, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text('Log out', style: TextStyle(color: Colors.white)),
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
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, notifState) {
                    return BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, chatState) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
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
                            tabBackgroundColor: Colors.blueAccent.withOpacity(
                              0.5,
                            ),
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            gap: 8,
                            selectedIndex: _selectedIndex,
                            onTabChange: (index) =>
                                setState(() => _selectedIndex = index),
                            tabs: [
                              GButton(icon: Icons.person, text: 'Profile'),
                              GButton(
                                icon: Icons.chat,
                                text: 'Chat',
                                leading: Stack(
                                  children: [
                                    Icon(
                                      Icons.chat,
                                      color: Colors.grey[400],
                                      size: 24,
                                    ), // base icon
                                    chatState.chat.unreadCount > 0
                                        ? Positioned(
                                            right: -2,
                                            top: -2,
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: BoxConstraints(
                                                minWidth: 15,
                                                minHeight: 15,
                                              ),
                                              child: Text(
                                                chatState.chat.unreadCount > 9
                                                    ? '9+'
                                                    : chatState.chat.unreadCount
                                                          .toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                              GButton(
                                icon: Icons.notifications_active,
                                text: 'Alerts',
                                leading: Stack(
                                  children: [
                                    Icon(
                                      Icons.notifications_active,
                                      color: Colors.grey[400],
                                      size: 24,
                                    ), // base icon
                                    notifState.notificationReponse.unseenCount >
                                            0
                                        ? Positioned(
                                            right: -2,
                                            top: -2,
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: BoxConstraints(
                                                minWidth: 15,
                                                minHeight: 15,
                                              ),
                                              child: Text(
                                                notifState
                                                            .notificationReponse
                                                            .unseenCount >
                                                        9
                                                    ? '9+'
                                                    : notifState
                                                          .notificationReponse
                                                          .unseenCount
                                                          .toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
