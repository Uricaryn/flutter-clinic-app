import 'package:flutter/material.dart';
import 'package:clinic_app/shared/widgets/animated_page_route.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Named route navigation
  static Future<dynamic> navigateToNamed(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateToNamedReplacement(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateToNamedAndClearStack(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // Animated navigation
  static Future<dynamic> navigateTo(Widget page, {bool replace = false}) {
    final route = AnimatedPageRoute.fadeThrough(page);
    if (replace) {
      return navigatorKey.currentState!.pushReplacement(route);
    }
    return navigatorKey.currentState!.push(route);
  }

  static Future<dynamic> navigateToSlideUp(Widget page,
      {bool replace = false}) {
    final route = AnimatedPageRoute.slideUp(page);
    if (replace) {
      return navigatorKey.currentState!.pushReplacement(route);
    }
    return navigatorKey.currentState!.push(route);
  }

  static Future<dynamic> navigateToSlideRight(Widget page,
      {bool replace = false}) {
    final route = AnimatedPageRoute.slideRight(page);
    if (replace) {
      return navigatorKey.currentState!.pushReplacement(route);
    }
    return navigatorKey.currentState!.push(route);
  }

  // Navigation actions
  static void goBack([dynamic result]) {
    navigatorKey.currentState!.pop(result);
  }

  static void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  static void popToFirst() {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }
}
