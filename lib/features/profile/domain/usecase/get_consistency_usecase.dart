import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/profile/domain/entites/consistency_entites.dart';
import 'package:lingo/features/profile/domain/repository/profile_repo.dart';

class GetConsistencyUsecase {
  final ProfileRepo profileRepo;
  GetConsistencyUsecase({required this.profileRepo});
  Future<Either<Failure, List<ConsistencyEntites>>> call(int? userId) {
    return profileRepo.getConsistency(userId);
  }
}
