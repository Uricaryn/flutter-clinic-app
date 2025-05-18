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
import 'package:clinic_app/shared/widgets/auth_background.dart';

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
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Scaffold(
      body: AuthBackground(
        showMedicalIcons: false,
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.appointments,
                      style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
              // Search and Filter Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
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
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
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
                child: userDataAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Hata: $e')),
                  data: (userData) {
                    if (userData == null) {
                      return const Center(child: Text('Kullanıcı bulunamadı'));
                    }

                    try {
                      final clinicId = userData['clinicId'] as String?;
                      if (clinicId == null) {
                        return const Center(child: Text('Klinik bulunamadı'));
                      }

                      return StreamBuilder<QuerySnapshot>(
                        stream: ref
                            .read(firestoreServiceProvider)
                            .getClinicAppointmentsStream(clinicId),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            print('StreamBuilder Error: ${snapshot.error}');
                            return Center(
                                child: Text('Hata: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          try {
                            final appointments =
                                snapshot.data!.docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final dateTime =
                                  (data['dateTime'] as Timestamp).toDate();
                              final now = DateTime.now();
                              final today =
                                  DateTime(now.year, now.month, now.day);

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
                                  .contains(
                                      _searchController.text.toLowerCase());
                            }).toList();

                            if (appointments.isEmpty) {
                              return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                                      color: theme.colorScheme.primary
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                                      l10n.noAppointmentsFound,
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Yeni bir randevu ekleyerek başlayın',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
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
                                try {
                                  final doc = appointments[index];
                                  final data = doc.data();
                                  if (data == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final appointment =
                                      AppointmentModel.fromJson({
                                    ...data as Map<String, dynamic>,
                                    'id': doc.id,
                                  });

                          return AppointmentCard(
                            appointment: appointment,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/appointment/details',
                                        arguments: appointment,
                                      );
                                    },
                                    onEdit: () async {
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text('Randevuyu Düzenle'),
                                          content: const Text(
                                              'Randevuyu düzenlemek istediğinize emin misiniz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('İptal'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Düzenle'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (result == true) {
                                        if (!mounted) return;
                                        Navigator.pushNamed(
                                          context,
                                          '/appointment/edit',
                                          arguments: appointment,
                                        );
                                      }
                                    },
                                    onDelete: () async {
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Randevuyu Sil'),
                                          content: const Text(
                                              'Bu randevuyu silmek istediğinize emin misiniz?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('İptal'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    theme.colorScheme.error,
                                              ),
                                              child: const Text('Sil'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (result == true) {
                                        try {
                                          await ref
                                              .read(firestoreServiceProvider)
                                              .deleteAppointment(
                                                  appointment.id);
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Randevu başarıyla silindi'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('Hata: $e'),
                                              backgroundColor:
                                                  theme.colorScheme.error,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                } catch (e) {
                                  print('Error building appointment card: $e');
                                  return const SizedBox.shrink();
                                }
                              },
                            );
                          } catch (e) {
                            print('Error processing appointments: $e');
                            return Center(
                                child: Text(
                                    'Randevular işlenirken hata oluştu: $e'));
                          }
                        },
                      );
                    } catch (e) {
                      print('Error getting clinicId: $e');
                      return Center(
                          child:
                              Text('Klinik bilgisi alınırken hata oluştu: $e'));
                    }
                        },
                      ),
          ),
        ],
          ),
        ),
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
        checkmarkColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
      ),
    );
  }
}
