import 'package:dartz/dartz.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/features/chat/domain/entities/chat_model.dart';
import 'package:lingo/features/chat/domain/repository/chat_repository.dart';

class GetChatsUsecase {
  final ChatRepository chatRepository;
  GetChatsUsecase({required this.chatRepository});
  Future<Either<Failure, List<ChatModel>>> call() {
    return chatRepository.getChats();
  }
}
