import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:lingo/core/constant/api_constant.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/core/constant/shared_preference_constant.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/core/network/network_info_impl.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/profile/domain/entites/consistency_entites.dart';
import 'package:lingo/features/profile/domain/entites/rank_entities.dart';
import 'package:lingo/features/profile/domain/repository/profile_repo.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepoImpl implements ProfileRepo {
  final http.Client client;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  final FirebaseFirestore firestore;
  ProfileRepoImpl({
    required this.networkInfo,
    required this.client,
    required this.sharedPreferences,
    required this.firestore,
  });
  @override
  Future<Either<Failure, List<ConsistencyEntites>>> getConsistency(
    int? userId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        User? userModel;

        if (userId == null) {
          var userData = sharedPreferences.getString(
            SharedPreferenceConstant.userKey,
          );
          userModel = userData != null
              ? User.fromMap(jsonDecode(userData))
              : null;
        } else {
          final data = await firestore
              .collection('users')
              .doc(userId.toString())
              .get();
          if (data.exists) {
            userModel = User.fromFirestore(data.data()!);
          }
        }

        if (userModel == null) {
          return Left(ServerFailure(message: "User not found"));
        }

        final datesSnapshot = await firestore
            .collection('consistency')
            .doc(userModel.id.toString())
            .collection('dates')
            .get();

        List<ConsistencyEntites> consistencyList = [];

        for (final doc in datesSnapshot.docs) {
          final data = doc.data();
          final score = (data['score'] ?? 0) as int;
          consistencyList.add(
            ConsistencyEntites(
              date: DateTime.parse(
                doc.id,
              ), // doc id is the date string like "2025-06-24"
              score: score,
            ),
          );
        }
        consistencyList.sort((a, b) => a.date.compareTo(b.date));

        return Right(consistencyList);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<RankEntities>>> getRanks(int? userId) async {
    if (await networkInfo.isConnected) {
      try {
        User? userModel;

        if (userId == null) {
          // Get user from shared preferences
          var userData = sharedPreferences.getString(
            SharedPreferenceConstant.userKey,
          );
          userModel = userData != null
              ? User.fromMap(jsonDecode(userData))
              : null;
        } else {
          // Fetch user from Firestore by userId
          final data = await firestore
              .collection('users')
              .doc(userId.toString())
              .get();
          if (data.exists) {
            userModel = User.fromFirestore(data.data()!);
          }
        }

        final usersSnapshot = await firestore.collection('users').get();

        // Step 1: Calculate score for each user
        final List<Map<String, dynamic>> scoredUsers = usersSnapshot.docs.map((
          doc,
        ) {
          final data = doc.data();
          final int attendance = data['attendance'] ?? 0;
          final int participated = data['participatedCount'] ?? 0;
          final int missCount = data['missCount'] ?? 0;

          final double score =
              attendance * 5 + participated * 2 - missCount * 3;

          return {
            "userId": data['userId'],
            "nickname": data['nickname'] ?? "unknown",
            "score": score.toDouble(),
            "photoUrl": data['profileUrl'] ?? '',
          };
        }).toList();

        // Step 2: Sort by score descending
        scoredUsers.sort((a, b) => b['score'].compareTo(a['score']));

        // Step 3: Assign rank
        for (int i = 0; i < scoredUsers.length; i++) {
          scoredUsers[i]['rank'] = i + 1;
        }

        // Step 4: Extract top 10
        final top10 = scoredUsers.take(10).toList();

        // Step 5: Check if current user is in top 10
        final userInTop10 = top10.any(
          (user) => user['userId'].toString() == userModel?.id.toString(),
        );

        if (!userInTop10 && userModel != null) {
          // Find the user and add them as 11th
          final user = scoredUsers.firstWhere(
            (u) => u['userId'].toString() == userModel?.id.toString(),
          );
          top10.add(user);
        }
        return Right(top10.map((e) => RankEntities.fromMap(e)).toList());
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> getUser(int? userId) async {
    if (await networkInfo.isConnected) {
      try {
        String? userString = sharedPreferences.getString(
          SharedPreferenceConstant.userKey,
        );
        User? userData;
        if (userId == null) {
          userData = User.fromMap(jsonDecode(userString!));
        } else {
          // Use the given userId, but fallback to sharedPreferences if not found
          userData = User(
            id: userId,
            username: '',
            photoUrl: '',
            attendance: 0,
            missCount: 0,
            participatedCount: 0,
          );
        }
        var data = await firestore
            .collection('users')
            .doc(userData.id.toString())
            .get();
        if (data.exists) {
          User userFromFirestore = User.fromFirestore(data.data()!);
          // Only update sharedPreferences if this is the current user
          if (userId == null ||
              userData.id.toString() ==
                  jsonDecode(userString!)['id'].toString()) {
            sharedPreferences.setString(
              SharedPreferenceConstant.userKey,
              jsonEncode(userFromFirestore.toMap()),
            );
          }
          return Right(userFromFirestore);
        } else {
          return Left(ServerFailure(message: 'User not found'));
        }
      } catch (e) {
        print('Error fetching user: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      var user = sharedPreferences.getString(SharedPreferenceConstant.userKey);
      if (user != null) {
        User? userData;
        userData = User.fromMap(jsonDecode(user));
        return Right(userData);
      } else {
        print('No user data found in shared preferences');
      }
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> updateNickname(String nickname) async {
    if (await networkInfo.isConnected) {
      try {
        var user = sharedPreferences.getString(
          SharedPreferenceConstant.userKey,
        );
        User? userData;
        userData = User.fromMap(jsonDecode(user!));
        var data = await firestore
            .collection('users')
            .doc(userData.id.toString())
            .get();
        if (data.exists) {
          User userFromFirestore = User.fromFirestore(data.data()!);
          userFromFirestore = userFromFirestore.copyWith(nickname: nickname);
          await firestore
              .collection('users')
              .doc(userFromFirestore.id.toString())
              .update(userFromFirestore.toMap());
          sharedPreferences.setString(
            SharedPreferenceConstant.userKey,
            jsonEncode(userFromFirestore.toMap()),
          );
          await Client.instance.updateFields(nickname: nickname);
          return Right(null);
        } else {
          throw Exception('User not found');
        }
      } catch (e) {
        print('Error updating nickname: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> generateDailyPair() async {
    if (await networkInfo.isConnected) {
      try {
        var uri = Uri.parse("${ApiConstant.baseUrl}/api/v1/user/generate-pair");
        var response = await client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
        );
        print("⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️");
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          return Right(data["message"]);
        } else {
          return Left(
            ServerFailure(
              message:
                  'Failed to generate daily pair, status code: ${response.statusCode}',
            ),
          );
        }
      } catch (e) {
        print('Error generating daily pair: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }
}
