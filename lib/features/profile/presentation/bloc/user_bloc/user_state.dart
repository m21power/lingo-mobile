part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  final List<RankEntities> ranks;
  final List<ConsistencyEntites> consistencies;
  final User? user;

  UserState(this.consistencies, this.ranks, this.user);

  @override
  List<Object> get props => [consistencies, ranks, user ?? Object()];
}

final class UserInitial extends UserState {
  UserInitial() : super([], [], null);
}

final class GetUserSuccessState extends UserState {
  GetUserSuccessState({
    required List<ConsistencyEntites> consistencies,
    required List<RankEntities> ranks,
    required User? user,
  }) : super(consistencies, ranks, user);
}

final class GetUserErrorState extends UserState {
  final String message;

  GetUserErrorState({
    required this.message,
    required List<ConsistencyEntites> consistencies,
    required List<RankEntities> ranks,
    required User? user,
  }) : super(consistencies, ranks, user);

  @override
  List<Object> get props => [message, ...super.props];
}
