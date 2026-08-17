import 'package:erickshaw/screens/login.dart';
import 'package:erickshaw/screens/login_driver.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'role_card.dart';

class UserChoice extends StatelessWidget {
  const UserChoice({super.key});

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
              const Text('Log in as', style: AppText.display),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Pick the account you signed up with.',
                style: AppText.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.xl),
              RoleCard(
                icon: Icons.electric_rickshaw,
                title: 'Driver',
                subtitle: 'See and accept ride requests on campus',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Login_Driver())),
              ),
              const SizedBox(height: AppSpacing.md),
              RoleCard(
                icon: Icons.person_outline,
                title: 'Passenger',
                subtitle: 'Request a rickshaw between campus stops',
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const Login())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
