import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/procedure/domain/models/procedure_model.dart';
import 'package:clinic_app/features/procedure/presentation/widgets/procedure_card.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/shared/widgets/auth_background.dart';
import 'package:clinic_app/features/procedure/presentation/widgets/add_procedure_dialog.dart';
import 'package:clinic_app/features/procedure/presentation/widgets/edit_procedure_dialog.dart';
import 'package:clinic_app/features/procedure/presentation/widgets/delete_procedure_dialog.dart';

class ProcedureManagementScreen extends ConsumerWidget {
  const ProcedureManagementScreen({super.key});

  void _showAddProcedureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddProcedureDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final asyncProcedures = ref.watch(proceduresStreamProvider);

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
                      l10n.procedureManagement,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: asyncProcedures.when(
                  data: (snapshot) {
                    final docs = snapshot.docs;
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ).animate().fadeIn().scale(),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noProceduresFound,
                              style: theme.textTheme.titleLarge,
                            ).animate().fadeIn().slideY(),
                            const SizedBox(height: 8),
                            Text(
                              l10n.addProcedureToStart,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ).animate().fadeIn().slideY(),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: l10n.addProcedure,
                              onPressed: () => _showAddProcedureDialog(context),
                            ).animate().fadeIn().scale(),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final procedure = ProcedureModel.fromJson(data);
                        return ProcedureCard(
                          procedure: procedure,
                          onTap: () {
                            // TODO: Navigate to procedure details
                          },
                          onEdit: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  EditProcedureDialog(procedure: procedure),
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  DeleteProcedureDialog(procedure: procedure),
                            );
                          },
                        ).animate().fadeIn().slideX();
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Hata: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProcedureDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
