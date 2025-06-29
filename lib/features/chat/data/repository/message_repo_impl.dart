import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lingo/core/constant/api_constant.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/core/network/network_info_impl.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/domain/repository/message_repository.dart';
import 'package:http/http.dart' as http;

class MessageRepoImpl implements MessageRepository {
  final FirebaseDatabase firebaseDatabase;
  final NetworkInfo networkInfo;
  final http.Client client;
  MessageRepoImpl({
    required this.firebaseDatabase,
    required this.networkInfo,
    required this.client,
  });
  @override
  Future<Either<Failure, List<MessageModel>>> getMessages(String chatId) async {
    if (await networkInfo.isConnected) {
      try {
        final messagesRef = firebaseDatabase.ref("messages/$chatId");
        final snapshot = await messagesRef.get();

        if (snapshot.exists) {
          final Object? rawData = snapshot.value;
          final Map<String, dynamic> messagesData = (rawData is Map)
              ? rawData
                    .map(
                      (key, value) => MapEntry(
                        key.toString(),
                        value as Map<dynamic, dynamic>,
                      ),
                    )
                    .map(
                      (key, value) =>
                          MapEntry(key, Map<String, dynamic>.from(value)),
                    )
              : <String, dynamic>{};
          final List<MessageModel> messages = messagesData.entries.map((entry) {
            return MessageModel.fromMap(entry.value, entry.key);
          }).toList();
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return Right(messages);
        } else {
          return Left(ServerFailure(message: 'No messages found for chat'));
        }
      } catch (e) {
        print("Error fetching messages: $e");
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Stream<List<MessageModel>> listenToMessages(String chatId) {
    final messagesRef = firebaseDatabase.ref("messages/$chatId");
    return messagesRef.onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        final Object? rawData = snapshot.value;
        final Map<String, dynamic> messagesData = (rawData is Map)
            ? rawData
                  .map(
                    (key, value) => MapEntry(
                      key.toString(),
                      value as Map<dynamic, dynamic>,
                    ),
                  )
                  .map(
                    (key, value) =>
                        MapEntry(key, Map<String, dynamic>.from(value)),
                  )
            : <String, dynamic>{};
        final List<MessageModel> messages = messagesData.entries.map((entry) {
          return MessageModel.fromMap(entry.value, entry.key);
        }).toList();
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return messages;
      } else {
        return [];
      }
    });
  }

  @override
  Future<Either<Failure, void>> sendMessage(
    MessageModel message,
    String chatId,
    List<int> participantIds,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final newRef = firebaseDatabase.ref("messages/$chatId").push();
        final generatedId = newRef.key;

        await newRef.set({
          ...message.toMap(),
          'id': generatedId, // <-- include ID in the message data
        });
        final chatRef = firebaseDatabase.ref("chats/$chatId");
        final snapshot = await chatRef.child('unreadCounts').get();

        Map<String, dynamic> updatedCounts = {};

        for (final id in participantIds) {
          final isSender = id == message.senderId;
          final current = snapshot.child(id.toString()).value as int? ?? 0;
          updatedCounts[id.toString()] = isSender ? 0 : current + 1;
        }

        await chatRef.update({
          'lastMessage': message.text,
          'lastMessageId': generatedId,
          'lastMessageTime': message.createdAt.millisecondsSinceEpoch,
          'unreadCounts': updatedCounts,
          'seenBy': [],
        });
        print("Message sent successfully: ${message.toMap()}");
        return Future.value(Right(null));
      } catch (e) {
        return Future.value(Left(ServerFailure(message: e.toString())));
      }
    } else {
      return Future.value(
        Left(ServerFailure(message: 'No internet connection')),
      );
    }
  }

  @override
  Future<Either<Failure, void>> setParticipatingStatus(
    String chatId,
    String userId,
    String messageId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final systemMessageRef = firebaseDatabase.ref(
          "messages/$chatId/$messageId",
        );
        final snapshot = await systemMessageRef.get();

        if (snapshot.exists) {
          final message = MessageModel.fromMap(
            Map<String, dynamic>.from(snapshot.value as Map),
            messageId,
          );

          if (!message.isParticipating.contains(Client.instance.username)) {
            message.isParticipating.add(Client.instance.username ?? "Unknown");
            await systemMessageRef.update({
              'isParticipating': message.isParticipating,
            });
          }
        }

        var uri = Uri.parse("${ApiConstant.baseUrl}/api/v1/pair");
        var response = await client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'pairId': chatId,
            'userId': int.parse(userId),
            "isParticipating": true,
          }),
        );
        if (response.statusCode != 200) {
          return Left(ServerFailure(message: 'Failed to update status'));
        }

        // we should call the backend endpoint here too
        return Right(null);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> setSeenBy(
    String chatId,
    String messageId,
    String username,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final messageRef = firebaseDatabase.ref("messages/$chatId/$messageId");
        final snapshot = await messageRef.get();

        final chatRef = firebaseDatabase.ref("chats/$chatId");
        final unreadSnapshot = await chatRef.child('unreadCounts').get();

        if (unreadSnapshot.exists) {
          final data = Map<String, dynamic>.from(unreadSnapshot.value as Map);

          final myId = Client.instance.id.toString();
          final currentCount = data[myId] ?? 0;

          // Decrease my unread count by 1, but not below 0
          data[myId] = (currentCount > 0) ? currentCount - 1 : 0;

          await chatRef.update({'unreadCounts': data});
        }

        if (snapshot.exists) {
          final messageData = Map<String, dynamic>.from(snapshot.value as Map);
          List<String> seenBy = List<String>.from(messageData['seenBy'] ?? []);

          if (messageData['senderId'] != Client.instance.id &&
              !seenBy.contains(username)) {
            seenBy.add(username);
            await messageRef.update({'seenBy': seenBy});
          }
          return Right(null);
        } else {
          return Left(ServerFailure(message: 'Message not found'));
        }
      } catch (e) {
        print("Error setting seen by: $e");
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: 'No internet connection'));
    }
  }
}
