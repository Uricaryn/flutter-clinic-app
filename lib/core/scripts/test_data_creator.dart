import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/core/services/logger_service.dart';

class TestDataCreator {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _logger = LoggerService();

  Future<void> createSuperAdmin() async {
    try {
      _logger.info('Creating super admin account...');

      // Önce kullanıcıyı oluşturmayı dene
      User? currentUser;
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: 'admin@clinic.com',
          password: 'admin123',
        );
        currentUser = userCredential.user;
        _logger.info('Super admin user created: ${currentUser?.uid}');
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          // Kullanıcı zaten varsa giriş yapmayı dene
          try {
            final userCredential = await _auth.signInWithEmailAndPassword(
              email: 'admin@clinic.com',
              password: 'admin123',
            );
            currentUser = userCredential.user;
            _logger.info('Super admin user signed in: ${currentUser?.uid}');
          } catch (signInError) {
            _logger.error('Failed to sign in as super admin', signInError,
                StackTrace.current);
            rethrow;
          }
        } else {
          _logger.error(
              'Failed to create super admin user', e, StackTrace.current);
          rethrow;
        }
      }

      // Kullanıcı giriş yapmış durumda değilse hata fırlat
      if (currentUser == null) {
        throw 'Failed to create or sign in as super admin';
      }

      // Firestore'da kullanıcı dokümanını oluştur
      await _firestore.collection('users').doc(currentUser.uid).set({
        'email': 'admin@clinic.com',
        'role': 'super_admin',
        'name': 'Super Admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _logger.info('Super admin document created in Firestore');

      // Test departmanlarını oluştur
      await _createTestDepartments();

      // Test doktorlarını oluştur
      await _createTestDoctors();

      // Test hastalarını oluştur
      await _createTestPatients();

      _logger.info('Test data created successfully');
    } catch (e, stackTrace) {
      _logger.error('Error creating test data', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _createTestDepartments() async {
    try {
      _logger.info('Creating test departments...');

      // First, check if departments collection exists
      try {
        await _firestore.collection('departments').limit(1).get();
        _logger.info('Departments collection exists');
      } catch (e) {
        _logger.error(
            'Error checking departments collection', e, StackTrace.current);
        throw 'Failed to access departments collection: $e';
      }

      final departments = [
        {
          'name': 'Cardiology',
          'description': 'Heart and cardiovascular system care',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Neurology',
          'description': 'Brain and nervous system care',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Pediatrics',
          'description': 'Children\'s health care',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var dept in departments) {
        try {
          final docRef = await _firestore.collection('departments').add(dept);
          _logger.info('Department created: ${docRef.id} - ${dept['name']}');
        } catch (e) {
          _logger.error('Error creating department: ${dept['name']}', e,
              StackTrace.current);
          throw 'Failed to create department ${dept['name']}: $e';
        }
      }
      _logger.info('All test departments created successfully');
    } catch (e) {
      _logger.error('Error in _createTestDepartments', e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> _createTestDoctors() async {
    try {
      _logger.info('Creating test doctors...');

      // First, check if doctors collection exists
      try {
        await _firestore.collection('doctors').limit(1).get();
        _logger.info('Doctors collection exists');
      } catch (e) {
        _logger.error(
            'Error checking doctors collection', e, StackTrace.current);
        throw 'Failed to access doctors collection: $e';
      }

      final doctors = [
        {
          'fullName': 'Dr. John Smith',
          'email': 'john.smith@clinic.com',
          'department': 'Cardiology',
          'specialization': 'Cardiologist',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'fullName': 'Dr. Sarah Johnson',
          'email': 'sarah.johnson@clinic.com',
          'department': 'Neurology',
          'specialization': 'Neurologist',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'fullName': 'Dr. Michael Brown',
          'email': 'michael.brown@clinic.com',
          'department': 'Pediatrics',
          'specialization': 'Pediatrician',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var doctor in doctors) {
        try {
          final docRef = await _firestore.collection('doctors').add(doctor);
          _logger.info('Doctor created: ${docRef.id} - ${doctor['fullName']}');
        } catch (e) {
          _logger.error('Error creating doctor: ${doctor['fullName']}', e,
              StackTrace.current);
          throw 'Failed to create doctor ${doctor['fullName']}: $e';
        }
      }
      _logger.info('All test doctors created successfully');
    } catch (e) {
      _logger.error('Error in _createTestDoctors', e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> _createTestPatients() async {
    try {
      _logger.info('Creating test patients...');

      // First, check if patients collection exists
      try {
        await _firestore.collection('patients').limit(1).get();
        _logger.info('Patients collection exists');
      } catch (e) {
        _logger.error(
            'Error checking patients collection', e, StackTrace.current);
        throw 'Failed to access patients collection: $e';
      }

      final patients = [
        {
          'fullName': 'Alice Wilson',
          'email': 'alice.wilson@example.com',
          'phone': '+1234567890',
          'dateOfBirth': DateTime(1990, 5, 15),
          'gender': 'Female',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'fullName': 'Bob Thompson',
          'email': 'bob.thompson@example.com',
          'phone': '+1987654321',
          'dateOfBirth': DateTime(1985, 8, 22),
          'gender': 'Male',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'fullName': 'Carol Martinez',
          'email': 'carol.martinez@example.com',
          'phone': '+1122334455',
          'dateOfBirth': DateTime(1995, 3, 10),
          'gender': 'Female',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var patient in patients) {
        try {
          final docRef = await _firestore.collection('patients').add(patient);
          _logger
              .info('Patient created: ${docRef.id} - ${patient['fullName']}');
        } catch (e) {
          _logger.error('Error creating patient: ${patient['fullName']}', e,
              StackTrace.current);
          throw 'Failed to create patient ${patient['fullName']}: $e';
        }
      }
      _logger.info('All test patients created successfully');
    } catch (e) {
      _logger.error('Error in _createTestPatients', e, StackTrace.current);
      rethrow;
    }
  }
}
