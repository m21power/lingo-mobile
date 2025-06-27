import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lingo/core/constant/client_constant.dart';
import 'package:lingo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lingo/features/auth/presentation/pages/login_page.dart';
import 'package:lingo/features/chat/presentation/bloc/chat/chat_bloc.dart';
import 'package:lingo/features/home/presentation/pages/home_page.dart';
import 'package:lingo/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:lingo/welcome_page.dart';

import '../constant/route_constant.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: RouteConstant.welcomePageRoute,
      builder: (context, state) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            print('Current Auth State: $state'); // Debugging line
            if (state is AuthInitial) {
              return const WelcomePage();
            } else if (state is IsLoggedInSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              });
              context.read<ChatBloc>().add(GetChatsEvent());
              context.read<ChatBloc>().add(ListenToChatEvent());
              context.read<ProfileBloc>().add(GetUserEvent());
              context.read<ProfileBloc>().add(GetRanksEvent());
              context.read<ProfileBloc>().add(GetConsistencyEvent());

              return HomePage();
            } else {
              return LoginPage();
            }
          },
        );
      },
    ),
    // GoRoute(
    //   path: '/login',
    //   name: RouteConstant.loginPageRoute,
    //   builder: (context, state) => LoginPage(),
    // ),
  ],
);
