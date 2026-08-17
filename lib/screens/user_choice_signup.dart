import 'package:erickshaw/screens/customer.dart';
import 'package:erickshaw/screens/driversign.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'role_card.dart';

class UserChoiceSignUp extends StatelessWidget {
  const UserChoiceSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create an account', style: AppText.display),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Drivers and passengers sign up separately.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.xl),
              RoleCard(
                icon: Icons.electric_rickshaw,
                title: 'Driver',
                subtitle: 'Register your rickshaw and number-plate',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DriverSign())),
              ),
              const SizedBox(height: AppSpacing.md),
              RoleCard(
                icon: Icons.person_outline,
                title: 'Passenger',
                subtitle: 'Sign up with your campus email',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const customer_login())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
