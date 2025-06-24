// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dartz/dartz.dart';

import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/profile/domain/entites/consistency_entites.dart';
import 'package:lingo/features/profile/domain/entites/rank_entities.dart';

class ProfileEntites {
  final User user;
  final List<RankEntities> ranks;
  final List<ConsistencyEntites> consistencies;

  ProfileEntites({
    required this.user,
    required this.ranks,
    required this.consistencies,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user': user.toMap(),
      'ranks': ranks.map((x) => x.toMap()).toList(),
      'consistencies': consistencies.map((x) => x.toMap()).toList(),
    };
  }

  factory ProfileEntites.fromMap(Map<String, dynamic> map) {
    return ProfileEntites(
      user: User.fromMap(map['user'] as Map<String, dynamic>),
      ranks: List<RankEntities>.from(
        (map['ranks'] as List<int>).map<RankEntities>(
          (x) => RankEntities.fromMap(x as Map<String, dynamic>),
        ),
      ),
      consistencies: List<ConsistencyEntites>.from(
        (map['consistencies'] as List<int>).map<ConsistencyEntites>(
          (x) => ConsistencyEntites.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileEntites.fromJson(String source) =>
      ProfileEntites.fromMap(json.decode(source) as Map<String, dynamic>);

  ProfileEntites copyWith({
    User? user,
    List<RankEntities>? ranks,
    List<ConsistencyEntites>? consistencies,
  }) {
    return ProfileEntites(
      user: user ?? this.user,
      ranks: ranks ?? this.ranks,
      consistencies: consistencies ?? this.consistencies,
    );
  }
}
