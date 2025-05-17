import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewAppointmentScreen extends StatefulWidget {
  final String clinicId;

  const NewAppointmentScreen({
    super.key,
    required this.clinicId,
  });

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  List<QueryDocumentSnapshot> _doctors = [];
  QueryDocumentSnapshot? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctorsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('clinicId', isEqualTo: widget.clinicId)
          .where('role', isEqualTo: 'Doktor')
          .where('isActive', isEqualTo: true)
          .get();

      setState(() {
        _doctors = doctorsSnapshot.docs;
        if (_doctors.isNotEmpty) {
          _selectedDoctor = _doctors.first;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doktorlar yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Randevu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Doktor seçimi
          DropdownButtonFormField<QueryDocumentSnapshot>(
            value: _selectedDoctor,
            decoration: const InputDecoration(
              labelText: 'Doktor',
              border: OutlineInputBorder(),
            ),
            items: _doctors.map((doctor) {
              return DropdownMenuItem(
                value: doctor,
                child: Text(doctor['name'] ?? ''),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedDoctor = value);
              }
            },
          ),
          // Diğer form alanları...
        ],
      ),
    );
  }
}
