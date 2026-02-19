import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class NavigationService {
  NavigationService(this._navigatorKey);

  final GlobalKey<NavigatorState> _navigatorKey;

  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return _navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  // Go to 'routeName' screen and remove all the other screen from navigator
  void resetToScreen(String routeName, {Object? arguments}) {
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  void replaceScreen(String routeName, {Object? arguments}) {
    _navigatorKey.currentState?.popAndPushNamed(
      routeName,
      arguments: arguments,
    );
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }
}
