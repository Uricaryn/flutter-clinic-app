import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:clinic_app/core/scripts/test_data_creator.dart';
import 'package:clinic_app/core/services/logger_service.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Create test data
    final testDataCreator = TestDataCreator();
    await testDataCreator.createSuperAdmin();

    LoggerService().info('Test data creation completed successfully');
  } catch (e, stackTrace) {
    LoggerService().error('Failed to create test data', e, stackTrace);
  }
}
 