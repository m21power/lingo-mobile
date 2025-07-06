import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart' as get_it;
import 'package:http/http.dart' as http;
import 'package:lingo/core/network/network_info_impl.dart';
import 'package:lingo/features/auth/data/auth_repo_impl.dart';
import 'package:lingo/features/auth/domain/repository/auth_repo.dart';
import 'package:lingo/features/auth/domain/usecase/check_otp_usecase.dart';
import 'package:lingo/features/auth/domain/usecase/is_logged_in_usecase.dart';
import 'package:lingo/features/auth/domain/usecase/logout_usecase.dart';
import 'package:lingo/features/auth/domain/usecase/wake_up_usecase.dart';
import 'package:lingo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lingo/features/chat/data/repository/chat_repo_impl.dart';
import 'package:lingo/features/chat/data/repository/message_repo_impl.dart';
import 'package:lingo/features/chat/domain/repository/chat_repository.dart';
import 'package:lingo/features/chat/domain/repository/message_repository.dart';
import 'package:lingo/features/chat/domain/usecase/get_chats_usecase.dart';
import 'package:lingo/features/chat/domain/usecase/get_messages_usecase.dart';
import 'package:lingo/features/chat/domain/usecase/listen_to_chat_usecase.dart';
import 'package:lingo/features/chat/domain/usecase/listen_to_messages.dart';
import 'package:lingo/features/chat/domain/usecase/mark_message_as_seen.dart';
import 'package:lingo/features/chat/domain/usecase/send_messages_usecase.dart';
import 'package:lingo/features/chat/domain/usecase/set_participating_status_usecase.dart';
import 'package:lingo/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:lingo/features/chat/presentation/bloc/message/message_bloc.dart';
import 'package:lingo/features/notifications/data/repository/notification_repo_impl.dart';
import 'package:lingo/features/notifications/domain/repository/notification_repo.dart';
import 'package:lingo/features/notifications/domain/usecase/get_notification.dart';
import 'package:lingo/features/notifications/domain/usecase/mark_notification_as_seen_usecase.dart';
import 'package:lingo/features/notifications/domain/usecase/pair_me_usecase.dart';
import 'package:lingo/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:lingo/features/profile/data/repository/profile_repo_impl.dart';
import 'package:lingo/features/profile/domain/repository/profile_repo.dart';
import 'package:lingo/features/profile/domain/usecase/generate_daily_pair_usecase.dart';
import 'package:lingo/features/profile/domain/usecase/get_consistency_usecase.dart';
import 'package:lingo/features/profile/domain/usecase/get_ranks_usecase.dart';
import 'package:lingo/features/profile/domain/usecase/get_user_usecase.dart';
import 'package:lingo/features/profile/domain/usecase/update_nickname_usecase.dart';
import 'package:lingo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:lingo/features/profile/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = get_it.GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  // firebase
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseDatabase>(() => FirebaseDatabase.instance);
  //auth
  // repository
  sl.registerLazySingleton<AuthRepo>(
    () =>
        AuthRepoImpl(networkInfo: sl(), client: sl(), sharedPreferences: sl()),
  );
  // usecases
  sl.registerLazySingleton<CheckOtpUsecase>(
    () => CheckOtpUsecase(authRepo: sl()),
  );
  sl.registerLazySingleton<IsLoggedInUsecase>(
    () => IsLoggedInUsecase(authRepo: sl()),
  );
  sl.registerLazySingleton<WakeUpUsecase>(() => WakeUpUsecase(authRepo: sl()));
  sl.registerLazySingleton<LogoutUsecase>(() => LogoutUsecase(authRepo: sl()));
  // bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      checkOtpUsecase: sl(),
      isLoggedInUsecase: sl(),
      wakeUpUsecase: sl(),
      logoutUsecase: sl(),
    ),
  );

  // profile
  // repository
  sl.registerLazySingleton<ProfileRepo>(
    () => ProfileRepoImpl(
      networkInfo: sl(),
      client: sl(),
      sharedPreferences: sl(),
      firestore: sl(),
    ),
  );
  // usecases
  sl.registerLazySingleton<GetRanksUsecase>(
    () => GetRanksUsecase(profileRepo: sl()),
  );
  sl.registerLazySingleton<GetConsistencyUsecase>(
    () => GetConsistencyUsecase(profileRepo: sl()),
  );
  sl.registerLazySingleton<GetUserUsecase>(
    () => GetUserUsecase(profileRepo: sl()),
  );
  sl.registerLazySingleton<UpdateNicknameUsecase>(
    () => UpdateNicknameUsecase(profileRepo: sl()),
  );
  sl.registerLazySingleton<GenerateDailyPairUsecase>(
    () => GenerateDailyPairUsecase(profileRepo: sl()),
  );
  // bloc
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getConsistencyUsecase: sl(),
      getUserUsecase: sl(),
      getRanksUsecase: sl(),
      updateNicknameUsecase: sl(),
      generateDailyPairUsecase: sl(),
    ),
  );
  // user bloc
  sl.registerFactory<UserBloc>(
    () => UserBloc(
      getConsistencyUsecase: sl(),
      getRanksUsecase: sl(),
      getUserUsecase: sl(),
    ),
  );
  // chats
  // repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepoImpl(
      firebaseDatabase: sl(),
      networkInfo: sl(),
      sharedPreferences: sl(),
    ),
  );
  // usecases
  sl.registerLazySingleton<GetChatsUsecase>(
    () => GetChatsUsecase(chatRepository: sl()),
  );
  sl.registerLazySingleton<ListenToChatUsecase>(
    () => ListenToChatUsecase(chatRepository: sl()),
  );
  // bloc
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(getChatsUsecase: sl(), listenToChatUsecase: sl()),
  );

  // messages
  // repository
  sl.registerLazySingleton<MessageRepository>(
    () => MessageRepoImpl(
      firebaseDatabase: sl(),
      networkInfo: sl(),
      client: sl(),
    ),
  );
  // usecases
  sl.registerLazySingleton<GetMessagesUsecase>(
    () => GetMessagesUsecase(messageRepository: sl()),
  );
  sl.registerLazySingleton<ListenToMessages>(
    () => ListenToMessages(messageRepository: sl()),
  );
  sl.registerLazySingleton<SendMessagesUsecase>(
    () => SendMessagesUsecase(messageRepository: sl()),
  );
  sl.registerLazySingleton<SetParticipatingStatusUsecase>(
    () => SetParticipatingStatusUsecase(messageRepository: sl()),
  );
  sl.registerLazySingleton<MarkMessageAsSeenUsecase>(
    () => MarkMessageAsSeenUsecase(messageRepository: sl()),
  );
  // bloc
  sl.registerFactory<MessageBloc>(
    () => MessageBloc(
      getMessagesUsecase: sl(),
      listenToMessages: sl(),
      sendMessagesUsecase: sl(),
      setParticipatingStatusUsecase: sl(),
      markMessageAsSeenUsecase: sl(),
    ),
  );
  // notifications
  // repository
  sl.registerLazySingleton<NotificationRepo>(
    () => NotificationRepoImpl(networkInfo: sl(), client: sl()),
  );
  // usecases
  sl.registerLazySingleton<GetNotificationUsecase>(
    () => GetNotificationUsecase(notificationRepo: sl()),
  );
  sl.registerLazySingleton<MarkNotificationAsSeenUsecase>(
    () => MarkNotificationAsSeenUsecase(notificationRepo: sl()),
  );
  sl.registerLazySingleton<PairMeUsecase>(
    () => PairMeUsecase(notificationRepo: sl()),
  );
  // bloc
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getNotificationUsecase: sl(),
      markNotificationAsSeenUsecase: sl(),
      pairMeUsecase: sl(),
    ),
  );
}
