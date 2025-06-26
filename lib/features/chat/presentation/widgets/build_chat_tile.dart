import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lingo/features/chat/domain/entities/chat_model.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/presentation/bloc/message/message_bloc.dart';
import 'package:lingo/features/chat/presentation/pages/chat_page.dart';
import 'package:lingo/features/chat/presentation/pages/conversation_page.dart';

class BuildChatTile extends StatelessWidget {
  ChatModel chat;
  BuildChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return buildChatTile(context, chat);
  }

  List<MessageModel> sampleMessages = [];
  Widget buildChatTile(BuildContext context, ChatModel chat) {
    const String currentUser = "Mesay";

    final filteredImages = chat.isGroup
        ? chat.participantImages
        : chat.participantImages
              .asMap()
              .entries
              .where(
                (entry) => chat.participantUsernames[entry.key] != currentUser,
              )
              .map((entry) => entry.value)
              .toList();
    return InkWell(
      onTap: () {
        context.read<MessageBloc>().add(GetMessagesEvent(chat.chatId));
        context.read<MessageBloc>().add(ListenToMessagesEvent(chat.chatId));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConversationPage(chat: chat)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Pictures
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(
                width: 56,
                height: 56,
                child: chat.isGroup
                    ? Stack(
                        clipBehavior: Clip.hardEdge,
                        children: filteredImages.isNotEmpty
                            ? filteredImages
                                  .take(2)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final i = entry.key;
                                    final image = entry.value;
                                    return Positioned(
                                      left: i * 20.0,
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey[800],
                                        backgroundImage: NetworkImage(image),
                                        onBackgroundImageError: (_, __) =>
                                            const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                      ),
                                    );
                                  })
                                  .toList()
                            : [
                                const Positioned(
                                  left: 0,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.group,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                      )
                    : filteredImages.isNotEmpty
                    ? CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: NetworkImage(filteredImages.first),
                        onBackgroundImageError: (_, __) => const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      )
                    : const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Name, Message, and Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          if (chat.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                chat.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            formatChatTimestamp(chat.lastMessageTime),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage.isNotEmpty
                        ? chat.lastMessage
                        : "No messages yet",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Seen Avatars
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 36,
                height: 24,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: chat.seenBy.isNotEmpty
                      ? chat.seenBy.take(2).toList().asMap().entries.map((
                          entry,
                        ) {
                          final i = entry.key;
                          final viewer = entry.value;
                          return Positioned(
                            left: i * 12.0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: const Color.fromARGB(
                                255,
                                33,
                                87,
                                134,
                              ),
                              child: Text(
                                viewer.isNotEmpty ? viewer[0] : '?',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList()
                      : [
                          const Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.transparent,
                              child: Text(
                                '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatChatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      // Same day → return time only
      return DateFormat('h:mm a').format(dateTime); // e.g., 4:20 PM
    } else if (today.difference(date).inDays == 1) {
      return "Yesterday";
    } else if (today.difference(date).inDays < 7) {
      return DateFormat.E().format(dateTime); // e.g., Mon, Tue
    } else {
      return DateFormat('MMM d').format(dateTime); // e.g., Mar 21
    }
  }
}
