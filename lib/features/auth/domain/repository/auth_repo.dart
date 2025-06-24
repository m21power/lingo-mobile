import 'package:dartz/dartz.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';

import '../../../../core/error/failure.dart';

abstract class AuthRepo {
  Future<Either<Failure, User>> checkOtp(String otp, String username);
  Future<Either<Failure, void>> IsLoggedIn();
  Future<void> wakeUp();
}
