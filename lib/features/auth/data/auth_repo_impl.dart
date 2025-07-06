import 'dart:convert';
import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:lingo/core/constant/api_constant.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/core/constant/shared_preference_constant.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/core/network/network_info_impl.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/auth/domain/repository/auth_repo.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepoImpl implements AuthRepo {
  final NetworkInfo networkInfo;
  final http.Client client;
  final SharedPreferences sharedPreferences;
  AuthRepoImpl({
    required this.networkInfo,
    required this.client,
    required this.sharedPreferences,
  });
  @override
  Future<Either<Failure, User>> checkOtp(String otp, String username) async {
    if (await networkInfo.isConnected) {
      try {
        if (username[0] == '@') {
          username = username.substring(1);
        }
        print(username);
        print(otp);
        var ot = int.parse(otp);
        final response = await client.post(
          Uri.parse("${ApiConstant.baseUrl}/api/v1/otp"),
          body: jsonEncode({'otp': ot, 'username': username}),
        );

        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          print("****************");
          print(data);
          final user = User.fromMap(data['user']);
          await sharedPreferences.setString(
            SharedPreferenceConstant.userKey,
            jsonEncode(user.toMap()),
          );
          await sharedPreferences.setBool(
            SharedPreferenceConstant.isLoggedIn,
            true,
          );
          await Client.initFromPrefs();
          return Right(user);
        } else {
          return Left(ServerFailure(message: data["error"]));
        }
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> IsLoggedIn() async {
    final isLoggedIn = sharedPreferences.getBool(
      SharedPreferenceConstant.isLoggedIn,
    );
    print("IsLoggedIn: $isLoggedIn");
    var user = sharedPreferences.getString(SharedPreferenceConstant.userKey);
    if (user != null) {
      print("User found: $user");
    } else {
      print("No user found in shared preferences");
    }
    if (isLoggedIn == true) {
      await Client.initFromPrefs();
      return Future.value(Right(Void));
    } else {
      return Left(ServerFailure(message: 'User is not logged in'));
    }
  }

  @override
  Future<void> wakeUp() async {
    if (await networkInfo.isConnected) {
      final response = await client.get(
        Uri.parse("${ApiConstant.baseUrl}/otp/wake-up"),
      );
      return Future.value();
    } else {
      throw ServerFailure(message: 'No internet connection');
    }
  }
}
