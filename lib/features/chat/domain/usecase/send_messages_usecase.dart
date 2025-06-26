import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/domain/repository/message_repository.dart';

class SendMessagesUsecase {
  final MessageRepository messageRepository;
  SendMessagesUsecase({required this.messageRepository});
  Future<Either<Failure, void>> call(
    MessageModel message,
    String chatId,
    List<int> participantIds,
  ) {
    return messageRepository.sendMessage(message, chatId, participantIds);
  }
}
