import 'package:dartz/dartz.dart';
import 'package:lingo/features/auth/domain/repository/auth_repo.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';

class CheckOtpUsecase {
  final AuthRepo authRepo;
  CheckOtpUsecase({required this.authRepo});
  Future<Either<Failure, User>> call(String otp, String username) {
    return authRepo.checkOtp(otp, username);
  }
}
