import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/notifications/domain/repository/notification_repo.dart';

class PairMeUsecase {
  final NotificationRepo notificationRepo;
  PairMeUsecase({required this.notificationRepo});
  Future<Either<Failure, bool>> call() {
    return notificationRepo.pairMe();
  }
}
