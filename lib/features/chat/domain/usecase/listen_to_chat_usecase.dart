import 'package:lingo/features/chat/domain/entities/chat_model.dart';
import 'package:lingo/features/chat/domain/repository/chat_repository.dart';

class ListenToChatUsecase {
  final ChatRepository chatRepository;
  ListenToChatUsecase({required this.chatRepository});
  Stream<List<ChatModel>> call() {
    return chatRepository.listenToChats();
  }
}
