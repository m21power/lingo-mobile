import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/domain/usecase/get_messages_usecase.dart';
import 'package:lingo/features/chat/domain/usecase/listen_to_messages.dart';
import 'package:lingo/features/chat/domain/usecase/send_messages_usecase.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetMessagesUsecase getMessagesUsecase;
  final ListenToMessages listenToMessages;
  final SendMessagesUsecase sendMessagesUsecase;
  MessageBloc({
    required this.getMessagesUsecase,
    required this.listenToMessages,
    required this.sendMessagesUsecase,
  }) : super(MessageInitial()) {
    on<GetMessagesEvent>((event, emit) async {
      emit(MessageLoading());
      final result = await getMessagesUsecase(event.chatId);
      result.fold(
        (failure) => emit(MessageError(failure.message)),
        (messages) => emit(MessageLoaded(messages)),
      );
    });
    on<SendMessageEvent>((event, emit) async {
      final result = await sendMessagesUsecase(
        event.message,
        event.chatId,
        event.participantIds,
      );
      // result.fold(
      //   // (failure) => emit(MessageError(failure.message)),
      //   // (success) => emit(MessageSent(event.message)),
      // );
    });
    on<ListenToMessagesEvent>((event, emit) async {
      emit(MessageLoading());
      await emit.forEach<List<MessageModel>>(
        listenToMessages(event.chatId),
        onData: (messages) {
          print("Messages received: ${messages.length}");
          return MessageLoaded(messages);
        },
        // onError: (error, stackTrace) {
        //   print("Error listening to messages: $error");
        //   // return MessageError(error.toString());
        // },
      );
    });
  }
}
