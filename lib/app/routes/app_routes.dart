import 'package:flutter/material.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String landing = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String chat = '/chat';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landing:
        return MaterialPageRoute<void>(
          builder: (_) => const LandingPage(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case signup:
        return MaterialPageRoute<void>(
          builder: (_) => const SignupPage(),
          settings: settings,
        );
      case chat:
        final user = settings.arguments;
        if (user is! AppUser) {
          return MaterialPageRoute<void>(
            builder: (_) => const LandingPage(),
            settings: settings,
          );
        }
        return MaterialPageRoute<void>(
          builder: (_) => ChatPage(user: user),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const LandingPage(),
          settings: settings,
        );
    }
  }
}
