part of 'notification_bloc.dart';

sealed class NotificationEvent {
  const NotificationEvent();
}

class GetNotificationsEvent extends NotificationEvent {
  const GetNotificationsEvent();
}

class MarkNotificationAsSeenEvent extends NotificationEvent {
  const MarkNotificationAsSeenEvent();
}

class PairMeEvent extends NotificationEvent {
  const PairMeEvent();
}
