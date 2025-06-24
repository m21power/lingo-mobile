import 'package:lingo/features/auth/domain/repository/auth_repo.dart';

class WakeUpUsecase {
  final AuthRepo authRepo;
  WakeUpUsecase({required this.authRepo});
  Future<void> call() {
    return authRepo.wakeUp();
  }
}
