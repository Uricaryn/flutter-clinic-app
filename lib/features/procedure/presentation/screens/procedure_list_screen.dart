import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/features/procedure/domain/models/procedure_model.dart';
import 'package:clinic_app/features/procedure/presentation/widgets/add_procedure_dialog.dart';
import 'package:clinic_app/features/procedure/presentation/widgets/edit_procedure_dialog.dart';
import 'package:clinic_app/features/procedure/presentation/widgets/delete_procedure_dialog.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProcedureListScreen extends ConsumerWidget {
  const ProcedureListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.procedureManagement),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('procedures')
            .where('clinicId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final procedures = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ProcedureModel.fromJson({
              ...data,
              'id': doc.id,
            });
          }).toList();

          if (procedures.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.noProceduresFound,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.addProcedureToStart,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: procedures.length,
            itemBuilder: (context, index) {
              final procedure = procedures[index];
              return Card(
                child: ListTile(
                  title: Text(procedure.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(procedure.description),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.price}: ₺${procedure.price.toStringAsFixed(2)}',
                      ),
                      Text(
                        '${l10n.duration}: ${procedure.durationMinutes} ${l10n.minutes}',
                      ),
                      if (procedure.materials.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.materials}: ${procedure.materials.map((m) => '${m.stockItemName} (${m.quantity} ${m.unit})').join(', ')}',
                        ),
                      ],
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
                            builder: (context) => EditProcedureDialog(
                              procedure: procedure,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => DeleteProcedureDialog(
                              procedure: procedure,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddProcedureDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
