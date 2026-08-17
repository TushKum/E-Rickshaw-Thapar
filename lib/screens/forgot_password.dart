// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/widget.dart';
import 'auth_errors.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _email.text.trim());
      if (mounted) setState(() => _sent = true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      showAuthError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: ListView(
        padding:
            const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xl),
        children: [
          if (_sent) ...[
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Container(
                height: 140,
                width: 140,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    size: 64, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Check your email',
                style: AppText.display, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              'We sent a reset link to ${_email.text.trim()}.',
              style: AppText.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Back to login',
              onPressed: () => Navigator.pop(context),
            ),
          ] else ...[
            const Text('Reset password', style: AppText.display),
            const SizedBox(height: AppSpacing.sm),
            const Text(
                'Enter the email you signed up with and we will send a reset link.',
                style: AppText.bodyMuted),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Email',
              hint: 'you@thapar.edu',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
                label: 'Send reset link', loading: _busy, onPressed: _submit),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to login'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
