import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lingo/features/chat/domain/usecase/mark_message_as_seen.dart';
import 'package:lingo/features/notifications/domain/entities/notification.dart';
import 'package:lingo/features/notifications/domain/usecase/get_notification.dart';
import 'package:lingo/features/notifications/domain/usecase/mark_notification_as_seen_usecase.dart';
import 'package:lingo/features/notifications/domain/usecase/pair_me_usecase.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationUsecase getNotificationUsecase;
  final MarkNotificationAsSeenUsecase markNotificationAsSeenUsecase;
  final PairMeUsecase pairMeUsecase;

  NotificationReponse notificationReponse = NotificationReponse(
    notifications: [],
    unseenCount: 0,
    isWaiting: false,
  );
  NotificationBloc({
    required this.getNotificationUsecase,
    required this.markNotificationAsSeenUsecase,
    required this.pairMeUsecase,
  }) : super(NotificationInitial()) {
    on<GetNotificationsEvent>((event, emit) async {
      print("Fetching notifications...");
      var result = await getNotificationUsecase();
      result.fold(
        (failure) {
          emit(
            NotificationErrorState(
              message: failure.message,
              notificationReponse: notificationReponse,
            ),
          );
        },
        (response) {
          notificationReponse = response;
          emit(NotificationLoadedState(notificationReponse: response));
        },
      );
    });
    on<MarkNotificationAsSeenEvent>((event, emit) async {
      await markNotificationAsSeenUsecase();
      add(const GetNotificationsEvent());
    });
    on<PairMeEvent>((event, emit) async {
      var result = await pairMeUsecase();
      result.fold(
        (failure) {
          emit(
            PairMeFailureState(
              message: failure.message,
              notificationReponse: notificationReponse,
            ),
          );
        },
        (wait) {
          emit(
            PairMeSuccessState(
              isWaiting: wait,
              notificationReponse: notificationReponse,
            ),
          );
        },
      );
    });
  }
}
