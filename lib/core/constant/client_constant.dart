import 'dart:convert';
import 'package:lingo/core/constant/shared_preference_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Client {
  // 1️⃣ Singleton Setup
  Client._internal();
  static final Client _instance = Client._internal();
  static Client get instance => _instance;

  // 2️⃣ Fields
  int? id;
  String? username;
  String? photoUrl;
  int? missCount;
  int? attendance;
  int? participatedCount;
  String? nickname;

  // ✅ Load from SharedPreferences on app start
  static Future<void> initFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(SharedPreferenceConstant.userKey);
    if (jsonString != null) {
      final data = jsonDecode(jsonString);
      instance._updateFromMap(data);
    }
  }

  // ✅ Full Update (overwrite all fields)
  Future<void> updateClient({
    required int id,
    required String username,
    required String photoUrl,
    required int missCount,
    required int attendance,
    required int participatedCount,
    String? nickname,
  }) async {
    this.id = id;
    this.username = username;
    this.photoUrl = photoUrl;
    this.missCount = missCount;
    this.attendance = attendance;
    this.participatedCount = participatedCount;
    this.nickname = nickname;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      SharedPreferenceConstant.userKey,
      jsonEncode(_toMap()),
    );
  }

  // ✅ Partial Update (only what you pass)
  Future<void> updateFields({
    int? id,
    String? username,
    String? photoUrl,
    int? missCount,
    int? attendance,
    int? participatedCount,
    String? nickname,
  }) async {
    this.id = id ?? this.id;
    this.username = username ?? this.username;
    this.photoUrl = photoUrl ?? this.photoUrl;
    this.missCount = missCount ?? this.missCount;
    this.attendance = attendance ?? this.attendance;
    this.participatedCount = participatedCount ?? this.participatedCount;
    this.nickname = nickname ?? this.nickname;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      SharedPreferenceConstant.userKey,
      jsonEncode(_toMap()),
    );
  }

  // 🔁 Convert to/from Map
  Map<String, dynamic> _toMap() {
    return {
      'id': id,
      'username': username,
      'photoUrl': photoUrl,
      'missCount': missCount,
      'attendance': attendance,
      'participatedCount': participatedCount,
      'nickname': nickname,
    };
  }

  void _updateFromMap(Map<String, dynamic> map) {
    id = map['id'];
    username = map['username'];
    photoUrl = map['photoUrl'];
    missCount = map['missCount'];
    attendance = map['attendance'];
    participatedCount = map['participatedCount'];
    nickname = map['nickname'];
  }
}
