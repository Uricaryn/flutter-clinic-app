import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:clinic_app/core/config/app_config.dart';
import 'package:clinic_app/core/config/app_mode.dart';
import 'package:clinic_app/core/theme/app_theme.dart';
import 'package:clinic_app/core/providers/theme_provider.dart';
import 'package:clinic_app/core/providers/locale_provider.dart';
import 'package:clinic_app/core/services/navigation_service.dart';
import 'package:clinic_app/features/auth/presentation/screens/login_screen.dart';
import 'package:clinic_app/features/home/presentation/screens/home_screen.dart';
import 'package:clinic_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:clinic_app/core/routes/app_router.dart';
import 'package:clinic_app/core/services/logger_service.dart';
import 'firebase_options.dart';
import 'package:clinic_app/core/providers/dual_auth_provider.dart';

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

Future<void> initializeApp() async {
  final logger = LoggerService();
  
  // Log current database mode
  logger.info('🚀 Starting app in ${AppMode.modeName} mode');
  debugPrint('═══════════════════════════════════════');
  debugPrint('🔧 DATABASE MODE: ${AppMode.modeName}');
  debugPrint('═══════════════════════════════════════');

  // Only initialize Firebase if in Firebase mode
  if (AppMode.isFirebase) {
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

      logger.info('✅ Firebase and Firestore initialized successfully');
      debugPrint('✅ Firebase initialized');
    } catch (e, stackTrace) {
      logger.error('❌ Failed to initialize Firebase', e, stackTrace);
      debugPrint('❌ Firebase initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  } else {
    // PostgreSQL mode
    logger.info('✅ PostgreSQL mode - skipping Firebase initialization');
    debugPrint('✅ PostgreSQL mode active');
    debugPrint('📡 Backend API: Check ApiConfig for endpoints');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeApp();
  } catch (e) {
    debugPrint('❌ Critical error: App initialization failed. $e');
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
    final authState = ref.watch(unifiedAuthStateProvider);
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
          final modeInfo = '${AppMode.modeName} mode';
          _logger.info(
              'Auth state changed ($modeInfo): ${user != null ? 'User logged in' : 'No user'}');
          if (user == null) {
            return const LoginScreen();
          }
          return const HomeScreen();
        },
        loading: () {
          _logger.info('Auth state is loading (${AppMode.modeName} mode), showing splash screen');
          return const SplashScreen();
        },
        error: (error, stack) {
          _logger.error('Auth state error (${AppMode.modeName} mode)', error, stack);
          return ErrorScreen(error: error.toString());
        },
      ),
    );
  }
}
