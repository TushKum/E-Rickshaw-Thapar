// ignore_for_file: camel_case_types, use_build_context_synchronously

import 'package:erickshaw/screens/emailVerification_passenger.dart';
import 'package:erickshaw/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../campus_email.dart';
import '../database.dart';
import '../theme/app_theme.dart';
import '../widgets/widget.dart';
import 'auth_errors.dart';

class customer_login extends StatefulWidget {
  const customer_login({Key? key}) : super(key: key);

  @override
  State<customer_login> createState() => _customer_loginState();
}

class _customer_loginState extends State<customer_login> {
  late Databases db;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _confirmpassword = TextEditingController();
  final _number = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    db = Databases();
    db.initialise();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _confirmpassword.dispose();
    _number.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_name.text.trim().isEmpty) return "Name can't be empty";
    if (_number.text.isEmpty) return "Number can't be empty";
    if (_number.text.length != 10) return 'Enter a 10-digit mobile number';
    if (_email.text.trim().isEmpty) return "Email can't be empty";
    if (!isThaparEmail(_email.text)) {
      return 'Use your $kCampusEmailDomain address to sign up';
    }
    if (_password.text.isEmpty) return "Password can't be empty";
    if (_password.text.length < 6) return 'Password must be at least 6 characters';
    if (_confirmpassword.text.isEmpty) return 'Confirm your password';
    if (_confirmpassword.text != _password.text) return "Passwords don't match";
    return null;
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ));
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) {
      _toast(problem);
      return;
    }

    setState(() => _busy = true);
    try {
      // createUserWithEmailAndPassword already signs the new user in, so take
      // the uid from the credential it returns rather than re-signing in and
      // racing to read auth.currentUser.
      final credential = await auth.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      final uid = credential.user?.uid ?? '';
      db.create_passenger(
          _name.text.trim(), uid, _number.text, _email.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(
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
        padding:
            const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xl),
        children: [
          const Text('Passenger sign up', style: AppText.display),
          const SizedBox(height: AppSpacing.sm),
          const Text(
              'Sign up with your $kCampusEmailDomain address. You will need to '
              'confirm it before you can request a ride.',
              style: AppText.bodyMuted),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Full name',
            hint: 'Your name',
            controller: _name,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Mobile number',
            hint: '10-digit number',
            controller: _number,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Campus email',
            hint: 'you$kCampusEmailDomain',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            hint: 'At least 6 characters',
            controller: _password,
            obscure: true,
            prefixIcon: Icons.lock_outline,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Confirm password',
            hint: 'Re-enter your password',
            controller: _confirmpassword,
            obscure: true,
            prefixIcon: Icons.lock_outline,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: 'Create account', loading: _busy, onPressed: _submit),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?', style: AppText.bodyMuted),
              TextButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const Login())),
                child: const Text('Log in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
