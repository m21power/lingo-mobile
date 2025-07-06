import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/profile/domain/entites/consistency_entites.dart';
import 'package:lingo/features/profile/domain/entites/rank_entities.dart';
import 'package:lingo/features/profile/domain/usecase/generate_daily_pair_usecase.dart';
import 'package:lingo/features/profile/domain/usecase/get_consistency_usecase.dart';
import 'package:lingo/features/profile/domain/usecase/get_ranks_usecase.dart';
import 'package:lingo/features/profile/domain/usecase/get_user_usecase.dart';
import 'package:lingo/features/profile/domain/usecase/update_nickname_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetConsistencyUsecase getConsistencyUsecase;
  final UpdateNicknameUsecase updateNicknameUsecase;
  final GetUserUsecase getUserUsecase;
  final GetRanksUsecase getRanksUsecase;
  final GenerateDailyPairUsecase generateDailyPairUsecase;
  List<ConsistencyEntites> consistencies = [];

  List<RankEntities> ranks = [];
  User? user;
  ProfileBloc({
    required this.getConsistencyUsecase,
    required this.getUserUsecase,
    required this.getRanksUsecase,
    required this.updateNicknameUsecase,
    required this.generateDailyPairUsecase,
  }) : super(ProfileInitial()) {
    on<GetConsistencyEvent>((event, emit) async {
      emit(GetProfileLoadingState(ranks, consistencies, user));
      final result = await getConsistencyUsecase(null);
      result.fold(
        (failure) => emit(
          ProfileErrorState(failure.message, ranks, consistencies, user),
        ),
        (consistencyList) {
          consistencies = consistencyList;
          emit(GetProfileSuccessState(user, ranks, consistencies));
        },
      );
    });
    on<GetUserEvent>((event, emit) async {
      emit(GetProfileLoadingState(ranks, consistencies, user));
      final result = await getUserUsecase(null);
      result.fold(
        (failure) => emit(
          ProfileErrorState(failure.message, ranks, consistencies, user),
        ),
        (userData) {
          user = userData;
          emit(GetProfileSuccessState(user, ranks, consistencies));
        },
      );
    });
    on<GetRanksEvent>((event, emit) async {
      emit(GetProfileLoadingState(ranks, consistencies, user));
      final result = await getRanksUsecase(null);
      result.fold(
        (failure) => emit(
          ProfileErrorState(failure.message, ranks, consistencies, user),
        ),
        (rankList) {
          ranks = rankList;
          emit(GetProfileSuccessState(user, ranks, consistencies));
        },
      );
    });
    on<UpdateNicknameEvent>((event, emit) async {
      emit(ProfileUpdateLoadingState(ranks, consistencies, user));
      final result = await updateNicknameUsecase(event.nickname);
      result.fold(
        (failure) => emit(
          ProfileErrorState(failure.message, ranks, consistencies, user),
        ),
        (message) {
          var updatedUser = user?.copyWith(nickname: event.nickname);
          user = updatedUser;
          emit(
            ProfileUpdateNicknameState(
              "Nickname updated successfully!",
              ranks,
              consistencies,
              user,
            ),
          );
        },
      );
    });
    on<GenerateDailyPairEvent>((event, emit) async {
      emit(ProfileUpdateLoadingState(ranks, consistencies, user));
      final result = await generateDailyPairUsecase();
      result.fold(
        (failure) => emit(
          GenerateDailyPairErrorState(
            failure.message,
            ranks,
            consistencies,
            user,
          ),
        ),
        (message) {
          emit(
            GenerateDailyPairSuccessState(message, ranks, consistencies, user),
          );
        },
      );
    });
  }
}
