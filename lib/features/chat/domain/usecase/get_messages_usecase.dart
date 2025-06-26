import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/domain/repository/message_repository.dart';

class GetMessagesUsecase {
  final MessageRepository messageRepository;
  GetMessagesUsecase({required this.messageRepository});
  Future<Either<Failure, List<MessageModel>>> call(String chatId) {
    return messageRepository.getMessages(chatId);
  }
}
