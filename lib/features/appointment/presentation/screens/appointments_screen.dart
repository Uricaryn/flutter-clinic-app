import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/appointment/domain/models/appointment_model.dart';
import 'package:clinic_app/features/appointment/presentation/widgets/appointment_card.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final clinicId = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appointments),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/appointment/new');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchAppointments,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(l10n.all, 'all'),
                      _buildFilterChip(l10n.today, 'today'),
                      _buildFilterChip(l10n.upcoming, 'upcoming'),
                      _buildFilterChip(l10n.past, 'past'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Appointments List
          Expanded(
            child: clinicId == null
                ? const Center(child: Text('Klinik bulunamadı'))
                : StreamBuilder<QuerySnapshot>(
                    stream: ref
                        .read(firestoreServiceProvider)
                        .getClinicAppointmentsStream(clinicId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Hata: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final appointments = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final dateTime =
                            (data['dateTime'] as Timestamp).toDate();
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);

                        switch (_selectedFilter) {
                          case 'today':
                            return dateTime.year == today.year &&
                                dateTime.month == today.month &&
                                dateTime.day == today.day;
                          case 'upcoming':
                            return dateTime.isAfter(now);
                          case 'past':
                            return dateTime.isBefore(now);
                          default:
                            return true;
                        }
                      }).where((doc) {
                        if (_searchController.text.isEmpty) return true;
                        final data = doc.data() as Map<String, dynamic>;
                        return (data['patientName'] as String)
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase());
                      }).toList();

                      if (appointments.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color:
                                    theme.colorScheme.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noAppointmentsFound,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Yeni bir randevu ekleyerek başlayın',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 24),
                              CustomButton(
                                text: 'Yeni Randevu',
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/appointment/new');
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final doc = appointments[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final appointment = AppointmentModel.fromJson({
                            ...data,
                            'id': doc.id,
                          });

                          return AppointmentCard(
                            appointment: appointment,
                            onTap: () {
                              // TODO: Navigate to appointment details
                            },
                            onEdit: () {
                              // TODO: Show edit dialog
                            },
                            onDelete: () {
                              // TODO: Show delete confirmation
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/appointment/new');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
      ),
    );
  }
}
