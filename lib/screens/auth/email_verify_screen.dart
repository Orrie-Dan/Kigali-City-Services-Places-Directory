import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/loading_overlay.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({super.key});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final auth = context.read<AuthProvider>();
      await auth.reloadUser();
      if (auth.isEmailVerified) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    final auth = context.read<AuthProvider>();
    await auth.sendEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.emailVerifyTitle),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (auth.errorMessage != null)
                    ErrorBanner(
                      message: auth.errorMessage!,
                      onClose: auth.clearError,
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.emailNotVerified,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    auth.firebaseUser?.email ?? '',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _resendEmail,
                    child: const Text(AppStrings.resendEmailButton),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (auth.isLoading) const LoadingOverlay(),
      ],
    );
  }
}

