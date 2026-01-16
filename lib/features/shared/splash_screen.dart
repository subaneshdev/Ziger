import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../auth/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      final role = auth.role;
      if (role == 'admin') {
        context.go('/admin/dashboard');
      } else if (role == 'worker') {
        if (auth.isKycApproved) {
          context.go('/worker/home');
        } else {
          context.go('/kyc');
        }
      } else if (role == 'employer') {
        context.go('/employer/home');
      } else {
        context.go('/role-selection');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  // Bold lowercase brand
                  Text(
                    'ziggers.',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.textOnCoral,
                          fontWeight: FontWeight.w900,
                          fontSize: 56,
                          letterSpacing: -1,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Instant Work.\nInstant Pay.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textOnCoralMuted,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                  ),
                  const Spacer(),
                  // Loading indicator
                  Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnCoral.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

