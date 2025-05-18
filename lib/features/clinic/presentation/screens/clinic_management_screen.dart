import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/clinic/domain/models/clinic_model.dart';
import 'package:clinic_app/features/clinic/presentation/widgets/clinic_card.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:clinic_app/core/services/logger_service.dart';
import 'package:clinic_app/features/operator/presentation/widgets/operator_list.dart';

class ClinicManagementScreen extends ConsumerStatefulWidget {
  const ClinicManagementScreen({super.key});

  @override
  ConsumerState<ClinicManagementScreen> createState() =>
      _ClinicManagementScreenState();
}

class _ClinicManagementScreenState
    extends ConsumerState<ClinicManagementScreen> {
  final _logger = LoggerService();

  Future<void> _addClinic({
    required String name,
    required String specialization,
    required String address,
    required String phone,
    required String email,
    required bool isActive,
  }) async {
    try {
      final clinic = ClinicModel(
        id: '', // Firestore will generate this
        name: name,
        specialization: specialization,
        address: address,
        phone: phone,
        email: email,
        isActive: isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(clinicServiceProvider).addClinic(clinic);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clinic added successfully')),
        );
      }
    } catch (e) {
      _logger.error('Failed to add clinic', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updateClinic({
    required String id,
    required String name,
    required String specialization,
    required String address,
    required String phone,
    required String email,
    required bool isActive,
  }) async {
    try {
      final clinic = ClinicModel(
        id: id,
        name: name,
        specialization: specialization,
        address: address,
        phone: phone,
        email: email,
        isActive: isActive,
        updatedAt: DateTime.now(),
      );

      await ref.read(clinicServiceProvider).updateClinic(clinic);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clinic updated successfully')),
        );
      }
    } catch (e) {
      _logger.error('Failed to update clinic', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteClinic(String id) async {
    try {
      await ref.read(clinicServiceProvider).deleteClinic(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clinic deleted successfully')),
        );
      }
    } catch (e) {
      _logger.error('Failed to delete clinic', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final clinicsAsync = ref.watch(clinicListProvider);
    final size = MediaQuery.of(context).size;

    // Responsive sizes
    final padding = size.width * 0.04; // 4% of screen width
    final spacing = size.height * 0.02; // 2% of screen height
    final titleSize = size.height * 0.03; // 3% of screen height
    final dialogWidth = size.width * 0.9; // 90% of screen width
    final dialogMaxWidth = 500.0; // Maximum width for dialog

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clinicManagement),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.clinicManagement,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: titleSize,
                    ),
                  ).animate().fadeIn().slideX(),
                  CustomButton(
                    text: l10n.addNewClinic,
                    onPressed: () => _showAddEditClinicDialog(),
                  ).animate().fadeIn().slideX(),
                ],
              ),
              SizedBox(height: spacing),
              clinicsAsync.when(
                data: (clinics) => clinics.isEmpty
                    ? _buildEmptyState(context)
                    : _buildClinicList(clinics),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text(l10n.errorWithMessage(error.toString())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final spacing = size.height * 0.02; // 2% of screen height

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: size.width * 0.15, // 15% of screen width
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: spacing),
          Text(
            l10n.noClinicsFound,
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: spacing * 0.5),
          Text(
            l10n.addClinicToStart,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: spacing),
          CustomButton(
            text: l10n.addClinic,
            onPressed: () => _showAddEditClinicDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicList(List<ClinicModel> clinics) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final crossAxisCount = isTablet ? 2 : 1;
    final spacing = size.width * 0.02; // 2% of screen width

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isTablet ? 1.5 : 1.2,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: clinics.length,
      itemBuilder: (context, index) {
        final clinic = clinics[index];
        return ClinicCard(
          clinic: clinic,
          onTap: () {
            // TODO: Navigate to clinic details
          },
          onEdit: () => _showAddEditClinicDialog(clinic),
          onDelete: () => _showDeleteConfirmationDialog(clinic),
        ).animate().fadeIn().scale();
      },
    );
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
    final size = MediaQuery.of(context).size;
    final spacing = size.height * 0.015; // 1.5% of screen height
    final dialogWidth = size.width * 0.9; // 90% of screen width
    final dialogMaxWidth = 500.0; // Maximum width for dialog

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Clinic' : 'Add New Clinic'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogMaxWidth,
            maxHeight: size.height * 0.8, // 80% of screen height
          ),
          child: SingleChildScrollView(
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
                SizedBox(height: spacing),
                TextField(
                  controller: specializationController,
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
                    hintText: 'Enter clinic specialization',
                  ),
                ),
                SizedBox(height: spacing),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter clinic address',
                  ),
                ),
                SizedBox(height: spacing),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter clinic phone number',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: spacing),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter clinic email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: spacing),
                SwitchListTile(
                  title: const Text('Active Status'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                ),
              ],
            ),
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
              if (isEditing) {
                _updateClinic(
                  id: clinic!.id,
                  name: nameController.text,
                  specialization: specializationController.text,
                  address: addressController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  isActive: isActive,
                );
              } else {
                _addClinic(
                  name: nameController.text,
                  specialization: specializationController.text,
                  address: addressController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  isActive: isActive,
                );
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(ClinicModel clinic) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = size.width * 0.9; // 90% of screen width
    final dialogMaxWidth = 400.0; // Maximum width for dialog

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Clinic'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogMaxWidth,
          ),
          child: Text('Are you sure you want to delete ${clinic.name}?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Delete',
            variant: ButtonVariant.secondary,
            onPressed: () {
              _deleteClinic(clinic.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
