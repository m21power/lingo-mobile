import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/core/network/network_info_impl.dart';
import 'package:lingo/features/chat/domain/entities/chat_model.dart';
import 'package:lingo/features/chat/domain/repository/chat_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepoImpl implements ChatRepository {
  final FirebaseDatabase firebaseDatabase;
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  ChatRepoImpl({
    required this.firebaseDatabase,
    required this.networkInfo,
    required this.sharedPreferences,
    required this.firestore,
  });
  @override
  Future<Either<Failure, Chat>> getChats() async {
    if (await networkInfo.isConnected) {
      try {
        final userChatIdsRef = firebaseDatabase.ref(
          "userChats/${Client.instance.id.toString()}",
        );

        final chatIdsSnapshot = await userChatIdsRef.get();
        final chatIds = (chatIdsSnapshot.value as Map?)?.keys ?? [];
        if (chatIds.isEmpty) {
          return Left(ServerFailure(message: 'No chats found for user'));
        }

        final List<ChatModel> allChats = [];
        for (final chatId in chatIds) {
          final chatSnapshot = await firebaseDatabase
              .ref("chats/$chatId")
              .get();
          if (chatSnapshot.exists) {
            var chats = chatSnapshot.value as Map<dynamic, dynamic>;

            final messageSnapshot = await firebaseDatabase
                .ref("messages/$chatId/${chats["lastMessageId"]}")
                .get();

            final messageData = messageSnapshot.value as Map<dynamic, dynamic>?;
            List<String> participantUsernames = [];
            List<String> participantImages = [];
            chats["seenBy"] = messageData?["seenBy"] ?? [];

            // Fetch user data synchronously
            for (var userId in chats["participantIds"]) {
              print("Fetching user data for ID: $userId");

              final userDoc = await firestore.doc("users/$userId").get();
              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>;
                participantUsernames.add(userData["username"]);
                participantImages.add(userData["profileUrl"]);
              }
            }

            allChats.add(
              ChatModel.fromMap(
                chats as Map<String, dynamic>, // safe to cast now
                chatId,
                participantUsernames,
                participantImages,
              ),
            );
          }
        }

        if (allChats.isEmpty) {
          return Left(ServerFailure(message: 'No chats found'));
        }
        // Sort chats by last message time in descending order
        allChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        int unreadCount = 0;
        for (var chat in allChats) {
          unreadCount += chat.unreadCount;
        }
        return Right(Chat(chats: allChats, unreadCount: unreadCount));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Stream<Chat> listenToChats() async* {
    final userChatIdsRef = firebaseDatabase.ref(
      "userChats/${Client.instance.id.toString()}",
    );
    final chatIdsSnapshot = await userChatIdsRef.get();

    final chatIds = (chatIdsSnapshot.value as Map?)?.keys.toList() ?? [];

    if (chatIds.isEmpty) {
      yield Chat(chats: [], unreadCount: 0); // No chats
      return;
    }

    // Create a controller to emit chat updates
    final controller = StreamController<Chat>();

    final List<ChatModel> chats = [];

    for (final chatId in chatIds) {
      firebaseDatabase.ref("chats/$chatId").onValue.listen((event) {
        if (event.snapshot.exists) {
          final chatData = Map<String, dynamic>.from(
            event.snapshot.value as Map,
          );

          firebaseDatabase
              .ref("messages/$chatId/${chatData["lastMessageId"]}")
              .onValue
              .listen((messageEvent) async {
                if (messageEvent.snapshot.exists) {
                  final messageData = Map<String, dynamic>.from(
                    messageEvent.snapshot.value as Map,
                  );
                  chatData["seenBy"] = messageData["seenBy"];
                } else {
                  chatData["seenBy"] = [];
                }
                List<String> participantUsernames = [];
                List<String> participantImages = [];
                for (var userId in chatData["participantIds"]) {
                  print("Fetching user data for ID: $userId");

                  var userDoc = await firestore.doc("users/$userId").get();
                  if (userDoc.exists) {
                    final userData = userDoc.data() as Map<String, dynamic>;
                    participantUsernames.add(userData["username"]);
                    participantImages.add(userData["profileUrl"]);
                  }
                }
                final chat = ChatModel.fromMap(
                  chatData,
                  chatId,
                  participantUsernames,
                  participantImages,
                );

                final index = chats.indexWhere((c) => c.chatId == chat.chatId);
                if (index >= 0) {
                  chats[index] = chat;
                } else {
                  chats.add(chat);
                }
                int unreadCount = 0;
                for (var chat in chats) {
                  unreadCount += chat.unreadCount;
                }
                controller.add(
                  Chat(
                    chats: List<ChatModel>.from(chats),
                    unreadCount: unreadCount,
                  ),
                );
              });
        }
      });
    }

    yield* controller.stream;
  }
}
