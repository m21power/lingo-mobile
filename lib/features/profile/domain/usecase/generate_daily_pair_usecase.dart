import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/profile/domain/repository/profile_repo.dart';

class GenerateDailyPairUsecase {
  final ProfileRepo profileRepo;
  GenerateDailyPairUsecase({required this.profileRepo});
  Future<Either<Failure, String>> call() {
    return profileRepo.generateDailyPair();
  }
}
