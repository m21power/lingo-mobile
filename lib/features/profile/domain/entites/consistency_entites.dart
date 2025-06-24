// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ConsistencyEntites {
  final DateTime date;
  final int score;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'score': score,
    };
  }

  factory ConsistencyEntites.fromMap(Map<String, dynamic> map) {
    return ConsistencyEntites(
      date: DateTime.parse(map['date'].toString()),
      score: map['score'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConsistencyEntites.fromJson(String source) =>
      ConsistencyEntites.fromMap(json.decode(source) as Map<String, dynamic>);

  ConsistencyEntites({required this.date, required this.score});

  ConsistencyEntites copyWith({DateTime? date, int? score}) {
    return ConsistencyEntites(
      date: date ?? this.date,
      score: score ?? this.score,
    );
  }
}
