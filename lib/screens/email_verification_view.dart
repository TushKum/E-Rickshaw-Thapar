import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/widget.dart';

/// Shared "verify your email" gate.
///
/// Firebase requires the address to be confirmed before the account is usable,
/// so both the driver and passenger flows land here after login or signup and
/// poll until [User.emailVerified] flips. The two variants differed only in
/// which screen they unlock, so that is the one parameter.
class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({
    super.key,
    required this.destination,
    required this.roleLabel,
  });

  /// Built once the address is confirmed.
  final WidgetBuilder destination;

  /// Shown in the body copy, e.g. "start requesting rides".
  final String roleLabel;

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  bool isEmailVerified = false;
  bool _resending = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.reload();
    if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
      timer?.cancel();
      if (mounted) setState(() => isEmailVerified = true);
    }
  }

  Future<void> sendVerificationEmail() async {
    setState(() => _resending = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Too many requests. Please wait.')),
        );
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) return widget.destination(context);

    final email = FirebaseAuth.instance.currentUser?.email ?? 'your inbox';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 160,
                width: 160,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    size: 72, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Verify your email',
                  style: AppText.display, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text(
                'We sent a link to $email. Open it to ${widget.roleLabel}.',
                style: AppText.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Check your spam folder if it has not arrived.',
                style: AppText.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text('Waiting for confirmation…',
                      style: AppText.bodyMuted),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SecondaryButton(
                label: _resending ? 'Sending…' : 'Send email again',
                onPressed: _resending ? null : sendVerificationEmail,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut().then((_) {
                  if (mounted) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                }),
                child: const Text('Use a different account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
