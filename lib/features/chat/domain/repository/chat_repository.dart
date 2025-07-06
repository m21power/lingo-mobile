import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/chat/domain/entities/chat_model.dart';

abstract class ChatRepository {
  Future<Either<Failure, Chat>> getChats();
  Stream<Chat> listenToChats();
}
