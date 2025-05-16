import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  late final Logger _logger;
  late final File _logFile;
  static const String _logFileName = 'app_logs.txt';

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
    _initLogFile();
  }

  Future<void> _initLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$_logFileName');
      if (!await _logFile.exists()) {
        await _logFile.create();
      }
      debugPrint('Log file initialized at: ${_logFile.path}');
    } catch (e) {
      debugPrint('Error initializing log file: $e');
    }
  }

  Future<void> _writeToFile(String message) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final logMessage = '$timestamp: $message\n';

      // Write to file
      await _logFile.writeAsString(
        logMessage,
        mode: FileMode.append,
      );

      // Also print to console in debug mode
      if (kDebugMode) {
        debugPrint(logMessage);
      }
    } catch (e) {
      debugPrint('Error writing to log file: $e');
    }
  }

  void info(String message) {
    _logger.i(message);
    _writeToFile('INFO: $message');
  }

  void warning(String message) {
    _logger.w(message);
    _writeToFile('WARNING: $message');
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _writeToFile(
        'ERROR: $message${error != null ? '\nError: $error' : ''}${stackTrace != null ? '\nStack trace: $stackTrace' : ''}');
  }

  void debug(String message) {
    _logger.d(message);
    _writeToFile('DEBUG: $message');
  }

  Future<String> getLogs() async {
    try {
      if (await _logFile.exists()) {
        final logs = await _logFile.readAsString();
        debugPrint('Current logs:\n$logs');
        return logs;
      }
      return 'No logs available';
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }

  Future<void> clearLogs() async {
    try {
      if (await _logFile.exists()) {
        await _logFile.writeAsString('');
        debugPrint('Logs cleared');
      }
    } catch (e) {
      debugPrint('Error clearing logs: $e');
    }
  }

  // Get log file path
  Future<String> getLogFilePath() async {
    try {
      return _logFile.path;
    } catch (e) {
      return 'Error getting log file path: $e';
    }
  }
}
