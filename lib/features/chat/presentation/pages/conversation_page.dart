import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/features/chat/domain/entities/chat_model.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/presentation/bloc/message/message_bloc.dart';

class ConversationPage extends StatefulWidget {
  final ChatModel chat;

  const ConversationPage({required this.chat, super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  String? pinnedMessageId;

  void scrollToSystemMessage(String messageId, List<MessageModel> messages) {
    final index = messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      _scrollController.animateTo(
        index * 100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    MessageModel newMessage = MessageModel(
      id: DateTime.now().toIso8601String(), // Generate a unique ID
      text: text,
      senderId: 12, // or your Client.id
      senderName: "Mesay", // or your Client.username
      createdAt: DateTime.now(),
      seenBy: [], // Initially empty, update as needed
      isSystemMessage: false, // Set to true if it's a system message
    );
    context.read<MessageBloc>().add(
      SendMessageEvent(
        widget.chat.chatId,
        newMessage,
        widget.chat.participantIds,
      ),
    );

    _messageController.clear();
  }

  Widget _buildMessageBubble(MessageModel message) {
    // later we will be using sender id
    final isMe = message.senderName == "mesay";

    if (message.isSystemMessage) {
      return GestureDetector(
        onTap: () => setState(() => pinnedMessageId = message.id),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                widget.chat.participantImages.first,
              ),
              backgroundColor: Colors.grey[800],
            ),
            const SizedBox(width: 10),
            Text(
              widget.chat.name,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
      body: BlocConsumer<MessageBloc, MessageState>(
        listener: (context, state) {
          print("Message state: $state");
          if (state is MessageLoaded) {
            Future.delayed(const Duration(milliseconds: 100), () {
              _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent,
              );
            });
          }
        },
        builder: (context, state) {
          List<MessageModel> messages = [];
          if (state is MessageLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MessageLoaded) {
            messages = state.messages;
          } else if (state is MessageError) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     backgroundColor: Colors.red,
            //     content: Text(
            //       state.message,
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            // );
          }
          return Stack(
            children: [
              Column(
                children: [
                  // Message list or fallback
                  Expanded(
                    child: messages.isEmpty
                        ? const Center(
                            child: Text(
                              "No messages yet",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) =>
                                _buildMessageBubble(messages[index]),
                          ),
                  ),

                  // Message input
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    color: Colors.grey[900],
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[800],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Pinned message
              if (pinnedMessageId != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () =>
                        scrollToSystemMessage(pinnedMessageId!, messages),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.grey[850],
                      child: Row(
                        children: [
                          const Icon(
                            Icons.push_pin,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "Pinned message. Tap to scroll.",
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );

          return const Center(
            child: Text(
              "Something went wrong",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
