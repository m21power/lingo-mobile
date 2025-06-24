import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/auth/domain/repository/auth_repo.dart';

final class IsLoggedInUsecase {
  final AuthRepo authRepo;

  IsLoggedInUsecase({required this.authRepo});

  Future<Either<Failure, void>> call() {
    return authRepo.IsLoggedIn();
  }
}
