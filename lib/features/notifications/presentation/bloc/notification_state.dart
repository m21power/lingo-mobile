part of 'notification_bloc.dart';

sealed class NotificationState extends Equatable {
  NotificationReponse notificationReponse = NotificationReponse(
    notifications: [],
    unseenCount: 0,
    isWaiting: false,
  );
  NotificationState({required this.notificationReponse});

  @override
  List<Object> get props => [this.notificationReponse];
}

final class NotificationInitial extends NotificationState {
  NotificationInitial()
    : super(
        notificationReponse: NotificationReponse(
          notifications: [],
          unseenCount: 0,
          isWaiting: false,
        ),
      );
}

final class NotificationLoadedState extends NotificationState {
  final NotificationReponse notificationReponse;

  NotificationLoadedState({required this.notificationReponse})
    : super(notificationReponse: notificationReponse);

  @override
  List<Object> get props => [notificationReponse];
}

final class NotificationErrorState extends NotificationState {
  final String message;

  NotificationErrorState({
    required this.message,
    required NotificationReponse notificationReponse,
  }) : super(notificationReponse: notificationReponse);

  @override
  List<Object> get props => [message, notificationReponse];
}

final class PairMeFailureState extends NotificationState {
  final String message;

  PairMeFailureState({
    required this.message,
    required NotificationReponse notificationReponse,
  }) : super(notificationReponse: notificationReponse);

  @override
  List<Object> get props => [message, notificationReponse];
}

final class PairMeSuccessState extends NotificationState {
  final bool isWaiting;

  PairMeSuccessState({
    required this.isWaiting,
    required NotificationReponse notificationReponse,
  }) : super(notificationReponse: notificationReponse);

  @override
  List<Object> get props => [isWaiting, notificationReponse];
}
