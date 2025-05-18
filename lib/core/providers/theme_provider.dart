import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create a provider for initial theme
final initialThemeProvider = Provider<ThemeMode>((ref) {
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;
  return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode>
    with WidgetsBindingObserver {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (_isSystemTheme) {
      _updateThemeFromSystem();
    }
  }

  static const _themeKey = 'theme_mode';
  bool _isSystemTheme = true;

  void _updateThemeFromSystem() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final newTheme =
        brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    if (state != newTheme) {
      state = newTheme;
    }
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);

      if (themeIndex != null) {
        final savedTheme = ThemeMode.values[themeIndex];
        _isSystemTheme = savedTheme == ThemeMode.system;

        if (_isSystemTheme) {
          _updateThemeFromSystem();
        } else {
          state = savedTheme;
        }
      } else {
        _isSystemTheme = true;
        _updateThemeFromSystem();
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
      _isSystemTheme = true;
      _updateThemeFromSystem();
    }
  }

  Future<void> setTheme(ThemeMode theme) async {
    try {
      _isSystemTheme = theme == ThemeMode.system;

      if (_isSystemTheme) {
        _updateThemeFromSystem();
      } else {
        state = theme;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  void toggleTheme() {
    if (_isSystemTheme) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final newTheme =
          brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
      setTheme(newTheme);
    } else {
      final newTheme =
          state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      setTheme(newTheme);
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _isSystemTheme = mode == ThemeMode.system;
  }

  // Sistem teması değişikliklerini dinle
  void updateSystemTheme(Brightness brightness) {
    if (_isSystemTheme) {
      setThemeMode(
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light);
    }
  }
}
