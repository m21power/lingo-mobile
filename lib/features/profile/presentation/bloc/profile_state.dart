part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  final List<RankEntities> ranks;
  final List<ConsistencyEntites> consistencies;
  final User? user;
  ProfileState(this.consistencies, this.ranks, this.user);

  @override
  List<Object> get props => [consistencies, ranks, user ?? Object()];
}

final class ProfileInitial extends ProfileState {
  ProfileInitial() : super([], [], null);
}

final class GetProfileLoadingState extends ProfileState {
  GetProfileLoadingState(
    List<RankEntities> ranks,
    List<ConsistencyEntites> consistencies,
    User? user,
  ) : super(consistencies, ranks, user);
}

final class GetProfileSuccessState extends ProfileState {
  GetProfileSuccessState(
    User? user,
    List<RankEntities> ranks,
    List<ConsistencyEntites> consistencies,
  ) : super(consistencies, ranks, user);
}

final class ProfileErrorState extends ProfileState {
  final String message;

  ProfileErrorState(
    this.message,
    List<RankEntities> ranks,
    List<ConsistencyEntites> consistencies,
    User? user,
  ) : super(consistencies, ranks, user);

  @override
  List<Object> get props => [message, ...super.props];
}

final class ProfileUpdateLoadingState extends ProfileState {
  ProfileUpdateLoadingState(
    List<RankEntities> ranks,
    List<ConsistencyEntites> consistencies,
    User? user,
  ) : super(consistencies, ranks, user);
}

final class ProfileUpdateNicknameState extends ProfileState {
  final String message;

  ProfileUpdateNicknameState(
    this.message,
    List<RankEntities> ranks,
    List<ConsistencyEntites> consistencies,
    User? user,
  ) : super(consistencies, ranks, user);

  @override
  List<Object> get props => [message, ...super.props];
}

final class GenerateDailyPairSuccessState extends ProfileState {
  final String message;

  GenerateDailyPairSuccessState(
    this.message,
    List<RankEntities> ranks,
    List<ConsistencyEntites> consistencies,
    User? user,
  ) : super(consistencies, ranks, user);

  @override
  List<Object> get props => [message, ...super.props];
}

final class GenerateDailyPairErrorState extends ProfileState {
  final String message;

  GenerateDailyPairErrorState(
    this.message,
    List<RankEntities> ranks,
    List<ConsistencyEntites> consistencies,
    User? user,
  ) : super(consistencies, ranks, user);

  @override
  List<Object> get props => [message, ...super.props];
}
