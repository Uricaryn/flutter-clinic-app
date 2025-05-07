// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/main.dart';
import 'package:clinic_app/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('App should start with SplashScreen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the app starts with SplashScreen
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('App should have correct theme configuration',
      (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Get the MaterialApp widget
    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify theme configuration
    expect(app.theme, isNotNull);
    expect(app.darkTheme, isNotNull);
    expect(app.themeMode, ThemeMode.system);
    expect(app.debugShowCheckedModeBanner, false);
  });

  testWidgets('App should have all required routes',
      (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Get the MaterialApp widget
    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify that routes are defined
    expect(app.routes, isNotNull);
    expect(app.routes!.length, greaterThan(0));
  });

  testWidgets('App should handle navigation service',
      (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Get the MaterialApp widget
    final MaterialApp app = tester.widget(find.byType(MaterialApp));

    // Verify that navigatorKey is set
    expect(app.navigatorKey, isNotNull);
  });
}
