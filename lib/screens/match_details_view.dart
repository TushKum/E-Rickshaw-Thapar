import 'package:erickshaw/screens/landingpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/widget.dart';

/// Shared "you've been matched" screen.
///
/// The driver and passenger versions showed the same thing from opposite
/// sides — a name, a phone number, the route — so the layout lives here and
/// each side passes its own copy and fields.
class MatchDetailsView extends StatelessWidget {
  const MatchDetailsView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.name,
    required this.phone,
    required this.from,
    required this.to,
    this.plate,
    this.loading = false,
  });

  final String title;
  final String subtitle;
  final String name;
  final String phone;
  final String from;
  final String to;

  /// Only the passenger's view shows a number-plate.
  final String? plate;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout, size: 22),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const Landing()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screen,
                    AppSpacing.sm, AppSpacing.screen, AppSpacing.xl),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(subtitle,
                              style: AppText.body.copyWith(
                                  color: AppColors.primaryDark, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        const AccentIcon(Icons.person, size: 68),
                        const SizedBox(height: AppSpacing.md),
                        Text(name.isEmpty ? '—' : name,
                            style: AppText.display.copyWith(fontSize: 22)),
                        if (plate != null && plate!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.field),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(plate!,
                                style: AppText.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2)),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(phone.isEmpty ? '—' : phone,
                                style: AppText.body.copyWith(fontSize: 17)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      children: [
                        _RouteRow(
                            icon: Icons.my_location,
                            label: 'PICKUP',
                            value: from),
                        const Divider(height: AppSpacing.lg),
                        _RouteRow(
                            icon: Icons.place_outlined,
                            label: 'DROP',
                            value: to),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.sectionLabel),
              const SizedBox(height: 2),
              Text(value, style: AppText.body.copyWith(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
