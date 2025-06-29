import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/chat/domain/repository/message_repository.dart';

class MarkMessageAsSeenUsecase {
  final MessageRepository messageRepository;
  MarkMessageAsSeenUsecase({required this.messageRepository});
  Future<Either<Failure, void>> call(
    String chatId,
    String messageId,
    String username,
  ) {
    return messageRepository.setSeenBy(chatId, messageId, username);
  }
}
