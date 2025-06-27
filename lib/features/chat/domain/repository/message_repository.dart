import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';

abstract class MessageRepository {
  Future<Either<Failure, List<MessageModel>>> getMessages(String chatId);
  Stream<List<MessageModel>> listenToMessages(String chatId);
  Future<Either<Failure, void>> sendMessage(
    MessageModel message,
    String chatId,
    List<int> participantIds,
  );
  Future<Either<Failure, void>> setParticipatingStatus(
    String chatId,
    String username,
    String messageId,
  );
}
