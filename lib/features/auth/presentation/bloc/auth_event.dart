part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class CheckOtpEvent extends AuthEvent {
  final String otp;
  final String username;

  const CheckOtpEvent({required this.otp, required this.username});
}

final class IsLoggedInEvent extends AuthEvent {
  const IsLoggedInEvent();
}

final class WakeUpEvent extends AuthEvent {
  const WakeUpEvent();
}
