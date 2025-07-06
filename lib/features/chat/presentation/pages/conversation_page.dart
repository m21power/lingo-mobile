import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/features/chat/domain/entities/chat_model.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/presentation/bloc/message/message_bloc.dart';
import 'package:lingo/features/chat/presentation/widgets/build_conversatioin_bubble.dart';
import 'package:lingo/features/chat/presentation/widgets/profile_picture.dart';
import 'package:url_launcher/url_launcher.dart';

class ConversationPage extends StatefulWidget {
  final List<String> filteredImages;
  final ChatModel chat;

  const ConversationPage({
    required this.chat,
    required this.filteredImages,
    super.key,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final Map<String, GlobalKey> _messageKeys = {};

  void scrollToSystemMessage(List<MessageModel> messages) async {
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].isSystemMessage) {
        final key = _messageKeys[messages[i].id];
        if (key != null) {
          // Step 1: Scroll near the item first
          _scrollController.animateTo(
            i * 100.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );

          // Step 2: Wait a little to allow widget to build
          await Future.delayed(const Duration(milliseconds: 350));

          // Step 3: Now ensure visible
          if (key.currentContext != null) {
            Scrollable.ensureVisible(
              key.currentContext!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
        break;
      }
    }
  }

  void sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    MessageModel newMessage = MessageModel(
      isParticipating: [],
      id: DateTime.now().toIso8601String(),
      text: text,
      senderId: Client.instance.id!,
      senderName: Client.instance.username ?? "Unknown",
      createdAt: DateTime.now(),
      seenBy: [],
      isSystemMessage: false,
      senderProfileImageUrl: Client.instance.photoUrl,
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
            ProfilePicture(
              filteredImages: widget.filteredImages,
              isGroup: widget.chat.isGroup,
            ),
            const SizedBox(width: 10),
            Text(
              widget.chat.participantIds.length == 2
                  ? widget.chat.participantUsernames.firstWhere(
                      (name) => name != Client.instance.username,
                    )
                  : widget.chat.participantUsernames
                        .where((name) => name != Client.instance.username)
                        .join(" and "),
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
                            itemBuilder: (context, index) {
                              final message = messages[index];

                              // Assign a key if not already assigned
                              _messageKeys.putIfAbsent(
                                message.id,
                                () => GlobalKey(),
                              );

                              return Container(
                                key: _messageKeys[message.id],
                                child: BuildConversatioinBubble(
                                  message: message,
                                  chat: widget.chat,
                                ),
                              );
                            },
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

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => scrollToSystemMessage(messages),
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
                            "Daily Pair. Tap to scroll.",
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
        },
      ),
    );
  }
}
