import 'dart:convert';

import 'package:lingo/core/constant/client_constant.dart';

class ChatModel {
  final String chatId;
  final String name;
  final String lastMessageId;
  final List<String> participantUsernames;
  final List<int> participantIds;
  final List<String> participantImages;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isGroup;
  final List<String> seenBy;
  final int unreadCount;
  final DateTime? createdAt;

  ChatModel({
    required this.chatId,
    required this.name,
    required this.participantUsernames,
    required this.participantIds,
    required this.participantImages,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isGroup,
    required this.seenBy,
    required this.unreadCount,
    required this.lastMessageId,
    this.createdAt,
  });

  ChatModel copyWith({
    String? chatId,
    String? name,
    List<String>? participantUsernames,
    List<int>? participantIds,
    List<String>? participantImages,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isGroup,
    List<String>? seenBy,
    int? unreadCount,
    String? lastMessageId,
    DateTime? createdAt,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      name: name ?? this.name,
      participantUsernames: participantUsernames ?? this.participantUsernames,
      participantIds: participantIds ?? this.participantIds,
      participantImages: participantImages ?? this.participantImages,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isGroup: isGroup ?? this.isGroup,
      seenBy: seenBy ?? this.seenBy,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatId': chatId,
      'name': name,
      'participantUsernames': participantUsernames,
      'participantIds': participantIds,
      'participantImages': participantImages,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'isGroup': isGroup,
      'seenBy': seenBy,
      'unreadCount': unreadCount,
      'lastMessageId': lastMessageId,
    };
  }

  factory ChatModel.fromMap(
    Map<String, dynamic> map,
    String chatId,
    List<String> participantUsernames,
    List<String> participantImages,
  ) {
    print("ChatModel.fromMap: $map");
    print(map["seenBy"]);
    return ChatModel(
      chatId: chatId,
      name: map['name'] as String,
      participantUsernames: participantUsernames,
      participantIds: List<int>.from(map['participantIds'] as List),
      participantImages: participantImages,
      lastMessage: map['lastMessage'] as String,
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        map['lastMessageTime'] as int,
      ),
      isGroup: map['isGroup'] as bool,
      lastMessageId: map['lastMessageId'] != null
          ? map['lastMessageId'] as String
          : '',

      seenBy: map['seenBy'] != null
          ? List<String>.from(
              (map['seenBy'] as List)
                  .where((e) => e != null)
                  .map((e) => e.toString()),
            )
          : [],
      unreadCount:
          map["unreadCounts"][Client.instance.id.toString()] as int? ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  // factory ChatModel.fromJson(String source) =>
  //     ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Chat {
  List<ChatModel> chats;
  int unreadCount;
  Chat({required this.chats, required this.unreadCount});
}
