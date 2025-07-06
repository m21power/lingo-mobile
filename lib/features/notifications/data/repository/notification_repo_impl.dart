import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:lingo/core/constant/api_constant.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/core/network/network_info_impl.dart';
import 'package:lingo/features/notifications/domain/entities/notification.dart';
import 'package:lingo/features/notifications/domain/repository/notification_repo.dart';
import 'package:http/http.dart' as http;

class NotificationRepoImpl implements NotificationRepo {
  final NetworkInfo networkInfo;
  final http.Client client;
  NotificationRepoImpl({required this.networkInfo, required this.client});
  @override
  Future<Either<Failure, NotificationReponse>> getNotifications() async {
    if (await networkInfo.isConnected) {
      var uri = Uri.parse(
        "${ApiConstant.baseUrl}/api/v1/user/notifications/${Client.instance.id}",
      );
      print('Fetching notifications from: $uri');
      var response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        List<Notification> notifications = [];
        var data = jsonDecode(response.body)['notifications'];
        if (data['notifications'] != null) {
          for (var item in data['notifications']) {
            notifications.add(
              Notification(
                id: item['id'],
                message: item['message'],
                type: "daily",
                seen: item['seen'].toString(),
                createdAt: item['createdAt'],
              ),
            );
          }
        }
        int unseenCount = notifications.where((n) => n.seen == 'false').length;
        return Right(
          NotificationReponse(
            notifications: notifications,
            unseenCount: unseenCount,
            isWaiting: data['isWaiting'],
          ),
        );
      } else {
        return Left(ServerFailure(message: 'Failed to load notifications'));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<void> markNotificationAsSeen() async {
    if (await networkInfo.isConnected) {
      var uri = Uri.parse(
        "${ApiConstant.baseUrl}/api/v1/user/seen-notification/${Client.instance.id}",
      );
      var response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return;
    } else {
      print('No internet connection');
    }
  }

  @override
  Future<Either<Failure, bool>> pairMe() async {
    if (await networkInfo.isConnected) {
      var uri = Uri.parse("${ApiConstant.baseUrl}/api/v1/user/pair");
      var ob;
      if (Client.instance.photoUrl != null &&
          Client.instance.photoUrl!.isNotEmpty) {
        ob = {
          'userId': Client.instance.id,
          'username': Client.instance.username,
          "profileUrl": Client.instance.photoUrl,
        };
      } else {
        ob = {
          'userId': Client.instance.id,
          'username': Client.instance.username,
        };
      }

      var response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ob),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return Right(data['wait']);
      } else {
        return Left(ServerFailure(message: 'Failed to pair'));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }
}
