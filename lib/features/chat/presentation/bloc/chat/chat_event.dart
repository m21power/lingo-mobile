part of 'chat_bloc.dart';

sealed class ChatEvent {
  const ChatEvent();
}

class GetChatsEvent extends ChatEvent {
  const GetChatsEvent();
}

class ListenToChatEvent extends ChatEvent {
  const ListenToChatEvent();
}
