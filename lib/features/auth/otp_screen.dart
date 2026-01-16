import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _resendCountdown = 30;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOtp() {
    if (_resendCountdown == 0) {
      context.read<AuthProvider>().sendOtp(widget.phoneNumber);
      setState(() => _resendCountdown = 30);
      _startCountdown();
    }
  }

  void _onOtpChanged(String value) {
    if (value.length == 6) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text;
    if (otp.length != 6) return;

    setState(() => _isVerifying = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(widget.phoneNumber, otp);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (success) {
      if (authProvider.role == null || authProvider.role == 'user') {
        context.go('/role-selection');
      } else if (authProvider.isKycApproved) {
        if (authProvider.role == 'worker') {
          context.go('/worker/home');
        } else {
          context.go('/employer/home');
        }
      } else {
        if (authProvider.role == 'worker') {
          context.go('/worker-kyc');
        } else {
          context.go('/employer-kyc');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification Failed. Try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _otpController.clear();
      _focusNode.requestFocus();
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.textOnCoral),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 16),
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
                  'Enter the code we sent to',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textOnCoral,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+91 ${widget.phoneNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textOnCoral,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                // Resend countdown
                GestureDetector(
                  onTap: _resendOtp,
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        color: _resendCountdown == 0
                            ? AppColors.textOnCoral
                            : AppColors.textOnCoral.withOpacity(0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _resendCountdown > 0
                            ? 'RESEND CODE (${_resendCountdown} SEC)'
                            : 'RESEND CODE',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: _resendCountdown == 0
                                  ? AppColors.textOnCoral
                                  : AppColors.textOnCoral.withOpacity(0.5),
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // OTP Input - Single pill
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  child: TextField(
                    controller: _otpController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textOnCoral,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 12,
                        ),
                    decoration: InputDecoration(
                      hintText: 'XXXXXX',
                      hintStyle: TextStyle(
                        color: AppColors.textOnCoral.withOpacity(0.4),
                        letterSpacing: 12,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                    ),
                    onChanged: _onOtpChanged,
                  ),
                ),
                const SizedBox(height: 32),
                // Verify button with loading state
                if (_isVerifying)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textOnCoral.withOpacity(0.8),
                      ),
                    ),
                  ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

