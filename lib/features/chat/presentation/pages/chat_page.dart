import 'package:flutter/material.dart';
import 'package:lingo/features/chat/presentation/widgets/build_chat_tile.dart';

class ChatUserModel {
  final String name;
  final List<String> participantNames;
  final List<String> participantImages;
  final String lastMessage;
  final String lastMessageTime;
  final bool isGroup;
  final List<String> seenBy;
  final int unreadCount;

  ChatUserModel({
    required this.name,
    required this.participantNames,
    required this.participantImages,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isGroup,
    required this.seenBy,
    required this.unreadCount,
  });
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatUserModel> _chatList = [
    ChatUserModel(
      name: "Naruto Uzumaki",
      participantNames: ["Naruto", "Mesay"],
      participantImages: ["assets/naruto.jpg", "assets/mesay.png"],
      lastMessage: "Believe it! Let's train!",
      lastMessageTime: "10:30 AM",
      isGroup: false,
      seenBy: [],
      unreadCount: 3,
    ),
    ChatUserModel(
      name: "Uchiha Bros",
      participantNames: ["Sasuke", "Itachi", "Mesay"],
      participantImages: [
        "assets/mesay.png",
        "assets/naruto.jpg",
        "assets/mesay.png",
      ],
      lastMessage: "We’re ready for the mission.",
      lastMessageTime: "Yesterday",
      isGroup: true,
      seenBy: ["Mesay", "Sasuke"],
      unreadCount: 0,
    ),
    ChatUserModel(
      name: "Team 7",
      participantNames: ["Naruto", "Sakura", "Kakashi", "Mesay"],
      participantImages: [
        "assets/naruto.jpg",
        "assets/mesay.png",
        "assets/naruto.jpg",
        "assets/mesay.png",
      ],
      lastMessage: "Mission briefing at 0900.",
      lastMessageTime: "8:00 PM",
      isGroup: true,
      seenBy: ["Sasuke"],
      unreadCount: 5,
    ),
  ];

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<ChatUserModel> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _filteredChats = _chatList;
    _searchController.addListener(_filterChats);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChats);
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChats = _chatList
          .where((chat) => chat.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredChats = _chatList;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 2,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search chats...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                ),
              )
            : const Text(
                "Chats",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),

        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white70,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: _filteredChats.isEmpty
          ? const Center(
              child: Text(
                "No chats found",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filteredChats.length,
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                return BuildChatTile(chat: chat);
              },
            ),
    );
  }
}
