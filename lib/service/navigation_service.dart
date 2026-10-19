// navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static navigateToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
