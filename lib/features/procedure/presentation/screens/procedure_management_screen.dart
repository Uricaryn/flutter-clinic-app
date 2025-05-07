import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/procedure/domain/models/procedure_model.dart';
import 'package:clinic_app/features/procedure/presentation/widgets/procedure_card.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';

class ProcedureManagementScreen extends StatefulWidget {
  const ProcedureManagementScreen({super.key});

  @override
  State<ProcedureManagementScreen> createState() =>
      _ProcedureManagementScreenState();
}

class _ProcedureManagementScreenState extends State<ProcedureManagementScreen> {
  List<ProcedureModel> _procedures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProcedures();
  }

  Future<void> _loadProcedures() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _procedures = ProcedureModel.getMockProcedures();
      _isLoading = false;
    });
  }

  void _showAddEditProcedureDialog([ProcedureModel? procedure]) {
    final isEditing = procedure != null;
    final nameController = TextEditingController(text: procedure?.name);
    final descriptionController =
        TextEditingController(text: procedure?.description);
    final priceController =
        TextEditingController(text: procedure?.price.toString() ?? '');
    final durationController = TextEditingController(
        text: procedure?.durationMinutes.toString() ?? '');
    bool isActive = procedure?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Procedure' : 'Add New Procedure'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Procedure Name',
                  hintText: 'Enter procedure name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter procedure description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'Enter procedure price',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  hintText: 'Enter procedure duration in minutes',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active Status'),
                value: isActive,
                onChanged: (value) => setState(() => isActive = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: isEditing ? 'Save Changes' : 'Add Procedure',
            onPressed: () {
              // TODO: Implement save functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(ProcedureModel procedure) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Procedure'),
        content: Text('Are you sure you want to delete ${procedure.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Delete',
            variant: ButtonVariant.secondary,
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Procedure Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditProcedureDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _procedures.isEmpty
              ? Center(
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
                        'No Procedures Found',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a new procedure to get started',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Add Procedure',
                        onPressed: () => _showAddEditProcedureDialog(),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _procedures.length,
                  itemBuilder: (context, index) {
                    final procedure = _procedures[index];
                    return ProcedureCard(
                      procedure: procedure,
                      onTap: () {
                        // TODO: Navigate to procedure details
                      },
                      onEdit: () => _showAddEditProcedureDialog(procedure),
                      onDelete: () => _showDeleteConfirmationDialog(procedure),
                    );
                  },
                ),
    );
  }
}
