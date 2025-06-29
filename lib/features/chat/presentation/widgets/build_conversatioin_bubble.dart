import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/features/chat/domain/entities/chat_model.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/presentation/bloc/message/message_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool isViewingChat = false;
  @override
  void initState() {
    super.initState();
    isViewingChat = true;
  }

  @override
  void dispose() {
    isViewingChat = false;
    super.dispose();
  }

  void _redirectToTelegram(String username) async {
    final Uri tgUrl = Uri.parse('tg://resolve?domain=$username');
    final Uri httpsUrl = Uri.parse('https://t.me/$username');

    try {
      if (await canLaunchUrl(tgUrl)) {
        await launchUrl(tgUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(httpsUrl)) {
        await launchUrl(httpsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Telegram')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildMessageBubble(MessageModel message, BuildContext context) {
    final isMe = message.senderId == Client.instance.id;

    if (!isMe) {
      // Mark message as seen if the user is viewing the chat
      if (isViewingChat && !message.seenBy.contains(Client.instance.username)) {
        print(message.text);
        context.read<MessageBloc>().add(
          MarkMessageAsSeenEvent(
            chatId: widget.chat.chatId,
            messageId: message.id,
            username: Client.instance.username ?? "Unknown",
          ),
        );
      }
    }
    final isImageAvailable =
        message.senderProfileImageUrl != null &&
        message.senderProfileImageUrl!.isNotEmpty;

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
                        for (var username in widget.chat.participantUsernames) {
                          if (username != Client.instance.username) {
                            _redirectToTelegram(username);
                            return;
                          }
                        }
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
        child: IntrinsicWidth(
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
                // Username (only show for others)
                if (!isMe)
                  GestureDetector(
                    onTap: () {
                      _redirectToTelegram(widget.message.senderName);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        "@${widget.message.senderName}" ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                // Row with Avatar and Message Text
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: isImageAvailable
                            ? CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  widget.message.senderProfileImageUrl!,
                                ),
                                backgroundColor: Colors.grey[800],
                                onBackgroundImageError: (_, __) =>
                                    const Icon(Icons.person),
                              )
                            : const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                      ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          message.text,
                          textAlign: TextAlign.left,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (message.seenBy.isNotEmpty)
                      SizedBox(
                        width: message.seenBy.length * 20.0, // Give it width
                        height: 20,
                        child: Stack(
                          children: [
                            for (int i = 0; i < message.seenBy.length; i++)
                              message.seenBy[i] != Client.instance.username
                                  ? Positioned(
                                      left: i * 16,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          92,
                                          90,
                                          90,
                                        ),
                                        child: Text(
                                          message.seenBy[i][0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('hh:mm a').format(message.createdAt),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
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
            "• @$name",
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
