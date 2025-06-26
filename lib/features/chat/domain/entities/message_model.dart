import 'dart:convert';

class MessageModel {
  final String id;
  final String text;
  final String senderName;
  final int senderId;
  final DateTime createdAt;
  final List<String> seenBy;
  final bool isSystemMessage;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    required this.seenBy,
    required this.isSystemMessage,
  });

  MessageModel copyWith({
    String? id,
    String? text,
    String? senderName,
    int? senderId,
    DateTime? createdAt,
    List<String>? seenBy,
    bool? isSystemMessage,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      senderName: senderName ?? this.senderName,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      seenBy: seenBy ?? this.seenBy,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'senderName': senderName,
      'senderId': senderId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'seenBy': seenBy,
      'isSystemMessage': isSystemMessage,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    print("***************");
    print(map);
    return MessageModel(
      id: map['id'] as String,
      text: map['text'] as String,
      senderName: map['senderName'] as String,
      senderId: map['senderId'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      seenBy: map['seenBy'] != null ? List<String>.from(map['seenBy']) : [],
      isSystemMessage: map['isSystemMessage'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
