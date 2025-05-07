import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/appointment/presentation/screens/appointments_screen.dart';
import 'package:clinic_app/features/stock/presentation/screens/stock_management_screen.dart';
import 'package:clinic_app/features/procedure/presentation/screens/procedure_management_screen.dart';
import 'package:clinic_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:clinic_app/shared/widgets/custom_bottom_nav.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/features/admin/presentation/screens/admin_panel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildHomePage(),
          const AppointmentsScreen(),
          _buildProceduresPage(),
          const StockManagementScreen(),
          _buildProfilePage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 32),
          _buildRecentActivity(),
          if (_isAdmin) ...[
            const SizedBox(height: 32),
            _buildAdminSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'Appointments',
              Icons.event,
              Colors.blue,
              () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            _buildActionCard(
              'Procedures',
              Icons.medical_services,
              Colors.green,
              () {
                _pageController.animateToPage(
                  2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            _buildActionCard(
              'Stock',
              Icons.inventory,
              Colors.orange,
              () {
                _pageController.animateToPage(
                  3,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            _buildActionCard(
              'Profile',
              Icons.person,
              Colors.purple,
              () {
                _pageController.animateToPage(
                  4,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.calendar_today,
                  title: 'Upcoming Appointments',
                  subtitle: 'You have 3 appointments today',
                  onTap: () => _onNavItemTapped(1),
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.inventory,
                  title: 'Low Stock Alert',
                  subtitle: '5 items need to be restocked',
                  onTap: () => _onNavItemTapped(3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildProceduresPage() {
    return const ProcedureManagementScreen();
  }

  Widget _buildProfilePage() {
    return const ProfileScreen();
  }

  Widget _buildAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Controls',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.admin_panel_settings, color: Colors.white),
            ),
            title: const Text('Super Admin Panel'),
            subtitle: const Text('Manage clinics, users, and view statistics'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPanelScreen(),
                ),
              );
            },
          ),
        ).animate().fadeIn().slideX(),
      ],
    );
  }

  bool get _isAdmin {
    // TODO: Replace with actual user role check
    return true;
  }
}
