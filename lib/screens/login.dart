// ignore_for_file: use_build_context_synchronously

import 'package:erickshaw/screens/customer.dart';
import 'package:erickshaw/screens/emailVerification_passenger.dart';
import 'package:erickshaw/screens/forgot_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/widget.dart';
import 'auth_errors.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EmailVerification_Passenger()),
      );
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
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xl),
        children: [
          const Text('Welcome back', style: AppText.display),
          const SizedBox(height: AppSpacing.sm),
          const Text('Log in to request a ride across campus.',
              style: AppText.bodyMuted),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Email',
            hint: 'you@thapar.edu',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _password,
            obscure: true,
            prefixIcon: Icons.lock_outline,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ForgotPassword())),
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: 'Log In', loading: _busy, onPressed: _submit),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?", style: AppText.bodyMuted),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const customer_login())),
                child: const Text('Sign up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
