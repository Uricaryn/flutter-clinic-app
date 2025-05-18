import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:clinic_app/core/routes/app_router.dart';
import 'package:clinic_app/core/services/logger_service.dart';
import 'firebase_options.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(error),
      ),
    );
  }
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Firestore ayarlarını yapılandır
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Firestore bağlantısını test et
    await FirebaseFirestore.instance.collection('test').doc('test').set({
      'timestamp': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance.collection('test').doc('test').delete();

    LoggerService().info('Firebase and Firestore initialized successfully');
  } catch (e, stackTrace) {
    LoggerService().error('Failed to initialize Firebase', e, stackTrace);
    // Hata detaylarını göster
    debugPrint('Firebase initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
  } catch (e) {
    // Firebase başlatma hatası durumunda kullanıcıya bilgi ver
    debugPrint('Critical error: Firebase initialization failed. $e');
    // Burada bir hata ekranı gösterebilirsiniz
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final _logger = LoggerService();

    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeProvider),
      navigatorKey: NavigationService.navigatorKey,
      scaffoldMessengerKey: NavigationService.scaffoldMessengerKey,
      onGenerateRoute: AppRouter.generateRoute,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(localeProvider),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home: authState.when(
        data: (user) {
          _logger.info(
              'Auth state changed: ${user != null ? 'User logged in' : 'No user'}');
          if (user == null) {
            return const LoginScreen();
          }
          return const HomeScreen();
        },
        loading: () {
          _logger.info('Auth state is loading, showing splash screen');
          return const SplashScreen();
        },
        error: (error, stack) {
          _logger.error('Auth state error', error, stack);
          return ErrorScreen(error: error.toString());
        },
      ),
    );
  }
}
