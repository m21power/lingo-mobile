import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingo/core/route/route.dart';
import 'package:lingo/dependency_injection.dart';
import 'package:lingo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lingo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:lingo/features/profile/presentation/bloc/user_bloc/user_bloc.dart';

import 'package:lingo/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<AuthBloc>()..add(IsLoggedInEvent()),
        ),
        BlocProvider(create: (context) => sl<UserBloc>()),
        BlocProvider(
          create: (context) => sl<ProfileBloc>()
            ..add(GetUserEvent())
            ..add(GetRanksEvent())
            ..add(GetConsistencyEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Lingo',
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
