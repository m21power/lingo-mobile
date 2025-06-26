import 'dart:convert';

class ChatModel {
  final String chatId;
  final String name;
  final List<String> participantUsernames;
  final List<int> participantIds;
  final List<String> participantImages;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isGroup;
  final List<String> seenBy;
  final int unreadCount;

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
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] as String,
      name: map['name'] as String,
      participantUsernames: List<String>.from(
        map['participantUsernames'] as List,
      ),
      participantIds: List<int>.from(map['participantIds'] as List),
      participantImages: List<String>.from(map['participantImages'] as List),
      lastMessage: map['lastMessage'] as String,
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        map['lastMessageTime'] as int,
      ),
      isGroup: map['isGroup'] as bool,
      seenBy: map['seenBy'] != null
          ? List<String>.from(map['seenBy'] as List)
          : [],
      unreadCount: map["unreadCounts"]["12"],
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
