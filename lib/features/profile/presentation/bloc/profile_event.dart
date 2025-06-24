part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

final class GetUserEvent extends ProfileEvent {
  const GetUserEvent();
}

final class GetRanksEvent extends ProfileEvent {
  const GetRanksEvent();
}

final class GetConsistencyEvent extends ProfileEvent {
  const GetConsistencyEvent();
}

final class UpdateNicknameEvent extends ProfileEvent {
  final String nickname;

  const UpdateNicknameEvent(this.nickname);
}
