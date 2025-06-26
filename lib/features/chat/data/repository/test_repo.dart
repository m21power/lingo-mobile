import 'package:firebase_database/firebase_database.dart';

final FirebaseDatabase db = FirebaseDatabase.instance;

Future<void> pushTestChats() async {
  const profilePicUrl =
      "https://res.cloudinary.com/dl6vahv6t/image/upload/v1750662987/profile_3975792825_cppjs6.jpg";

  // Main user (you)
  const mainUserId = 12;
  const mainUsername = "mesay";

  final sampleChats = [
    {
      "chatId": "12_45",
      "name": "Mesay & Mike",
      "participantIds": [12, 45],
      "participantUsernames": ["mesay", "mike"],
      "participantImages": [profilePicUrl, profilePicUrl],
      "lastMessage": "Hello Mike!",
      "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
      "isGroup": false,
      "seenBy": ["mesay"],
      "unreadCounts": {"12": 0, "45": 1},
    },
    {
      "chatId": "12_34",
      "name": "Mesay & Sarah",
      "participantIds": [12, 34],
      "participantUsernames": ["mesay", "sarah"],
      "participantImages": [profilePicUrl, profilePicUrl],
      "lastMessage": "Hey Sarah, what's up?",
      "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
      "isGroup": false,
      "seenBy": ["mesay"],
      "unreadCounts": {"12": 0, "34": 2},
    },
    {
      "chatId": "8_12_35",
      "name": "Group: Mesay, Abebe, Zinabu",
      "participantIds": [8, 12, 35],
      "participantUsernames": ["abebe", "mesay", "zinabu"],
      "participantImages": [profilePicUrl, profilePicUrl, profilePicUrl],
      "lastMessage": "Group chat started 🎉",
      "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
      "isGroup": true,
      "seenBy": ["mesay"],
      "unreadCounts": {"8": 1, "12": 0, "35": 1},
    },
    {
      "chatId": "10_12",
      "name": "Alex & Mesay",
      "participantIds": [10, 12],
      "participantUsernames": ["alex", "mesay"],
      "participantImages": [profilePicUrl, profilePicUrl],
      "lastMessage": "Yo!",
      "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
      "isGroup": false,
      "seenBy": ["mesay"],
      "unreadCounts": {"10": 2, "12": 0},
    },
    {
      "chatId": "12_80",
      "name": "Teddy & Mesay",
      "participantIds": [12, 80],
      "participantUsernames": ["mesay", "teddy"],
      "participantImages": [profilePicUrl, profilePicUrl],
      "lastMessage": "Good night 🌙",
      "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
      "isGroup": false,
      "seenBy": ["teddy"],
      "unreadCounts": {"12": 1, "80": 0},
    },
  ];

  for (final chat in sampleChats) {
    final chatId = chat["chatId"] as String;
    final chatRef = db.ref("chats/$chatId");
    await chatRef.set(chat);

    // Also update userChats/ for all participants
    final participantIds = (chat["participantIds"] as List);
    for (final id in participantIds) {
      await db.ref("userChats/$id/$chatId").set(true);
    }
  }

  print("✅ Test chats pushed successfully.");
}

Future<void> pushSampleMessagesForChat(String chatId) async {
  final messages = [
    {
      "id": "msg_1",
      "text": "Hey Mike, what's up?",
      "senderName": "mesay",
      "senderId": 12,
      "createdAt": DateTime.now()
          .subtract(const Duration(minutes: 10))
          .millisecondsSinceEpoch,
      "seenBy": ["mesay"],
      "isSystemMessage": false,
    },
    {
      "id": "msg_2",
      "text": "Not much, just relaxing. You?",
      "senderName": "mike",
      "senderId": 45,
      "createdAt": DateTime.now()
          .subtract(const Duration(minutes: 8))
          .millisecondsSinceEpoch,
      "seenBy": ["mesay"],
      "isSystemMessage": false,
    },
    {
      "id": "msg_3",
      "text": "We have a group meeting at 5PM.",
      "senderName": "mesay",
      "senderId": 12,
      "createdAt": DateTime.now()
          .subtract(const Duration(minutes: 6))
          .millisecondsSinceEpoch,
      "seenBy": ["mesay", "mike"],
      "isSystemMessage": false,
    },
    {
      "id": "msg_4",
      "text": "System: Meeting pinned by Mesay",
      "senderName": "system",
      "senderId": 0,
      "createdAt": DateTime.now()
          .subtract(const Duration(minutes: 5))
          .millisecondsSinceEpoch,
      "seenBy": [],
      "isSystemMessage": true,
    },
    {
      "id": "msg_5",
      "text": "Got it. See you!",
      "senderName": "mike",
      "senderId": 45,
      "createdAt": DateTime.now()
          .subtract(const Duration(minutes: 3))
          .millisecondsSinceEpoch,
      "seenBy": ["mesay"],
      "isSystemMessage": false,
    },
  ];

  for (final msg in messages) {
    final msgId = msg['id'];
    await db.ref("messages/$chatId/$msgId").set(msg);
  }

  print("✅ Sample messages pushed under /messages/$chatId/");
}
