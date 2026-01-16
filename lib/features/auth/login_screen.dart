import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleGetCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final phone = _phoneController.text;
      final success = await context.read<AuthProvider>().sendOtp(phone);
      
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        context.push('/otp', extra: phone);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send OTP'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
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
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  // Brand
                  Text(
                    'ziggers.',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.textOnCoral,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                  ),
                  const SizedBox(height: 48),
                  // Heading
                  Text(
                    'To start working,\nplease verify your phone',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textOnCoral,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 48),
                  // Phone input row
                  Row(
                    children: [
                      // Country code pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                        ),
                        child: Text(
                          '+91',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textOnCoral,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Phone number input
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                          ),
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textMain,
                                  fontWeight: FontWeight.w500,
                                ),
                            decoration: InputDecoration(
                              hintText: '123 4567',
                              hintStyle: TextStyle(
                                color: AppColors.textMain.withOpacity(0.5),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 10) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // GET CODE Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleGetCode,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            )
                          : const Text('GET CODE'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Privacy policy
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textOnCoral.withOpacity(0.8),
                            ),
                        children: [
                          const TextSpan(
                            text: 'By continuing, you confirm that you have read and understood the ',
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: AppColors.textOnCoral,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

