import 'package:chat_app_test/pages/home_page.dart';
import 'package:chat_app_test/pages/login_page.dart';
import 'package:chat_app_test/pages/register_page.dart';
import 'package:flutter/material.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigationKey;
  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => const LoginPage(),
    "/register": (context) => const RegisterPage(),
    "/home": (context) => const HomePage(),
  };

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigationKey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  NavigationService() {
    _navigationKey = GlobalKey<NavigatorState>();
  }

  void pushNamed(String routeName) {
    _navigationKey.currentState?.pushNamed(routeName);
  }

  void push(MaterialPageRoute route) {
    _navigationKey.currentState?.push(route);
  }

  void pushReplacementNamed(String routeName) {
    _navigationKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigationKey.currentState?.pop();
  }
}
