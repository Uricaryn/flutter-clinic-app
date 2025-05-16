import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/procedure/domain/models/procedure_model.dart';
import 'package:clinic_app/features/procedure/presentation/widgets/procedure_card.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProcedureManagementScreen extends ConsumerWidget {
  const ProcedureManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final asyncProcedures = ref.watch(proceduresStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.procedureManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: İşlem ekleme dialogu
            },
          ),
        ],
      ),
      body: asyncProcedures.when(
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
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noProceduresFound,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.addProcedureToStart,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: l10n.addProcedure,
                    onPressed: () {
                      // TODO: İşlem ekleme dialogu
                    },
                      ),
                    ],
                  ),
            );
          }
          return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                  // TODO: İşlem düzenleme dialogu
                },
                onDelete: () {
                  // TODO: İşlem silme dialogu
                },
              );
            },
                    );
                  },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
                ),
    );
  }
}
