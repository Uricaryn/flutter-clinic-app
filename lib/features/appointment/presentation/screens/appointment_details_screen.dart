import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/features/appointment/domain/models/appointment_model.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentDetailsScreen extends ConsumerWidget {
  final AppointmentModel appointment;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final proceduresAsync = ref.watch(proceduresStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Detayları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/appointment/edit',
                arguments: appointment,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hasta Bilgileri
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
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Hasta Adı',
                      value: appointment.patientName,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'Telefon',
                      value: appointment.patientPhone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Randevu Detayları
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
                    _buildInfoRow(
                      icon: Icons.calendar_month,
                      label: 'Tarih',
                      value:
                          DateFormat('dd/MM/yyyy').format(appointment.dateTime),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: 'Saat',
                      value: DateFormat('HH:mm').format(appointment.dateTime),
                    ),
                    const SizedBox(height: 8),
                    proceduresAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Hata: $e'),
                      data: (procedures) {
                        final procedure = procedures.docs.firstWhere(
                          (doc) => doc.id == appointment.procedureId,
                          orElse: () => throw Exception('İşlem bulunamadı'),
                        );
                        return _buildInfoRow(
                          icon: Icons.medical_services,
                          label: 'İşlem',
                          value: procedure['name'] as String,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('doctors')
                          .doc(appointment.operatorId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Hata: ${snapshot.error}');
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return _buildInfoRow(
                            icon: Icons.person_outline,
                            label: 'Doktor',
                            value: 'Doktor bilgisi bulunamadı',
                          );
                        }

                        final data = snapshot.data!.data();
                        if (data == null) {
                          return _buildInfoRow(
                            icon: Icons.person_outline,
                            label: 'Doktor',
                            value: 'Doktor bilgisi boş',
                          );
                        }

                        final doctorData = data as Map<String, dynamic>;
                        return _buildInfoRow(
                          icon: Icons.person_outline,
                          label: 'Doktor',
                          value:
                              doctorData['name'] as String? ?? 'İsimsiz Doktor',
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.info_outline,
                      label: 'Durum',
                      value: _getStatusText(appointment.status),
                    ),
                    if (appointment.notes != null &&
                        appointment.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.note,
                        label: 'Notlar',
                        value: appointment.notes!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Ödeme Bilgileri
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payment,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ödeme Bilgileri',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (appointment.paymentAmount != null) ...[
                      _buildInfoRow(
                        icon: Icons.attach_money,
                        label: 'Ödeme Tutarı',
                        value:
                            '₺${appointment.paymentAmount!.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Ödeme Tarihi',
                        value: DateFormat('dd/MM/yyyy HH:mm')
                            .format(appointment.paymentDate!),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.payment,
                        label: 'Ödeme Yöntemi',
                        value: appointment.paymentMethod ?? 'Belirtilmemiş',
                      ),
                      if (appointment.paymentNote != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.note,
                          label: 'Ödeme Notu',
                          value: appointment.paymentNote!,
                        ),
                      ],
                    ] else ...[
                      const Center(
                        child: Text(
                          'Henüz ödeme yapılmamış',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (appointment.status == 'completed' &&
                        appointment.paymentAmount == null)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/appointment/edit',
                              arguments: appointment,
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ödeme Ekle'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Planlandı';
      case 'confirmed':
        return 'Onaylandı';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      case 'noShow':
        return 'Gelmedi';
      default:
        return status;
    }
  }
}
