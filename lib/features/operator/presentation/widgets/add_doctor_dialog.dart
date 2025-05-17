import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/features/operator/domain/models/operator_model.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddDoctorDialog extends ConsumerStatefulWidget {
  final String clinicId;
  final OperatorModel? doctor;

  const AddDoctorDialog({
    super.key,
    required this.clinicId,
    this.doctor,
  });

  @override
  ConsumerState<AddDoctorDialog> createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends ConsumerState<AddDoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _nameController.text = widget.doctor!.name;
      _emailController.text = widget.doctor!.email;
      _phoneController.text = widget.doctor!.phone;
      _isActive = widget.doctor!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final now = DateTime.now();

      if (widget.doctor != null) {
        // Düzenleme işlemi
        final doctor = OperatorModel(
          id: widget.doctor!.id,
          clinicId: widget.clinicId,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          role: 'Doktor',
          isActive: _isActive,
          createdAt: widget.doctor!.createdAt,
          updatedAt: now,
          isEmailVerified: true,
          temporaryPassword: false,
        );

        await firestore.collection('operators').doc(doctor.id).update({
          ...doctor.toJson(),
          'name': _nameController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doktor başarıyla güncellendi')),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Yeni doktor ekleme işlemi
        final doctor = OperatorModel(
          id: FirebaseFirestore.instance.collection('doctors').doc().id,
          clinicId: widget.clinicId,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          role: 'Doktor',
          isActive: _isActive,
          createdAt: now,
          updatedAt: now,
          isEmailVerified: true,
          temporaryPassword: false,
        );

        // Doktor bilgilerini doctors koleksiyonuna ekle
        await firestore.collection('doctors').doc(doctor.id).set({
          ...doctor.toJson(),
          'name': _nameController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doktor başarıyla eklendi')),
          );
          Navigator.of(context).pop();
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Bu e-posta adresi zaten kullanımda.';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta adresi.';
          break;
        case 'weak-password':
          message = 'Şifre çok zayıf.';
          break;
        default:
          message = 'Bir hata oluştu: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _generateTemporaryPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final password = List.generate(8, (index) {
      final charIndex = int.parse(random[index % random.length]) % chars.length;
      return chars[charIndex];
    }).join();
    return password;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEditing = widget.doctor != null;

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Doktor Düzenle' : 'Yeni Doktor Ekle',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  hintText: 'Doktor adını girin',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ad soyad girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  hintText: 'E-posta adresini girin',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-posta girin';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  hintText: 'Telefon numarasını girin',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen telefon numarası girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aktif'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveDoctor,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(isEditing ? 'Kaydet' : 'Ekle'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
