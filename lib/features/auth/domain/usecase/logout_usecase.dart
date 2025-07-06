import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/auth/domain/repository/auth_repo.dart';

class LogoutUsecase {
  final AuthRepo authRepo;

  LogoutUsecase({required this.authRepo});

  Future<Either<Failure, void>> call() {
    return authRepo.logout();
  }
}
