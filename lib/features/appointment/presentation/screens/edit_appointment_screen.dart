import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:clinic_app/features/appointment/domain/models/appointment_model.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class EditAppointmentScreen extends ConsumerStatefulWidget {
  final AppointmentModel appointment;

  const EditAppointmentScreen({
    super.key,
    required this.appointment,
  });

  @override
  ConsumerState<EditAppointmentScreen> createState() =>
      _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends ConsumerState<EditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentAmountController = TextEditingController();
  final _paymentNoteController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedProcedureId;
  String? _selectedOperatorId;
  String? _selectedStatus;
  String? _selectedPaymentMethod;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _patientNameController.text = widget.appointment.patientName;
    _patientPhoneController.text = widget.appointment.patientPhone;
    _notesController.text = widget.appointment.notes ?? '';
    _paymentAmountController.text =
        widget.appointment.paymentAmount?.toString() ?? '';
    _paymentNoteController.text = widget.appointment.paymentNote ?? '';
    _selectedDate = widget.appointment.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.dateTime);
    _selectedProcedureId = widget.appointment.procedureId;
    _selectedOperatorId = widget.appointment.operatorId;
    _selectedStatus = widget.appointment.status;
    _selectedPaymentMethod = widget.appointment.paymentMethod;
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientPhoneController.dispose();
    _notesController.dispose();
    _paymentAmountController.dispose();
    _paymentNoteController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    final initialTime = _selectedTime != null
        ? DateTime(
            now.year,
            now.month,
            now.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          )
        : now;

    picker.DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      showSecondsColumn: false,
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() {
          _selectedTime = TimeOfDay(hour: date.hour, minute: date.minute);
        });
      },
      currentTime: initialTime,
      locale: picker.LocaleType.tr,
      theme: picker.DatePickerTheme(
        backgroundColor: Theme.of(context).colorScheme.surface,
        itemStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        doneStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
        ),
        cancelStyle: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final proceduresAsync = ref.watch(proceduresStreamProvider);
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevuyu Düzenle'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
              data: (userData) {
                if (userData == null) {
                  return const Center(child: Text('Kullanıcı bulunamadı'));
                }

                final clinicId = userData['clinicId'] as String?;
                if (clinicId == null) {
                  return const Center(child: Text('Klinik bulunamadı'));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Hasta Bilgileri',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _patientNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Hasta Adı',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen hasta adını girin';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _patientPhoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Telefon',
                                    prefixIcon: const Icon(Icons.phone),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen telefon numarasını girin';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Randevu Detayları',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _selectDate(context),
                                        icon: const Icon(Icons.calendar_today),
                                        label: Text(_selectedDate == null
                                            ? 'Tarih Seçin'
                                            : DateFormat('dd/MM/yyyy')
                                                .format(_selectedDate!)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _selectTime(context),
                                        icon: const Icon(Icons.access_time),
                                        label: Text(_selectedTime == null
                                            ? 'Saat Seçin'
                                            : _formatTimeOfDay(_selectedTime!)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                proceduresAsync.when(
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (e, _) => Text('Hata: $e'),
                                  data: (procedures) {
                                    return DropdownButtonFormField<String>(
                                      value: _selectedProcedureId,
                                      decoration: InputDecoration(
                                        labelText: 'İşlem',
                                        prefixIcon:
                                            const Icon(Icons.medical_services),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      items: procedures.docs.map((doc) {
                                        return DropdownMenuItem<String>(
                                          value: doc.id,
                                          child: Text(doc['name'] as String),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedProcedureId = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Lütfen işlem seçin';
                                        }
                                        return null;
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('doctors')
                                      .where('clinicId', isEqualTo: clinicId)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Hata: ${snapshot.error}');
                                    }

                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    final doctors = snapshot.data!.docs;
                                    if (doctors.isEmpty) {
                                      return const Center(
                                        child: Text('Henüz doktor bulunmuyor'),
                                      );
                                    }

                                    return DropdownSearch<String>(
                                      popupProps: const PopupProps.menu(
                                        showSearchBox: true,
                                        searchFieldProps: TextFieldProps(
                                          decoration: InputDecoration(
                                            labelText: 'Doktor Ara',
                                            hintText: 'Doktor adı ile arayın',
                                          ),
                                        ),
                                      ),
                                      items: doctors.map((doc) {
                                        final data =
                                            doc.data() as Map<String, dynamic>;
                                        return data['name'] as String;
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          final selectedDoctor =
                                              doctors.firstWhere(
                                            (doc) =>
                                                (doc.data() as Map<String,
                                                    dynamic>)['name'] ==
                                                value,
                                          );
                                          setState(() {
                                            _selectedOperatorId =
                                                selectedDoctor.id;
                                          });
                                        }
                                      },
                                      selectedItem: _selectedOperatorId != null
                                          ? doctors
                                                  .where((doc) =>
                                                      doc.id ==
                                                      _selectedOperatorId)
                                                  .isNotEmpty
                                              ? (doctors
                                                      .firstWhere((doc) =>
                                                          doc.id ==
                                                          _selectedOperatorId)
                                                      .data()
                                                  as Map<String,
                                                      dynamic>)['name'] as String
                                              : null
                                          : null,
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: 'Doktor Seçin',
                                          hintText: 'Doktor seçin',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  decoration: InputDecoration(
                                    labelText: 'Durum',
                                    prefixIcon: const Icon(Icons.info),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'scheduled',
                                      child: const Text('Planlandı'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'confirmed',
                                      child: const Text('Onaylandı'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'completed',
                                      child: const Text('Tamamlandı'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'cancelled',
                                      child: const Text('İptal Edildi'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'noShow',
                                      child: const Text('Gelmedi'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStatus = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _notesController,
                                  decoration: InputDecoration(
                                    labelText: 'Notlar',
                                    prefixIcon: const Icon(Icons.note),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Ödeme Bilgileri',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _paymentAmountController,
                          decoration: const InputDecoration(
                            labelText: 'Ödeme Tutarı',
                            prefixText: '₺',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Geçerli bir tutar giriniz';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedPaymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Ödeme Yöntemi',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text('Nakit'),
                            ),
                            DropdownMenuItem(
                              value: 'credit_card',
                              child: Text('Kredi Kartı'),
                            ),
                            DropdownMenuItem(
                              value: 'bank_transfer',
                              child: Text('Banka Transferi'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _paymentNoteController,
                          decoration: const InputDecoration(
                            labelText: 'Ödeme Notu',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _updateAppointment,
                            icon: const Icon(Icons.save),
                            label: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Değişiklikleri Kaydet'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _updateAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tarih ve saat seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedProcedureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen işlem seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedOperatorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen doktor seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      double? paymentAmount;
      if (_paymentAmountController.text.isNotEmpty) {
        paymentAmount = double.parse(_paymentAmountController.text);
      }

      await ref.read(firestoreServiceProvider).updateAppointment(
            appointmentId: widget.appointment.id,
            patientId: widget.appointment.patientId,
            patientName: _patientNameController.text.trim(),
            patientPhone: _patientPhoneController.text.trim(),
            procedureId: _selectedProcedureId!,
            operatorId: _selectedOperatorId!,
            dateTime: dateTime,
            notes: _notesController.text.trim(),
            status: _selectedStatus,
            paymentAmount: paymentAmount,
            paymentMethod: _selectedPaymentMethod,
            paymentNote: _paymentNoteController.text,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Randevu başarıyla güncellendi'),
          backgroundColor: Colors.green,
        ),
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
}
