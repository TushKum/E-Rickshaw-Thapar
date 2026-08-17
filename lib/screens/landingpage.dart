import 'package:erickshaw/screens/user_choice.dart';
import 'package:erickshaw/screens/user_choice_signup.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/widget.dart';

class Landing extends StatelessWidget {
  const Landing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                height: 128,
                width: 128,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(34),
                ),
                child: const Icon(
                  Icons.electric_rickshaw,
                  size: 70,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('E-Rickshaw',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  )),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Rides across Thapar campus, on demand.',
                style: AppText.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              PrimaryButton(
                label: 'Log In',
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UserChoice())),
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: 'Sign Up',
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UserChoiceSignUp())),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
