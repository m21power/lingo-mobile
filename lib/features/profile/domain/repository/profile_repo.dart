import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/profile/domain/entites/consistency_entites.dart';
import 'package:lingo/features/profile/domain/entites/rank_entities.dart';

abstract class ProfileRepo {
  Future<Either<Failure, List<RankEntities>>> getRanks(int? userId);
  Future<Either<Failure, List<ConsistencyEntites>>> getConsistency(int? userId);
  Future<Either<Failure, User>> getUser(int? userId);
  Future<Either<Failure, void>> updateNickname(String nickname);
  Future<Either<Failure, String>> generateDailyPair();
}
