part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  final Chat chat;
  ChatState({required this.chat});

  @override
  List<Object> get props => [chat];
}

final class ChatInitial extends ChatState {
  ChatInitial() : super(chat: Chat(chats: [], unreadCount: 0));
}

final class GetChatsSuccessState extends ChatState {
  GetChatsSuccessState({required Chat chat}) : super(chat: chat);
}

final class GetChatsFailureState extends ChatState {
  final String message;
  final Chat chat;
  GetChatsFailureState({required this.message, required this.chat})
    : super(chat: chat);
}
