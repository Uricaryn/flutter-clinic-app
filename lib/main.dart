import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:clinic_app/core/config/app_config.dart';
import 'package:clinic_app/core/theme/app_theme.dart';
import 'package:clinic_app/core/providers/theme_provider.dart';
import 'package:clinic_app/core/providers/locale_provider.dart';
import 'package:clinic_app/core/services/navigation_service.dart';
import 'package:clinic_app/features/auth/presentation/screens/login_screen.dart';
import 'package:clinic_app/features/auth/presentation/screens/register_screen.dart';
import 'package:clinic_app/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:clinic_app/features/home/presentation/screens/home_screen.dart';
import 'package:clinic_app/features/appointment/presentation/screens/appointments_screen.dart';
import 'package:clinic_app/features/stock/presentation/screens/stock_management_screen.dart';
import 'package:clinic_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:clinic_app/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:clinic_app/features/splash/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/email-verification': (context) => const EmailVerificationScreen(),
        '/home': (context) => const HomeScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
        '/stock': (context) => const StockManagementScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/admin': (context) => const AdminPanelScreen(),
      },
    );
  }
}
