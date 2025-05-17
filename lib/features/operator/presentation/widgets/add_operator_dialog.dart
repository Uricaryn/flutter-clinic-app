import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/features/operator/domain/models/operator_model.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddOperatorDialog extends ConsumerStatefulWidget {
  final String clinicId;
  final OperatorModel? operator;

  const AddOperatorDialog({
    super.key,
    required this.clinicId,
    this.operator,
  });

  @override
  ConsumerState<AddOperatorDialog> createState() => _AddOperatorDialogState();
}

class _AddOperatorDialogState extends ConsumerState<AddOperatorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRole = 'Sekreter';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.operator != null) {
      _nameController.text = widget.operator!.name;
      _emailController.text = widget.operator!.email;
      _phoneController.text = widget.operator!.phone;
      _selectedRole = widget.operator!.role;
      _isActive = widget.operator!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveOperator() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final now = DateTime.now();

      if (widget.operator != null) {
        // Düzenleme işlemi
        final operator = OperatorModel(
          id: widget.operator!.id,
          clinicId: widget.clinicId,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          role: _selectedRole,
          isActive: _isActive,
          createdAt: widget.operator!.createdAt,
          updatedAt: now,
          isEmailVerified: widget.operator!.isEmailVerified,
          temporaryPassword: widget.operator!.temporaryPassword,
        );

        // Koleksiyonu role göre belirle
        final collection = _selectedRole == 'Doktor' ? 'users' : 'operators';
        await firestore.collection(collection).doc(operator.id).update({
          ...operator.toJson(),
          'name': _nameController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Operatör başarıyla güncellendi')),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Yeni operatör ekleme işlemi
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _generateTemporaryPassword(),
        );

        if (_selectedRole == 'Sekreter') {
          await userCredential.user?.sendEmailVerification();
        }

        final operator = OperatorModel(
          id: userCredential.user!.uid,
          clinicId: widget.clinicId,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          role: _selectedRole,
          isActive: _isActive,
          createdAt: now,
          updatedAt: now,
          isEmailVerified: _selectedRole == 'Doktor',
          temporaryPassword: _selectedRole == 'Sekreter',
        );

        // Kullanıcı bilgilerini users koleksiyonuna ekle
        await firestore.collection('users').doc(operator.id).set({
          ...operator.toJson(),
          'name': _nameController.text,
        });

        // Sekreter ise operators koleksiyonuna da ekle
        if (_selectedRole == 'Sekreter') {
          await firestore.collection('operators').doc(operator.id).set({
            ...operator.toJson(),
            'name': _nameController.text,
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedRole == 'Sekreter'
                    ? 'Operatör başarıyla eklendi. E-posta adresine doğrulama maili gönderildi.'
                    : 'Doktor başarıyla eklendi.',
              ),
            ),
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
    // Geçici şifre oluştur (8 karakter, en az 1 büyük harf, 1 küçük harf, 1 rakam)
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
    final isEditing = widget.operator != null;

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
                isEditing ? 'Operatör Düzenle' : 'Yeni Operatör Ekle',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  hintText: 'Operatör adını girin',
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
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  hintText: 'Operatör rolünü seçin',
                ),
                items: const [
                  DropdownMenuItem(value: 'Sekreter', child: Text('Sekreter')),
                  DropdownMenuItem(value: 'Doktor', child: Text('Doktor')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aktif'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              if (!isEditing) ...[
                const SizedBox(height: 16),
                const Text(
                  'Not: Operatör eklendiğinde e-posta adresine doğrulama maili gönderilecek ve kendi şifresini belirleyebilecek.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
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
                    onPressed: _isLoading ? null : _saveOperator,
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
