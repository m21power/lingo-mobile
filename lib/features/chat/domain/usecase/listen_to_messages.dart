import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/domain/repository/message_repository.dart';

class ListenToMessages {
  final MessageRepository messageRepository;
  ListenToMessages({required this.messageRepository});
  Stream<List<MessageModel>> call(String chatId) {
    return messageRepository.listenToMessages(chatId);
  }
}
