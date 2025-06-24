part of 'user_bloc.dart';

sealed class UserEvent {
  const UserEvent();
}

final class GetRemoteUserEvent extends UserEvent {
  final int userId;
  const GetRemoteUserEvent({required this.userId});
}

final class GetRemoteUserRanksEvent extends UserEvent {
  final int userId;
  const GetRemoteUserRanksEvent({required this.userId});
}

final class GetRemoteUserConsistencyEvent extends UserEvent {
  final int userId;
  const GetRemoteUserConsistencyEvent({required this.userId});
}
