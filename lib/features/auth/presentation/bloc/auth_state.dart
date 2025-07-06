part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class CheckOtpLoading extends AuthState {
  const CheckOtpLoading();
}

final class CheckOtpSuccess extends AuthState {
  final User user;

  const CheckOtpSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

final class CheckOtpFailure extends AuthState {
  final String message;

  const CheckOtpFailure({required this.message});

  @override
  List<Object> get props => [message];
}

final class IsLoggedInSuccess extends AuthState {
  final bool isLoggedIn;

  const IsLoggedInSuccess({required this.isLoggedIn});

  @override
  List<Object> get props => [isLoggedIn];
}

final class IsLoggedInFailure extends AuthState {
  final String message;

  const IsLoggedInFailure({required this.message});

  @override
  List<Object> get props => [message];
}

final class WakeUpLoadingState extends AuthState {
  const WakeUpLoadingState();
}

final class WakeUpSuccessState extends AuthState {
  const WakeUpSuccessState();
}

final class LogoutSuccessState extends AuthState {
  const LogoutSuccessState();
}
