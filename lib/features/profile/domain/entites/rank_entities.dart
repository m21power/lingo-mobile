import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class RankEntities {
  final int userId;
  final int rank;
  final String nickname;
  final String photoUrl;
  final double score;

  RankEntities({
    required this.userId,
    required this.rank,
    required this.nickname,
    required this.photoUrl,
    required this.score,
  });

  RankEntities copyWith({
    int? userId,
    int? rank,
    String? nickname,
    String? photoUrl,
    double? score,
  }) {
    return RankEntities(
      userId: userId ?? this.userId,
      rank: rank ?? this.rank,
      nickname: nickname ?? this.nickname,
      photoUrl: photoUrl ?? this.photoUrl,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'rank': rank,
      'nickname': nickname,
      'photoUrl': photoUrl,
      'score': score,
    };
  }

  factory RankEntities.fromMap(Map<String, dynamic> map) {
    return RankEntities(
      userId: map['userId'] as int,
      rank: map['rank'] as int,
      nickname: map['nickname'] as String,
      photoUrl: map['photoUrl'] as String,
      score: map['score'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory RankEntities.fromJson(String source) =>
      RankEntities.fromMap(json.decode(source) as Map<String, dynamic>);
}
