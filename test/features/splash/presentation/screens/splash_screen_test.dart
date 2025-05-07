import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:clinic_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('SplashScreen shows all required elements',
        (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
        ),
      );

      // Verify logo is present
      expect(find.byIcon(Icons.local_hospital), findsOneWidget);

      // Verify app name is present
      expect(find.text('Clinic App'), findsOneWidget);

      // Verify tagline is present
      expect(find.text('Your Health, Our Priority'), findsOneWidget);

      // Verify loading indicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('SplashScreen navigates to LoginScreen after delay',
        (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
        ),
      );

      // Verify we're on the splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Fast forward 3 seconds
      await tester.pump(const Duration(seconds: 3));

      // Verify navigation to LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('SplashScreen animations are triggered',
        (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
        ),
      );

      // Initial pump to start animations
      await tester.pump();

      // Verify logo animation
      final logoFinder = find.byIcon(Icons.local_hospital);
      expect(logoFinder, findsOneWidget);
      final logoWidget = tester.widget<Icon>(logoFinder);
      expect(logoWidget.color, Colors.white);
      expect(logoWidget.size, 100);

      // Verify text animations
      final appNameFinder = find.text('Clinic App');
      expect(appNameFinder, findsOneWidget);

      final taglineFinder = find.text('Your Health, Our Priority');
      expect(taglineFinder, findsOneWidget);

      // Verify loading indicator animation
      final loadingFinder = find.byType(CircularProgressIndicator);
      expect(loadingFinder, findsOneWidget);
    });

    testWidgets('SplashScreen handles theme colors correctly',
        (WidgetTester tester) async {
      // Build our widget with a custom theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.blue,
          ),
          home: const SplashScreen(),
        ),
      );

      // Verify background color
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);
      final scaffoldWidget = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffoldWidget.backgroundColor, Colors.blue);

      // Verify text colors
      final appNameFinder = find.text('Clinic App');
      expect(appNameFinder, findsOneWidget);
      final appNameWidget = tester.widget<Text>(appNameFinder);
      expect(appNameWidget.style?.color, Colors.white);
    });

    testWidgets('SplashScreen handles widget disposal correctly',
        (WidgetTester tester) async {
      // Build our widget
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
        ),
      );

      // Verify initial state
      expect(find.byType(SplashScreen), findsOneWidget);

      // Dispose the widget
      await tester.pumpWidget(const SizedBox());

      // Verify widget is disposed
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}
