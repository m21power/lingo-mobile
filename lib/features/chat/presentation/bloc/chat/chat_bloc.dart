import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lingo/features/chat/domain/entities/chat_model.dart';
import 'package:lingo/features/chat/domain/usecase/get_chats_usecase.dart';
import 'package:lingo/features/chat/domain/usecase/listen_to_chat_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatsUsecase getChatsUsecase;
  final ListenToChatUsecase listenToChatUsecase;
  Chat chat = Chat(chats: [], unreadCount: 0);
  ChatBloc({required this.getChatsUsecase, required this.listenToChatUsecase})
    : super(ChatInitial()) {
    on<GetChatsEvent>((event, emit) async {
      final result = await getChatsUsecase();
      result.fold(
        (failure) =>
            emit(GetChatsFailureState(message: failure.message, chat: chat)),
        (chats) {
          chat = chats;
          emit(GetChatsSuccessState(chat: chat));
        },
      );
    });
    on<ListenToChatEvent>((event, emit) async {
      await emit.forEach<Chat>(
        listenToChatUsecase(),
        onData: (chats) {
          chat = chats;
          return GetChatsSuccessState(chat: chat);
        },
      );
    });
  }
}
