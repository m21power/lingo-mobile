import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/profile/domain/entites/rank_entities.dart';
import 'package:lingo/features/profile/domain/repository/profile_repo.dart';

class GetRanksUsecase {
  final ProfileRepo profileRepo;
  GetRanksUsecase({required this.profileRepo});
  Future<Either<Failure, List<RankEntities>>> call(int? userId) {
    return profileRepo.getRanks(userId);
  }
}
