import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/notifications/domain/entities/notification.dart';
import 'package:lingo/features/notifications/domain/repository/notification_repo.dart';

class GetNotificationUsecase {
  final NotificationRepo notificationRepo;
  GetNotificationUsecase({required this.notificationRepo});
  Future<Either<Failure, NotificationReponse>> call() {
    return notificationRepo.getNotifications();
  }
}
