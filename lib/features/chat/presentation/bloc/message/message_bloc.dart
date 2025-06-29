import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/domain/usecase/get_messages_usecase.dart';
import 'package:lingo/features/chat/domain/usecase/listen_to_messages.dart';
import 'package:lingo/features/chat/domain/usecase/mark_message_as_seen.dart';
import 'package:lingo/features/chat/domain/usecase/send_messages_usecase.dart';
import 'package:lingo/features/chat/domain/usecase/set_participating_status_usecase.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final GetMessagesUsecase getMessagesUsecase;
  final ListenToMessages listenToMessages;
  final SendMessagesUsecase sendMessagesUsecase;
  final SetParticipatingStatusUsecase setParticipatingStatusUsecase;
  final MarkMessageAsSeenUsecase markMessageAsSeenUsecase;
  MessageBloc({
    required this.getMessagesUsecase,
    required this.listenToMessages,
    required this.sendMessagesUsecase,
    required this.setParticipatingStatusUsecase,
    required this.markMessageAsSeenUsecase,
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
    on<SetParticipatingStatusEvent>((event, emit) async {
      final result = await setParticipatingStatusUsecase(
        event.chatId,
        event.userId,
        event.messageId,
      );
      result.fold(
        (failure) {
          print("Error setting participating status: ${failure.message}");
        },
        (_) {
          print(
            "Participating status set successfully for chat ${event.chatId}",
          );
        },
      );
    });
    on<MarkMessageAsSeenEvent>((event, emit) async {
      final result = await markMessageAsSeenUsecase(
        event.chatId,
        event.messageId,
        event.username,
      );
      result.fold(
        (failure) {
          print("Error marking message as seen: ${failure.message}");
        },
        (_) {
          print(
            "Message ${event.messageId} marked as seen by ${event.username}",
          );
        },
      );
    });
  }
}
