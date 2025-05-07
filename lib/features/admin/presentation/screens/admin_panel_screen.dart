import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:clinic_app/features/clinic/presentation/screens/clinic_management_screen.dart';
import 'package:clinic_app/features/admin/domain/models/admin_stats_model.dart';
import 'package:clinic_app/features/clinic/domain/models/clinic_model.dart';
import 'package:clinic_app/features/profile/domain/models/user_model.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final clinics = ref.watch(clinicListProvider);
    final users = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 16),
              stats.when(
                data: (data) => _buildStatsGrid(context, data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 16),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AdminStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - 32) / 2; // 32 = padding + spacing
        final cardHeight = cardWidth * 0.8; // Kart yüksekliği genişliğin %80'i

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildStatCard(
                context,
                'Total Clinics',
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
                'Active Clinics',
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
                'Total Users',
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
                'Total Appointments',
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.local_hospital, color: Colors.white),
            ),
            title: const Text('Manage Clinics'),
            subtitle: const Text('Add, edit, or remove clinics'),
            trailing: const Icon(Icons.arrow_forward_ios),
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
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.people, color: Colors.white),
            ),
            title: const Text('Manage Users'),
            subtitle: const Text('View and manage user accounts'),
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
            title: const Text('System Settings'),
            subtitle: const Text('Configure system preferences'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Clinic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Clinic Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Address',
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
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
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
              // TODO: Implement clinic creation
              Navigator.pop(context);
            },
            child: const Text('Add Clinic'),
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
