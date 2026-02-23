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

  void resetToScreen(String routeName, {Object? arguments}) {
    _navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
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
