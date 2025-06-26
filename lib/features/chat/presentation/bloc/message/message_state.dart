part of 'message_bloc.dart';

sealed class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object> get props => [];
}

final class MessageInitial extends MessageState {}

final class MessageLoading extends MessageState {}

final class MessageLoaded extends MessageState {
  final List<MessageModel> messages;

  const MessageLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

final class MessageError extends MessageState {
  final String message;

  const MessageError(this.message);

  @override
  List<Object> get props => [message];
}

final class MessageSent extends MessageState {
  final MessageModel message;

  const MessageSent(this.message);

  @override
  List<Object> get props => [message];
}
