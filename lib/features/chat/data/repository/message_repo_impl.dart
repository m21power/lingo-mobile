import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/core/network/network_info_impl.dart';
import 'package:lingo/features/chat/domain/entities/message_model.dart';
import 'package:lingo/features/chat/domain/repository/message_repository.dart';

class MessageRepoImpl implements MessageRepository {
  final FirebaseDatabase firebaseDatabase;
  final NetworkInfo networkInfo;
  MessageRepoImpl({required this.firebaseDatabase, required this.networkInfo});
  @override
  Future<Either<Failure, List<MessageModel>>> getMessages(String chatId) async {
    if (await networkInfo.isConnected) {
      try {
        // return Right([]); // Return an empty list if no messages are found
        final messagesRef = firebaseDatabase.ref("messages/$chatId");
        final snapshot = await messagesRef.get();
        if (snapshot.exists) {
          // Use a logging framework instead of print
          // logger.i("snapshot exists: ${snapshot.value}");
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
            return MessageModel.fromMap(entry.value);
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
          return MessageModel.fromMap(entry.value);
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
          final isSender = id == message.senderId.toString();
          final current = snapshot.child(id.toString()).value as int? ?? 0;
          updatedCounts[id.toString()] = isSender ? 0 : current + 1;
        }

        await chatRef.update({
          'lastMessage': message.text,
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
}
