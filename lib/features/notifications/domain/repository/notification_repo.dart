import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/notifications/domain/entities/notification.dart';

abstract class NotificationRepo {
  Future<Either<Failure, NotificationReponse>> getNotifications();
  Future<Either<Failure, bool>> pairMe();
  Future<void> markNotificationAsSeen();
}
