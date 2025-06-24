import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/profile/domain/repository/profile_repo.dart';

class GetUserUsecase {
  final ProfileRepo profileRepo;
  GetUserUsecase({required this.profileRepo});
  Future<Either<Failure, User>> call(int? userId) {
    return profileRepo.getUser(userId);
  }
}
