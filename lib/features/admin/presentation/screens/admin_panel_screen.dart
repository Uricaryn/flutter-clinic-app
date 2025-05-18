import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:clinic_app/features/clinic/presentation/screens/clinic_management_screen.dart';
import 'package:clinic_app/features/admin/domain/models/admin_stats_model.dart';
import 'package:clinic_app/features/clinic/domain/models/clinic_model.dart';
import 'package:clinic_app/features/profile/domain/models/user_model.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:clinic_app/core/services/logger_service.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  Future<void> _createTestData(BuildContext context) async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('createTestData');

      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fonksiyonu çağır
      final result = await callable();

      // Loading'i kapat
      Navigator.pop(context);

      // Başarı mesajını göster
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test data başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      LoggerService().info('Test data created successfully: ${result.data}');
    } catch (e) {
      // Loading'i kapat
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Hata mesajını göster
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      LoggerService().error('Failed to create test data', e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final clinics = ref.watch(clinicListProvider);
    final users = ref.watch(userListProvider);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    // Responsive sizes
    final padding = size.width * 0.04; // 4% of screen width
    final spacing = size.height * 0.02; // 2% of screen height
    final titleSize = size.height * 0.03; // 3% of screen height

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminPanel),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.statistics,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: titleSize,
                    ),
              ).animate().fadeIn().slideX(),
              SizedBox(height: spacing),
              stats.when(
                data: (data) => _buildStatsGrid(context, data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text(l10n.errorWithMessage(error.toString())),
                ),
              ),
              SizedBox(height: spacing * 1.5),
              Text(
                l10n.quickActions,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: titleSize,
                    ),
              ).animate().fadeIn().slideX(),
              SizedBox(height: spacing),
              _buildQuickActions(context),
              SizedBox(height: spacing),
              CustomButton(
                text: 'Test Data Oluştur',
                onPressed: () => _createTestData(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AdminStats stats) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = size.width > 600;
        final crossAxisCount = isTablet ? 4 : 2;
        final cardWidth = (constraints.maxWidth - (16 * (crossAxisCount - 1))) /
            crossAxisCount;
        final cardHeight = cardWidth * 0.8;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildStatCard(
                context,
                l10n.totalClinics,
                stats.totalClinics.toString(),
                Icons.local_hospital_outlined,
                Colors.blue,
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildStatCard(
                context,
                l10n.activeClinics,
                stats.activeClinics.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildStatCard(
                context,
                l10n.totalUsers,
                stats.totalUsers.toString(),
                Icons.people_outline,
                Colors.purple,
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildStatCard(
                context,
                l10n.totalAppointments,
                stats.totalAppointments.toString(),
                Icons.calendar_today_outlined,
                Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final size = MediaQuery.of(context).size;
    final iconSize = size.width * 0.06; // 6% of screen width
    final valueSize = size.width * 0.04; // 4% of screen width
    final titleSize = size.width * 0.03; // 3% of screen width

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.02), // 2% of screen width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            SizedBox(height: size.height * 0.01), // 1% of screen height
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: valueSize,
                  ),
            ),
            SizedBox(height: size.height * 0.005), // 0.5% of screen height
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                    fontSize: titleSize,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final spacing = size.height * 0.01; // 1% of screen height

    return Column(
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              radius: size.width * 0.03, // 3% of screen width
              child: Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: size.width * 0.04, // 4% of screen width
              ),
            ),
            title: Text(
              l10n.manageClinics,
              style: TextStyle(
                  fontSize: size.width * 0.035), // 3.5% of screen width
            ),
            subtitle: Text(
              l10n.addEditRemoveClinics,
              style:
                  TextStyle(fontSize: size.width * 0.03), // 3% of screen width
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: size.width * 0.04, // 4% of screen width
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClinicManagementScreen(),
                ),
              );
            },
          ),
        ).animate().fadeIn().slideX(),
        SizedBox(height: spacing),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.people, color: Colors.white),
            ),
            title: Text(l10n.manageUsers),
            subtitle: Text(l10n.viewManageUsers),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to user management
            },
          ),
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.settings, color: Colors.white),
            ),
            title: Text(l10n.systemSettings),
            subtitle: Text(l10n.configureSystemPreferences),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to settings
            },
          ),
        ).animate().fadeIn().slideX(),
      ],
    );
  }

  void _showAddClinicDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addNewClinic),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: l10n.clinicName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.address,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.phone,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement add clinic
              Navigator.pop(context);
            },
            child: Text(l10n.saveChanges),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement user creation
              Navigator.pop(context);
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }
}
