part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  final List<ChatModel> chatList;
  ChatState({required this.chatList});

  @override
  List<Object> get props => [chatList];
}

final class ChatInitial extends ChatState {
  ChatInitial() : super(chatList: []);
}

final class GetChatsSuccessState extends ChatState {
  GetChatsSuccessState({required List<ChatModel> chatList})
    : super(chatList: chatList);
}

final class GetChatsFailureState extends ChatState {
  final String message;
  final List<ChatModel> chatList;
  GetChatsFailureState({required this.message, required this.chatList})
    : super(chatList: chatList);
}
