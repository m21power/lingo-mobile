import 'dart:convert';

class NotificationReponse {
  final bool isWaiting;
  final List<Notification> notifications;
  final int unseenCount;
  NotificationReponse({
    required this.notifications,
    required this.unseenCount,
    required this.isWaiting,
  });
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Notification {
  final String id;
  final String message;
  final String type;
  final String seen;
  final String createdAt;

  Notification({
    required this.id,
    required this.message,
    required this.type,
    required this.seen,
    required this.createdAt,
  });

  Notification copyWith({
    String? id,
    String? message,
    String? type,
    String? seen,
    String? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      seen: seen ?? this.seen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'message': message,
      'type': type,
      'seen': seen,
      'createdAt': createdAt,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      seen: map['seen'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Notification.fromJson(String source) =>
      Notification.fromMap(json.decode(source) as Map<String, dynamic>);
}
