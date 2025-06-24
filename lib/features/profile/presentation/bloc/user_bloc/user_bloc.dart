import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/profile/domain/entites/consistency_entites.dart';
import 'package:lingo/features/profile/domain/entites/rank_entities.dart';
import 'package:lingo/features/profile/domain/usecase/get_consistency_usecase.dart';
import 'package:lingo/features/profile/domain/usecase/get_ranks_usecase.dart';
import 'package:lingo/features/profile/domain/usecase/get_user_usecase.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetConsistencyUsecase getConsistencyUsecase;
  final GetRanksUsecase getRanksUsecase;
  final GetUserUsecase getUserUsecase;
  List<ConsistencyEntites> consistencies = [];
  List<RankEntities> ranks = [];
  User? user;
  UserBloc({
    required this.getConsistencyUsecase,
    required this.getRanksUsecase,
    required this.getUserUsecase,
  }) : super(UserInitial()) {
    on<GetRemoteUserEvent>((event, emit) async {
      emit(UserInitial());
      final result = await getUserUsecase(event.userId);
      result.fold(
        (failure) => emit(
          GetUserErrorState(
            message: failure.message,
            consistencies: consistencies,
            ranks: ranks,
            user: user,
          ),
        ),
        (user) {
          this.user = user;
          emit(
            GetUserSuccessState(
              consistencies: consistencies,
              ranks: ranks,
              user: user,
            ),
          );
        },
      );
    });

    on<GetRemoteUserRanksEvent>((event, emit) async {
      emit(UserInitial());
      final result = await getRanksUsecase(event.userId);
      result.fold(
        (failure) => emit(
          GetUserErrorState(
            message: failure.message,
            consistencies: consistencies,
            ranks: ranks,
            user: user,
          ),
        ),
        (ranks) {
          this.ranks = ranks;
          emit(
            GetUserSuccessState(
              consistencies: consistencies,
              ranks: ranks,
              user: user,
            ),
          );
        },
      );
    });

    on<GetRemoteUserConsistencyEvent>((event, emit) async {
      emit(UserInitial());
      final result = await getConsistencyUsecase(event.userId);
      result.fold(
        (failure) => emit(
          GetUserErrorState(
            message: failure.message,
            consistencies: consistencies,
            ranks: ranks,
            user: user,
          ),
        ),
        (consistencies) {
          this.consistencies = consistencies;
          emit(
            GetUserSuccessState(
              consistencies: consistencies,
              ranks: ranks,
              user: user,
            ),
          );
        },
      );
    });
  }
}
