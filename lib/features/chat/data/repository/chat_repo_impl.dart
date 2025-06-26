import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/core/constant/shared_preference_constant.dart';
import 'package:lingo/core/error/failure.dart';
import 'package:lingo/core/network/network_info_impl.dart';
import 'package:lingo/features/auth/domain/entities/user.dart';
import 'package:lingo/features/chat/domain/entities/chat_model.dart';
import 'package:lingo/features/chat/domain/repository/chat_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepoImpl implements ChatRepository {
  final FirebaseDatabase firebaseDatabase;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  ChatRepoImpl({
    required this.firebaseDatabase,
    required this.networkInfo,
    required this.sharedPreferences,
  });
  @override
  Future<Either<Failure, List<ChatModel>>> getChats() async {
    if (await networkInfo.isConnected) {
      try {
        print("testing ---------------------------------");
        print(Client.instance.attendance);
        print(Client.instance.id);
        print(Client.instance.username);
        print(Client.instance.photoUrl);
        var user = sharedPreferences.getString(
          SharedPreferenceConstant.userKey,
        );
        if (user == null) {
          return Left(ServerFailure(message: 'User not found'));
        }
        User u = User.fromMap(jsonDecode(user));
        final myUserId = "45";

        final userChatIdsRef = firebaseDatabase.ref("userChats/$myUserId");

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
            allChats.add(
              ChatModel.fromMap(chatSnapshot.value as Map<String, dynamic>),
            );
          }
        }
        if (allChats.isEmpty) {
          return Left(ServerFailure(message: 'No chats found'));
        }
        // Sort chats by last message time in descending order
        allChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        return Right(allChats);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(ServerFailure(message: 'No internet connection'));
    }
  }

  @override
  Stream<List<ChatModel>> listenToChats() async* {
    final user = sharedPreferences.getString(SharedPreferenceConstant.userKey);

    if (user == null) {
      throw Exception('User not found');
    }

    final User u = User.fromMap(jsonDecode(user));
    // final String myUserId = u.id.toString();
    final String myUserId = "12"; // For testing, replace with actual user ID

    final userChatIdsRef = firebaseDatabase.ref("userChats/$myUserId");
    final chatIdsSnapshot = await userChatIdsRef.get();

    final chatIds = (chatIdsSnapshot.value as Map?)?.keys.toList() ?? [];

    if (chatIds.isEmpty) {
      yield []; // No chats
      return;
    }

    // Create a controller to emit chat updates
    final controller = StreamController<List<ChatModel>>();

    final List<ChatModel> chats = [];

    for (final chatId in chatIds) {
      firebaseDatabase.ref("chats/$chatId").onValue.listen((event) {
        if (event.snapshot.exists) {
          final chatData = Map<String, dynamic>.from(
            event.snapshot.value as Map,
          );
          final chat = ChatModel.fromMap(chatData);

          // Replace or insert the chat in the list
          final index = chats.indexWhere((c) => c.chatId == chat.chatId);
          if (index >= 0) {
            chats[index] = chat;
          } else {
            chats.add(chat);
          }

          controller.add(List.from(chats)); // Emit updated chat list
        }
      });
    }

    yield* controller.stream;
  }
}
