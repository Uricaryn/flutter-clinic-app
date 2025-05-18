import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:clinic_app/core/enums/user_role.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:clinic_app/features/operator/domain/models/operator_model.dart';
import 'package:clinic_app/features/operator/presentation/widgets/add_operator_dialog.dart';
import 'package:clinic_app/features/operator/presentation/widgets/add_doctor_dialog.dart';
import 'package:rxdart/rxdart.dart';
import 'package:clinic_app/features/clinic/domain/models/expense_model.dart';
import 'package:clinic_app/features/clinic/presentation/widgets/add_expense_dialog.dart';

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

                return _ClinicManagerPanelContent(
                  clinicId: clinicId,
                  clinic: clinic,
                  appointments: sortedAppointments,
                  operators: operators,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ClinicManagerPanelContent extends ConsumerWidget {
  final String clinicId;
  final dynamic clinic;
  final List<QueryDocumentSnapshot> appointments;
  final List<QueryDocumentSnapshot> operators;

  const _ClinicManagerPanelContent({
    required this.clinicId,
    required this.clinic,
    required this.appointments,
    required this.operators,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clinicManagement),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 8,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_hospital,
                            size: 32,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                clinic.address,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.phone,
                            text:
                                '${clinic.clinicPhoneCountryCode}${clinic.clinicPhoneNumber}',
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.email,
                            text: clinic.email,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _StatCard(
              title: l10n.monthlyIncome,
              value:
                  '₺${_calculateMonthlyIncome(context, ref, appointments).toStringAsFixed(2)}',
              chart: _buildMonthlyIncomeChart(context, ref, appointments),
            ),
            const SizedBox(height: 16),
            _StatCard(
              title: l10n.stockValue,
              value:
                  '₺${_calculateStockValue(context, ref).toStringAsFixed(2)}',
              chart: _buildStockChart(context, ref),
            ),
            const SizedBox(height: 16),
            _StatCard(
              title: l10n.profitMargin,
              value:
                  '${_calculateProfitMargin(context, ref, appointments).toStringAsFixed(1)}%',
              chart: _buildProfitMarginChart(context, ref, appointments),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.money_off, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              l10n.expenses,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddExpenseDialog(
                                clinicId: clinicId,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addExpense),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<QueryDocumentSnapshot>>(
                      stream: FirebaseFirestore.instance
                          .collection('expenses')
                          .where('clinicId', isEqualTo: clinicId)
                          .orderBy('date', descending: true)
                          .snapshots()
                          .map((snapshot) => snapshot.docs),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Hata: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final expenses = snapshot.data!;
                        if (expenses.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.money_off_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.noExpensesFound,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            final data = expense.data() as Map<String, dynamic>;
                            final date = (data['date'] as Timestamp).toDate();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  child: Icon(
                                    Icons.money_off,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                title: Text(
                                  data['title'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['description'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (data['category'] == 'Fatura' &&
                                        data['invoiceNumber'] != null)
                                      Text(
                                        l10n.invoiceNumber(
                                            data['invoiceNumber']),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      '${date.day}/${date.month}/${date.year}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        '₺${(data['amount'] as num).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AddExpenseDialog(
                                            clinicId: clinicId,
                                            expense: ExpenseModel.fromJson({
                                              ...data,
                                              'id': expense.id,
                                            }),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(l10n.deleteExpense),
                                            content: Text(
                                              l10n.deleteExpenseConfirmation,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(l10n.cancel),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('expenses')
                                                        .doc(expense.id)
                                                        .delete();
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content:
                                                              Text('Hata: $e'),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Text(l10n.delete),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              l10n.operators,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddOperatorDialog(
                                clinicId: clinicId,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addOperator),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<QueryDocumentSnapshot>>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('clinicId', isEqualTo: clinicId)
                          .where('role', isEqualTo: 'Sekreter')
                          .snapshots()
                          .map((snapshot) => snapshot.docs),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Hata: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final operators = snapshot.data!;
                        if (operators.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.noOperatorsFound,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: operators.length,
                          itemBuilder: (context, index) {
                            final op = operators[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: op['isActive'] == true
                                      ? Colors.green
                                      : Colors.grey,
                                  child: Text(
                                    (op['name'] as String?)?.isNotEmpty == true
                                        ? (op['name'] as String)[0]
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(op['name'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(op['email'] ?? ''),
                                    Text(op['role'] ?? ''),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AddOperatorDialog(
                                            clinicId: clinicId,
                                            operator: OperatorModel(
                                              id: op.id,
                                              clinicId: clinicId,
                                              name: op['name'] ?? '',
                                              email: op['email'] ?? '',
                                              phone: op['phone'] ?? '',
                                              role: op['role'] ?? '',
                                              isActive: op['isActive'] ?? true,
                                              createdAt:
                                                  (op['createdAt'] as Timestamp)
                                                      .toDate(),
                                              updatedAt: op['updatedAt'] != null
                                                  ? (op['updatedAt']
                                                          as Timestamp)
                                                      .toDate()
                                                  : null,
                                              isEmailVerified:
                                                  op['isEmailVerified'] ??
                                                      false,
                                              temporaryPassword:
                                                  op['temporaryPassword'] ??
                                                      false,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(l10n.deleteOperator),
                                            content: Text(
                                              l10n.deleteOperatorConfirmation,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(l10n.cancel),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(op.id)
                                                        .delete();
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content:
                                                              Text('Hata: $e'),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Text(l10n.delete),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medical_services, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              l10n.doctors,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddDoctorDialog(
                                clinicId: clinicId,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addDoctor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<QueryDocumentSnapshot>>(
                      stream: FirebaseFirestore.instance
                          .collection('doctors')
                          .where('clinicId', isEqualTo: clinicId)
                          .snapshots()
                          .map((snapshot) => snapshot.docs),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Hata: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final doctors = snapshot.data!;
                        if (doctors.isEmpty) {
                          return Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.medical_services_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.noDoctorsFound,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            final doc = doctors[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: doc['isActive'] == true
                                      ? Colors.green
                                      : Colors.grey,
                                  child: Text(
                                    (doc['name'] as String?)?.isNotEmpty == true
                                        ? (doc['name'] as String)[0]
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(doc['name'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(doc['email'] ?? ''),
                                    Text(doc['role'] ?? ''),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AddDoctorDialog(
                                            clinicId: clinicId,
                                            doctor: OperatorModel(
                                              id: doc.id,
                                              clinicId: clinicId,
                                              name: doc['name'] ?? '',
                                              email: doc['email'] ?? '',
                                              phone: doc['phone'] ?? '',
                                              role: doc['role'] ?? '',
                                              isActive: doc['isActive'] ?? true,
                                              createdAt: (doc['createdAt']
                                                      as Timestamp)
                                                  .toDate(),
                                              updatedAt:
                                                  doc['updatedAt'] != null
                                                      ? (doc['updatedAt']
                                                              as Timestamp)
                                                          .toDate()
                                                      : null,
                                              isEmailVerified:
                                                  doc['isEmailVerified'] ??
                                                      false,
                                              temporaryPassword:
                                                  doc['temporaryPassword'] ??
                                                      false,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(l10n.deleteDoctor),
                                            content: Text(
                                              l10n.deleteDoctorConfirmation,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(l10n.cancel),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('doctors')
                                                        .doc(doc.id)
                                                        .delete();
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content:
                                                              Text('Hata: $e'),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Text(l10n.delete),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  double _calculateMonthlyIncome(BuildContext context, WidgetRef ref,
      List<QueryDocumentSnapshot> procedures) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Tamamlanan randevuları getir
    final appointmentsAsync =
        ref.watch(clinicAppointmentsStreamProvider(clinicId));

    return appointmentsAsync.when(
      loading: () => 0.0,
      error: (_, __) => 0.0,
      data: (appointments) {
        // Sadece ödeme yapılmış randevuları filtrele
        final paidAppointments = appointments.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['paymentAmount'] != null;
        });

        // Bu ayki ödemeleri filtrele
        final monthlyPaidAppointments = paidAppointments.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final paymentDate = (data['paymentDate'] as Timestamp).toDate();
          return paymentDate.isAfter(firstDayOfMonth) &&
              paymentDate.isBefore(lastDayOfMonth);
        });

        // Toplam geliri hesapla
        return monthlyPaidAppointments.fold(0.0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          final paymentAmount = data['paymentAmount'] != null
              ? (data['paymentAmount'] as num).toDouble()
              : 0.0;
          return sum + paymentAmount;
        });
      },
    );
  }

  double _calculateStockValue(BuildContext context, WidgetRef ref) {
    final stockAsync = ref.watch(clinicStockStreamProvider(clinicId));
    return stockAsync.when(
      loading: () => 0.0,
      error: (_, __) => 0.0,
      data: (stock) {
        return stock.docs.fold(0.0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          final quantity = data['quantity'] != null
              ? (data['quantity'] as num).toDouble()
              : 0.0;
          final price =
              data['price'] != null ? (data['price'] as num).toDouble() : 0.0;
          return sum + (quantity * price);
        });
      },
    );
  }

  double _calculateMonthlyExpenses(WidgetRef ref) {
    final expensesAsync = ref.watch(clinicExpensesStreamProvider(clinicId));
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return expensesAsync.when(
      loading: () => 0.0,
      error: (_, __) => 0.0,
      data: (expenses) {
        if (expenses.isEmpty) return 0.0;

        // Bu ayki giderleri filtrele
        final monthlyExpenses = expenses.where((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final date = data['date'] as Timestamp?;
            if (date == null) return false;

            final expenseDate = date.toDate();
            return expenseDate.isAfter(firstDayOfMonth) &&
                expenseDate.isBefore(lastDayOfMonth);
          } catch (e) {
            print('Error processing expense: $e');
            return false;
          }
        });

        // Toplam giderleri hesapla
        return monthlyExpenses.fold(0.0, (sum, doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final amount = data['amount'] as num? ?? 0;
            return sum + amount.toDouble();
          } catch (e) {
            print('Error calculating expense amount: $e');
            return sum;
          }
        });
      },
    );
  }

  double _calculateDailyExpenses(WidgetRef ref, DateTime date) {
    final expensesAsync = ref.watch(clinicExpensesStreamProvider(clinicId));
    return expensesAsync.when(
      loading: () => 0.0,
      error: (_, __) => 0.0,
      data: (expenses) {
        if (expenses.isEmpty) return 0.0;

        // O günkü giderleri filtrele
        final dailyExpenses = expenses.where((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final expenseDate = data['date'] as Timestamp?;
            if (expenseDate == null) return false;

            final expenseDateTime = expenseDate.toDate();
            return expenseDateTime.year == date.year &&
                expenseDateTime.month == date.month &&
                expenseDateTime.day == date.day;
          } catch (e) {
            print('Error processing daily expense: $e');
            return false;
          }
        });

        // Toplam giderleri hesapla
        return dailyExpenses.fold(0.0, (sum, doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final amount = data['amount'] as num? ?? 0;
            return sum + amount.toDouble();
          } catch (e) {
            print('Error calculating daily expense amount: $e');
            return sum;
          }
        });
      },
    );
  }

  double _calculateProfitMargin(BuildContext context, WidgetRef ref,
      List<QueryDocumentSnapshot> appointments) {
    try {
      final monthlyIncome = _calculateMonthlyIncome(context, ref, appointments);
      final monthlyExpenses = _calculateMonthlyExpenses(ref);
      final monthlyStockCosts = _calculateMonthlyStockCosts(ref, appointments);

      // Toplam giderler
      final totalExpenses = monthlyExpenses + monthlyStockCosts;

      // Kar marjı hesapla
      if (monthlyIncome == 0) return 0.0;
      final profit = monthlyIncome - totalExpenses;
      return (profit / monthlyIncome) * 100;
    } catch (e) {
      print('Error calculating profit margin: $e');
      return 0.0;
    }
  }

  double _calculateMonthlyStockCosts(
      WidgetRef ref, List<QueryDocumentSnapshot> appointments) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Bu ayki ödeme yapılmış randevuları filtrele
    final monthlyAppointments = appointments.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final paymentDate = data['paymentDate'] as Timestamp?;
      if (paymentDate == null) return false;

      final date = paymentDate.toDate();
      return date.isAfter(firstDayOfMonth) && date.isBefore(lastDayOfMonth);
    });

    // Stok maliyetlerini hesapla
    return monthlyAppointments.fold(0.0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      final usedStockItems = data['usedStockItems'] as List<dynamic>?;

      if (usedStockItems == null || usedStockItems.isEmpty) return sum;

      return sum +
          usedStockItems.fold(0.0, (itemSum, item) {
            final quantity = (item['quantity'] as num).toDouble();
            final cost = (item['cost'] as num).toDouble();
            return itemSum + (quantity * cost);
          });
    });
  }

  Widget _buildMonthlyIncomeChart(BuildContext context, WidgetRef ref,
      List<QueryDocumentSnapshot> procedures) {
    final now = DateTime.now();
    final appointmentsAsync =
        ref.watch(clinicAppointmentsStreamProvider(clinicId));

    return appointmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Hata')),
      data: (appointments) {
        final l10n = AppLocalizations.of(context)!;
        // Sadece ödeme yapılmış randevuları filtrele
        final paidAppointments = appointments.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['paymentAmount'] != null;
        });

        // Son 6 ayın gelirlerini hesapla
        final monthlyIncome = List.generate(6, (index) {
          final date = DateTime(now.year, now.month - index, 1);
          final firstDayOfMonth = DateTime(date.year, date.month, 1);
          final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

          return paidAppointments.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final paymentDate = (data['paymentDate'] as Timestamp).toDate();
            return paymentDate.isAfter(firstDayOfMonth) &&
                paymentDate.isBefore(lastDayOfMonth);
          }).fold(0.0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            final paymentAmount = data['paymentAmount'] != null
                ? (data['paymentAmount'] as num).toDouble()
                : 0.0;
            return sum + paymentAmount;
          });
        }).reversed.toList(); // En eski ay başta olacak şekilde sırala

        final maxIncome = monthlyIncome.reduce((a, b) => a > b ? a : b);
        final currentMonth = monthlyIncome.last;
        final percentage =
            maxIncome > 0 ? (currentMonth / maxIncome * 100) : 0.0;

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
                    '₺${currentMonth.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.thisMonth,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStockChart(BuildContext context, WidgetRef ref) {
    final stockAsync = ref.watch(clinicStockStreamProvider(clinicId));
    return stockAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Hata')),
      data: (stock) {
        final l10n = AppLocalizations.of(context)!;
        final totalValue = stock.docs.fold(0.0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          final quantity = data['quantity'] != null
              ? (data['quantity'] as num).toDouble()
              : 0.0;
          final price =
              data['price'] != null ? (data['price'] as num).toDouble() : 0.0;
          return sum + (quantity * price);
        });

        final lowStockItems = stock.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final quantity = data['quantity'] != null
              ? (data['quantity'] as num).toDouble()
              : 0.0;
          final minQuantity = data['minimumQuantity'] != null
              ? (data['minimumQuantity'] as num).toDouble()
              : 0.0;
          return quantity <= minQuantity;
        }).length;

        final percentage = stock.docs.isNotEmpty
            ? (lowStockItems / stock.docs.length * 100)
            : 0.0;

        return Stack(
          children: [
            Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  color: Colors.red,
                  strokeWidth: 8,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lowStockItems.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.criticalStock,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfitMarginChart(BuildContext context, WidgetRef ref,
      List<QueryDocumentSnapshot> appointments) {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;
    final dailyProfitMargin = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));

      // O günkü ödeme yapılmış randevuları filtrele
      final dayAppointments = appointments.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final paymentDate = data['paymentDate'] as Timestamp?;
        if (paymentDate == null) return false;

        final appointmentDate = paymentDate.toDate();
        return appointmentDate.year == date.year &&
            appointmentDate.month == date.month &&
            appointmentDate.day == date.day;
      });

      // Günlük geliri hesapla
      final income = dayAppointments.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['paymentAmount'] as num? ?? 0).toDouble();
      });

      // Günlük stok maliyetlerini hesapla
      final stockCosts = dayAppointments.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        final usedStockItems = data['usedStockItems'] as List<dynamic>?;

        if (usedStockItems == null || usedStockItems.isEmpty) return sum;

        return sum +
            usedStockItems.fold(0.0, (itemSum, item) {
              final quantity = (item['quantity'] as num).toDouble();
              final cost = (item['cost'] as num).toDouble();
              return itemSum + (quantity * cost);
            });
      });

      // Günlük diğer giderleri hesapla
      final expenses = _calculateDailyExpenses(ref, date);

      // Toplam giderler
      final totalExpenses = stockCosts + expenses;

      // Kar marjı hesapla
      if (income == 0) return 0.0;
      final profit = income - totalExpenses;
      return (profit / income) * 100;
    });

    final maxMargin = dailyProfitMargin.reduce((a, b) => a > b ? a : b);
    final today = dailyProfitMargin.last;
    final percentage = maxMargin > 0 ? (today / maxMargin * 100) : 0.0;

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
                '${today.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.todayProfit,
                style: const TextStyle(
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
