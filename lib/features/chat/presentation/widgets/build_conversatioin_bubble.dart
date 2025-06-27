import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/features/chat/domain/entities/chat_model.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/presentation/bloc/message/message_bloc.dart';

class BuildConversatioinBubble extends StatefulWidget {
  final MessageModel message;
  final ChatModel chat;
  const BuildConversatioinBubble({
    super.key,
    required this.message,
    required this.chat,
  });

  @override
  State<BuildConversatioinBubble> createState() =>
      _BuildConversatioinBubbleState();
}

class _BuildConversatioinBubbleState extends State<BuildConversatioinBubble> {
  @override
  Widget build(BuildContext context) {
    return _buildMessageBubble(widget.message, context);
  }

  Widget _buildMessageBubble(MessageModel message, BuildContext context) {
    final isMe = message.senderId == Client.instance.id;

    if (message.isSystemMessage) {
      final bool iJoined = widget.message.isParticipating.contains(
        Client.instance.username,
      );
      final bool allJoined =
          widget.message.isParticipating.length ==
          widget.chat.participantIds.length;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.all(18),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF1f1f1f), Color(0xFF2b2b2b)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Welcome! Ready to practice? Press 'Ready' below to notify your peers.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    DateFormat('hh:mm a').format(message.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "🎯 Your daily pairs:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                for (var username in widget.chat.participantUsernames)
                  _buildFancyName(username),
                const SizedBox(height: 16),
                if (allJoined) ...[
                  const Text(
                    "If you're all ready to practice, one of you click the 'Start' button below.",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                ],

                const SizedBox(height: 14),

                if (!iJoined)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<MessageBloc>().add(
                          SetParticipatingStatusEvent(
                            chatId: widget.chat.chatId,
                            userId: Client.instance.id.toString(),
                            messageId: message.id,
                          ),
                        );
                        setState(() {
                          widget.message.isParticipating.add(
                            Client.instance.username ?? "Unknown",
                          );
                        });
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        "Ready",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          226,
                          134,
                          94,
                          207,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                      ),
                    ),
                  )
                else if (allJoined)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Start logic
                      },
                      icon: const Icon(Icons.call, color: Colors.white),
                      label: const Text(
                        "Start",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 94, 66, 170),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Text(
                      "Waiting for others to join...",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe
                ? const Color.fromARGB(255, 87, 119, 145)
                : Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          widget.chat.participantImages.first,
                        ),
                        backgroundColor: Colors.grey[800],
                        onBackgroundImageError: (_, __) =>
                            const Icon(Icons.person),
                      ),
                    ),
                  Flexible(
                    child: Text(
                      message.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                "Seen by: ${message.seenBy.join(', ')}",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                DateFormat('hh:mm a').format(message.createdAt),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFancyName(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "• $name",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.cyanAccent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          widget.message.isParticipating.contains(name)
              ? Icon(Icons.check_circle, color: Colors.green, size: 16)
              : Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
        ],
      ),
    );
  }
}
