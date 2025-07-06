import 'dart:convert';

class User {
  final int id;
  final String username;
  final String photoUrl;
  final int missCount;
  final int attendance;
  final String? nickname;
  final int participatedCount;
  User({
    required this.id,
    required this.username,
    required this.photoUrl,
    required this.attendance,
    required this.missCount,
    this.nickname,
    required this.participatedCount,
  });

  User copyWith({
    int? id,
    String? username,
    String? photoUrl,
    int? missCount,
    int? attendance,
    String? nickname,
    int? participatedCount,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      missCount: missCount ?? this.missCount,
      attendance: attendance ?? this.attendance,
      nickname: nickname ?? this.nickname,
      participatedCount: participatedCount ?? this.participatedCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'photoUrl': photoUrl,
      'missCount': missCount,
      'attendance': attendance,
      'nickname': nickname,
      'participatedCount': participatedCount,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
      photoUrl: map['photoUrl'] as String,
      missCount: map['missCount'] as int,
      attendance: map['attendance'] as int,
      nickname: map['nickname'] != null ? map['nickname'] as String : null,
      participatedCount: map['participatedCount'] ?? 0,
    );
  }
  factory User.fromFirestore(Map<String, dynamic> map) {
    return User(
      id: map['userId'] as int,
      username: map['username'] as String,
      photoUrl: map['profileUrl'] as String,
      missCount: map['missCount'] as int,
      attendance: map['attendance'] as int,
      nickname: map['nickname'] != null ? map['nickname'] as String : null,
      participatedCount: map['participatedCount'] as int? ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
