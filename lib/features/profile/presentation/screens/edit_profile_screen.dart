import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/config/app_mode.dart';
import 'package:clinic_app/core/providers/dual_auth_provider.dart';
import 'package:clinic_app/core/services/postgresql_auth_service.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/shared/widgets/custom_text_field.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _clinicPhoneController = TextEditingController();
  final _clinicEmailController = TextEditingController();
  final _clinicSpecializationController = TextEditingController();
  bool _isLoading = false;
  String? _phoneCountryCode = '+90'; // Varsayılan Türkiye
  String? _clinicPhoneCountryCode = '+90'; // Varsayılan Türkiye

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _clinicPhoneController.dispose();
    _clinicEmailController.dispose();
    _clinicSpecializationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = ref.read(unifiedAuthStateProvider);
      if (user == null) return;

      if (AppMode.isFirebase) {
        // Firebase mode
        await _loadFirebaseUserData(user);
      } else {
        // PostgreSQL mode
        await _loadPostgresqlUserData(user);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _loadFirebaseUserData(UnifiedUser user) async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userData.exists) {
      final data = userData.data()!;
      _fullNameController.text = data['fullName'] ?? '';
      _phoneCountryCode = data['phoneCountryCode'] ?? '+90';
      _phoneController.text = data['phoneNumber'] ?? '';

      // Load clinic data
      final clinicId = data['clinicId'];
      if (clinicId != null && clinicId is String && clinicId.isNotEmpty) {
        final clinicDoc = await FirebaseFirestore.instance
            .collection('clinics')
            .doc(clinicId)
            .get();
        final clinicData = clinicDoc.data();
        if (clinicData != null) {
          _clinicNameController.text = clinicData['name'] ?? '';
          _clinicAddressController.text = clinicData['address'] ?? '';
          _clinicPhoneCountryCode =
              clinicData['clinicPhoneCountryCode'] ?? '+90';
          _clinicPhoneController.text = clinicData['clinicPhoneNumber'] ?? '';
          _clinicEmailController.text = clinicData['email'] ?? '';
          _clinicSpecializationController.text =
              clinicData['specialization'] ?? '';
        }
      }
    }
  }

  Future<void> _loadPostgresqlUserData(UnifiedUser user) async {
    final postgresUser = user.postgresqlUser;
    if (postgresUser != null) {
      _fullNameController.text = postgresUser.fullName;
      _phoneController.text = postgresUser.phone ?? '';
      _phoneCountryCode = '+90'; // Default

      // Clinic data comes from backend - we don't store it locally
      // User can edit and it will be sent to backend
      _clinicNameController.clear();
      _clinicAddressController.clear();
      _clinicPhoneController.clear();
      _clinicEmailController.clear();
      _clinicSpecializationController.clear();
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(unifiedAuthStateProvider);
      if (user == null) throw Exception('User not found');

      if (AppMode.isFirebase) {
        await _updateFirebaseProfile(user);
      } else {
        await _updatePostgresqlProfile(user);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateFirebaseProfile(UnifiedUser user) async {
    // Klinik bilgilerini clinics koleksiyonunda güncelle veya oluştur
    final clinicsCollection = FirebaseFirestore.instance.collection('clinics');
    final clinicData = {
      'name': _clinicNameController.text.trim(),
      'address': _clinicAddressController.text.trim(),
      'clinicPhoneCountryCode': _clinicPhoneCountryCode ?? '+90',
      'clinicPhoneNumber': _clinicPhoneController.text.trim(),
      'email': _clinicEmailController.text.trim(),
      'specialization': _clinicSpecializationController.text.trim(),
      'ownerId': user.uid,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    DocumentReference? clinicRef;
    final existingClinic = await clinicsCollection
        .where('ownerId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (existingClinic.docs.isNotEmpty) {
      clinicRef = existingClinic.docs.first.reference;
      await clinicRef.update(clinicData);
    } else {
      clinicRef = await clinicsCollection.add(clinicData);
    }

    // Update user data
    await ref.read(firestoreServiceProvider).updateUserData(
      user.uid,
      {
        'fullName': _fullNameController.text.trim(),
        'phoneCountryCode': _phoneCountryCode ?? '+90',
        'phoneNumber': _phoneController.text.trim(),
        'clinicId': clinicRef.id,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _updatePostgresqlProfile(UnifiedUser user) async {
    final authService = PostgresqlAuthService();
    
    // Build phone number
    final fullPhone = '$_phoneCountryCode${_phoneController.text.trim()}';

    // Update profile
    await authService.updateProfile({
      'fullName': _fullNameController.text.trim(),
      'phone': fullPhone,
    });

    // Note: Clinic data update would need a separate endpoint
    // For now, we only update user profile
    // TODO: Add clinic update endpoint in backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _fullNameController,
                label: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              IntlPhoneField(
                controller: _phoneController,
                initialCountryCode: 'TR',
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                onChanged: (phone) {
                  setState(() {
                    _phoneCountryCode = '+${phone.countryCode}';
                  });
                },
                validator: (value) {
                  if (value == null || value.number.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              if (AppMode.isFirebase) ...[
                const SizedBox(height: 32),
                Text('Klinik Bilgileri',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _clinicNameController,
                  label: 'Klinik Adı',
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _clinicAddressController,
                  label: 'Klinik Adresi',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: 16),
                IntlPhoneField(
                  controller: _clinicPhoneController,
                  initialCountryCode: 'TR',
                  decoration: const InputDecoration(
                    labelText: 'Klinik Telefonu',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (phone) {
                    _clinicPhoneCountryCode = phone.countryCode;
                  },
                  validator: (value) {
                    if (value == null || value.number.isEmpty) {
                      return 'Lütfen klinik telefonunu girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _clinicEmailController,
                  label: 'Klinik E-posta',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _clinicSpecializationController,
                  label: 'Klinik Uzmanlık Alanı',
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                ),
              ],
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save Changes',
                onPressed: _isLoading ? null : _updateProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
