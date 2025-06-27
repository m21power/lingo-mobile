import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/chat/domain/repository/message_repository.dart';

class SetParticipatingStatusUsecase {
  final MessageRepository messageRepository;
  SetParticipatingStatusUsecase({required this.messageRepository});
  Future<Either<Failure, void>> call(
    String chatId,
    String userId,
    String messageId,
  ) {
    return messageRepository.setParticipatingStatus(chatId, userId, messageId);
  }
}
