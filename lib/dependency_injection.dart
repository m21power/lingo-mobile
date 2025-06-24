import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart' as get_it;
import 'package:http/http.dart' as http;
import 'package:lingo/core/network/network_info_impl.dart';
import 'package:lingo/features/auth/data/auth_repo_impl.dart';
import 'package:lingo/features/auth/domain/repository/auth_repo.dart';
import 'package:lingo/features/auth/domain/usecase/check_otp_usecase.dart';
import 'package:lingo/features/auth/domain/usecase/is_logged_in_usecase.dart';
import 'package:lingo/features/auth/domain/usecase/wake_up_usecase.dart';
import 'package:lingo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lingo/features/profile/data/repository/profile_repo_impl.dart';
import 'package:lingo/features/profile/domain/repository/profile_repo.dart';
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
  // bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      checkOtpUsecase: sl(),
      isLoggedInUsecase: sl(),
      wakeUpUsecase: sl(),
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
  // bloc
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getConsistencyUsecase: sl(),
      getUserUsecase: sl(),
      getRanksUsecase: sl(),
      updateNicknameUsecase: sl(),
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
}
