import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/profile/domain/repository/profile_repo.dart';

class UpdateNicknameUsecase {
  final ProfileRepo profileRepo;
  UpdateNicknameUsecase({required this.profileRepo});
  Future<Either<Failure, void>> call(String nickname) {
    return profileRepo.updateNickname(nickname);
  }
}
