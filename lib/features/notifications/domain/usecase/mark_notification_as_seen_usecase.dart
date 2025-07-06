import 'package:lingo/features/notifications/domain/repository/notification_repo.dart';

class MarkNotificationAsSeenUsecase {
  final NotificationRepo notificationRepo;
  MarkNotificationAsSeenUsecase({required this.notificationRepo});
  Future<void> call() {
    return notificationRepo.markNotificationAsSeen();
  }
}
