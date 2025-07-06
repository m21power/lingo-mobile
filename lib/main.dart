import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/core/route/route.dart';
import 'package:lingo/dependency_injection.dart';
import 'package:lingo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lingo/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:lingo/features/chat/presentation/bloc/message/message_bloc.dart';
import 'package:lingo/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:lingo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:lingo/features/profile/presentation/bloc/user_bloc/user_bloc.dart';

import 'package:lingo/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Client.initFromPrefs();
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
        BlocProvider(create: (context) => sl<ProfileBloc>()),
        BlocProvider(create: (context) => sl<ChatBloc>()),
        BlocProvider(create: (context) => sl<MessageBloc>()),
        BlocProvider(
          create: (context) =>
              sl<NotificationBloc>()..add(GetNotificationsEvent()),
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
