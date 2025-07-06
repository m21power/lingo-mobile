import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/auth/domain/usecase/check_otp_usecase.dart';
import 'package:lingo/features/auth/domain/usecase/is_logged_in_usecase.dart';
import 'package:lingo/features/auth/domain/usecase/logout_usecase.dart';

import '../../domain/usecase/wake_up_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckOtpUsecase checkOtpUsecase;
  final IsLoggedInUsecase isLoggedInUsecase;
  final WakeUpUsecase wakeUpUsecase;
  final LogoutUsecase logoutUsecase;
  AuthBloc({
    required this.checkOtpUsecase,
    required this.isLoggedInUsecase,
    required this.wakeUpUsecase,
    required this.logoutUsecase,
  }) : super(AuthInitial()) {
    on<CheckOtpEvent>((event, emit) async {
      emit(CheckOtpLoading()); // Reset state before checking OTP
      final result = await checkOtpUsecase(event.otp, event.username);
      result.fold(
        (failure) => emit(CheckOtpFailure(message: failure.message)),
        (user) => emit(CheckOtpSuccess(user: user)),
      );
    });
    on<IsLoggedInEvent>((event, emit) async {
      final result = await isLoggedInUsecase();
      result.fold(
        (failure) => emit(IsLoggedInFailure(message: failure.message)),
        (isLoggedIn) => emit(IsLoggedInSuccess(isLoggedIn: true)),
      );
    });
    on<WakeUpEvent>((event, emit) async {
      print("WakeUpEvent triggered");
      emit(WakeUpLoadingState());
      await wakeUpUsecase();
      emit(WakeUpSuccessState());
      // emit(WakeUpSuccess());
    });
    on<LogoutEvent>((event, emit) async {
      final result = await logoutUsecase();
      result.fold((failure) {
        print("Logout failed: ${failure.message}");
      }, (_) => emit(LogoutSuccessState()));
    });
  }
}
