import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/clinic/domain/models/clinic_model.dart';
import 'package:clinic_app/features/clinic/presentation/widgets/clinic_card.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';

class ClinicManagementScreen extends StatefulWidget {
  const ClinicManagementScreen({super.key});

  @override
  State<ClinicManagementScreen> createState() => _ClinicManagementScreenState();
}

class _ClinicManagementScreenState extends State<ClinicManagementScreen> {
  List<ClinicModel> _clinics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _clinics = ClinicModel.getMockClinics();
      _isLoading = false;
    });
  }

  void _showAddEditClinicDialog([ClinicModel? clinic]) {
    final isEditing = clinic != null;
    final nameController = TextEditingController(text: clinic?.name);
    final addressController = TextEditingController(text: clinic?.address);
    final phoneController = TextEditingController(text: clinic?.phone);
    final emailController = TextEditingController(text: clinic?.email);
    final specializationController =
        TextEditingController(text: clinic?.specialization);
    bool isActive = clinic?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Clinic' : 'Add New Clinic'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Clinic Name',
                  hintText: 'Enter clinic name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  hintText: 'Enter clinic specialization',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter clinic address',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter clinic phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter clinic email',
                ),
                keyboardType: TextInputType.emailAddress,
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
            text: isEditing ? 'Save Changes' : 'Add Clinic',
            onPressed: () {
              // TODO: Implement save functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(ClinicModel clinic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Clinic'),
        content: Text('Are you sure you want to delete ${clinic.name}?'),
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
        title: const Text('Clinic Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditClinicDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clinics.isEmpty
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
                        'No Clinics Found',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a new clinic to get started',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Add Clinic',
                        onPressed: () => _showAddEditClinicDialog(),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _clinics.length,
                  itemBuilder: (context, index) {
                    final clinic = _clinics[index];
                    return ClinicCard(
                      clinic: clinic,
                      onTap: () {
                        // TODO: Navigate to clinic details
                      },
                      onEdit: () => _showAddEditClinicDialog(clinic),
                      onDelete: () => _showDeleteConfirmationDialog(clinic),
                    );
                  },
                ),
    );
  }
}
