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
  List<ChatModel> chatList = [];
  ChatBloc({required this.getChatsUsecase, required this.listenToChatUsecase})
    : super(ChatInitial()) {
    on<GetChatsEvent>((event, emit) async {
      final result = await getChatsUsecase();
      result.fold(
        (failure) => emit(
          GetChatsFailureState(message: failure.message, chatList: chatList),
        ),
        (chats) {
          chatList = chats;
          emit(GetChatsSuccessState(chatList: chatList));
        },
      );
    });
    on<ListenToChatEvent>((event, emit) async {
      await emit.forEach<List<ChatModel>>(
        listenToChatUsecase(),
        onData: (chats) {
          chatList = chats;
          return GetChatsSuccessState(chatList: chatList);
        },
      );
    });
  }
}
