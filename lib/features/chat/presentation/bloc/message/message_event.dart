part of 'message_bloc.dart';

sealed class MessageEvent {
  const MessageEvent();
}

final class GetMessagesEvent extends MessageEvent {
  final String chatId;

  const GetMessagesEvent(this.chatId);
}

final class SendMessageEvent extends MessageEvent {
  final String chatId;
  final MessageModel message;
  final List<int> participantIds;
  const SendMessageEvent(this.chatId, this.message, this.participantIds);
}

final class ListenToMessagesEvent extends MessageEvent {
  final String chatId;

  const ListenToMessagesEvent(this.chatId);
}

final class SetParticipatingStatusEvent extends MessageEvent {
  final String chatId;
  final String userId;
  final String messageId;

  const SetParticipatingStatusEvent({
    required this.chatId,
    required this.userId,
    required this.messageId,
  });
}
