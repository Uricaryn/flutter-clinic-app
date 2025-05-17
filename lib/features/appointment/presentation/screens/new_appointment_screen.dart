import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:clinic_app/core/enums/user_role.dart';
import 'package:clinic_app/features/patient/domain/models/patient_model.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

class NewAppointmentScreen extends ConsumerStatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  ConsumerState<NewAppointmentScreen> createState() =>
      _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends ConsumerState<NewAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedProcedureId;
  String? _selectedOperatorId;
  String? _selectedPatientId;
  bool _isLoading = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientPhoneController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveAppointment() async {
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
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen hasta seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not found');

      final userData =
          await ref.read(firestoreServiceProvider).getUserData(user.uid);
      final clinicId = userData?['clinicId'] as String?;
      if (clinicId == null) throw Exception('Clinic not found');

      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await ref.read(firestoreServiceProvider).addAppointment(
            clinicId: clinicId,
            patientId: _selectedPatientId!,
            patientName: _patientNameController.text.trim(),
            patientPhone: _patientPhoneController.text.trim(),
            procedureId: _selectedProcedureId!,
            operatorId: _selectedOperatorId!,
            dateTime: dateTime,
            notes: _notesController.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Randevu başarıyla oluşturuldu'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final proceduresAsync = ref.watch(proceduresStreamProvider);
    final operatorsAsync = ref.watch(usersStreamProvider);
    final user = ref.watch(currentUserProvider);
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Randevu'),
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

                final clinicId = userData.get('clinicId') as String?;
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
                                StreamBuilder<QuerySnapshot>(
                                  stream: ref
                                      .read(firestoreServiceProvider)
                                      .getClinicPatientsStream(clinicId),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Hata: ${snapshot.error}');
                                    }

                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    final patients = snapshot.data!.docs
                                        .map((doc) {
                                          final data = doc.data()
                                              as Map<String, dynamic>;
                                          return PatientModel.fromJson(
                                              {...data, 'id': doc.id});
                                        })
                                        .where((patient) =>
                                            _searchController.text.isEmpty ||
                                            patient.fullName
                                                .toLowerCase()
                                                .contains(_searchController.text
                                                    .toLowerCase()) ||
                                            patient.phone
                                                .toLowerCase()
                                                .contains(_searchController.text
                                                    .toLowerCase()))
                                        .toList();

                                    if (patients.isEmpty) {
                                      return Column(
                                        children: [
                                          const Text('Hasta bulunamadı'),
                                          const SizedBox(height: 16),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/patient/new',
                                              );
                                            },
                                            icon: const Icon(Icons.add),
                                            label:
                                                const Text('Yeni Hasta Ekle'),
                                          ),
                                        ],
                                      );
                                    }

                                    return Column(
                                      children: [
                                        DropdownSearch<PatientModel>(
                                          items: patients,
                                          itemAsString: (p) =>
                                              '${p.fullName} - ${p.phone}',
                                          selectedItem: _selectedPatientId !=
                                                  null
                                              ? patients
                                                      .where((p) =>
                                                          p.id ==
                                                          _selectedPatientId)
                                                      .isNotEmpty
                                                  ? patients.firstWhere((p) =>
                                                      p.id ==
                                                      _selectedPatientId)
                                                  : null
                                              : null,
                                          compareFn: (a, b) => a.id == b.id,
                                          dropdownDecoratorProps:
                                              DropDownDecoratorProps(
                                            dropdownSearchDecoration:
                                                InputDecoration(
                                              labelText: 'Hasta Seçin',
                                              hintText: 'Hasta seçin',
                                              prefixIcon:
                                                  const Icon(Icons.person),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                          popupProps: PopupProps.menu(
                                            showSearchBox: true,
                                            searchFieldProps: TextFieldProps(
                                              decoration: InputDecoration(
                                                hintText:
                                                    'İsim veya telefon ile arayın',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                            itemBuilder: (context, patient,
                                                    isSelected) =>
                                                ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: theme
                                                    .colorScheme.primary
                                                    .withOpacity(0.1),
                                                child: Icon(Icons.person,
                                                    color: theme
                                                        .colorScheme.primary),
                                              ),
                                              title: Text(patient.fullName),
                                              subtitle: Text(patient.phone),
                                            ),
                                            showSelectedItems: true,
                                            menuProps: const MenuProps(
                                              backgroundColor: Colors.white,
                                              elevation: 2,
                                            ),
                                          ),
                                          onChanged: (patient) {
                                            if (patient != null) {
                                              setState(() {
                                                _selectedPatientId = patient.id;
                                                _patientNameController.text =
                                                    patient.fullName;
                                                _patientPhoneController.text =
                                                    patient.phone;
                                              });

                                              // Hasta notlarını göster
                                              if (patient.notes.isNotEmpty) {
                                                final notesController =
                                                    TextEditingController(
                                                        text: patient.notes);
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              24),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: theme
                                                                      .colorScheme
                                                                      .primary
                                                                      .withOpacity(
                                                                          0.1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .note_alt_outlined,
                                                                  color: theme
                                                                      .colorScheme
                                                                      .primary,
                                                                  size: 24,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 16),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      patient
                                                                          .fullName,
                                                                      style: theme
                                                                          .textTheme
                                                                          .titleLarge
                                                                          ?.copyWith(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            4),
                                                                    Text(
                                                                      'Hasta Notları',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodyMedium
                                                                          ?.copyWith(
                                                                        color: Colors
                                                                            .grey[600],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 24),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .grey[50],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .grey[200]!,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: TextField(
                                                              controller:
                                                                  notesController,
                                                              maxLines: 5,
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                hintText:
                                                                    'Notları düzenleyin...',
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 24),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child:
                                                                    const Text(
                                                                        'İptal'),
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  try {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'patients')
                                                                        .doc(patient
                                                                            .id)
                                                                        .update({
                                                                      'notes':
                                                                          notesController
                                                                              .text,
                                                                      'updatedAt':
                                                                          FieldValue
                                                                              .serverTimestamp(),
                                                                    });
                                                                    if (context
                                                                        .mounted) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        const SnackBar(
                                                                          content:
                                                                              Text('Notlar güncellendi'),
                                                                          backgroundColor:
                                                                              Colors.green,
                                                                        ),
                                                                      );
                                                                    }
                                                                  } catch (e) {
                                                                    if (context
                                                                        .mounted) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text('Hata: $e'),
                                                                          backgroundColor:
                                                                              Colors.red,
                                                                        ),
                                                                      );
                                                                    }
                                                                  }
                                                                },
                                                                child: const Text(
                                                                    'Kaydet'),
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
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/patient/new',
                                                  );
                                                },
                                                icon: const Icon(Icons.add),
                                                label: const Text(
                                                    'Yeni Hasta Ekle'),
                                              ),
                                            ),
                                            if (_selectedPatientId != null) ...[
                                              const SizedBox(width: 8),
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/patient/edit',
                                                    arguments:
                                                        _selectedPatientId,
                                                  );
                                                },
                                                icon: const Icon(Icons.edit),
                                                label: const Text(
                                                    'Hastayı Düzenle'),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    );
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
                                            : _selectedTime!.format(context)),
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveAppointment,
                            icon: const Icon(Icons.save),
                            label: const Text('Randevu Oluştur'),
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
}
