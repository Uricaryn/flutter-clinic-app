import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:clinic_app/core/enums/user_role.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ClinicManagerPanelScreen extends ConsumerWidget {
  const ClinicManagerPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Klinik bilgisini Firestore'dan çek
    final clinicsAsync = ref.watch(clinicListProvider);
    return clinicsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hata: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(clinicListProvider),
                child: const Text('Yeniden Dene'),
              ),
            ],
          ),
        ),
      ),
      data: (clinics) {
        if (clinics.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Klinik Yönetimi'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_hospital_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz bir klinik bulunmuyor.',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Profil sayfasından klinik bilgilerinizi ekleyebilirsiniz.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: const Text('Profile Git'),
                  ),
                ],
              ),
            ),
          );
        }

        final clinic = clinics.first;
        final clinicId = clinic.id;

        // Randevu ve operatör verilerini çek
        final appointmentsAsync =
            ref.watch(clinicAppointmentsStreamProvider(clinicId));
        final operatorsAsync = ref.watch(usersStreamProvider);

        return appointmentsAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
          data: (appointmentsSnapshot) {
            final allAppointments = appointmentsSnapshot.docs;
            final totalAppointments = allAppointments.length;
            final now = DateTime.now();

            // Randevuları tarihe göre sırala ve filtrele
            final sortedAppointments = allAppointments.toList()
              ..sort((a, b) {
                final dateA = (a['dateTime'] as Timestamp).toDate();
                final dateB = (b['dateTime'] as Timestamp).toDate();
                return dateB.compareTo(dateA); // En yeni randevular önce
              });

            final upcomingAppointments = sortedAppointments.where((doc) {
              final date = (doc['dateTime'] as Timestamp).toDate();
              return date.isAfter(now);
            }).length;

            return operatorsAsync.when(
              loading: () => const Scaffold(
                  body: Center(child: CircularProgressIndicator())),
              error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
              data: (usersSnapshot) {
                final operators = usersSnapshot.docs
                    .where((doc) =>
                        doc['role'] == UserRole.operator.value &&
                        doc['clinicId'] == clinicId)
                    .toList();
                final activeOperators = operators.length;

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Klinik Yönetimi'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.pushNamed(context, '/appointments');
                        },
                        tooltip: 'Randevular',
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clinic.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(clinic.address),
                                const SizedBox(height: 8),
                                Text(
                                    'Telefon: ${clinic.clinicPhoneCountryCode}${clinic.clinicPhoneNumber}'),
                                Text('E-posta: ${clinic.email}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatCard(
                          title: 'Toplam Randevu',
                          value: totalAppointments.toString(),
                          chart: _buildAppointmentsChart(sortedAppointments),
                        ),
                        const SizedBox(height: 16),
                        _StatCard(
                          title: 'Yaklaşan Randevu',
                          value: upcomingAppointments.toString(),
                          chart: _buildUpcomingAppointmentsChart(
                              sortedAppointments),
                        ),
                        const SizedBox(height: 16),
                        _StatCard(
                          title: 'Aktif Operatör',
                          value: activeOperators.toString(),
                          chart: _buildOperatorsChart(operators),
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
                                    const Icon(Icons.people, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Operatörler',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...operators.map((op) => ListTile(
                                      leading: const CircleAvatar(
                                        child: Icon(Icons.person),
                                      ),
                                      title: Text(op['fullName'] ?? ''),
                                      subtitle: Text(op['email'] ?? ''),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentsChart(List<QueryDocumentSnapshot> appointments) {
    final now = DateTime.now();
    final dailyAppointments = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return appointments.where((doc) {
        final appointmentDate = (doc['dateTime'] as Timestamp).toDate();
        return appointmentDate.year == date.year &&
            appointmentDate.month == date.month &&
            appointmentDate.day == date.day;
      }).length;
    });

    final total = dailyAppointments.reduce((a, b) => a + b);
    final today = dailyAppointments.last;
    final percentage = total > 0 ? (today / total * 100) : 0.0;

    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.blue.withOpacity(0.1),
              color: Colors.blue,
              strokeWidth: 8,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Bugün',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointmentsChart(
      List<QueryDocumentSnapshot> appointments) {
    final now = DateTime.now();
    final upcomingAppointments = appointments.where((doc) {
      final date = (doc['dateTime'] as Timestamp).toDate();
      return date.isAfter(now);
    }).toList();

    final total = appointments.length;
    final upcoming = upcomingAppointments.length;
    final percentage = total > 0 ? (upcoming / total * 100) : 0.0;

    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.green.withOpacity(0.1),
              color: Colors.green,
              strokeWidth: 8,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Yaklaşan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperatorsChart(List<QueryDocumentSnapshot> operators) {
    final totalOperators = operators.length;
    final activeOperators = operators.where((op) {
      final appointments = op['appointments'] as List<dynamic>? ?? [];
      return appointments.isNotEmpty;
    }).length;

    final percentage =
        totalOperators > 0 ? (activeOperators / totalOperators * 100) : 0.0;

    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.orange.withOpacity(0.1),
              color: Colors.orange,
              strokeWidth: 8,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Aktif',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget chart;

  const _StatCard({
    required this.title,
    required this.value,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              height: 100,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
