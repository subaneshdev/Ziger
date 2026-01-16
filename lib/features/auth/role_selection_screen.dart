import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import 'auth_provider.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surfaceDim,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Header with coral accent
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ziggers.',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                      ),
                      IconButton(
                        onPressed: () {
                          Provider.of<AuthProvider>(context, listen: false).logout();
                          context.go('/login');
                        },
                        icon: const Icon(Icons.logout_rounded, color: AppColors.textSub),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
                Text(
                  'Choose Your Role',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select how you want to use Ziggers',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSub,
                      ),
                ),
                const SizedBox(height: 40),
                // Role cards
                _buildRoleCard(
                  context,
                  title: 'Gig Worker',
                  subtitle: 'Find instant tasks nearby and earn money',
                  icon: Icons.work_outline_rounded,
                  role: AppConstants.roleWorker,
                  accentColor: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                _buildRoleCard(
                  context,
                  title: 'Employer',
                  subtitle: 'Hire workers for quick tasks',
                  icon: Icons.business_center_outlined,
                  role: AppConstants.roleEmployer,
                  accentColor: AppColors.secondary,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String role,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: accentColor.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<AuthProvider>().setRole(role);
            // Navigation handled by router redirect in main.dart based on role & kyc status,
            // but we can help it by pushing explicitly if needed.
            // However, since setRole notifies listeners, the RefreshListenable in router should trigger redirect.
            // Just in case, we can go to the expected path.
            if (role == AppConstants.roleWorker) {
              context.go('/worker-kyc');
            } else if (role == AppConstants.roleEmployer) {
              context.go('/employer-kyc');
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon container with gradient
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withOpacity(0.15),
                        accentColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSub,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

