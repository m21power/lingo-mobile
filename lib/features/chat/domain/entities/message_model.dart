import 'dart:convert';

class MessageModel {
  final String id;
  final String text;
  final String senderName;
  final int senderId;
  final String? senderProfileImageUrl;
  final DateTime createdAt;
  final List<String> seenBy;
  final bool isSystemMessage;
  final List<String> isParticipating;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
    required this.seenBy,
    required this.isSystemMessage,
    required this.isParticipating,
    this.senderProfileImageUrl,
  });

  MessageModel copyWith({
    String? id,
    String? text,
    String? senderName,
    int? senderId,
    DateTime? createdAt,
    List<String>? seenBy,
    bool? isSystemMessage,
    List<String>? isParticipating,
    String? senderProfileImageUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      senderName: senderName ?? this.senderName,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      seenBy: seenBy ?? this.seenBy,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      isParticipating: isParticipating ?? this.isParticipating,
      senderProfileImageUrl:
          senderProfileImageUrl ?? this.senderProfileImageUrl,
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
      'isParticipating': isParticipating,
      'senderProfileImageUrl': senderProfileImageUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    print("***************");
    print(map);
    return MessageModel(
      id: id,
      text: map['text'] as String,
      senderName: map['senderName'] as String,
      senderId: map['senderId'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      seenBy: map['seenBy'] != null ? List<String>.from(map['seenBy']) : [],
      // seenBy: ["DMesay", "Shinra", "Filfilu"],
      isSystemMessage: map['isSystemMessage'] as bool? ?? false,
      isParticipating: map['isParticipating'] != null
          ? List<String>.from(map['isParticipating'])
          : [],
      senderProfileImageUrl: map['senderProfileImageUrl'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  // factory MessageModel.fromJson(String source) =>
  //     MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
