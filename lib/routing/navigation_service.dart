import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  NavigationService._internal();

  // With this factory setup, any time NavigationService() is called
  // within the application _instance will be returned and not a new instance
  factory NavigationService() => _instance;

  // This would allow the app to monitor the current screen state during navigation.
  //
  // This is where the singleton setup we did
  // would help as the state is internally maintained
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState
        ?.pushNamed(routeName, arguments: arguments);
  }

  // Go to 'routeName' screen and remove all the other screen from navigator
  void resetToScreen(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  void replaceScreen(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.popAndPushNamed(
      routeName,
      arguments: arguments,
    );
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }
}
